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

	// extract pronouns from the start of the string
	// only letters and slashes, must be first
	var/regex/reg = regex(@"^[a-z/]+", "i")
	reg.Find(value)

	if (!length(reg.match))
		to_chat(usr, span_warning("Could not find any pronouns. Pronouns must come first and be separated by slashes (/)."))
		return FALSE

	var/pronoun_block = reg.match
	var/extra_text = copytext(value, length(pronoun_block) + 1)
	extra_text = trim(extra_text)

	var/pronouns = splittext(pronoun_block, "/")
	if (length(pronouns) > MAX_PRONOUNS)
		to_chat(usr, span_warning("You can only set up to [MAX_PRONOUNS] different pronouns."))
		return FALSE

	for (var/pronoun in pronouns)
		pronoun = trim(pronoun)
		// remove/normalize common suffixes
		if (endswith(pronoun, "selfs"))
			pronoun = copytext(pronoun, 1, length(pronoun) - 5)
		else if (endswith(pronoun, "self"))
			pronoun = copytext(pronoun, 1, length(pronoun) - 4)
		else if (endswith(pronoun, "s"))
			pronoun = copytext(pronoun, 1, length(pronoun) - 1)

		if (!(pronoun in GLOB.pronouns_valid))
			to_chat(usr, span_warning("Invalid pronoun: [pronoun]. Valid pronouns are: [GLOB.pronouns_valid.Join(", ")]"))
			return FALSE

	if (length(pronouns) != length(unique_list(pronouns)))
		to_chat(usr, span_warning("You cannot use the same pronoun multiple times."))
		return FALSE

	var/has_required = FALSE
	for (var/req in GLOB.pronouns_required)
		if (req in pronouns)
			has_required = TRUE
			break

	if (!has_required)
		to_chat(usr, span_warning("You must include at least one of the following pronouns: [GLOB.pronouns_required.Join(", ")]"))
		return FALSE

	// If there's extra text after pronouns, only staff/donators/mentors can use it
	if (extra_text != "")
		if (!(usr && (is_admin(usr) || is_mentor(usr) || usr.persistent_client.patreon.is_donator())))
			to_chat(usr, span_warning("Only staff, mentors, and donators may add extra text after their pronouns."))
			return FALSE

		to_chat(usr, span_notice("Reminder: extra text after pronouns is a privilege. Please use it in good faith."))
		log_game("OOC pronouns (with extra text) set by [usr] ([usr.ckey]) to: [value]")

	return TRUE

#undef MAX_PRONOUNS
