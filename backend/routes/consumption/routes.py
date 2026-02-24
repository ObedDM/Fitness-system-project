from fastapi import Depends, Query, Request  # ← AGREGAR Request
from sqlmodel import Session
from fastapi import status  # ← Para status_code

from database.connection import get_session
from backend.routes.router import router
from backend.schemas.consumption import ConsumptionCreate, ConsumptionReport
from backend.services.consumption.consumption import log_consumption, get_consumption_range_report
from backend.utils.dependencies import get_user_id

@router.post("/consumption/log", status_code=status.HTTP_201_CREATED)
async def log_consumption_handler(data: ConsumptionCreate, session: Session = Depends(get_session), user_id: str = Depends(get_user_id)):
    log = log_consumption(user_id, data, session)
    return {"message": f"{log.consumption_id} logged successfully"}

@router.get("/consumption/report", response_model=ConsumptionReport)
async def get_consumption_report_handler(days: int = Query(default=1, ge=1, le=90), session: Session = Depends(get_session), user_id: str = Depends(get_user_id)):
    return get_consumption_range_report(user_id, session, days)
