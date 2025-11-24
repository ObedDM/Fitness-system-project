from fastapi import HTTPException
from sqlmodel import Session, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from database.models.models import User, Role, User_Role
from backend.schemas.user import UserCreate, UserRead, UserResponse
from backend.utils.db_utils import is_existing
from backend.utils.password_encryption import hash_password

def register_user(data: UserCreate, session: Session) -> str:

    if is_existing(session, User, "email", data.email):
        raise HTTPException(409, "Email already exists")
    
    if is_existing(session, User, "username", data.username):
        raise HTTPException(409, "Username already exists")

    try:
        hashed_pw = hash_password(data.password)
        role_name = data.role

        new_user = User(**data.model_dump(exclude={"password", "role"}), password=hashed_pw)
        session.add(new_user)
        session.flush()

        role = session.exec(
            select(Role)
            .where(Role.role == role_name)
        ).first()

        if not role:
            raise HTTPException(404, f"Role '{role_name}' not found")
        
        user_role = User_Role(
            user_id=new_user.user_id,
            role=role.role
        )
        session.add(user_role)

        session.commit()
        session.refresh(new_user)

        return "success"

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
    

def get_users(session: Session) -> UserRead:
    users = session.exec(select(User)).all()

    return users

def get_profile(user_id: str, session: Session) -> UserRead:
    result = session.exec(
        select(User, User_Role.role)
        .join(User_Role)
        .where(User.user_id == user_id)
    ).first()

    if not result:
        raise HTTPException(404, "User not found")
    
    user_data, role = result

    user_dict = user_data.model_dump(exclude={"password"})
    user_dict["role"] = role
    
    return user_dict