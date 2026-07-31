import os
import uuid

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from agents.image_agent import generate_outfit_image


router = APIRouter(
    prefix="/recommendation",
    tags=["Image Generation"]
)


class ImageGenerationRequest(BaseModel):

    prompt: str

    user_image_path: str



@router.post("/generate-image")
async def generate_selected_outfit(
    request: ImageGenerationRequest
):

    try:

        print(
            "[INFO] Generating selected outfit image"
        )


        # --------------------------------
        # Check user image exists
        # --------------------------------

        if not os.path.exists(
            request.user_image_path
        ):

            raise HTTPException(

                status_code=400,

                detail=f"Image not found: {request.user_image_path}"

            )



        # --------------------------------
        # Create unique output filename
        # --------------------------------

        os.makedirs(
            "outputs/images",
            exist_ok=True
        )


        image_name = (
            f"outfit_{uuid.uuid4().hex}.png"
        )


        output_path = os.path.join(

            "outputs",
            "images",
            image_name

        )



        # --------------------------------
        # Generate image
        # --------------------------------

        image_path = generate_outfit_image(

            prompt=request.prompt,

            user_image_path=request.user_image_path,

            output_path=output_path

        )



        # --------------------------------
        # Browser accessible URL
        # --------------------------------

        image_url = (

            "http://127.0.0.1:8000/"

            +

            image_path.replace("\\", "/")

        )



        return {


            "status": "success",


            "message":
            "Outfit image generated",


            "image_url":
            image_url

        }



    except HTTPException:

        raise



    except Exception as e:


        print(

            f"[ERROR] Image generation failed: {e}"

        )


        raise HTTPException(

            status_code=500,

            detail=str(e)

        )