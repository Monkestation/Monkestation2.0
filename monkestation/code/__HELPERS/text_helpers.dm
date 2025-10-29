/// -- Text helpers. --
/// Provides a preview of [string] up to [len - 3], after which it appends "..." if it pasts the length.
/proc/TextPreview(string, len = 40)
	var/char_len = length_char(string)
	if(char_len <= len)
		if(!char_len)
			return "\[...\]"
		else
			return string
	else
		return "[copytext_char(string, 1, len - 3)]..."

/proc/get_fancy_key(mob/user)
	if(ismob(user))
		var/mob/temp = user
		return temp.key
	else if(istype(user, /client))
		var/client/temp = user
		return temp.key
	else if(istype(user, /datum/mind))
		var/datum/mind/temp = user
		return temp.key
	return "* Unknown *"
