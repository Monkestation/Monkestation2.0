/mob/living/proc/grant_mimicry()
	if(!src.GetComponent(/datum/component/perfect_mimicry))
		src.AddComponent(/datum/component/perfect_mimicry)
/mob/living/proc/remove_mimicry()
	var/datum/component/perfect_mimicry/mimic_component = GetComponent(/datum/component/perfect_mimicry)
	if(mimic_component)
		qdel(mimic_component)

/datum/component/perfect_mimicry
	dupe_mode = COMPONENT_DUPE_UNIQUE

	//var/obj/mimicked_object
	var/currently_disguised = FALSE
	var/datum/action/cooldown/mimic_object/mimic_ability

/datum/component/perfect_mimicry/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	mimic_ability = new(src)

/datum/component/perfect_mimicry/Destroy(force)
	QDEL_NULL(mimic_ability)
	return ..()

/datum/component/perfect_mimicry/RegisterWithParent()
	mimic_ability.Grant(parent)

/datum/component/perfect_mimicry/proc/is_allowed_object(atom/mimic_target)
	if(!isobj(mimic_target))
		return FALSE
	return TRUE

/datum/component/perfect_mimicry/proc/can_start_mimicry(atom/mimic_target)
	var/mob/living/mimic = parent

	if(!istype(mimic) || QDELETED(mimic))
		return FALSE
	if(mimic_target == mimic)
		to_chat(mimic, span_notice("You cannot mimic yourself."))
		return FALSE
	if(!isobj(mimic_target) || QDELETED(mimic_target))
		return FALSE
	if(get_dist(mimic, mimic_target) > 3)
		to_chat(mimic, span_notice("[mimic_target.name] is too far away."))
		return FALSE
	if(!is_allowed_object(mimic_target))
		to_chat(mimic, span_notice("[mimic_target.name] is too complex to mimic."))
		return FALSE
	if(mimic.movement_type & VENTCRAWLING)
		to_chat(mimic, span_notice("You cannot mimic objects while ventcrawling."))
		return FALSE

	return TRUE
/*
 * Mimicry actions
 */
/datum/action/cooldown/mimic_object
	name = "Mimic Object"
	desc = "Take on the appearance and behavior of a nearby object."
	button_icon = 'icons/hud/mimicry.dmi'
	button_icon_state = "mimic"

	click_to_activate = TRUE
	cooldown_time = 1 SECONDS
	var/cooldown_after_use = 3 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED

/datum/action/cooldown/mimic_object/PreActivate(atom/mimic_target)
	var/datum/component/perfect_mimicry/mimic_component = target

	if(!istype(mimic_component) || QDELETED(mimic_component))
		return FALSE
	if(mimic_component.currently_disguised)
		return ..()
	if(!mimic_component.can_start_mimicry(mimic_target))
		return FALSE

	return ..()

/datum/action/cooldown/mimic_object/Activate(atom/mimic_target)
	var/datum/component/perfect_mimicry/mimic_component = target

	if(!istype(mimic_component) || QDELETED(mimic_component))
		return FALSE

	mimic_component.currently_disguised = !mimic_component.currently_disguised
	update_mimic_mode(mimic_component.currently_disguised)
	StartCooldown(mimic_component.currently_disguised ? cooldown_time : cooldown_after_use)
	return TRUE

/datum/action/cooldown/mimic_object/proc/update_mimic_mode(disguised)
	if(disguised)
		click_to_activate = FALSE
		button_icon_state = "unmimic"
	else
		click_to_activate = TRUE
		button_icon_state = "mimic"

	build_all_button_icons(UPDATE_BUTTON_ICON | UPDATE_BUTTON_STATUS)
