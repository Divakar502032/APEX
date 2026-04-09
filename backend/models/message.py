from pydantic import BaseModel
from typing import Optional, List
from enum import Enum


class AgentType(str, Enum):
    reasoning = "reasoning"
    research = "research"
    code = "code"
    domain = "domain"
    general = "general"


class ChatMessage(BaseModel):
    role: str  # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    user_id: str
    conversation_id: str
    message: str
    agent_type: AgentType = AgentType.general
    history: List[ChatMessage] = []
    memory_context: Optional[str] = None
