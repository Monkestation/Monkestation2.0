/mob/living/silicon/ai/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		. += span_deadsay("[p_they(capitalized = TRUE)] appears to be powered-down.")
		return .
	if (getBruteLoss())
		if (getBruteLoss() < 30)
			. += span_warning("[p_they(capitalized = TRUE)] list minor brute injuries sustained.")
		else
			. += span_warning("[p_they(capitalized = TRUE)] list <B>major</B> brute injuries sustained.")
	if (getFireLoss())
		if (getFireLoss() < 30)
			. += span_warning("[p_they(capitalized = TRUE)] list minor burn injuries sustained.")
		else
			. += span_warning("[p_they(capitalized = TRUE)] list <B>major</B> burn injuries sustained.")
	if(deployed_shell)
		. += "[p_their(capitalized = TRUE)] wireless networking light is blinking."
	else if(!shunted && !client && last_connection_time)
		var/formatted_afk_time = span_bold("[round((world.time - lastclienttime) / (1 MINUTES), 0.1)]")
		. += "[src]Core.exe has stopped responding [formatted_afk_time] minute(s) ago! NTOS is searching for a solution to the problem..."

/mob/living/silicon/ai/late_examine(mob/user)
	return
