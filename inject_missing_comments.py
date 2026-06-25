import os

dirs_to_check = [
    "Pages/Physics/blogs",
    "Pages/Maths/blogs"
]

for dir_path in dirs_to_check:
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if file.endswith(".md"):
                filepath = os.path.join(root, file)
                
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # If comments are missing, append them!
                if '{{comments}}' not in content:
                    # Append it before the very last line if the last line is HTML like <button>
                    # But simpler: just append it at the bottom.
                    with open(filepath, 'a', encoding='utf-8') as f:
                        f.write('\n\n{{comments}}\n')
                    print(f"Added {{comments}} to {filepath}")
