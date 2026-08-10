from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import shutil

from utils.wardrobe_manager import (
    build_wardrobe_database,
    add_wardrobe_item,
    remove_wardrobe_item,
    list_wardrobe
)


router = APIRouter(
    prefix="/wardrobe",
    tags=["Wardrobe"]
)


UPLOAD_DIR = "uploads"


# =========================
# Build wardrobe database
# =========================

@router.post("/build")
def build_wardrobe():

    try:

        result = build_wardrobe_database(
            folder_path="wardrobe"
        )

        return {

            "status": "success",

            "message":
            "Wardrobe database created",

            "count":
            len(result),

            "items":
            result

        }

    except Exception as e:

        print(
            f"[ERROR] Wardrobe build failed: {str(e)}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to build wardrobe database",
                "error": str(e)
            }
        )


# =========================
# Add wardrobe item
# =========================

@router.post("/add")
async def add_item(
    file: UploadFile = File(...)
):

    try:

        
        allowed_types = [
            "image/jpeg",
            "image/png",
            "image/webp",
            "application/octet-stream"
        ]

        if file.content_type not in allowed_types:

            raise HTTPException(
                status_code=400,
                detail="Only JPG, PNG and WEBP images are allowed"
            )


        os.makedirs(
            UPLOAD_DIR,
            exist_ok=True
        )


        image_path = os.path.join(
            UPLOAD_DIR,
            file.filename
        )


        with open(
            image_path,
            "wb"
        ) as buffer:

            shutil.copyfileobj(
                file.file,
                buffer
            )


        wardrobe = add_wardrobe_item(
            image_path
        )


        return {

            "status": "success",

            "message":
            "Wardrobe item added",

            "wardrobe":
            wardrobe

        }

    except HTTPException:
        raise

    except Exception as e:

        print(
            f"[ERROR] Add wardrobe item failed: {str(e)}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to add wardrobe item",
                "error": str(e)
            }
        )


# =========================
# List wardrobe
# =========================

@router.get("")
def get_wardrobe():

    try:

        wardrobe = list_wardrobe()

        return {

            "status": "success",

            "count":
            len(wardrobe),

            "items":
            wardrobe

        }

    except Exception as e:

        print(
            f"[ERROR] Unable to load wardrobe: {str(e)}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to load wardrobe",
                "error": str(e)
            }
        )


# =========================
# Remove wardrobe item
# =========================

@router.delete("/{item_id}")
def delete_item(
    item_id: str
):

    try:

        wardrobe = remove_wardrobe_item(
            item_id
        )

        return {

            "status": "success",

            "message":
            "Wardrobe item removed",

            "items":
            wardrobe

        }

    except Exception as e:

        print(
            f"[ERROR] Remove wardrobe item failed: {str(e)}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Unable to remove wardrobe item",
                "error": str(e)
            }
        )