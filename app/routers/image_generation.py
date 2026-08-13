import os
import uuid

from fastapi import (
    APIRouter,
    HTTPException,
    Request,
)
from pydantic import BaseModel

from agents.image_agent import (
    generate_outfit_image,
)


router = APIRouter(
    prefix="/image",
    tags=["Image Generation"],
)


class ImageGenerationRequest(BaseModel):
    prompt: str
    user_image_path: str
    wardrobe_image_paths: list[str] = []


@router.post(
    "/generate",
)
async def generate_image(
    request: ImageGenerationRequest,
    http_request: Request,
) -> dict[str, str]:

    if not os.path.isfile(
        request.user_image_path
    ):
        raise HTTPException(
            status_code=400,
            detail=(
                f"User image not found: "
                f"{request.user_image_path}"
            ),
        )

    output_dir = (
        "outputs/images"
    )

    os.makedirs(
        output_dir,
        exist_ok=True,
    )

    image_name = (
        f"outfit_{uuid.uuid4().hex}.png"
    )

    output_path = os.path.join(
        output_dir,
        image_name,
    )

    try:
        image_path = (
            generate_outfit_image(
                prompt=request.prompt,
                user_image_path=(
                    request.user_image_path
                ),
                output_path=output_path,
                wardrobe_image_paths=(
                    request.wardrobe_image_paths
                ),
            )
        )

        filename = os.path.basename(
            image_path
        )

        image_url = (
            str(
                http_request.base_url
            ).rstrip("/")
            + f"/images/{filename}"
        )

        return {
            "status": "success",
            "message": (
                "Image generated."
            ),
            "image_url": image_url,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc