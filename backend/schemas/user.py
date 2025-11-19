from sqlmodel import SQLModel
from typing import Optional
from pydantic import EmailStr, Field

class UserBase(SQLModel):
    username: str
    email: EmailStr = Field(..., max_length=254)

class UserCreate(UserBase):
    name: str
    surname: str
    password: str
    age: Optional[int] = None
    weight: Optional[float] = None
    height: Optional[float] = None

class UserRead(UserBase):
    user_id: str
    name: str
    surname: str
    age: Optional[int] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    
    class Config:
        from_attributes = True

class UserLogin(SQLModel):
    username: str
    password: str