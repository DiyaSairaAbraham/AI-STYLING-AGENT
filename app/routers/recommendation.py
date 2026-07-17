from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import shutil

from app.services.pipeline_service import run_full_pipeline


router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation"]
)


UPLOAD_DIR = "uploads"


@router.post("/generate")
async def generate_recommendation(
    user_image: UploadFile = File(...)
):

    try:

        os.makedirs(
            UPLOAD_DIR,
            exist_ok=True
        )


        image_path = os.path.join(
            UPLOAD_DIR,
            user_image.filename
        )


        # Save user image
        with open(
            image_path,
            "wb"
        ) as buffer:

            shutil.copyfileobj(
                user_image.file,
                buffer
            )


        print(
            "[INFO] Starting AI Stylist Pipeline"
        )


        # Run complete AI stylist pipeline
        result = run_full_pipeline(
            user_image_path=image_path,
            wardrobe_path="wardrobe"
        )


        print(
            "[INFO] Recommendation completed"
        )


        return {

            "status": "success",

            "message":
            "Outfit recommendation generated",

            "data":
            result

        }


    except Exception as e:


        print(
            f"[ERROR] Recommendation failed: {str(e)}"
        )


        raise HTTPException(

            status_code=500,

            detail={

                "status": "failed",

                "message":
                "Unable to generate outfit recommendation",

                "error":
                str(e)

            }

        )