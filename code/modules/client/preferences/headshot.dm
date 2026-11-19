GLOBAL_VAR(admin_approving_headshot)

#define APPROVED_HEADSHOTS_FILE "data/approved_headshots.json"

/proc/get_approved_headshots()
	var/static/list/approved_headshots
	if(!approved_headshots)
		approved_headshots = list()
		if(fexists(APPROVED_HEADSHOTS_FILE))
			var/raw_json = file2text(APPROVED_HEADSHOTS_FILE)
			if(length(raw_json))
				var/list/loaded = json_decode(raw_json)
				if(islist(loaded))
					approved_headshots = loaded
	return approved_headshots

/proc/cache_approved_headshot(url)
	var/list/approved_headshots = get_approved_headshots()
	if(approved_headshots[url])
		return
	approved_headshots[url] = TRUE
	rustg_file_write(json_encode(approved_headshots), APPROVED_HEADSHOTS_FILE)

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
		return FALSE

	var/static/regex/compiled_link_regex
	var/static/compiled_pattern
	if(compiled_pattern != configured_pattern)
		compiled_link_regex = regex(configured_pattern, "i")
		compiled_pattern = configured_pattern

	if(!compiled_link_regex.Find(value))
		to_chat(usr, span_warning("Please enter a direct HTTPS image URL from a configured host (Default: Catbox, Imgbox, Gyazo, Lensdump), ending in JPG, PNG, JPEG, or WebP"))
		return FALSE

	if(usr)
		 var/list/approved_headshots = get_approved_headshots()
		if(approved_headshots[value] || GLOB.admin_approving_headshot == value)
			return TRUE

		logger.Log(LOG_CATEGORY_HEADSHOT, "\[[time2text(world.realtime,"YYYY-MM-DD hh:mm:ss")]\] [key_name(usr)] submitted a new headshot for approval: [value]")

		message_admins("[ADMIN_LOOKUPFLW(usr)] submitted a headshot: <a href='[value]' target='_blank'>[value]</a> | <a href='byond://?src=[REF(src)];approve_headshot=[usr.ckey];url=[url_encode(value)]'>\[Approve]</a>")
		to_chat(usr, span_notice("Your headshot has been submitted and is pending administrator approval."))

	return FALSE

/datum/preference/text/headshot/deserialize(input, datum/preferences/preferences)
	. = ..(input, preferences)

	if(!.)
		return

	var/configured_pattern = CONFIG_GET(string/headshot_link_regex)
	if(!configured_pattern)
		return ""

	var/static/regex/compiled_link_regex
	var/static/compiled_pattern
	if(compiled_pattern != configured_pattern)
		compiled_link_regex = regex(configured_pattern, "i")
		compiled_pattern = configured_pattern

	if(!compiled_link_regex.Find(.))
		return ""

/datum/preference/text/headshot/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["approve_headshot"])
		if(!check_rights(R_ADMIN))
			return

		var/target_ckey = href_list["approve_headshot"]
		var/approved_url = url_decode(href_list["url"])
		var/client/C = GLOB.directory[target_ckey]

		if(!C || !C.prefs)
			to_chat(usr, span_warning("Could not find active client preferences for ckey: [target_ckey]"))
			return

		cache_approved_headshot(approved_url)

		GLOB.admin_approving_headshot = approved_url
		C.prefs.write_preference(src, approved_url)
		GLOB.admin_approving_headshot = null

		C.prefs.save_preferences()

		to_chat(C, span_notice("Your headshot has been approved by an administrator!"))
		message_admins("[key_name_admin(usr)] approved the headshot for [target_ckey]: [approved_url]")
		logger.Log(LOG_CATEGORY_HEADSHOT, "\[[time2text(world.realtime,"YYYY-MM-DD hh:mm:ss")]\] [key_name(usr)] approved headshot for [target_ckey] to: [approved_url]")

/datum/preference/toggle/see_headshots
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "see_headshots"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE
