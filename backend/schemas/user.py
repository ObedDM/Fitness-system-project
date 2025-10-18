from sqlmodel import SQLModel
from typing import Optional

class UserBase(SQLModel):
    name: str
    surname: str
    email: str

class UserCreate(UserBase):
    password: str
    age: Optional[int] = None
    weight: Optional[int] = None
    height: Optional[int] = None

class UserRead(UserBase):
    age: Optional[int] = None
    weight: Optional[int] = None
    height: Optional[int] = None