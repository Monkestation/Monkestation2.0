/datum/memory/key/codewords
	memory_flags = parent_type::memory_flags | MEMORY_NO_STORY

/datum/memory/key/codewords/get_names()
	return list("The code phrases used by the Syndicate: [jointext(GLOB.syndicate_code_phrase, ", ")].")

/datum/memory/key/codewords/responses/get_names()
	return list("The code responses used by the Syndicate: [jointext(GLOB.syndicate_code_response, ", ")].")

/datum/memory/key/on_the_run
	var/crime

/datum/memory/key/on_the_run/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	crime,
)
	src.crime = crime
	return ..()

/datum/memory/key/on_the_run/get_names()
	return list("[protagonist_name] with the law on their back for the crime of [crime].")

/datum/memory/key/on_the_run/get_starts()
	return list(
		"[protagonist_name] running away from security after comitting [crime].",
		"[protagonist_name] looking over their shoulder, looking for security, after having committed [crime].",
	)
