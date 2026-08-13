import base64
import os
from typing import Sequence

from openai import OpenAI

from config import (
    OPENAI_API_KEY,
    IMAGE_MODEL,
)
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY,
)


def generate_outfit_image(
    prompt: str,
    user_image_path: str,
    output_path: str,
    wardrobe_image_paths: Sequence[str] | None = None,
) -> str:
    """
    Generate a personalized outfit image.

    Function 1:
        user image is used as the visual reference.

    Function 2:
        user image + selected wardrobe images are supplied
        as references.
    """

    log(
        "Running Image Generator"
    )

    try:
        if not os.path.isfile(
            user_image_path
        ):
            raise FileNotFoundError(
                f"User image not found: {user_image_path}"
            )

        wardrobe_image_paths = (
            list(wardrobe_image_paths or [])
        )

        for image_path in wardrobe_image_paths:
            if not os.path.isfile(image_path):
                raise FileNotFoundError(
                    "Wardrobe image not found: "
                    f"{image_path}"
                )

        output_dir = os.path.dirname(
            output_path
        )

        if output_dir:
            os.makedirs(
                output_dir,
                exist_ok=True,
            )

        reference_files = []

        user_file = open(
            user_image_path,
            "rb",
        )

        reference_files.append(
            user_file
        )

        wardrobe_files = []

        try:
            for wardrobe_path in wardrobe_image_paths:
                wardrobe_file = open(
                    wardrobe_path,
                    "rb",
                )

                wardrobe_files.append(
                    wardrobe_file
                )

                reference_files.append(
                    wardrobe_file
                )

            response = client.images.edit(
                model=IMAGE_MODEL,
                image=reference_files,
                prompt=prompt,
                size="1024x1536",
            )

        finally:
            user_file.close()

            for wardrobe_file in wardrobe_files:
                wardrobe_file.close()

        if not response.data:
            raise RuntimeError(
                "Image generation returned no image data."
            )

        image_base64 = (
            response.data[0].b64_json
        )

        if not image_base64:
            raise RuntimeError(
                "Image generation returned empty image data."
            )

        with open(
            output_path,
            "wb",
        ) as output_file:
            output_file.write(
                base64.b64decode(
                    image_base64
                )
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