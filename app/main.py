import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.routers import commercial
from app.routers import health
from app.routers import image_generation
from app.routers import recommendation
from app.routers import vision
from app.routers import wardrobe


# =====================================================
# Required directories
# =====================================================

REQUIRED_DIRECTORIES: tuple[str, ...] = (
    "outputs",
    "outputs/images",
    "wardrobe",
    "wardrobe_thumbnails",
    "database/commercial",
)

for directory in REQUIRED_DIRECTORIES:
    os.makedirs(directory, exist_ok=True)


# =====================================================
# FastAPI application
# =====================================================

app = FastAPI(
    title="AI Styling Agent API",
    version="1.0.0",
)


# =====================================================
# CORS
# =====================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =====================================================
# Generated outfit images
# =====================================================

app.mount(
    "/images",
    StaticFiles(
        directory="outputs/images",
    ),
    name="images",
)

# Keep the existing /outputs route for compatibility.
app.mount(
    "/outputs",
    StaticFiles(
        directory="outputs",
    ),
    name="outputs",
)


# =====================================================
# Personal wardrobe clothing images
# =====================================================

app.mount(
    "/clothes",
    StaticFiles(
        directory="wardrobe",
    ),
    name="clothes",
)


# =====================================================
# Personal wardrobe thumbnails
# =====================================================

app.mount(
    "/clothes-thumbnails",
    StaticFiles(
        directory="wardrobe_thumbnails",
    ),
    name="clothes-thumbnails",
)


# =====================================================
# Commercial wardrobe images
# =====================================================

app.mount(
    "/commercial-images",
    StaticFiles(
        directory="database/commercial",
    ),
    name="commercial-images",
)


# =====================================================
# API routers
# =====================================================

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

app.include_router(
    commercial.router,
)


# =====================================================
# Root endpoint
# =====================================================

@app.get("/")
def home() -> dict[str, str]:
    return {
        "message": "AI Styling Agent API running",
    }