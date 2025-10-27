/obj/structure/blood_fountain
	name = "blood fountain"
	desc = "A huge resevoir of thick blood, perhaps drinking some of it would restore some vigor..."
	icon = 'monkestation/icons/obj/blood_fountain.dmi'
	icon_state = "blood_fountain"
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	density = TRUE
	bound_width = 64
	bound_height = 64
	resistance_flags = INDESTRUCTIBLE

/obj/structure/blood_fountain/Initialize(mapload)
	. = ..()
	add_overlay("droplet")

/obj/structure/blood_fountain/attackby(obj/item/bottle, mob/living/user, params)
	if(!istype(bottle, /obj/item/blood_vial))
		balloon_alert(user, "need a blood vial!")
		return ..()
	var/obj/item/blood_vial/vial = bottle
	vial.fill_vial(user)

/obj/item/blood_vial
	name = "blood vial"
	desc = "Used to collect samples of blood from the dead-still blood fountain."
	icon = 'monkestation/icons/obj/items/monster_hunter.dmi'
	base_icon_state = "blood_vial"
	icon_state = "blood_vial_empty"
	inhand_icon_state = "beaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/filled = FALSE ///does the bottle contain fluid

/obj/item/blood_vial/proc/fill_vial(mob/living/user)
	if(filled)
		balloon_alert(user, "vial already full!")
		return
	filled = TRUE
	update_appearance(UPDATE_ICON_STATE)

/obj/item/blood_vial/attack_self(mob/living/user)
	if(!filled)
		balloon_alert(user, "empty!")
		return
	filled = FALSE
	user.apply_status_effect(/datum/status_effect/cursed_blood)
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'monkestation/sound/items/blood_vial_slurp.ogg', vol = 50)

/obj/item/blood_vial/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with == user)
		attack_self(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/blood_vial/update_icon_state()
	icon_state = "[base_icon_state][filled ? "" : "_empty"]"
	return ..()

/datum/status_effect/cursed_blood
	id = "cursed_blood"
	duration = 20 SECONDS
	tick_interval = 0.2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/cursed_blood
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY
	/// The base amount of damage to heal each tick.
	var/static/base_healing = 2

/datum/status_effect/cursed_blood/on_apply()
	to_chat(owner, span_warning("You feel a great power surging through you!"))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/cursed_blood)
	owner.fully_heal(HEAL_NEGATIVE_DISEASES)
	owner.set_pain_mod(id, 0.5)
	owner.add_homeostasis_level(id, owner.standard_body_temperature, 10 KELVIN)

	var/datum/physiology/physiology = astype(owner, /mob/living/carbon/human)?.physiology
	if(physiology)
		physiology.bleed_mod *= 0.5
		physiology.stun_mod *= 0.75
	return TRUE

/datum/status_effect/cursed_blood/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/cursed_blood)
	owner.unset_pain_mod(id)
	owner.remove_homeostasis_level(id)
	var/datum/physiology/physiology = astype(owner, /mob/living/carbon/human)?.physiology
	if(physiology)
		physiology.bleed_mod /= 0.5
		physiology.stun_mod /= 0.75

/datum/status_effect/cursed_blood/tick(seconds_between_ticks, times_fired)
	var/healing_amount = base_healing * seconds_between_ticks
	if(owner.health <= owner.crit_threshold)
		healing_amount *= 2
	owner.AdjustAllImmobility((-6 SECONDS) * seconds_between_ticks)
	owner.stamina.adjust(7 * seconds_between_ticks, forced = TRUE)
	adjust_all_damages(healing_amount)
	adjust_bleed_wounds(healing_amount)
	heal_wounds()

/datum/status_effect/cursed_blood/proc/adjust_all_damages(amount)
	var/needs_update = FALSE
	needs_update += owner.adjustBruteLoss(-amount, updating_health = FALSE)
	needs_update += owner.adjustFireLoss(-amount, updating_health = FALSE)
	needs_update += owner.adjustToxLoss(-(amount / 2), updating_health = FALSE, forced = TRUE)
	needs_update += owner.adjustOxyLoss(-(amount / 2), updating_health = FALSE)
	if(needs_update)
		owner.updatehealth()

/datum/status_effect/cursed_blood/proc/adjust_bleed_wounds(amount)
	if(HAS_TRAIT(owner, TRAIT_NOBLOOD) || !iscarbon(owner))
		return

	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(owner.blood_volume + amount, BLOOD_VOLUME_NORMAL)

	var/mob/living/carbon/carbon_owner = owner
	var/datum/wound/bloodiest_wound
	for(var/datum/wound/iter_wound as anything in carbon_owner.all_wounds)
		if(iter_wound.blood_flow && (iter_wound.blood_flow > bloodiest_wound?.blood_flow))
			bloodiest_wound = iter_wound
	bloodiest_wound?.adjust_blood_flow(-0.5)

/datum/status_effect/cursed_blood/proc/heal_wounds()
	var/mob/living/carbon/carbon_owner = astype(owner)
	if(length(carbon_owner?.all_wounds))
		var/list/datum/wound/ordered_wounds = sort_list(carbon_owner.all_wounds, GLOBAL_PROC_REF(cmp_wound_severity_dsc))
		ordered_wounds[1]?.remove_wound()

/atom/movable/screen/alert/status_effect/cursed_blood
	name = "Cursed Blood"
	desc = "Something foreign is coursing through your veins!"
	icon_state = "blooddrunk"

/datum/movespeed_modifier/cursed_blood
	multiplicative_slowdown = -0.6
