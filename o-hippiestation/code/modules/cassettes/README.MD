# How to download lobby music
>We hold our lobby music in very high regard so dont be suprised if your song is rejected
#### prerequisites
add these to PATH as well
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/)
## steps
1. find a high quality verson of the song on youtube, soundclound, or **bandcamp**

2. download some sites offer mp3 downloads, some dont. If not, open up the command prompt and enter the following commands

`yt-dlp -x ENTER_URL_HERE`

this should output a file in whatever directory your operating in. If its saved as an mp3, can skip the next command

`ffmpeg -i filesaved.extension filesaved.mp3`

3. upload to file open a browser and navigate to [CatBox](https://catbox.moe/) and upload the mp3
4. copy the url and add a new entry to base_tracks.json.
you can use this template if you are retarded (dont forget the comma carlospaul)
```json
	{
		"url": "URL_HERE",
		"title": "SONG_NAME_HERE",
		"duration": 1230 (seconds*10),
		"artist": "ARTIST_NAME_HERE",
		"secret": false,
		"lobby": true,
		"jukebox": true,
		"genre": "HippieTracks"
	}
```
5. run sort_tracks.py to sort the tracks alphabetically and ensure there are no duplicates/wrong files
6.  if the song intro is really long or its really quiet, use [audacity](https://github.com/audacity/audacity) to cut the intro or adjust the volume
