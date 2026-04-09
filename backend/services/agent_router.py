from services.gemini_service import classify_agent


async def route_agent(message: str, requested_agent: str = "general") -> str:
    """
    If requested_agent is 'general' (Auto mode), classify automatically.
    Otherwise use the explicitly requested agent.
    """
    if requested_agent != "general":
        return requested_agent
    return await classify_agent(message)
