/datum/antagonist/evil_clone
	name = "\improper Evil Clone"
	show_in_antagpanel = TRUE
	roundend_category = "evil clones"
	antagpanel_category = "Evil Clones"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE

/datum/antagonist/evil_clone/greet()
	. = ..()
	owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/revolutionary_tide.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
