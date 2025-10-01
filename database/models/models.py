import uuid
from sqlmodel import SQLModel, Field
from typing import Optional
from sqlalchemy import String, Column, Numeric, CheckConstraint

class User(SQLModel, table=True):
    user_id: str = Field(default_factory=lambda: str(uuid.uuid7()), primary_key=True, index=True, unique=True)
    name: str
    surname: str
    email: str = Field(sa_column=Column(String(254), unique=True, index=True, nullable=False))
    age: Optional[int] = Field(default=None)
    weight: Optional[float] = Field(sa_column=Column(Numeric(5, 2), default=None))
    height: Optional[float] = Field(sa_column=Column(Numeric(3, 2), default=None))

    __table_args__ = (
        CheckConstraint('age >= 0 AND age <= 120', name='age_to_120'),
    )