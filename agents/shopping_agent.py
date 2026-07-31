from urllib.parse import quote


def create_search_links(outfit):

    search_terms = []

    for item in outfit.selected_items:
        search_terms.append(item.description)

    query = " ".join(search_terms)

    encoded = quote(query)

    return {
        "hm": f"https://www2.hm.com/en/search-results.html?q={encoded}",
        "uniqlo": f"https://www.uniqlo.com/search?q={encoded}"
    }