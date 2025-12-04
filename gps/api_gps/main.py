from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import (
    create_engine,
    Column,
    Integer,
    String,
    TIMESTAMP,
    ForeignKey,
    DECIMAL
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from pydantic import BaseModel
import hashlib 
import requests
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware

# --- CONEXIÓN BD ---
# Asegúrate de que tu XAMPP/MySQL esté corriendo y la base de datos 'gps' exista
Database_URL = "mysql+pymysql://root:@localhost:3306/gps"
engine = create_engine(Database_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI()

# --- CONFIGURACIÓN CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- MODELOS DE BASE DE DATOS (TABLAS) ---
class User(Base):
    __tablename__ = "users"
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(100))
    created_at = Column(TIMESTAMP, default=datetime.utcnow)

class Attendance(Base):
    __tablename__ = "attendance"
    attendance_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    latitude = Column(DECIMAL(10, 8), nullable=False)
    longitude = Column(DECIMAL(11, 8), nullable=False)
    address = Column(String(255))
    registered_at = Column(TIMESTAMP, default=datetime.utcnow)
    user = relationship("User")

# CREAR TABLAS
Base.metadata.create_all(bind=engine)

# --- MODELOS PYDANTIC (VALIDACIÓN) ---
class RegisterModel(BaseModel):
    username: str
    password: str
    full_name: str

class LoginModel(BaseModel):
    username: str
    password: str

class AttendanceModel(BaseModel):
    user_id: int
    latitude: float
    longitude: float

# --- DEPENDENCIAS ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- ENDPOINTS ---

@app.post("/register/")
def register(user: RegisterModel, db: SessionLocal = Depends(get_db)):
    # Verificar si el usuario ya existe
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="El usuario ya existe")
    
    # Crear nuevo usuario (Hashear contraseña en producción)
    hashed_password = hashlib.sha256(user.password.encode()).hexdigest()
    
    new_user = User(
        username=user.username,
        password_hash=hashed_password,
        full_name=user.full_name
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"message": "Usuario registrado exitosamente", "user_id": new_user.user_id}

@app.post("/login/")
def login(user: LoginModel, db: SessionLocal = Depends(get_db)):
    hashed_password = hashlib.sha256(user.password.encode()).hexdigest()
    
    db_user = db.query(User).filter(
        User.username == user.username, 
        User.password_hash == hashed_password
    ).first()
    
    if not db_user:
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")
    
    return {
        "message": "Login exitoso", 
        "user_id": db_user.user_id,
        "full_name": db_user.full_name
    }

@app.post("/attendance/")
def register_attendance(attendance: AttendanceModel, db: SessionLocal = Depends(get_db)):
    # 1. Obtener dirección con Nominatim (OpenStreetMap)
    try:
        headers = {'User-Agent': 'PaseListaApp/1.0'}
        url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={attendance.latitude}&lon={attendance.longitude}"
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            address_data = response.json()
            address = address_data.get("display_name", "Dirección desconocida")
        else:
            address = "No se pudo obtener la dirección"
    except Exception as e:
        address = f"Error obteniendo dirección: {str(e)}"

    # 2. Guardar en BD
    new_attendance = Attendance(
        user_id=attendance.user_id,
        latitude=attendance.latitude,
        longitude=attendance.longitude,
        address=address
    )
    
    db.add(new_attendance)
    db.commit()
    db.refresh(new_attendance)
    
    return {
        "message": "Asistencia registrada", 
        "attendance_id": new_attendance.attendance_id,
        "address": address
    }

@app.get("/attendance/")
def get_attendance(db: SessionLocal = Depends(get_db)):
    attendance_records = db.query(Attendance).all()
    return attendance_records