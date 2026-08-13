from urllib.parse import quote

from schemas.models import (
    ShoppingLinks,
    ShoppingItemLink,
)


def create_search_links(
    outfit,
) -> ShoppingLinks:
    """
    Create H&M and UNIQLO search links for
    Function 1 AI-generated outfit items.
    """

    search_items: list[ShoppingItemLink] = []

    descriptions = _extract_outfit_items(
        outfit
    )

    for description in descriptions:
        encoded = quote(
            description
        )

        search_items.append(
            ShoppingItemLink(
                description=description,
                hm=(
                    "https://www2.hm.com/en_us/"
                    "search-results.html"
                    f"?q={encoded}"
                ),
                uniqlo=(
                    "https://www.uniqlo.com/us/en/"
                    f"search?q={encoded}"
                ),
            )
        )

    return ShoppingLinks(
        items=search_items
    )


def _extract_outfit_items(
    outfit,
) -> list[str]:
    if hasattr(
        outfit,
        "shopping_items",
    ):
        return [
            item.strip()
            for item in outfit.shopping_items
            if item and item.strip()
        ]

    return []