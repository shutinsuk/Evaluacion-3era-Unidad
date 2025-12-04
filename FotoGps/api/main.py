from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth, packages, deliveries

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory="api/uploads"), name="uploads")

app.include_router(auth.router)
app.include_router(packages.router)
app.include_router(deliveries.router)

@app.get("/")
def read_root():
    return {"message": "FotoGps API is running"}
