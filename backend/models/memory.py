from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class MemoryModel(BaseModel):
    id: Optional[str] = None
    user_id: str
    category: str  # "projects" | "preferences" | "about_you" | "past_tasks"
    content: str
    confidence: float = 1.0
    created_at: Optional[datetime] = None
    source_conversation_id: Optional[str] = None


class MemoryExtractRequest(BaseModel):
    user_id: str
    conversation_id: str
    messages: list  # last N turns
