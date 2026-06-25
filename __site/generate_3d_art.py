import os
import trimesh
from PIL import Image
import numpy as np

art_dir = "_assets/art"

# Process all images
for file in os.listdir(art_dir):
    if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif')):
        base_name = os.path.splitext(file)[0]
        glb_path = os.path.join(art_dir, base_name + ".glb")
        
        if os.path.exists(glb_path):
            continue
            
        img_path = os.path.join(art_dir, file)
        print(f"Processing {file} -> {base_name}.glb")
        
        try:
            with Image.open(img_path) as img:
                w, h = img.size
                aspect = w / h
                
            # Create a box. The front face will be Z+ 
            width = 3.0 * aspect
            height = 3.0
            depth = 0.1
            mesh = trimesh.creation.box(extents=[width, height, depth])
            
            # Box has 8 vertices, 12 faces. 
            # Default trimesh box doesn't have ideal UVs for a single image across the front face.
            # So let's create a custom plane (2 triangles, 4 vertices)
            
            vertices = np.array([
                [-width/2, -height/2, 0.0],
                [ width/2, -height/2, 0.0],
                [-width/2,  height/2, 0.0],
                [ width/2,  height/2, 0.0]
            ])
            faces = np.array([
                [0, 1, 2],
                [1, 3, 2]
            ])
            # UVs map bottom-left (0,0) to top-right (1,1)
            uvs = np.array([
                [0.0, 0.0],
                [1.0, 0.0],
                [0.0, 1.0],
                [1.0, 1.0]
            ])
            
            # Create the mesh
            plane = trimesh.Trimesh(vertices=vertices, faces=faces, process=False)
            
            # Apply texture
            # Convert image to RGB (GLTF doesn't support some formats natively as well as jpeg/png)
            # Actually GLTF natively supports JPEG and PNG. WebP is supported via extension but might fail in trimesh export.
            # We will convert the image to PNG in memory for the GLB export
            with Image.open(img_path) as img:
                if img.mode != 'RGB' and img.mode != 'RGBA':
                    img = img.convert('RGBA')
                
                material = trimesh.visual.material.PBRMaterial(
                    baseColorTexture=img,
                    roughnessFactor=0.8,
                    metallicFactor=0.1
                )
                
                visuals = trimesh.visual.TextureVisuals(uv=uvs, image=img, material=material)
                plane.visual = visuals
                
            # Export to GLB
            plane.export(glb_path, file_type='glb')
            print(f"Successfully generated 3D plane for {file}")
            
        except Exception as e:
            print(f"Failed to process {file}: {e}")
