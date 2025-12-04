from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List
from ..core import database
from ..models import schemas
from .auth import get_current_user

router = APIRouter()

@router.get("/packages/assigned", response_model=List[schemas.Package])
def read_assigned_packages(current_user = Depends(get_current_user), db: Session = Depends(database.get_db)):
    user_id = current_user.id
    query = text("SELECT * FROM packages WHERE assigned_to = :user_id AND status = 'pending'")
    result = db.execute(query, {"user_id": user_id}).fetchall()
    return result
