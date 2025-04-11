
/datum/action/cooldown/spell/pointed/conjure/path_entrance
	name = "Path Entrance"
	desc = "Place an entrance to a shortcut through the veil between this world and the other one."

	school = SCHOOL_CONJURATION
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 1
	summon_type = list(/obj/effect/new_rune)


	var/chosen_path = ""

/datum/action/cooldown/spell/pointed/conjure/path_entrance/PreActivate(atom/target)
	var/turf/T = get_turf(target)
	var/obj/effect/new_rune/rune = locate() in T
	if (rune)
		to_chat(owner, span_warning("You cannot draw on top of an already existing rune.") )
		return FALSE
	if(istype(T, /turf/open/space))
		to_chat(owner, span_warning("Get over a solid surface first!") )
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/conjure/path_entrance/post_summon(obj/effect/new_rune/R, atom/cast_on)
	var/turf/T = R.loc
	log_admin("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] (@[T.x], [T.y], [T.z]).")
	message_admins("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] <A HREF = '?_src_ = holder;adminplayerobservecoodjump = 1;X = [T.x];Y = [T.y];Z = [T.z]'>(JMP)</a>.")
	write_full_rune(R.loc, /datum/rune_spell/portalentrance)
	R.one_pulse()
	R.trigger(owner)

	var/datum/antagonist/cult/C = owner.mind?.has_antag_datum(/datum/antagonist/cult)
	C?.gain_devotion(30, DEVOTION_TIER_1, "new_path_entrance", R)

/datum/action/cooldown/spell/pointed/conjure/path_exit
	name = "Path Exit"
	desc = "Place an exit to a shotcut through the veil between this world and the other one."

	school = SCHOOL_CONJURATION
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 3
	summon_type = list(/obj/effect/new_rune)

	var/chosen_path = ""

/datum/action/cooldown/spell/pointed/conjure/path_exit/PreActivate(atom/target)
	var/turf/T = get_turf(target)
	var/obj/effect/new_rune/rune = locate() in T
	if (rune)
		to_chat(owner, span_warning("You cannot draw on top of an already existing rune.") )
		return FALSE
	if(istype(T, /turf/open/space))
		to_chat(owner, span_warning("Get over a solid surface first!") )
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/conjure/path_exit/post_summon(obj/effect/new_rune/R, atom/cast_on)
	. = ..()
	var/turf/T = R.loc
	log_admin("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] (@[T.x], [T.y], [T.z]).")
	message_admins("BLOODCULT: [key_name(owner)] has created a new rune at [T.loc] <A HREF = '?_src_ = holder;adminplayerobservecoodjump = 1;X = [T.x];Y = [T.y];Z = [T.z]'>(JMP)</a>.")
	write_full_rune(R.loc, /datum/rune_spell/portalexit)
	R.one_pulse()
	R.trigger(owner)

	var/datum/antagonist/cult/C = owner.mind?.has_antag_datum(/datum/antagonist/cult)
	C?.gain_devotion(30, DEVOTION_TIER_1, "new_path_exit", R)
