from fastapi import APIRouter, UploadFile, File, HTTPException, Form
import shutil
import os

from agents.vision_agent import analyze_user_image


router = APIRouter(
    prefix="/vision",
    tags=["Vision"]
)


UPLOAD_DIR = "uploads"


@router.post("/analyze")
async def analyze_image(
    file: UploadFile = File(...),
    style_type: str = Form(...)
):

    try:

        # Validate file type
        allowed_types = [
            "image/jpeg",
            "image/png",
            "image/webp"
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


        # Save uploaded image
        with open(
            image_path,
            "wb"
        ) as buffer:

            shutil.copyfileobj(
                file.file,
                buffer
            )


        print(
            "[INFO] Running Vision Agent"
        )


        result = analyze_user_image(
        image_path=image_path,
        style_type=style_type
        )


        print(
            "[INFO] Vision completed"
        )


        return {

            "status": "success",

            "message":
            "Vision analysis completed",

            "profile":
            result.model_dump()

        }


    except HTTPException:
        raise

    except Exception as e:

        print(
            f"[ERROR] Vision failed: {str(e)}"
        )

        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Vision analysis failed",
                "error": str(e)
            }
        )