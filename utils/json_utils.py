import json
import os
from typing import Any


def load_json(
    path: str,
) -> Any:

    if not os.path.exists(
        path
    ):
        return None

    if os.path.getsize(
        path
    ) == 0:
        return None

    with open(
        path,
        "r",
        encoding="utf-8",
    ) as file:
        return json.load(
            file
        )


def save_json(
    data: Any,
    path: str,
) -> None:

    directory = os.path.dirname(
        path
    )

    if directory:
        os.makedirs(
            directory,
            exist_ok=True,
        )

    with open(
        path,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            data,
            file,
            indent=4,
            ensure_ascii=False,
        )