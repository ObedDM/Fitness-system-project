from fastapi import HTTPException
from fastapi.responses import FileResponse
from pathlib import Path

def get_image(filename: str) -> FileResponse:
    IMAGES_DIR = Path("backend/assets/images/dish")
    
    for ext in ['.jpg', '.jpeg', '.png', '.webp']:
        file_path = IMAGES_DIR / f"{filename}{ext}"
        if file_path.exists():
            return FileResponse(file_path)
    
    raise HTTPException(404, "Image not found")
