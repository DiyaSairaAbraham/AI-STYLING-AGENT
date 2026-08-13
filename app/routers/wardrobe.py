import os
import shutil

from fastapi import (
    APIRouter,
    File,
    HTTPException,
    UploadFile,
)

from utils.wardrobe_manager import (
    add_wardrobe_item,
    build_wardrobe_database,
    list_wardrobe,
    remove_wardrobe_item,
)


router = APIRouter(
    prefix="/wardrobe",
    tags=["Wardrobe"],
)


UPLOAD_DIR = "uploads"


def _validate_source(
    source: str,
) -> str:

    normalized = (
        source.strip().lower()
    )

    if normalized in {
        "personal",
        "wardrobe_1",
        "1",
    }:
        return "personal"

    if normalized in {
        "commercial",
        "wardrobe_2",
        "2",
    }:
        return "commercial"

    raise HTTPException(
        status_code=400,
        detail=(
            "source must be "
            "'personal' or 'commercial'."
        ),
    )


# ============================================================
# BUILD
# ============================================================


@router.post(
    "/build/{source}",
)
def build_wardrobe(
    source: str,
):

    source = _validate_source(
        source
    )

    try:
        result = (
            build_wardrobe_database(
                source
            )
        )

        return {
            "status": "success",
            "source": source,
            "message": (
                "Wardrobe database created."
            ),
            "count": len(result),
            "items": result,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": (
                    "Unable to build wardrobe."
                ),
                "error": str(exc),
            },
        ) from exc


# ============================================================
# LIST
# ============================================================


@router.get(
    "/{source}",
)
def get_wardrobe(
    source: str,
):

    source = _validate_source(
        source
    )

    try:
        wardrobe = list_wardrobe(
            source
        )

        return {
            "status": "success",
            "source": source,
            "count": len(wardrobe),
            "items": wardrobe,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc


# ============================================================
# ADD
# ============================================================


@router.post(
    "/add/{source}",
)
async def add_item(
    source: str,
    file: UploadFile = File(...),
):

    source = _validate_source(
        source
    )

    allowed_types = {
        "image/jpeg",
        "image/png",
        "image/webp",
        "application/octet-stream",
    }

    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=(
                "Only JPG, PNG and WEBP "
                "images are allowed."
            ),
        )

    os.makedirs(
        UPLOAD_DIR,
        exist_ok=True,
    )

    filename = (
        file.filename
        or "wardrobe_item.jpg"
    )

    image_path = os.path.join(
        UPLOAD_DIR,
        filename,
    )

    try:
        with open(
            image_path,
            "wb",
        ) as buffer:
            shutil.copyfileobj(
                file.file,
                buffer,
            )

        wardrobe = (
            add_wardrobe_item(
                image_path,
                source,
            )
        )

        return {
            "status": "success",
            "source": source,
            "message": (
                "Wardrobe item added."
            ),
            "wardrobe": wardrobe,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc


# ============================================================
# DELETE
# ============================================================


@router.delete(
    "/{source}/{item_id}",
)
def delete_item(
    source: str,
    item_id: str,
):

    source = _validate_source(
        source
    )

    try:
        wardrobe = (
            remove_wardrobe_item(
                item_id,
                source,
            )
        )

        return {
            "status": "success",
            "source": source,
            "message": (
                "Wardrobe item removed."
            ),
            "items": wardrobe,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc