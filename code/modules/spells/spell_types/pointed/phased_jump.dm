/datum/action/cooldown/spell/pointed/phase_jump
	name = "Phase Jump"
	desc = "Tap the power of your telecrystal body to teleport a short distance!"
	button_icon_state = "phasejump"
	ranged_mousepointer = 'icons/effects/mouse_pointers/phase_jump.dmi'

	cooldown_time = 20 SECONDS
	cast_range = 3
	active_msg = span_notice("You start channeling your telecrystal core....")
	deactive_msg = span_notice("You stop channeling your telecrystal core.")
	spell_requirements = NONE
	var/beam_icon = "tentacle"

/datum/action/cooldown/spell/pointed/phase_jump/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out
	var/obj/spot1 = new phaseout(get_turf(user), user.dir)
	owner.forceMove(target_turf)
	var/obj/spot2 = new phasein(get_turf(user), user.dir)
	spot1.Beam(spot2, beam_icon, time=2 SECONDS)
	user.visible_message(span_danger("[user] phase shifts away!"), span_warning("You shift around the space around you."))
	return TRUE

/datum/action/cooldown/spell/pointed/phase_jump/is_valid_target(atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(target)
	var/area/AU = get_area(owner)
	var/area/AT = get_area(T)
	if((AT.area_flags & NOTELEPORT) || (AU.area_flags & NOTELEPORT))
		owner.balloon_alert(owner, "can't teleport there!")
		return FALSE
	return TRUE
