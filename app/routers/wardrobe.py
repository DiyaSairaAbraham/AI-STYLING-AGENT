import os
import shutil

from fastapi import APIRouter, File, HTTPException, UploadFile

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

ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
    "application/octet-stream",
}

ALLOWED_EXTENSIONS = {
    ".jpg": ".jpg",
    ".jpeg": ".jpg",
    ".png": ".png",
    ".webp": ".webp",
}


def _validate_source(source: str) -> str:
    normalized = source.strip().lower()

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
        detail="source must be 'personal' or 'commercial'.",
    )


def _get_extension(
    filename: str,
    content_type: str | None,
) -> str:
    extension = os.path.splitext(filename)[1].lower()

    if extension in ALLOWED_EXTENSIONS:
        return ALLOWED_EXTENSIONS[extension]

    mime_to_extension = {
        "image/jpeg": ".jpg",
        "image/jpg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
        "application/octet-stream": ".jpg",
    }

    if content_type in mime_to_extension:
        return mime_to_extension[content_type]

    raise HTTPException(
        status_code=400,
        detail=(
            "Unsupported image format. "
            "Please select a JPG, JPEG, PNG or WEBP image."
        ),
    )


@router.post("/build/{source}")
def build_wardrobe(source: str):
    source = _validate_source(source)

    try:
        result = build_wardrobe_database(source)

        return {
            "status": "success",
            "source": source,
            "message": "Wardrobe database created.",
            "count": len(result),
            "items": result,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to build wardrobe.",
                "error": str(exc),
            },
        ) from exc


@router.get("/{source}")
def get_wardrobe(source: str):
    source = _validate_source(source)

    try:
        wardrobe = list_wardrobe(source)

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


@router.post("/add/{source}")
async def add_item(
    source: str,
    file: UploadFile = File(...),
):
    source = _validate_source(source)

    filename = file.filename or "wardrobe_item.jpg"

    extension = _get_extension(
        filename,
        file.content_type,
    )

    os.makedirs(
        UPLOAD_DIR,
        exist_ok=True,
    )

    safe_filename = (
        f"wardrobe_upload_{os.urandom(8).hex()}"
        f"{extension}"
    )

    image_path = os.path.join(
        UPLOAD_DIR,
        safe_filename,
    )

    try:
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(
                file.file,
                buffer,
            )

        if os.path.getsize(image_path) == 0:
            raise HTTPException(
                status_code=400,
                detail="Uploaded image is empty.",
            )

        wardrobe = add_wardrobe_item(
            image_path,
            source,
        )

        return {
            "status": "success",
            "source": source,
            "message": "Wardrobe item added.",
            "items": wardrobe,
        }

    except HTTPException:
        raise

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc


@router.delete("/{source}/{item_id}")
def delete_item(
    source: str,
    item_id: str,
):
    source = _validate_source(source)

    if not item_id.strip():
        raise HTTPException(
            status_code=400,
            detail="item_id cannot be empty.",
        )

    try:
        print(
            f"[WARDROBE DELETE] source={source}, "
            f"item_id={item_id}"
        )

        wardrobe = remove_wardrobe_item(
            item_id,
            source,
        )

        return {
            "status": "success",
            "source": source,
            "message": "Wardrobe item removed.",
            "items": wardrobe,
        }

    except ValueError as exc:
        raise HTTPException(
            status_code=404,
            detail=str(exc),
        ) from exc

    except Exception as exc:
        print(
            f"[WARDROBE DELETE ERROR] {exc}"
        )

        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc