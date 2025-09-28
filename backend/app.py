#run with: uvicorn app:app --reload --port 8000

from fastapi import FastAPI
from dotenv import load_dotenv
from routes.routes import router
import os

load_dotenv()

app = FastAPI()

app.include_router(router)