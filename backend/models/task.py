from pydantic import BaseModel
from typing import Optional, List
from enum import Enum
from datetime import datetime


class TaskStatus(str, Enum):
    planning = "planning"
    executing = "executing"
    waiting_approval = "waiting_approval"
    done = "done"
    failed = "failed"


class TaskModel(BaseModel):
    id: Optional[str] = None
    user_id: str
    title: str
    description: str
    status: TaskStatus = TaskStatus.planning
    steps: List[str] = []
    current_step: int = 0
    result: Optional[str] = None
    created_at: Optional[datetime] = None
    elapsed_ms: Optional[int] = None
