from decouple import config
import requests
import json

def search_food(query, api_key):
    url = "https://api.nal.usda.gov/fdc/v1/foods/search"

    params = {
        "api_key": api_key,
        "query": query,
        "dataType": ["SR Legacy"], 
        "pageSize": 1,             
        "requireAllWords": "true"  
    }

    response = requests.get(url, params=params)

    if response.status_code == 200:
        data = response.json()
        foods = data.get("foods", [])
        
        if not foods:
            print("No results found.")
            return
        
        # --- EXPORT TO JSON FILE ---
        output_file = "food_debug.json"
        with open(output_file, "w", encoding="utf-8") as f:
            # indent=4 makes it readable; ensure_ascii=False handles special characters properly
            json.dump(foods[0], f, indent=4, ensure_ascii=False)
            
        print(f"Success! JSON exported to '{output_file}'")
        # ---------------------------

    else:
        print(f"Error: {response.status_code}")
        print(response.text)


USDA_KEY = config("FOOD_DATA_CENTRAL_KEY")
search_food("raw chicken breast", USDA_KEY)