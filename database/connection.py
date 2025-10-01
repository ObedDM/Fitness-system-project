from sqlmodel import SQLModel, create_engine, Session
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL')

print(DATABASE_URL)

engine = create_engine(DATABASE_URL, echo=True) # Turn off echo in prod

def get_session():
    with Session(engine) as session:
        yield session