from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import desc, select
from sqlalchemy.orm import Session

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
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5000",
        "http://localhost:5173",
        "http://localhost:8080",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.post("/auth/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
def signup(payload: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.scalar(
        select(User).where(
            (User.email == payload.email) | (User.username == payload.username)
        )
    )
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email or username already exists",
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
def read_feed(db: Session = Depends(get_db)):
    records = db.scalars(
        select(RunningRecord)
        .order_by(desc(RunningRecord.created_at))
        .limit(50)
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
