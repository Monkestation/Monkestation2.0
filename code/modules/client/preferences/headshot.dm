/datum/preference/text/headshot
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "headshot"
	maximum_value_length = MAX_MESSAGE_LEN
	should_update_preview = FALSE
	can_randomize = FALSE

/datum/preference/text/headshot/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features["headshot"] = value

/datum/preference/text/headshot/is_valid(value)
	if(!..())
		return FALSE

	if(!length(value))
		return TRUE

	var/configured_pattern = CONFIG_GET(string/headshot_link_regex)
	if(!configured_pattern)
		to_chat(usr, span_warning("Invalid character artwork link"))
		return FALSE

	var/static/regex/compiled_link_regex
	var/static/compiled_pattern
	if(compiled_pattern != configured_pattern)
		compiled_link_regex = regex(configured_pattern, "i")
		compiled_pattern = configured_pattern

	if(!compiled_link_regex.Find(value))
		to_chat(usr, span_warning("Please enter a direct HTTPS image URL from a configured host (Default: Catbox, Imgbox, Gyazo, Lensdump), ending in JPG, PNG, JPEG, or WebP"))
		return FALSE

	return TRUE
