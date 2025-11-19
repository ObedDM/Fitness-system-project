from fastapi import HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from returns.result import Result, Success, Failure

from database.models.models import User
from backend.utils.password_encryption import verify_password
from backend.utils.jwt_handler import create_token, decode_token
from backend.schemas.refresh import RefreshRequest

# Login service
def login(data: OAuth2PasswordRequestForm, session: Session) -> dict:

    user = session.exec(
        select(User).where(User.username == data.username)
    ).first()

    if not user or not verify_password(data.password, user.password):
        raise HTTPException(status_code=401, detail='Incorrect credentials')
    
    access_token = create_token({"user_id": user.user_id}, token_type="access")
    refresh_token = create_token({"user_id": user.user_id}, token_type="refresh")
        
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

# Token refresh service
def refresh(data: RefreshRequest) -> dict:
    result = decode_token(data.refresh_token)

    match result:
        case Success(payload):
            if payload.get("type") != "refresh":
                raise HTTPException(status_code=401, detail="Token is not a refresh")
            
            user_id = payload.get("user_id")

            if not user_id:
                raise HTTPException(status_code=401, detail="Invalid token payload")

            new_access_token = create_token({"user_id": user_id}, token_type='access')
            return {
                "access_token": new_access_token,
                "token_type": "bearer"
            } 
            
        case Failure("expired"):
            raise HTTPException(status_code=401, detail="Token expired. Log back in")
        
        case Failure("token decoding failure"):
            raise HTTPException(status_code=500, detail='Something unexpected happened. Try again later')
        
        case Failure(_):
            raise HTTPException(status_code=401, detail="Invalid token.")
