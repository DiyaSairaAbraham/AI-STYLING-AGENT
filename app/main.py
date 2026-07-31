import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.routers import health
from app.routers import vision
from app.routers import wardrobe
from app.routers import recommendation
from app.routers import image_generation


# Ensure static folders exist
os.makedirs(
    "outputs",
    exist_ok=True
)

os.makedirs(
    "wardrobe",
    exist_ok=True
)



app = FastAPI(
    title="AI Styling Agent API",
    version="1.0.0"
)



app.add_middleware(
    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],
)



# Generated outfit images
app.mount(
    "/outputs",
    StaticFiles(
        directory="outputs"
    ),
    name="outputs"
)



# Wardrobe clothing images
app.mount(
    "/clothes",
    StaticFiles(
        directory="wardrobe"
    ),
    name="clothes"
)




# Routers

app.include_router(
    health.router
)


app.include_router(
    vision.router
)


app.include_router(
    wardrobe.router
)


app.include_router(
    recommendation.router
)


app.include_router(
    image_generation.router
)




@app.get("/")
def home():

    return {
        "message":
        "AI Styling Agent API running"
    }