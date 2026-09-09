import json
from pathlib import Path
from typing import Any


HISTORY_FILE = Path("outputs/json/outfit_history.json")


def _ensure_history_directory() -> None:
    HISTORY_FILE.parent.mkdir(
        parents=True,
        exist_ok=True,
    )


def load_outfit_history() -> dict[str, Any]:
    """Load persistent outfit history from disk."""

    _ensure_history_directory()

    if not HISTORY_FILE.exists():
        return {
            "sessions": []
        }

    try:
        with open(
            HISTORY_FILE,
            "r",
            encoding="utf-8",
        ) as file:
            data = json.load(file)

        if not isinstance(data, dict):
            return {
                "sessions": []
            }

        if not isinstance(
            data.get("sessions"),
            list,
        ):
            data["sessions"] = []

        return data

    except (
        json.JSONDecodeError,
        OSError,
    ):
        return {
            "sessions": []
        }


def save_outfit_history(
    history: dict[str, Any],
) -> None:
    """Save persistent outfit history."""

    _ensure_history_directory()

    with open(
        HISTORY_FILE,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            history,
            file,
            indent=4,
            ensure_ascii=False,
        )


def get_used_combinations(
    style_type: str,
    wardrobe_source: str,
) -> list[list[str]]:
    """
    Return previously used wardrobe-item combinations.

    This is primarily useful for personal and commercial
    wardrobe-based styling.
    """

    history = load_outfit_history()

    combinations: list[list[str]] = []

    for session in history.get(
        "sessions",
        [],
    ):
        if not isinstance(session, dict):
            continue

        session_style = str(
            session.get("style_type", "")
        ).strip().lower()

        session_source = str(
            session.get("wardrobe_source", "")
        ).strip().lower()

        if session_style != style_type.strip().lower():
            continue

        if session_source != wardrobe_source.strip().lower():
            continue

        outfits = session.get(
            "outfits",
            [],
        )

        if not isinstance(outfits, list):
            continue

        for outfit in outfits:
            if not isinstance(outfit, dict):
                continue

            item_ids = outfit.get(
                "item_ids",
                [],
            )

            if not isinstance(item_ids, list):
                continue

            clean_ids = sorted(
                str(item_id)
                for item_id in item_ids
                if item_id
            )

            if clean_ids:
                combinations.append(clean_ids)

    return combinations


def get_outfit_history_for_stylist(
    style_type: str,
    wardrobe_source: str,
) -> list[dict[str, Any]]:
    """
    Return previous outfits for the same style.

    The stylist receives both wardrobe IDs and textual
    descriptions so history works for:
    - personal wardrobe
    - commercial wardrobe
    - AI/open-world styling
    """

    history = load_outfit_history()

    previous_outfits: list[dict[str, Any]] = []

    requested_style = style_type.strip().lower()
    requested_source = wardrobe_source.strip().lower()

    for session in history.get(
        "sessions",
        [],
    ):
        if not isinstance(session, dict):
            continue

        session_style = str(
            session.get("style_type", "")
        ).strip().lower()

        session_source = str(
            session.get("wardrobe_source", "")
        ).strip().lower()

        if session_style != requested_style:
            continue

        if session_source != requested_source:
            continue

        outfits = session.get(
            "outfits",
            [],
        )

        if not isinstance(outfits, list):
            continue

        for outfit in outfits:
            if not isinstance(outfit, dict):
                continue

            previous_outfits.append(
                {
                    "item_ids": outfit.get(
                        "item_ids",
                        [],
                    ),
                    "category": outfit.get(
                        "category",
                        "",
                    ),
                    "description": outfit.get(
                        "description",
                        "",
                    ),
                    "styling_advice": outfit.get(
                        "styling_advice",
                        "",
                    ),
                }
            )

    return previous_outfits


def save_new_combinations(
    style_type: str,
    wardrobe_source: str,
    combinations: list[list[str]],
) -> None:
    """
    Persist wardrobe-item combinations.

    Kept for compatibility with existing code.
    """

    if not combinations:
        return

    history = load_outfit_history()

    clean_outfits: list[dict[str, Any]] = []

    for combination in combinations:
        clean_ids = sorted(
            str(item_id)
            for item_id in combination
            if item_id
        )

        if not clean_ids:
            continue

        clean_outfits.append(
            {
                "item_ids": clean_ids,
                "category": "",
                "description": "",
                "styling_advice": "",
            }
        )

    if not clean_outfits:
        return

    history["sessions"].append(
        {
            "style_type": style_type,
            "wardrobe_source": wardrobe_source,
            "outfits": clean_outfits,
        }
    )

    save_outfit_history(history)


def save_generated_outfit(
    style_type: str,
    wardrobe_source: str,
    recommendation: Any,
) -> None:
    """
    Save a generated recommendation regardless of wardrobe source.

    This supports:
    - Personal wardrobe
    - Commercial wardrobe
    - AI/Open World styling
    """

    if hasattr(
        recommendation,
        "model_dump",
    ):
        recommendation = recommendation.model_dump()

    if not isinstance(
        recommendation,
        dict,
    ):
        return

    selected_items = recommendation.get(
        "selected_items",
        [],
    )

    if not isinstance(
        selected_items,
        list,
    ):
        selected_items = []

    item_ids: list[str] = []

    item_descriptions: list[str] = []

    for item in selected_items:
        if isinstance(item, dict):
            item_id = (
                item.get("id_baju")
                or item.get("id")
                or item.get("item_id")
            )

            if item_id:
                item_ids.append(
                    str(item_id)
                )

            description_parts = []

            for field in (
                "category",
                "color",
                "style",
                "material",
                "description",
                "name",
            ):
                value = item.get(field)

                if value:
                    description_parts.append(
                        str(value)
                    )

            if description_parts:
                item_descriptions.append(
                    " ".join(description_parts)
                )

        elif isinstance(item, str):
            item_descriptions.append(item)

    category = str(
        recommendation.get(
            "category",
            "",
        )
    )

    styling_advice = str(
        recommendation.get(
            "styling_advice",
            "",
        )
    )

    image_prompt = str(
        recommendation.get(
            "image_generation_prompt",
            "",
        )
    )

    description = "; ".join(
        item_descriptions
    )

    if not description:
        description = image_prompt

    outfit_record = {
        "item_ids": sorted(
            set(item_ids)
        ),
        "category": category,
        "description": description,
        "styling_advice": styling_advice,
    }

    history = load_outfit_history()

    history["sessions"].append(
        {
            "style_type": style_type,
            "wardrobe_source": wardrobe_source,
            "outfits": [
                outfit_record
            ],
        }
    )

    save_outfit_history(history)