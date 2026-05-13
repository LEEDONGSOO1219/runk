from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str = "mysql+pymysql://runk_user:runk_password@localhost:3306/runk"
    jwt_secret_key: str = "change-me-in-local"
    access_token_expire_minutes: int = 1440
    environment: str = "local"
    cors_origins: str = (
        "http://localhost:3000,"
        "http://localhost:5000,"
        "http://localhost:5173,"
        "http://localhost:8080"
    )

    @property
    def cors_origin_list(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.cors_origins.split(",")
            if origin.strip()
        ]

    @model_validator(mode="after")
    def validate_security_settings(self):
        if self.environment != "local" and self.jwt_secret_key == "change-me-in-local":
            raise ValueError("JWT_SECRET_KEY must be changed outside local development")
        return self

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()
