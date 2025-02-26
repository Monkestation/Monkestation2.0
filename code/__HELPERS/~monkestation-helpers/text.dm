/// Checks to see if a string starts with http:// or https://
/proc/is_http_protocol(text)
	var/static/regex/http_regex
	if(isnull(http_regex))
		http_regex = new("^https?://")
	return findtext(text, http_regex)
