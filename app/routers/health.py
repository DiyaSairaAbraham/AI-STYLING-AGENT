from fastapi import APIRouter


router = APIRouter(
    prefix="/health",
    tags=["Health"],
)


@router.get("/")
def home() -> dict[str, str]:
    return {
        "message": (
            "AI Fashion Stylist API is running."
        )
    }


@router.get("")
def health() -> dict[str, str]:
    return {
        "status": "healthy"
    }