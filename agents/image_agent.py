import base64
import os

from openai import OpenAI

from config import OPENAI_API_KEY, IMAGE_MODEL
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY,
)


def generate_outfit_image(
    prompt: str,
    user_image_path: str,
    output_path: str = "outputs/images/recommended_outfit.png",
) -> str:
    """Generate a personalized outfit image using the user's image as reference."""

    log("Running Image Generator (Module 4)")

    try:
        if not os.path.isfile(user_image_path):
            raise FileNotFoundError(
                f"User image not found: {user_image_path}"
            )

        output_dir = os.path.dirname(output_path)

        if output_dir:
            os.makedirs(
                output_dir,
                exist_ok=True,
            )

        with open(
            user_image_path,
            "rb",
        ) as image_file:
            response = client.images.edit(
                model=IMAGE_MODEL,
                image=[image_file],
                prompt=prompt,
                size="1024x1536",
            )

        if not response.data:
            raise RuntimeError(
                "Image generation returned no image data."
            )

        image_base64 = response.data[0].b64_json

        if not image_base64:
            raise RuntimeError(
                "Image generation returned empty image data."
            )

        with open(
            output_path,
            "wb",
        ) as output_file:
            output_file.write(
                base64.b64decode(image_base64)
            )

        log(
            f"Image saved to {output_path}"
        )

        return output_path

    except Exception as exc:
        log(
            f"Image generation failed: {str(exc)}"
        )
        raise