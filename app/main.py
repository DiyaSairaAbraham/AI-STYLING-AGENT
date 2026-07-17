from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from app.routers import health
from app.routers import vision
from app.routers import wardrobe
from app.routers import recommendation


app = FastAPI(
    title="AI Stylist API"
)


# =========================
# Root Endpoint
# =========================

@app.get("/")
def root():

    return {
        "status": "success",
        "message": "AI Stylist API is running",
        "docs": "/docs",
        "health": "/health"
    }


# =========================
# Global Exception Handler
# =========================

@app.exception_handler(Exception)
async def global_exception_handler(
    request: Request,
    exc: Exception
):

    print(
        f"[ERROR] {request.url.path}: {exc}"
    )

    return JSONResponse(
        status_code=500,
        content={
            "status": "failed",
            "message": "Internal Server Error"
        }
    )


# =========================
# Routers
# =========================

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


# =========================
# Static Images
# =========================

app.mount(
    "/images",
    StaticFiles(
        directory="outputs/images"
    ),
    name="images"
)