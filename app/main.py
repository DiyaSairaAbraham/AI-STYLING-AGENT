import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.routers import health
from app.routers import vision
from app.routers import wardrobe
from app.routers import recommendation
from app.routers import image_generation


# ============================================================
# REQUIRED DIRECTORIES
# ============================================================

os.makedirs(
    "outputs",
    exist_ok=True,
)

os.makedirs(
    "outputs/images",
    exist_ok=True,
)

os.makedirs(
    "wardrobe",
    exist_ok=True,
)

os.makedirs(
    "uploads",
    exist_ok=True,
)


# ============================================================
# FASTAPI APPLICATION
# ============================================================

app = FastAPI(
    title="AI Styling Agent API",
    version="1.0.0",
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

app.mount(
    "/clothes",
    StaticFiles(
        directory="wardrobe",
    ),
    name="clothes",
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
# ROOT ENDPOINT
# ============================================================

@app.get("/")
def home() -> dict[str, str]:
    return {
        "message": "AI Styling Agent API running",
        "function_1": (
            "AI-generated Business Formal and Smart Casual outfits"
        ),
        "function_2": (
            "Personal and Commercial Wardrobe - coming next"
        ),
    }