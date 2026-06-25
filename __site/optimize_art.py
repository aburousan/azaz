import os
import glob
from PIL import Image

def optimize_images(input_dir, output_dir=None):
    if output_dir is None:
        output_dir = input_dir
        
    os.makedirs(output_dir, exist_ok=True)
    
    # Supported image formats
    extensions = ["*.jpeg", "*.jpg", "*.png"]
    image_paths = []
    for ext in extensions:
        image_paths.extend(glob.glob(os.path.join(input_dir, ext)))
        # uppercase extensions
        image_paths.extend(glob.glob(os.path.join(input_dir, ext.upper())))
        
    for path in image_paths:
        try:
            img = Image.open(path)
            basename = os.path.basename(path)
            name, _ = os.path.splitext(basename)
            webp_path = os.path.join(output_dir, f"{name}.webp")
            
            # Save as webp if it doesn't already exist or if we want to overwrite
            if not os.path.exists(webp_path):
                img.save(webp_path, "WEBP", quality=80, optimize=True)
                print(f"Optimized: {basename} -> {name}.webp")
            
        except Exception as e:
            print(f"Failed to optimize {path}: {e}")

if __name__ == "__main__":
    optimize_images("_assets/art/")
