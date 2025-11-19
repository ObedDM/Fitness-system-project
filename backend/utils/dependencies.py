from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from backend.utils.jwt_handler import decode_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_user_id(token: str = Depends(oauth2_scheme)) -> str:
    payload = decode_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail='invalid_token')
    
    return payload['user_id']

