from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from ..core import database, security
from ..models import schemas
from sqlalchemy import text

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
def get_user(db: Session, username: str):
    result = db.execute(text("SELECT * FROM users WHERE username = :username"), {"username": username}).fetchone()
    return result

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(database.get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, security.SECRET_KEY, algorithms=[security.ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = schemas.TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

@router.post("/token", response_model=schemas.Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.get_db)):
    print(f"Intento de login: {form_data.username}")
    user = get_user(db, form_data.username)
    if not user:
        print("Usuario no encontrado")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not security.verify_password(form_data.password, user.hashed_password):
        print("Contraseña incorrecta")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    print("Login exitoso")
    access_token = security.create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}
