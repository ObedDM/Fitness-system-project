from sqlmodel import SQLModel
from typing import Optional

class UserBase(SQLModel):
    username: str
    email: Optional[int] = None

class UserCreate(UserBase):
    name: str
    surname: str
    password: str
    age: Optional[int] = None
    weight: Optional[int] = None
    height: Optional[int] = None

class UserRead(UserCreate):
    pass

class UserLogin(UserBase):
    password: str