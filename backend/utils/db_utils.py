from sqlmodel import Session, select
from typing import Any

def is_existing(session: Session, model: type, field_name: str, value: Any) -> bool:
    
    field = getattr(model, field_name)
    
    return session.exec(
        select(model)
        .where(field == value)
    ).first()