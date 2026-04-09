import google.generativeai as genai
from pinecone import Pinecone, ServerlessSpec
from settings import get_settings
from typing import List, Dict, Optional
import numpy as np

settings = get_settings()

# Configure Gemini for Embeddings
genai.configure(api_key=settings.gemini_api_key)

# Initialize Pinecone
# Note: For production, ensure PINECONE_API_KEY is in .env
pc = Pinecone(api_key=settings.pinecone_api_key or "placeholder_key")

INDEX_NAME = "apex-memory"

def get_index():
    """Get or create the Pinecone index."""
    if settings.pinecone_api_key == "your_pinecone_api_key_here" or not settings.pinecone_api_key:
        print("⚠️ Warning: Pinecone API Key not configured. Memory functionality will be mocked.")
        return None
        
    try:
        if INDEX_NAME not in pc.list_indexes().names():
            pc.create_index(
                name=INDEX_NAME,
                dimension=768, # Gemini embedding-004 dimension
                metric="cosine",
                spec=ServerlessSpec(cloud="aws", region="us-east-1")
            )
        return pc.Index(INDEX_NAME)
    except Exception as e:
        print(f"❌ Pinecone Error: {e}")
        return None

async def get_embedding(text: str) -> List[float]:
    """Generate embedding using Gemini's text-embedding-004 model."""
    try:
        result = genai.embed_content(
            model="models/text-embedding-004",
            content=text,
            task_type="retrieval_document",
            title="Memory Item"
        )
        return result['embedding']
    except Exception as e:
        print(f"❌ Embedding Error: {e}")
        # Fallback to zero vector if failed (should be handled better in prod)
        return [0.0] * 768

async def upsert_memory(user_id: str, content: str, category: str, metadata: Optional[Dict] = None):
    """Store a memory item in Pinecone."""
    index = get_index()
    if not index:
        return
        
    embedding = await get_embedding(content)
    
    # Unique ID for the memory item
    import uuid
    memory_id = str(uuid.uuid4())
    
    vec_metadata = {
        "user_id": user_id,
        "content": content,
        "category": category,
        **(metadata or {})
    }
    
    index.upsert(vectors=[(memory_id, embedding, vec_metadata)])

async def query_memories(user_id: str, query_text: str, top_k: int = 5) -> List[str]:
    """Search for relevant memories for a given query."""
    index = get_index()
    if not index:
        return []
        
    query_embedding = await get_embedding(query_text)
    
    try:
        results = index.query(
            vector=query_embedding,
            top_k=top_k,
            filter={"user_id": {"$eq": user_id}},
            include_metadata=True
        )
        
        return [match['metadata']['content'] for match in results['matches'] if match['score'] > 0.65]
    except Exception as e:
        print(f"❌ Query Error: {e}")
        return []

async def get_memory_context(user_id: str, query: str) -> str:
    """Helper to get a formatted context string for LLM prompts."""
    memories = await query_memories(user_id, query)
    if not memories:
        return ""
        
    context = "\n".join([f"- {m}" for m in memories])
    return f"\nRelevant background about the user:\n{context}\n"
