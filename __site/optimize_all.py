import os
from PIL import Image

def optimize_images():
    assets_dir = "_assets"
    
    if not os.path.exists(assets_dir):
        print(f"Directory {assets_dir} does not exist.")
        return
        
    # Track conversions to update references later
    conversions = {}
    
    for root, dirs, files in os.walk(assets_dir):
        for file in files:
            ext = os.path.splitext(file)[1].lower()
            if ext in ['.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG']:
                original_path = os.path.join(root, file)
                new_filename = os.path.splitext(file)[0] + ".webp"
                new_path = os.path.join(root, new_filename)
                
                # Skip if a webp version already exists just in case
                if os.path.exists(new_path) and original_path != new_path:
                    # We still want to map the name to update links just in case
                    conversions[file] = new_filename
                    conversions[file.replace(" ", "%20")] = new_filename.replace(" ", "%20")
                    os.remove(original_path)
                    print(f"Removed redundant: {original_path}")
                    continue
                
                try:
                    with Image.open(original_path) as img:
                        # Ensure we convert properly if we need to save as WebP
                        img.save(new_path, "WEBP", quality=85)
                        
                    os.remove(original_path)
                    print(f"Optimized: {original_path} -> {new_path}")
                    
                    conversions[file] = new_filename
                    conversions[file.replace(" ", "%20")] = new_filename.replace(" ", "%20")
                    
                except Exception as e:
                    print(f"Failed to optimize {original_path}: {e}")

    if not conversions:
        print("No images needed optimization.")
        return

    print(f"Updating references for {len(conversions)} mapped filenames...")
    
    for root, dirs, files in os.walk("."):
        if "__site" in root or ".git" in root or "node_modules" in root:
            continue
            
        for file in files:
            ext = os.path.splitext(file)[1].lower()
            if ext in ['.md', '.html', '.jl', '.css']:
                filepath = os.path.join(root, file)
                
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                    new_content = content
                    for old_name, new_name in conversions.items():
                        new_content = new_content.replace(old_name, new_name)
                        
                    if new_content != content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f"Updated references in: {filepath}")
                except Exception as e:
                    # Ignore binary files or files that can't be decoded
                    pass

if __name__ == "__main__":
    optimize_images()
