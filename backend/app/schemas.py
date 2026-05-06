from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field


class UserCreate(BaseModel):
    email: EmailStr
    username: str = Field(min_length=2, max_length=50)
    password: str = Field(min_length=6, max_length=128)


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
    distance_km: float = Field(gt=0)
    duration_seconds: int = Field(gt=0)
    run_date: date
    memo: str | None = Field(default=None, max_length=255)


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
