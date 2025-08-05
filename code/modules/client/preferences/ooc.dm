#define MAX_PRONOUNS 4
// This list is non-exhaustive
GLOBAL_LIST_INIT(pronouns_valid, list(
	"he", "him", "his",
	"she","her","hers",
	"hyr", "hyrs",
	"they", "them", "their","theirs",
	"it", "its",
	"xey", "xe", "xem", "xyr", "xyrs",
	"ze", "zir", "zirs",
	"ey", "em", "eir", "eirs",
	"fae", "faer", "faers",
	"ve", "ver", "vis", "vers",
	"ne", "nem", "nir", "nirs"
))

// at least one is required
GLOBAL_LIST_INIT(pronouns_required, list(
	"he", "her", "she", "they", "them", "it", "fae", "its"
))

/// The color admins will speak in for OOC.
/datum/preference/color/ooc_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ooccolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/ooc_color/create_default_value()
	return "#c43b23"

/datum/preference/color/ooc_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return is_admin(preferences.parent) || preferences.unlock_content

/datum/preference/text/ooc_pronouns
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "oocpronouns"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/text/ooc_pronouns/create_default_value()
	return ""

/datum/preference/text/ooc_pronouns/is_valid(value)
	value = lowertext(value)

	if (!value || trim(value) == "")
		return TRUE

	// staff/donators/mentors can choose whatever pronouns they want given, you know, we trust them to use them like a normal person
	if (usr && (is_admin(usr) || is_mentor(usr) || usr.persistent_client.patreon.is_donator()))
		to_chat(usr, span_notice("Gentle reminder that since you are staff/donator, you can set this field however you like. But please use it in good faith."))
		log_game("OOC pronouns set by [usr] ([usr.ckey]) to: [value]")
		return TRUE

	var/pronouns = splittext(value, "/")
	if (length(pronouns) > MAX_PRONOUNS)
		to_chat(usr, span_warning("You can only set up to [MAX_PRONOUNS] different pronouns."))
		return FALSE

	for (var/pronoun in pronouns)
		// pronouns can end in "self" or "selfs" so allow those
		// if has "self" or "selfs" at the end, remove it
		if (endswith(pronoun, "selfs"))
			pronoun = copytext(pronoun, 1, length(pronoun) - 5)
		else if (endswith(pronoun, "self"))
			pronoun = copytext(pronoun, 1, length(pronoun) - 4)
		pronoun = trim(pronoun)

		if (!(pronoun in GLOB.pronouns_valid))
			to_chat(usr, span_warning("Invalid pronoun: [pronoun]. Valid pronouns are: [GLOB.pronouns_valid.Join(", ")]"))
			return FALSE

	if (length(pronouns) != length(unique_list(pronouns)))
		to_chat(usr, span_warning("You cannot use the same pronoun multiple times."))
		return FALSE

	for (var/pronoun in GLOB.pronouns_required)
		if (pronoun in pronouns)
			return TRUE

	to_chat(usr, span_warning("You must include at least one of the following pronouns: [GLOB.pronouns_required.Join(", ")]"))
	// Someone may yell at me i dont know
	return FALSE

#undef MAX_PRONOUNS
