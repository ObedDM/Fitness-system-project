import json
import os
from fastapi import Depends, UploadFile, File, Form
from fastapi.responses import FileResponse
from sqlmodel import Session
from pathlib import Path

from database.connection import get_session
from backend.routes.router import router
from backend.schemas.dish import DishCreate, DishRead, DishSummary
from backend.services.dish.dish import add_dish, retrieve_dishes, retrieve_single_dish
from backend.utils.dependencies import get_user_id
from backend.utils.image_utils import get_image

IMAGES_DIR = Path("backend/assets/images/dish")

@router.post('/dish', status_code=201)
async def add_dish_handler(data: str = Form(...), image: UploadFile | None = File(None), user_id: str = Depends(get_user_id), session: Session = Depends(get_session)):
    
    data = DishCreate(**json.loads(data))
    dish = add_dish(data, user_id, session)

    if image:
        IMAGES_DIR.mkdir(parents=True, exist_ok=True)
        ext = os.path.splitext(image.filename)[1] or ".jpg"
        file_path = IMAGES_DIR / f"{dish.dish_id}{ext}"
        with file_path.open("wb") as f:
            f.write(await image.read())

    return {"message": f"dish {dish.name} created successfully. Id: {dish.dish_id}"}

@router.get('/dishes', response_model=list[DishSummary], status_code=200)
async def retrieve_dishes_handler(session: Session = Depends(get_session)):
    return retrieve_dishes(session=session)

@router.get('/dishes/me', response_model=list[DishSummary], status_code=200)
async def retrieve_own_dishes_handler(user_id: str = Depends(get_user_id), session: Session = Depends(get_session)):
    return retrieve_dishes(user_id=user_id, session=session)

@router.get('/dish/{dish_id}', response_model=DishRead, status_code=200)
async def retrieve_single_dish_handler(dish_id: str, session: Session = Depends(get_session)):
    return retrieve_single_dish(dish_id, session)

@router.get('/dish/{dish_id}/image')
async def get_dish_image(dish_id: str):
    return get_image(filename=dish_id)