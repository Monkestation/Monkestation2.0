#dont use vsc to run this
from json import loads, dumps
#path to base_tracks.json
track_file_name = "base_tracks.json"
track_file = open(track_file_name, "r").read()
track_json = loads(track_file)

url_buffer = []
track_buffer = {}
def check_url(url:str):
    if(url[-3:] != "mp3"):
        print(f"{song['title']}:\n{url} is wrong file type. convert to mp3 for consistancy")
    if url in url_buffer:
        print(f"duplicate url at {song['title']}")

for song in track_json:
    check_url(song['url'])
    track_buffer[song['title']] = song #change title to whatever you want to sort by ex:"duration"
track_buffer = dict(sorted(track_buffer.items()))
track_json = []
for i in track_buffer:
   track_json.append(track_buffer[i])

track_file = open(track_file_name, "w")
track_file.write(dumps(track_json, indent='\t'))

