/obj/item/mcobject/messaging/regex
	var/regex_pattern
	var/regex_flags = ""
	var/regex/compiled_regex

/obj/item/mcobject/messaging/regex/proc/update_regex(new_pattern, new_flags)
	var/needs_recompile = FALSE
	if(!isnull(new_pattern))
		if(does_regex_contain_lookaround(new_pattern))
			return FALSE
		if(regex_pattern != new_pattern)
			regex_pattern = new_pattern
			needs_recompile = TRUE
	if(!isnull(new_flags))
		if(regex_flags != new_flags)
			regex_flags = new_flags
			needs_recompile = TRUE
	if(needs_recompile)
		compiled_regex = new(regex_pattern, regex_flags)
	return TRUE

/// Checks to see if a regex has any lookaround assertions.
/// This works by going through the string, and checking to see if a ( symbol is followed by either a =, !, or <
/proc/does_regex_contain_lookaround(regex_str)
	// For reference, these are the lookaround assertions that BYOND supports, according to the DM ref:
	// (?=pattern)
	// (?!pattern)
	// (?<=pattern)
	// (?<!pattern)
	var/static/list/lookaround_prefixes = list("(=", "(!", "(<")

	var/str_length = length_char(regex_str)
	if(str_length < 3)
		return FALSE
	for(var/idx = 1 to str_length - 2)
		var/part = copytext_char(regex_str, idx, idx + 2)
		if(part in lookaround_prefixes)
			return TRUE
	return FALSE
