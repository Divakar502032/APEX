from openai import AsyncOpenAI
from settings import get_settings

settings = get_settings()
client = AsyncOpenAI(api_key=settings.openai_api_key)

CODE_SYSTEM_PROMPT = (
    "You are APEX Code Agent — an elite software engineer powered by GPT-4o. "
    "Write clean, well-commented, production-ready code. "
    "Include error handling, edge cases, and explain your approach. "
    "Format code blocks with the correct language tag."
)


async def stream_openai_code(
    message: str,
    history: list,
    memory_context: str = "",
):
    """Stream tokens from GPT-4o for the Code agent."""
    system = CODE_SYSTEM_PROMPT
    if memory_context:
        system += f"\n\nRelevant context about this user:\n{memory_context}"

    messages = [{"role": "system", "content": system}]

    for msg in history[-10:]:
        messages.append({
            "role": msg["role"],
            "content": msg["content"],
        })

    messages.append({"role": "user", "content": message})

    stream = await client.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        stream=True,
        temperature=0.2,
        max_tokens=4096,
    )

    async for chunk in stream:
        delta = chunk.choices[0].delta
        if delta.content:
            yield delta.content
