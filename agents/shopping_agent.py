from urllib.parse import quote

from schemas.models import ShoppingLinks, ShoppingItemLink


def create_search_links(outfit) -> ShoppingLinks:
    """
    Create H&M and UNIQLO search links for the newly generated outfit.

    Function 1 does not use personal or commercial wardrobe items.
    Therefore, links are generated from the stylist's outfit description.
    """

    search_items: list[ShoppingItemLink] = []

    descriptions = _extract_outfit_items(outfit)

    for description in descriptions:
        encoded = quote(description)

        search_items.append(
            ShoppingItemLink(
                description=description,
                hm=(
                    "https://www2.hm.com/en_us/"
                    f"search-results.html?q={encoded}"
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


def _extract_outfit_items(outfit) -> list[str]:
    """
    Convert the stylist recommendation into useful individual
    shopping-search descriptions.
    """

    if hasattr(outfit, "shopping_items"):
        return [
            item.strip()
            for item in outfit.shopping_items
            if item and item.strip()
        ]

    return [
        outfit.category,
        outfit.styling_advice,
    ]