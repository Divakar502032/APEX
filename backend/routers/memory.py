from fastapi import APIRouter
from models.memory import MemoryExtractRequest
from services.gemini_service import extract_memories

router = APIRouter()


@router.post("/extract")
async def extract_memory(request: MemoryExtractRequest):
    """Extract memory facts from conversation using Gemini Flash."""
    memories = await extract_memories(request.messages)
    return {"memories": memories, "user_id": request.user_id}


@router.get("/{user_id}")
async def get_memories(user_id: str):
    """Get all memories for a user. (Pinecone integration in Phase 6)"""
    return {"memories": [], "user_id": user_id}


@router.delete("/{user_id}/{memory_id}")
async def delete_memory(user_id: str, memory_id: str):
    """Delete a specific memory. (Pinecone integration in Phase 6)"""
    return {"deleted": memory_id}
