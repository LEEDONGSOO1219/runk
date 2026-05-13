from fastapi import Depends, FastAPI, HTTPException, Query, Response, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import desc, select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import create_access_token, hash_password, verify_password
from app.db import Base, engine, get_db
from app.dependencies import get_current_user
from app.models import RunningRecord, User
from app.schemas import (
    RunningRecordCreate,
    RunningRecordRead,
    Token,
    UserCreate,
    UserLogin,
    UserRead,
)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Runk API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_security_headers(request, call_next):
    response: Response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["Permissions-Policy"] = "geolocation=()"
    if settings.environment != "local":
        response.headers["Strict-Transport-Security"] = (
            "max-age=31536000; includeSubDomains"
        )
    return response


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/auth/check-username")
def check_username(
    username: str = Query(min_length=2, max_length=50, pattern=r"^[a-zA-Z0-9_.-]+$"),
    db: Session = Depends(get_db),
):
    existing_user = db.scalar(select(User).where(User.username == username))
    return {"available": existing_user is None}


@app.get("/auth/check-email")
def check_email(
    email: str = Query(min_length=3, max_length=255),
    db: Session = Depends(get_db),
):
    existing_user = db.scalar(select(User).where(User.email == email))
    return {"available": existing_user is None}


@app.post("/auth/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
def signup(payload: UserCreate, db: Session = Depends(get_db)):
    existing_email = db.scalar(select(User).where(User.email == payload.email))
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists",
        )

    existing_username = db.scalar(select(User).where(User.username == payload.username))
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Username already exists",
        )

    user = User(
        email=payload.email,
        username=payload.username,
        hashed_password=hash_password(payload.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return Token(access_token=create_access_token(str(user.id)), user=user)


@app.post("/auth/login", response_model=Token)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.email == payload.email))
    if user is None or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    return Token(access_token=create_access_token(str(user.id)), user=user)


@app.get("/users/me", response_model=UserRead)
def read_my_profile(current_user: User = Depends(get_current_user)):
    return current_user


@app.post(
    "/running-records",
    response_model=RunningRecordRead,
    status_code=status.HTTP_201_CREATED,
)
def create_running_record(
    payload: RunningRecordCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    pace_seconds = round(payload.duration_seconds / payload.distance_km)
    record = RunningRecord(
        user_id=current_user.id,
        distance_km=payload.distance_km,
        duration_seconds=payload.duration_seconds,
        pace_seconds_per_km=pace_seconds,
        run_date=payload.run_date,
        memo=payload.memo,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return _record_to_read(record)


@app.get("/running-records/me", response_model=list[RunningRecordRead])
def read_my_running_records(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    records = db.scalars(
        select(RunningRecord)
        .where(RunningRecord.user_id == current_user.id)
        .order_by(desc(RunningRecord.run_date), desc(RunningRecord.created_at))
    ).all()
    return [_record_to_read(record) for record in records]


@app.get("/feed", response_model=list[RunningRecordRead])
def read_feed(
    limit: int = Query(default=50, ge=1, le=100),
    db: Session = Depends(get_db),
):
    records = db.scalars(
        select(RunningRecord)
        .order_by(desc(RunningRecord.created_at))
        .limit(limit)
    ).all()
    return [_record_to_read(record) for record in records]


def _record_to_read(record: RunningRecord) -> RunningRecordRead:
    return RunningRecordRead(
        id=record.id,
        user_id=record.user_id,
        username=record.user.username,
        distance_km=record.distance_km,
        duration_seconds=record.duration_seconds,
        pace_seconds_per_km=record.pace_seconds_per_km,
        run_date=record.run_date,
        memo=record.memo,
        created_at=record.created_at,
    )
