from fastapi import APIRouter


router = APIRouter(
    prefix="/health",
    tags=["Health"]
)


@router.get("/")
def home():

    return {
        "message": "AI Fashion Stylist API is running."
    }


@router.get("")
def health():

    return {
        "status": "healthy"
    }