import urllib.request
import base64
import json

url = "https://actions.google.com/sounds/v1/animals/cat_purr_close.ogg"
# Wait, Google's sound library has OGG. Let me use an MP3 URL.
# Actually, I can use an HTML5 data URI with MP3.
url = "https://raw.githubusercontent.com/mathiasbynens/small/master/mp3.mp3" # just testing
