/datum/preference/text/headshot
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "headshot"
	maximum_value_length = MAX_MESSAGE_LEN
	should_update_preview = FALSE
	can_randomize = FALSE
	var/static/list/valid_hosts = list(
		"i.gyazo.com",
		"i.l3n.co",
		"images2.imgbox.com",
		"thumbs2.imgbox.com",
		"images4.imgbox.com",
		"thumbs4.imgbox.com",
		"files.catbox.moe",
	)
	var/static/list/valid_extensions = list("jpg", "png", "jpeg")

/datum/preference/text/headshot/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["headshot"] = value

/datum/preference/text/headshot/is_valid(value)
	if(!..())
		return FALSE

	if(!length(value))
		return TRUE

	if(copytext(value, 1, 9) != "https://")
		to_chat(usr, span_warning("Your link must be https!"))
		return FALSE

	var/path_start = findtext(value, "/", 9)
	if(!path_start)
		to_chat(usr, span_warning("Your link must point directly to an image file!"))
		return FALSE

	var/host = lowertext(copytext(value, 9, path_start))
	if(!(host in valid_hosts))
		to_chat(usr, span_warning("The image must be hosted on one of the following sites: 'Catbox, Imgbox, Gyazo, Lensdump'"))
		return FALSE

	var/image_path = copytext(value, path_start + 1)
	var/query_start = findtext(image_path, "?")
	var/fragment_start = findtext(image_path, "#")
	if(query_start && (!fragment_start || query_start < fragment_start))
		image_path = copytext(image_path, 1, query_start)
	if(fragment_start)
		fragment_start = findtext(image_path, "#")
		if(fragment_start)
			image_path = copytext(image_path, 1, fragment_start)

	var/list/path_parts = splittext(image_path, "/")
	var/list/file_parts = splittext(path_parts[length(path_parts)], ".")
	var/extension = lowertext(file_parts[length(file_parts)])
	if(!(extension in valid_extensions))
		to_chat(usr, span_warning("The image must be one of the following extensions: '[english_list(valid_extensions)]'"))
		return FALSE

	return TRUE
