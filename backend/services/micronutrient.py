from fastapi import HTTPException
from sqlmodel import Session

from database.models.models import MicroNutrient
from backend.schemas.micronutrient import MicronutrientCreate

from backend.utils.db_utils import is_existing

from sqlalchemy.exc import IntegrityError, SQLAlchemyError

def add_micronutrient(data: MicronutrientCreate, session: Session) -> MicroNutrient:

    try:
        new_micronutrient = MicroNutrient(**data.model_dump())

        session.add(new_micronutrient)
        session.commit()
        session.refresh(new_micronutrient)

        return new_micronutrient
    
    except IntegrityError as e:
        session.rollback()
        raise HTTPException(409, f"Integrity error: {str(e.orig)}")

    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(500, f"database error: {str(e)}")
    
    except Exception as e:
        session.rollback()
        raise HTTPException(500, f"Unexpected error: {str(e)}")