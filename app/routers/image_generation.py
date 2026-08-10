import os
import uuid

from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel

from agents.image_agent import generate_outfit_image


router = APIRouter(
    prefix="/recommendation",
    tags=["Image Generation"],
)


class ImageGenerationRequest(BaseModel):
    prompt: str
    user_image_path: str


@router.post("/generate-image")
async def generate_selected_outfit(
    request: ImageGenerationRequest,
    http_request: Request,
) -> dict[str, str]:
    try:
        print("[INFO] Generating selected outfit image")

        if not os.path.exists(request.user_image_path):
            raise HTTPException(
                status_code=400,
                detail=f"Image not found: {request.user_image_path}",
            )

        output_dir = os.path.join(
            "outputs",
            "images",
        )

        os.makedirs(
            output_dir,
            exist_ok=True,
        )

        image_name = f"outfit_{uuid.uuid4().hex}.png"

        output_path = os.path.join(
            output_dir,
            image_name,
        )

        image_path = generate_outfit_image(
            prompt=request.prompt,
            user_image_path=request.user_image_path,
            output_path=output_path,
        )

        # Convert the local filesystem path into a URL
        # served by FastAPI's /images/ static route.
        image_filename = os.path.basename(image_path)

        image_url = str(
            http_request.base_url
        ).rstrip("/") + f"/images/{image_filename}"

        print(f"[INFO] Image URL: {image_url}")

        return {
            "status": "success",
            "message": "Outfit image generated",
            "image_url": image_url,
        }

    except HTTPException:
        raise

    except Exception as e:
        print(
            f"[ERROR] Image generation failed: {e}",
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        ) from e