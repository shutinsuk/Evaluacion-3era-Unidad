from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    full_name: Optional[str] = None
    is_active: bool

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class PackageBase(BaseModel):
    tracking_number: str
    address: str
    latitude: float
    longitude: float
    status: str

class Package(PackageBase):
    id: int
    assigned_to: int

    class Config:
        orm_mode = True

class DeliveryBase(BaseModel):
    package_id: int
    gps_latitude: float
    gps_longitude: float

class DeliveryCreate(DeliveryBase):
    pass

class Delivery(DeliveryBase):
    id: int
    delivered_by: int
    delivered_at: datetime
    photo_path: str
    photo_url: Optional[str] = None # campo calculado para la respuesta

    class Config:
        orm_mode = True
