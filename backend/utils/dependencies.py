from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from returns.result import Success, Failure

from backend.utils.jwt_handler import decode_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_user_id(token: str = Depends(oauth2_scheme)) -> str:
    result = decode_token(token)  # ← Ahora retorna Result
    
    match result:
        case Success(payload):
            # Verificar que sea access token
            if payload.get("type") != "access":
                raise HTTPException(status_code=401, detail="Invalid token type")
            
            # Extraer user_id
            user_id = payload.get("user_id")
            if not user_id:
                raise HTTPException(status_code=401, detail="Invalid token payload")
            
            return str(user_id)
        
        case Failure("expired"):
            raise HTTPException(status_code=401, detail="Token expired")
        
        case Failure(_):
            raise HTTPException(status_code=401, detail="Invalid token")