from decouple import config
from typing import Optional, Literal
from datetime import datetime, timedelta, timezone
import jwt
import secrets

SECRET_KEY = config("SECRET_KEY")
ALGORITHM = config("ALGORITHM", default="HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = config("ACCESS_TOKEN_EXPIRE_MINUTES", default=30, cast=int)
REFRESH_TOKEN_EXPIRE_DAYS = config("REFRESH_TOKEN_EXPIRE_DAYS", default=7, cast=int)

def create_token(data: dict, token_type: Literal['access', 'refresh'], expire_time_override: Optional[timedelta] = None) -> str:
    to_encode = data.copy()

    time_now = datetime.now(timezone.utc)

    if expire_time_override:
        expire = time_now + expire_time_override

    elif token_type == 'access':
        expire = time_now + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    else:
        expire = time_now + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)

    to_encode.update({
        "exp": expire,
        "iat": time_now,
        "type": token_type,
        "jti": secrets.token_hex(16), # Token id
        })

    return jwt.encode(to_encode, SECRET_KEY, algorithm = ALGORITHM)