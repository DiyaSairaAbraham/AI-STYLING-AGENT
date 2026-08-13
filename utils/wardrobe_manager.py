import os
import shutil

from utils.json_utils import (
    load_json,
    save_json,
)

from agents.wardrobe_agent import (
    analyze_wardrobe_folder,
    analyze_wardrobe_item,
)


PERSONAL_WARDROBE_FOLDER = "wardrobe"
COMMERCIAL_WARDROBE_FOLDER = "wardrobe_2"

PERSONAL_WARDROBE_FILE = (
    "outputs/json/personal_wardrobe.json"
)

COMMERCIAL_WARDROBE_FILE = (
    "outputs/json/commercial_wardrobe.json"
)


def _get_wardrobe_paths(
    source: str,
) -> tuple[str, str]:
    normalized = source.lower().strip()

    if normalized in {
        "personal",
        "wardrobe_1",
        "1",
    }:
        return (
            PERSONAL_WARDROBE_FOLDER,
            PERSONAL_WARDROBE_FILE,
        )

    if normalized in {
        "commercial",
        "wardrobe_2",
        "2",
    }:
        return (
            COMMERCIAL_WARDROBE_FOLDER,
            COMMERCIAL_WARDROBE_FILE,
        )

    raise ValueError(
        "Wardrobe source must be "
        "'personal' or 'commercial'."
    )


def build_wardrobe_database(
    source: str,
) -> list[dict]:
    """
    Build the selected wardrobe database.

    personal:
        wardrobe_1/

    commercial:
        wardrobe_2/
    """

    folder_path, wardrobe_file = (
        _get_wardrobe_paths(source)
    )

    print(
        f"[INFO] Building {source} wardrobe..."
    )

    if not os.path.exists(
        folder_path
    ):
        raise FileNotFoundError(
            f"Wardrobe folder not found: "
            f"{folder_path}"
        )

    wardrobe_items = (
        analyze_wardrobe_folder(
            folder_path
        )
    )

    wardrobe = []

    image_extensions = (
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
    )

    for item in wardrobe_items:
        try:
            image_url = None
            image_file_path = None

            for ext in image_extensions:
                possible = os.path.join(
                    folder_path,
                    f"{item.id_baju}{ext}",
                )

                if os.path.exists(
                    possible
                ):
                    image_file_path = possible

                    image_url = (
                        f"/clothes/{source}/"
                        f"{os.path.basename(possible)}"
                    )

                    break

            if image_file_path is None:
                print(
                    f"[WARNING] Image missing for "
                    f"{item.id_baju}"
                )
                continue

            item = item.model_copy(
                update={
                    "image_path": image_url,
                }
            )

            wardrobe.append(
                item.model_dump()
            )

            save_json(
                wardrobe,
                wardrobe_file,
            )

        except Exception as exc:
            print(
                f"[WARNING] Skipping "
                f"{item.id_baju}: {exc}"
            )

    print(
        f"[INFO] {source} wardrobe contains "
        f"{len(wardrobe)} items."
    )

    return wardrobe


def add_wardrobe_item(
    image_path: str,
    source: str = "personal",
) -> list[dict]:
    """
    Add one image to the selected wardrobe.
    """

    folder_path, wardrobe_file = (
        _get_wardrobe_paths(source)
    )

    wardrobe = (
        load_json(
            wardrobe_file
        )
        or []
    )

    os.makedirs(
        folder_path,
        exist_ok=True,
    )

    filename = os.path.basename(
        image_path
    )

    destination = os.path.join(
        folder_path,
        filename,
    )

    if os.path.abspath(
        image_path
    ) != os.path.abspath(
        destination
    ):
        shutil.copy(
            image_path,
            destination,
        )

    item = analyze_wardrobe_item(
        destination
    )

    item = item.model_copy(
        update={
            "id_baju": (
                os.path.splitext(filename)[0]
            ),
            "image_path": (
                f"/clothes/{source}/"
                f"{filename}"
            ),
        }
    )

    wardrobe = [
        cloth
        for cloth in wardrobe
        if cloth["id_baju"]
        != item.id_baju
    ]

    wardrobe.append(
        item.model_dump()
    )

    save_json(
        wardrobe,
        wardrobe_file,
    )

    return wardrobe


def remove_wardrobe_item(
    item_id: str,
    source: str = "personal",
) -> list[dict]:

    folder_path, wardrobe_file = (
        _get_wardrobe_paths(source)
    )

    wardrobe = (
        load_json(
            wardrobe_file
        )
        or []
    )

    item_to_remove = next(
        (
            item
            for item in wardrobe
            if item["id_baju"]
            == item_id
        ),
        None,
    )

    if item_to_remove is None:
        return wardrobe

    image_url = item_to_remove.get(
        "image_path"
    )

    if image_url:
        filename = os.path.basename(
            image_url
        )

        image_path = os.path.join(
            folder_path,
            filename,
        )

        if os.path.exists(
            image_path
        ):
            os.remove(
                image_path
            )

    wardrobe = [
        item
        for item in wardrobe
        if item["id_baju"]
        != item_id
    ]

    save_json(
        wardrobe,
        wardrobe_file,
    )

    return wardrobe


def list_wardrobe(
    source: str = "personal",
) -> list[dict]:

    _, wardrobe_file = (
        _get_wardrobe_paths(source)
    )

    return (
        load_json(
            wardrobe_file
        )
        or []
    )


def get_wardrobe_image_paths(
    source: str,
    item_ids: list[str],
) -> list[str]:
    """
    Convert selected wardrobe IDs into actual
    local image paths.
    """

    folder_path, wardrobe_file = (
        _get_wardrobe_paths(source)
    )

    wardrobe = (
        load_json(
            wardrobe_file
        )
        or []
    )

    lookup = {
        item["id_baju"]: item
        for item in wardrobe
    }

    paths = []

    for item_id in item_ids:
        item = lookup.get(
            item_id
        )

        if item is None:
            raise ValueError(
                f"Wardrobe item not found: "
                f"{item_id}"
            )

        image_url = item.get(
            "image_path"
        )

        if not image_url:
            raise ValueError(
                f"No image path stored for "
                f"{item_id}"
            )

        filename = os.path.basename(
            image_url
        )

        image_path = os.path.join(
            folder_path,
            filename,
        )

        if not os.path.isfile(
            image_path
        ):
            raise FileNotFoundError(
                f"Wardrobe image missing: "
                f"{image_path}"
            )

        paths.append(
            image_path
        )

    return paths