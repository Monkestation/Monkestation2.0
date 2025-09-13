// YOU SHOULD NEVER INITIALIZE THESE TYPES MANUALLY, ANERI WILL CREATE THEM!

/// Represents data for a single capture group in a regex match.
/datum/regex_capture_group
	/// The name of the capture group, if it has one.
	/// Unnamed capture groups will be null.
	var/name
	/// The starting index of the capture in the original string.
	var/start
	/// The ending index of the capture in the original string.
	var/end
	/// The actual string value of the captured text.
	var/value

/datum/regex_capture_group/New(name, start, end, value)
	src.name = name
	src.start = start
	src.end = end
	src.value = value

/datum/regex_capture_group/proc/operator""()
	return "[value]"

/// Represents data for a complete regex match, including all capture groups.
/datum/regex_match
	/// The full string that matched the entire regex pattern.
	var/match
	/// The starting index of the entire match in the original string.
	var/start
	/// The ending index of the entire match in the original string.
	var/end
	/// A list containing data for each capture group in the match.
	/// This includes both named and unnamed captures.
	var/list/datum/regex_capture_group/captures

/datum/regex_match/New(match, start, end, list/datum/regex_capture_group/captures)
	src.match = match
	src.start = start
	src.end = end
	src.captures = captures

/datum/regex_match/proc/get_named_group(name) as /datum/regex_capture_group
	RETURN_TYPE(/datum/regex_capture_group)
	if(!istext(name))
		CRASH("Passed invalid name to get_named_group")
	for(var/datum/regex_capture_group/group as anything in captures)
		if(group.name == name)
			return group
