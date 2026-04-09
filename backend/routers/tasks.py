from fastapi import APIRouter
from models.task import TaskModel, TaskStatus
import uuid
from datetime import datetime

router = APIRouter()

# In-memory store for Phase 4 (DB in Phase 7)
_tasks: dict = {}


@router.post("/")
async def create_task(task: TaskModel):
    task_id = str(uuid.uuid4())
    task = task.model_copy(update={
        "id": task_id,
        "status": TaskStatus.planning,
        "created_at": datetime.utcnow(),
    })
    _tasks[task_id] = task
    return task


@router.get("/{task_id}")
async def get_task(task_id: str):
    return _tasks.get(task_id, {"error": "Task not found"})


@router.get("/user/{user_id}")
async def get_user_tasks(user_id: str):
    return [t for t in _tasks.values() if t.user_id == user_id]
