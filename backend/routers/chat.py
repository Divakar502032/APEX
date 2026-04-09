import json
import asyncio
from fastapi import APIRouter, BackgroundTasks
from fastapi.responses import StreamingResponse
from models.message import ChatRequest, AgentType
from services.agent_router import route_agent
from services.gemini_service import stream_gemini, extract_memories
from services.openai_service import stream_openai_code
from services.memory_service import get_memory_context, upsert_memory

router = APIRouter()


@router.post("/stream")
async def chat_stream(request: ChatRequest, background_tasks: BackgroundTasks):
    """
    Main SSE endpoint. Streams back events:
      event: reasoning_step  — thinking steps
      event: token           — response tokens
      event: done            — final metadata
    """
    async def event_generator():
        try:
            # 1. Route to correct agent
            agent = await route_agent(request.message, request.agent_type.value)

            # 2. Emit agent selection
            yield _sse("agent", json.dumps({"agent": agent}))
            
            # 3. Fetch Memory Context (RAG)
            memory_context = await get_memory_context(request.user_id, request.message)
            # Combine with any context passed from frontend
            full_memory_context = (request.memory_context or "") + memory_context

            # 4. Emit reasoning steps for non-code agents
            if agent != "code":
                reasoning_steps = _reasoning_steps_for(agent)
                for step in reasoning_steps:
                    await asyncio.sleep(0.5)
                    yield _sse("reasoning_step", json.dumps(step))

            # 5. Stream tokens from the correct model
            history = [m.model_dump() for m in request.history]

            if agent == "code":
                token_stream = stream_openai_code(
                    message=request.message,
                    history=history,
                    memory_context=full_memory_context,
                )
            else:
                token_stream = stream_gemini(
                    message=request.message,
                    history=history,
                    agent_type=agent,
                    memory_context=full_memory_context,
                )

            token_count = 0
            full_response_content = ""
            async for token in token_stream:
                token_count += len(token.split())
                full_response_content += token
                yield _sse("token", json.dumps({"content": token}))

            # 6. Done event
            model_used = "gpt-4o" if agent == "code" else "gemini-2.0-flash-exp"
            yield _sse("done", json.dumps({
                "total_tokens": token_count,
                "model": model_used,
                "agent": agent,
            }))
            
            # 7. Background Task: Memory Extraction & Storage
            # We use the full history + new turn
            new_history = history + [
                {"role": "user", "content": request.message},
                {"role": "assistant", "content": full_response_content}
            ]
            background_tasks.add_task(_process_and_store_memories, request.user_id, new_history)

        except Exception as e:
            yield _sse("error", json.dumps({"message": str(e)}))

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


async def _process_and_store_memories(user_id: str, history: list):
    """Background helper to extract facts and upsert to vector store."""
    try:
        new_facts = await extract_memories(history)
        for fact in new_facts:
            await upsert_memory(
                user_id=user_id,
                content=fact['content'],
                category=fact.get('category', 'general'),
                metadata={"confidence": fact.get('confidence', 1.0)}
            )
    except Exception as e:
        print(f"⚠️ Memory Background Task Error: {e}")


def _sse(event: str, data: str) -> str:
    return f"event: {event}\ndata: {data}\n\n"


def _reasoning_steps_for(agent: str) -> list:
    steps_map = {
        "reasoning": [
            {"step": "Decomposing the problem into sub-tasks...", "type": "reasoning"},
            {"step": "Evaluating solution approaches...", "type": "reasoning"},
            {"step": "Formulating step-by-step answer...", "type": "writing"},
        ],
        "research": [
            {"step": "Searching for relevant information...", "type": "search"},
            {"step": "Cross-referencing sources...", "type": "reasoning"},
            {"step": "Synthesizing findings...", "type": "writing"},
        ],
        "domain": [
            {"step": "Consulting domain knowledge base...", "type": "search"},
            {"step": "Verifying accuracy of information...", "type": "verified"},
            {"step": "Composing expert-level response...", "type": "writing"},
        ],
        "general": [
            {"step": "Analyzing your request...", "type": "reasoning"},
            {"step": "Composing response...", "type": "writing"},
        ],
    }
    return steps_map.get(agent, steps_map["general"])
