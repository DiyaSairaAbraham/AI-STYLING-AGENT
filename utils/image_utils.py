import base64
from pathlib import Path


def encode_image(
    image_path: str,
) -> str:

    path = Path(
        image_path
    )

    if not path.is_file():
        raise FileNotFoundError(
            f"Image not found: {image_path}"
        )

    with path.open(
        "rb"
    ) as file:
        return base64.b64encode(
            file.read()
        ).decode("utf-8")


def save_image_bytes(
    image_bytes: bytes,
    output_path: str,
) -> None:

    path = Path(
        output_path
    )

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with path.open(
        "wb"
    ) as file:
        file.write(
            image_bytes
        )