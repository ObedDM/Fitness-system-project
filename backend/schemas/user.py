from sqlmodel import SQLModel
from typing import Optional

class UserBase(SQLModel):
    name: str
    surname: str
    email: str

class UserCreate(UserBase):
    surname: str
    email: str
    password: str
    age: Optional[int] = None
    weight: Optional[int] = None
    height: Optional[int] = None