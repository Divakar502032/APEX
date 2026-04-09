from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import chat, memory, tasks, code_exec

app = FastAPI(
    title="APEX AI Backend",
    description="Backend services for APEX AI application.",
    version="1.0.0",
)

# CORS middleware for any internal admin panels or debugging web targets
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(chat.router, prefix="/api/chat", tags=["Chat"])
app.include_router(memory.router, prefix="/api/memory", tags=["Memory"])
app.include_router(tasks.router, prefix="/api/tasks", tags=["Tasks"])
app.include_router(code_exec.router, prefix="/api/code", tags=["Code Execution"])

@app.get("/health")
async def health_check():
    return {"status": "ok", "version": "1.0.0"}
