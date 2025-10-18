from fastapi import HTTPException
from sqlmodel import Session

from database.models.models import User
from backend.schemas.user import UserCreate

from utils.db_utils import is_existing
from utils.password_encryption import hash_password

from sqlalchemy.exc import IntegrityError, SQLAlchemyError


def register_user(data: UserCreate, session: Session) -> User:

    if is_existing(session, User, "email", data.email):
        raise HTTPException(409, "Email already exists")

    try:
        hashed_pw = hash_password(data.password)
        new_user = User(**data.model_dump(exclude={"password"}), password=hashed_pw)

        session.add(new_user)
        session.commit()
        session.refresh(new_user)

        return new_user

    except IntegrityError:
        # If user table constraints fail
        session.rollback()
        raise HTTPException(409, "User already exists")
        
    except SQLAlchemyError as e:
        # Catches any DB errors
        session.rollback()
        raise HTTPException(500, f"database error: {str(e)}")
        
    except Exception as e:
        # Unexpected behavior
        session.rollback()
        raise HTTPException(500, f"Unexpected error: {str(e)}")