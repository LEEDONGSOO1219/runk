from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field, field_validator


class UserCreate(BaseModel):
    email: EmailStr
    username: str = Field(min_length=2, max_length=50, pattern=r"^[a-zA-Z0-9_.-]+$")
    password: str = Field(min_length=8, max_length=16)

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, value: str) -> str:
        if any(char.isspace() for char in value):
            raise ValueError("Password must not contain spaces")

        has_letter = any(char.isalpha() for char in value)
        has_digit = any(char.isdigit() for char in value)
        has_special = any(not char.isalnum() for char in value)
        category_count = sum([has_letter, has_digit, has_special])
        if category_count < 2:
            raise ValueError(
                "Password must combine at least two of letters, numbers, and special characters"
            )
        return value


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserRead(BaseModel):
    id: int
    email: EmailStr
    username: str
    created_at: datetime

    model_config = {"from_attributes": True}


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead


class RunningRecordCreate(BaseModel):
    distance_km: float = Field(gt=0, le=300)
    duration_seconds: int = Field(gt=0, le=86400)
    run_date: date
    memo: str | None = Field(default=None, max_length=255)

    @field_validator("run_date")
    @classmethod
    def reject_future_run_date(cls, value: date) -> date:
        if value > date.today():
            raise ValueError("Run date cannot be in the future")
        return value


class RunningRecordRead(BaseModel):
    id: int
    user_id: int
    username: str
    distance_km: float
    duration_seconds: int
    pace_seconds_per_km: int
    run_date: date
    memo: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
