#run with: uvicorn backend.app:app --reload --port 8000

from fastapi import FastAPI
from dotenv import load_dotenv
from backend.routes.routes import router

import backend.routes.auth.routes
import backend.routes.user.routes

load_dotenv()

app = FastAPI()

app.include_router(router)