import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.abspath(os.path.join(current_dir, '../../../')))

from typing import List
from database.connection import get_session
from backend.services.ingredients.ingredients import add_micronutrient
from backend.schemas.micronutrient import MicronutrientCreate
import csv

INPUT_FILE = 'nutrient.csv'

TARGET_NUTRIENTS = {
    "1008": "Energy",       

    "1003": "Protein",      
    "1004": "Fat",          
    "1005": "Carbohydrate", 
    "1051": "Water",        
    "1018": "Alcohol",      

    "1079": "Fiber",        
    "2000": "Sugar",        
    "1009": "Starch",       

    "1258": "Saturated Fat",
    "1292": "Monounsaturated",
    "1293": "Polyunsaturated",
    "1253": "Cholesterol",

    "1093": "Sodium",
    "1092": "Potassium",
    "1087": "Calcium",
    "1090": "Magnesium",
    "1089": "Iron",
    "1095": "Zinc",

    "1162": "Vitamin C",
    "1104": "Vitamin A",
    "1114": "Vitamin D",
}

def get_nutrients():
    nutrient_list = []

    try:
        with open(INPUT_FILE, mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            for nutrient in reader:
                n_id = nutrient['id']
                
                if n_id in TARGET_NUTRIENTS:
                    name = TARGET_NUTRIENTS[n_id]
                    unit = nutrient['unit_name'].lower()
                    usda_id = n_id

                    nutrient_dict = {
                        'name': name,
                        'category': None,
                        'unit': unit,
                        'usda_id': int(usda_id)
                    }
                    
                    nutrient_list.append(
                        MicronutrientCreate(**nutrient_dict)
                    )

    except FileNotFoundError:
        print(f"Error: Could not find '{INPUT_FILE}'. Put it in the same folder.")

    return nutrient_list


def set_nutrients(nutrients: List[MicronutrientCreate]):

    db_gen = get_session()
    session = next(db_gen)

    try:
        for nutrient in nutrients:

            try:
                add_micronutrient(nutrient, session)

            except Exception:
                pass         

    finally:
        next(db_gen, None)


nutrients = get_nutrients()
print(nutrients)

set_nutrients(nutrients)
