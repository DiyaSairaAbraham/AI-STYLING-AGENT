import os
import shutil

from fastapi import APIRouter, File, HTTPException, UploadFile

from utils.wardrobe_manager import (
    add_wardrobe_item,
    list_wardrobe,
    remove_wardrobe_item,
)


router = APIRouter(
    prefix="/wardrobe",
    tags=["Wardrobe"],
)


UPLOAD_DIR = "uploads"

ALLOWED_IMAGE_TYPES: set[str] = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "application/octet-stream",
}


# =====================================================
# Add personal wardrobe item
# =====================================================

@router.post("/add")
async def add_item(
    file: UploadFile = File(...),
) -> dict:
    try:
        if file.content_type not in ALLOWED_IMAGE_TYPES:
            raise HTTPException(
                status_code=400,
                detail="Only JPG, PNG and WEBP images are allowed.",
            )

        if not file.filename:
            raise HTTPException(
                status_code=400,
                detail="No filename was provided.",
            )

        os.makedirs(
            UPLOAD_DIR,
            exist_ok=True,
        )

        filename = os.path.basename(file.filename)

        image_path = os.path.join(
            UPLOAD_DIR,
            filename,
        )

        with open(
            image_path,
            "wb",
        ) as buffer:
            shutil.copyfileobj(
                file.file,
                buffer,
            )

        wardrobe = add_wardrobe_item(
            image_path,
        )

        return {
            "status": "success",
            "message": "Wardrobe item added",
            "wardrobe": wardrobe,
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(
            f"[ERROR] Add wardrobe item failed: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to add wardrobe item",
                "error": str(exc),
            },
        ) from exc


# =====================================================
# List personal wardrobe
# =====================================================

@router.get("/")
def get_wardrobe() -> dict:
    try:
        wardrobe = list_wardrobe()

        return {
            "status": "success",
            "count": len(wardrobe),
            "items": wardrobe,
        }

    except Exception as exc:
        print(
            f"[ERROR] Unable to load wardrobe: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to load wardrobe",
                "error": str(exc),
            },
        ) from exc


# =====================================================
# Remove personal wardrobe item
# =====================================================

@router.delete("/{item_id}")
def delete_item(
    item_id: str,
) -> dict:
    try:
        if not item_id.strip():
            raise HTTPException(
                status_code=400,
                detail="Wardrobe item ID cannot be empty.",
            )

        wardrobe = remove_wardrobe_item(
            item_id,
        )

        return {
            "status": "success",
            "message": "Wardrobe item removed",
            "items": wardrobe,
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(
            f"[ERROR] Remove wardrobe item failed: {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to remove wardrobe item",
                "error": str(exc),
            },
        ) from exc