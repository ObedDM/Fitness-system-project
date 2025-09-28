from fastapi import APIRouter

router = APIRouter()

@router.get('/')
async def root():
    return {'message': 'hola sssssyosaquessss'}

@router.get('/hola')
async def hola():
    return {'hola': 12543}