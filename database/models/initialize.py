from sqlmodel import SQLModel
from database.connection import engine
from database.models.models import User

SQLModel.metadata.create_all(engine)
print('Tables created')