import os
import re

disqus_pattern = re.compile(
    r'~~~\s*<div id="disqus_thread"></div>\s*<script>.*?var d = document, s = d\.createElement\(\'script\'\);.*?</noscript>\s*~~~',
    re.DOTALL
)

disqus_pattern_no_tilde = re.compile(
    r'<div id="disqus_thread"></div>\s*<script>.*?var d = document, s = d\.createElement\(\'script\'\);.*?</noscript>',
    re.DOTALL
)

for root, dirs, files in os.walk("Pages"):
    for file in files:
        if file.endswith(".md"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content, count = disqus_pattern.subn('{{comments}}', content)
            if count == 0:
                new_content, count = disqus_pattern_no_tilde.subn('{{comments}}', content)
            
            if count > 0:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Replaced Disqus in {filepath}")
