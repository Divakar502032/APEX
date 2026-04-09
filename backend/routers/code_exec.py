from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class CodeExecRequest(BaseModel):
    language: str
    code: str


@router.post("/execute")
async def execute_code(request: CodeExecRequest):
    """
    Sandboxed code execution — Phase 7 will implement full sandbox.
    Returns placeholder for now.
    """
    return {
        "stdout": "# Code execution sandbox coming in Phase 7",
        "stderr": "",
        "exit_code": 0,
    }
