import uuid6
from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from sqlalchemy import String, Column, Numeric, CheckConstraint

class User_Role(SQLModel, table=True):
    user_id: str = Field(foreign_key="user.user_id", primary_key=True)
    role: str = Field(foreign_key="role.role", primary_key=True)

class User(SQLModel, table=True):
    user_id: str = Field(default_factory=lambda: str(uuid6.uuid7()), primary_key=True, index=True, unique=True)
    name: str
    surname: str
    email: str = Field(sa_column=Column(String(254), unique=True, index=True, nullable=False))
    age: Optional[int] = Field(default=None)
    weight: Optional[float] = Field(sa_column=Column(Numeric(5, 2), default=None))
    height: Optional[float] = Field(sa_column=Column(Numeric(3, 2), default=None))

    __table_args__ = (
        CheckConstraint('age >= 0 AND age <= 120', name='age_to_120'),
    )

    roles: List["Role"] = Relationship(back_populates="users", link_model=User_Role)

class Role(SQLModel, table=True):
    role: str = Field(sa_column=Column(String(12), primary_key=True, index=True, unique=True))

    users: List[User] = Relationship(back_populates="roles", link_model=User_Role)