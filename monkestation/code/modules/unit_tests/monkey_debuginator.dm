// here be dragons

#ifdef UNIT_TESTS
/mob/living/carbon/human/species/monkey
	var/monkey_init_info

/mob/living/carbon/human/species/monkey/New()
	try
		CRASH("stupid monkey call stack hack")
	catch(var/exception/err)
		monkey_init_info = call_stack_from_exception(err)
	return ..()

/mob/living/carbon/human/species/monkey/dump_harddel_info()
	if(harddel_deets_dumped || !monkey_init_info)
		return
	harddel_deets_dumped = TRUE
	return "New() call stack: [monkey_init_info]"

/proc/call_stack_from_exception(exception/err)
	var/desc = "[err.desc]"
	var/start_pos = findtext_char(desc, "call stack:")
	if(start_pos)
		return trimtext(copytext_char(desc, start_pos + 11))
#endif
