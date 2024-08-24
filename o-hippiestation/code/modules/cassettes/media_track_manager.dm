/datum/controller/subsystem/media_tracks/load_tracks()
	var/music_list = list(GLOB.jukebox_track_files, "monkestation/code/modules/cassettes/track_folder/base_tracks.json")
	for(var/filename in music_list)
		message_admins("Loading jukebox track(s): [filename]")

		if(!fexists(filename))
			log_runtime("File not found: [filename]")
			continue

		var/list/jsonData = json_decode(file2text(filename))

		if(!istype(jsonData))
			log_runtime("Failed to read tracks from [filename], json_decode failed.")
			continue

		var/is_json_obj = json_encode(jsonData)[1] == "{"
		var/is_json_arr = json_encode(jsonData)[1] == "\["
		// Some files could be an object, since SSticker adds lobby tracks from jsons that aren't arrays
		if (is_json_obj)
			process_track(jsonData, filename)
		else if (is_json_arr)
			for(var/entry in jsonData)
				process_track(entry, filename)
		else
			// how did we end up here?
			log_runtime("Failed to read tracks from [filename], is not object or array.")
