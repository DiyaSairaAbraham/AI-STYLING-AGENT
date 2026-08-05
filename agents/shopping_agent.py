from urllib.parse import quote



# =====================================================
# SHOPPING LINK GENERATOR
# =====================================================

def create_search_links(outfit):


    items = []



    for item in outfit.selected_items:


        description = item.description.lower()



        # -------------------------------------
        # Extract useful shopping keywords
        # -------------------------------------

        useful_words = [

            # tops
            "shirt",
            "blouse",
            "top",
            "tshirt",
            "hoodie",
            "sweater",

            # bottoms
            "pant",
            "pants",
            "trouser",
            "trousers",
            "jeans",
            "shorts",
            "skirt",

            # outerwear
            "jacket",
            "blazer",
            "coat",
            "vest",
            "cardigan",

            # dresses
            "dress",
            "sundress",

            # footwear
            "shoe",
            "shoes",
            "sneaker",
            "sneakers",
            "sandal",
            "sandals",
            "heel",
            "heels",
            "pump",
            "pumps"

        ]



        words = description.split()



        keywords = []



        for word in words:


            clean_word = (
                word
                .replace(",", "")
                .replace(".", "")
                .replace("/", "")
            )



            if clean_word in useful_words:

                keywords.append(clean_word)



        # -------------------------------------
        # If category keywords found
        # keep a meaningful search phrase
        # -------------------------------------

        if keywords:


            search_phrase = " ".join(
                words[:8]
            )


        else:


            # fallback
            search_phrase = " ".join(
                words[:5]
            )



        encoded = quote(
            search_phrase
        )



        items.append(


            {

                "id_baju":
                    item.id_baju,


                "description":
                    item.description,


                "hm":
                    (
                        "https://www2.hm.com/en_us/"
                        f"search-results.html?q={encoded}"
                    ),


                "uniqlo":
                    (
                        "https://www.uniqlo.com/us/en/"
                        f"search?q={encoded}"
                    )

            }


        )



    return {


        "items":
            items


    }