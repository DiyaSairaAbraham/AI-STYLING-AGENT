import base64
import mimetypes
import os

from openai import OpenAI

from config import (
    OPENAI_API_KEY,
    WARDROBE_MODEL,
)
from schemas.models import (
    WardrobeItemTags,
)
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY,
)


WARDROBE_PROMPT = """
Analyze this clothing item.

Return structured fashion metadata only.

Identify:

- category
- sub_category
- color
- material
- fit
- style
- pattern
- formality_level
- suitable_occasions

Do not invent information that cannot be reasonably
observed from the image.
"""


def analyze_wardrobe_item(
    image_path: str,
) -> WardrobeItemTags:

    log(
        f"Analyzing clothing item: {image_path}"
    )

    if not os.path.isfile(
        image_path
    ):
        raise FileNotFoundError(
            f"Wardrobe image not found: {image_path}"
        )

    with open(
        image_path,
        "rb",
    ) as file:
        base64_image = (
            base64.b64encode(
                file.read()
            ).decode("utf-8")
        )

    mime_type, _ = (
        mimetypes.guess_type(
            image_path
        )
    )

    if mime_type is None:
        mime_type = "image/jpeg"

    completion = (
        client.beta.chat.completions.parse(
            model=WARDROBE_MODEL,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": WARDROBE_PROMPT,
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": (
                                    f"data:{mime_type};"
                                    f"base64,{base64_image}"
                                ),
                            },
                        },
                    ],
                }
            ],
            response_format=WardrobeItemTags,
        )
    )

    result = (
        completion
        .choices[0]
        .message
        .parsed
    )

    if result is None:
        raise ValueError(
            "Wardrobe Agent returned no result."
        )

    log(
        "Clothing analysis completed"
    )

    return result


def analyze_wardrobe_folder(
    folder_path: str,
) -> list[WardrobeItemTags]:

    log(
        f"Scanning wardrobe folder: {folder_path}"
    )

    if not os.path.isdir(
        folder_path
    ):
        raise FileNotFoundError(
            f"Wardrobe folder not found: "
            f"{folder_path}"
        )

    valid_extensions = {
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
    }

    wardrobe = []

    filenames = sorted(
        os.listdir(
            folder_path
        )
    )

    for filename in filenames:

        extension = (
            os.path.splitext(
                filename
            )[1]
            .lower()
        )

        if extension not in valid_extensions:
            continue

        image_path = os.path.join(
            folder_path,
            filename,
        )

        log(
            f"Processing {filename}"
        )

        item = analyze_wardrobe_item(
            image_path
        )

        item = item.model_copy(
            update={
                "id_baju": (
                    os.path.splitext(
                        filename
                    )[0]
                )
            }
        )

        wardrobe.append(
            item
        )

    log(
        f"{len(wardrobe)} clothing items analyzed"
    )

    return wardrobe