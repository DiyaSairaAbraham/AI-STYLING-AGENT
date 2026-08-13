import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.routers import (
    health,
    vision,
    wardrobe,
    recommendation,
    image_generation,
)


# ============================================================
# REQUIRED DIRECTORIES
# ============================================================


DIRECTORIES = [
    "outputs",
    "outputs/images",
    "outputs/json",
    "uploads",
    "wardrobe",
    "wardrobe_2",
]


for directory in DIRECTORIES:
    os.makedirs(
        directory,
        exist_ok=True,
    )


# ============================================================
# APPLICATION
# ============================================================


app = FastAPI(
    title="AI Styling Agent API",
    version="2.0.0",
)


# ============================================================
# CORS
# ============================================================


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# STATIC FILES
# ============================================================


app.mount(
    "/images",
    StaticFiles(
        directory="outputs/images",
    ),
    name="images",
)


app.mount(
    "/outputs",
    StaticFiles(
        directory="outputs",
    ),
    name="outputs",
)


# Personal wardrobe
app.mount(
    "/clothes/personal",
    StaticFiles(
        directory="wardrobe",
    ),
    name="personal_clothes",
)


# Commercial wardrobe
app.mount(
    "/clothes/commercial",
    StaticFiles(
        directory="wardrobe_2",
    ),
    name="commercial_clothes",
)


# ============================================================
# ROUTERS
# ============================================================


app.include_router(
    health.router,
)

app.include_router(
    vision.router,
)

app.include_router(
    wardrobe.router,
)

app.include_router(
    recommendation.router,
)

app.include_router(
    image_generation.router,
)


# ============================================================
# ROOT
# ============================================================


@app.get("/")
def home() -> dict[str, str]:
    return {
        "message": (
            "AI Styling Agent API running."
        ),
        "architecture": (
            "Upload once -> AI Styling or Wardrobe Styling"
        ),
        "function_1": (
            "AI Styling - unrestricted AI outfit "
            "with shopping links and generated image"
        ),
        "function_2": (
            "Wardrobe Styling - Personal or "
            "Commercial wardrobe"
        ),
    }