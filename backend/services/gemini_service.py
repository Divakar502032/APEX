import google.generativeai as genai
from settings import get_settings

settings = get_settings()
genai.configure(api_key=settings.gemini_api_key)

# Agent-specific system prompts
SYSTEM_PROMPTS = {
    "reasoning": (
        "You are APEX Reasoning Agent — an elite analytical thinker. "
        "Break every problem into clear numbered steps. Show your work explicitly. "
        "Think deeply before answering. Be rigorous and thorough."
    ),
    "research": (
        "You are APEX Research Agent — a world-class researcher. "
        "Provide well-sourced, factual, comprehensive answers. "
        "Cite your reasoning. Flag uncertainty clearly."
    ),
    "code": (
        "You are APEX Code Agent — an expert software engineer. "
        "Write clean, production-grade code with comments. "
        "Always include error handling. Explain your implementation decisions."
    ),
    "domain": (
        "You are APEX Domain Expert — a specialist in medical, legal, and financial topics. "
        "Provide accurate professional-level guidance. "
        "Always append: 'This is informational only, not professional advice.'"
    ),
    "general": (
        "You are APEX AI — a next-generation intelligent assistant. "
        "Be helpful, clear, and concise. Adapt your style to the user's needs."
    ),
}


async def stream_gemini(
    message: str,
    history: list,
    agent_type: str = "general",
    memory_context: str = "",
):
    """Stream tokens from Gemini 2.5 Pro via SSE-compatible async generator."""
    system = SYSTEM_PROMPTS.get(agent_type, SYSTEM_PROMPTS["general"])

    if memory_context:
        system += f"\n\nRelevant context about this user:\n{memory_context}"

    model = genai.GenerativeModel(
        model_name="gemini-2.0-flash-exp",
        system_instruction=system,
    )

    # Build history for multi-turn
    chat_history = []
    for msg in history[-10:]:  # last 10 turns max
        chat_history.append({
            "role": msg["role"] if msg["role"] == "user" else "model",
            "parts": [msg["content"]],
        })

    chat = model.start_chat(history=chat_history)
    response = chat.send_message(message, stream=True)

    for chunk in response:
        if chunk.text:
            yield chunk.text


async def classify_agent(message: str) -> str:
    """Use Gemini Flash to route the message to the right agent."""
    model = genai.GenerativeModel(model_name="gemini-2.0-flash-exp")
    prompt = (
        "Classify the following user message into exactly one category:\n"
        "reasoning (complex multi-step thinking needed), "
        "research (requires factual lookup or web search), "
        "code (programming task), "
        "domain (medical/legal/financial), "
        "general (everything else).\n"
        "Reply with ONLY the category name, nothing else.\n\n"
        f"Message: {message}"
    )
    result = model.generate_content(prompt)
    category = result.text.strip().lower()
    valid = {"reasoning", "research", "code", "domain", "general"}
    return category if category in valid else "general"


async def extract_memories(messages: list) -> list:
    """Use Gemini Flash to extract structured memory facts from conversation."""
    model = genai.GenerativeModel(model_name="gemini-2.0-flash-exp")
    convo_text = "\n".join(
        f"{m['role'].upper()}: {m['content']}" for m in messages[-10:]
    )
    prompt = (
        "Analyze this conversation and extract factual memory items about the user. "
        "Return a JSON array only, no explanation.\n"
        "Format: [{\"category\": \"projects|preferences|about_you|past_tasks\", "
        "\"content\": \"...\", \"confidence\": 0.0-1.0}]\n\n"
        f"Conversation:\n{convo_text}"
    )
    import json
    result = model.generate_content(prompt)
    try:
        text = result.text.strip()
        # Strip markdown code fences if present
        if text.startswith("```"):
            text = text.split("```")[1]
            if text.startswith("json"):
                text = text[4:]
        return json.loads(text)
    except Exception:
        return []
