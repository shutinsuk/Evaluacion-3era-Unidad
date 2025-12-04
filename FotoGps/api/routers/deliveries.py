from fastapi import APIRouter, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List
import shutil
import os
import uuid
from ..core import database
from ..models import schemas
from .auth import get_current_user

router = APIRouter()

UPLOAD_DIR = "api/uploads"

@router.post("/deliveries/", response_model=schemas.Delivery)
def create_delivery(
    package_id: int = Form(...),
    gps_latitude: float = Form(...),
    gps_longitude: float = Form(...),
    photo: UploadFile = File(...),
    current_user = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    # guardar foto
    file_extension = photo.filename.split(".")[-1]
    file_name = f"{uuid.uuid4()}.{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, file_name)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(photo.file, buffer)
        
    # insertar delivery
    query = text("""
        INSERT INTO deliveries (package_id, delivered_by, photo_path, gps_latitude, gps_longitude)
        VALUES (:pid, :uid, :path, :lat, :lon)
    """)
    db.execute(query, {
        "pid": package_id,
        "uid": current_user.id,
        "path": file_name,
        "lat": gps_latitude,
        "lon": gps_longitude
    })
    
    # actualizar paquete
    db.execute(text("UPDATE packages SET status = 'delivered' WHERE id = :pid"), {"pid": package_id})
    db.commit()
    
    # recuperar el delivery creado
    last_id = db.execute(text("SELECT LAST_INSERT_ID()")).scalar()
    delivery = db.execute(text("SELECT * FROM deliveries WHERE id = :id"), {"id": last_id}).fetchone()
    
    # mapear a esquema
    return {
        **delivery._mapping, 
        "photo_url": f"http://localhost:8000/uploads/{file_name}"
    }

@router.get("/deliveries/history", response_model=List[schemas.Delivery])
def read_delivery_history(current_user = Depends(get_current_user), db: Session = Depends(database.get_db)):
    query = text("SELECT * FROM deliveries WHERE delivered_by = :uid ORDER BY delivered_at DESC")
    results = db.execute(query, {"uid": current_user.id}).fetchall()
    
    # enriquecer con URL
    history = []
    for row in results:
        item = dict(row._mapping)
        item["photo_url"] = f"http://localhost:8000/uploads/{item['photo_path']}"
        history.append(item)
    return history
