# Fitness System Project 🍽️💪

A fullstack fitness and nutrition platform integrating a Python (FastAPI) backend, a cross-platform Flutter frontend (deployed natively on a Linux ARM touchscreen kiosk), and a Raspberry Pi edge computing module. The system is designed to calculate precise nutritional and chemical compositions for both user and community-made dishes using real-time hardware weighing and official USDA FoodData Central API data.

The application logic and functionality have been fully reviewed and approved by a chemist and a professional nutritionist.

---

## Tech Stack 🛠️

- **Backend:** FastAPI, PyJWT, SQLModel, Alembic
- **Database:** PostgreSQL
- **Frontend:** Flutter
- **Hardware:** Raspberry Pi 4 Model B 4GB, HX711 Weight Sensor, Touchscreen Display
- **External APIs:** USDA FoodData Central API

---

## Features ✨

- **Hardware Integration:** Seamlessly processes real-time weighed ingredient/dish data from the Raspberry Pi and HX711 sensor, interacting directly through the native touchscreen kiosk.

- **Automated Composition Data:** Automatically populates accurate macronutrient, micronutrient, and chemical composition data using the USDA API.

- **Custom Dish Creation:** Allows users to build, save, and analyze custom dishes from individual ingredients with dynamically calculated totals.

- **Secure Architecture:** Built with robust JWT token authentication.

- **Consistent UI:** Built with reusable cards, modals, and bottom sheets to ensure a clean, responsive, and tactile experience for users.

---

## System Flow 🚀

1. Users authenticate directly from the physical device interface (kiosk mode) to securely access their profiles and saved data.

2. The edge device processes physical analog inputs from the weight sensor via a dedicated Linux background daemon, which continuously streams the weight value for the backend to monitor and read.

3. Users select pre-existing ingredients or dishes from the database. (New, unknown items are imported on-demand via the USDA API to retrieve their chemical composition and saved automatically in the database).

4. Upon selecting the target ingredient/dish, the user places the physical item on the sensor. The system calculates and visualizes the exact composition totals based on the specific weight proportion or serving size.
