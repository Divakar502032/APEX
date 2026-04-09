from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    gemini_api_key: str
    openai_api_key: str
    database_url: str = "postgresql+asyncpg://user:password@localhost:5432/apex_ai"
    redis_url: str = "redis://localhost:6379/0"
    pinecone_api_key: str = ""
    revenuecat_api_key: str = ""
    environment: str = "development"
    debug: bool = True

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
