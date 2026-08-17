from fastapi import APIRouter

from utils.commercial_wardrobe_manager import (
    build_commercial_wardrobe_database,
    list_commercial_wardrobe
)

router = APIRouter(
    prefix="/commercial",
    tags=["Commercial Wardrobe"]
)


@router.post("/build")
def build_database():

    items = build_commercial_wardrobe_database()

    return {
        "status": "success",
        "count": len(items),
        "items": items
    }


@router.get("")
def get_commercial():

    items = list_commercial_wardrobe()

    return {
        "status": "success",
        "count": len(items),
        "items": items
    }