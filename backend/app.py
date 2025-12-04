#run with: uvicorn backend.app:app --reload --port 8000

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from backend.routes.router import router

import backend.routes.auth.routes
import backend.routes.user.routes
import backend.routes.ingredients.routes
import backend.routes.dish.routes

load_dotenv()

app = FastAPI()

app.include_router(router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)