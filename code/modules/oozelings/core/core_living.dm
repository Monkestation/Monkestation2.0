///The rate at which slimes regenerate their jelly normally
#define JELLY_REGEN_RATE 1.5
///The rate at which slimes regenerate their jelly when they completely run out of it and start taking damage, usually after having cannibalized all their limbs already
#define JELLY_REGEN_RATE_EMPTY 2.5
///The blood volume at which slimes begin to start losing nutrition -- so that IV drips can work for blood deficient slimes
#define BLOOD_VOLUME_LOSE_NUTRITION 550

#define FORMAT_SLIME_HUD_MAPTEXT(color_value, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color=[color_value]>[round(value,1)]</font></div>")

/obj/item/organ/internal/brain/slime/Insert(mob/living/carbon/organ_owner, special = FALSE, drop_if_replaced, no_id_transfer)
	. = ..()
	if(!.)
		return
	colorize()
	core_ejected = FALSE
	GLOB.dead_oozeling_cores -= src
	RegisterSignal(organ_owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(organ_owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(slime_blood))
	if(organ_owner.hud_used)
		on_hud_created(organ_owner)
	else
		RegisterSignal(organ_owner, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

/obj/item/organ/internal/brain/slime/Remove(mob/living/carbon/organ_owner, special = FALSE, no_id_transfer = FALSE)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_ON_HANDLE_BLOOD, COMSIG_MOB_HUD_CREATED))
	var/datum/hud/slime_hud = slime_wetness_display?.hud
	if(slime_hud)
		slime_hud.infodisplay -= slime_wetness_display
		slime_hud.show_hud(slime_hud.hud_version)
	QDEL_NULL(slime_wetness_display)

/obj/item/organ/internal/brain/slime/proc/slime_blood(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(slime.stat == DEAD)
		return NONE

	. = HANDLE_BLOOD_NO_NUTRITION_DRAIN|HANDLE_BLOOD_NO_EFFECTS

	if(slime.blood_volume <= 0)
		slime.blood_volume += JELLY_REGEN_RATE_EMPTY * seconds_per_tick
		slime.adjustBruteLoss(2.5 * seconds_per_tick)
		to_chat(slime, span_danger("You feel empty!"))

	if(slime.blood_volume < BLOOD_VOLUME_NORMAL)
		if(slime.nutrition >= NUTRITION_LEVEL_STARVING)
			slime.blood_volume += JELLY_REGEN_RATE * seconds_per_tick
			if(slime.blood_volume <= BLOOD_VOLUME_LOSE_NUTRITION) // don't lose nutrition if we are above a certain threshold, otherwise slimes on IV drips will still lose nutrition
				slime.adjust_nutrition(-1.25 * seconds_per_tick)

	if(HAS_TRAIT(slime, TRAIT_BLOOD_DEFICIENCY))
		var/datum/quirk/blooddeficiency/blooddeficiency = slime.get_quirk(/datum/quirk/blooddeficiency)
		blooddeficiency?.lose_blood(slime, seconds_per_tick)

	if(slime.blood_volume < BLOOD_VOLUME_OKAY)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(slime, span_danger("You feel drained!"))

	var/datum/status_effect/fire_handler/wet_stacks/oozeling/slime_wetness = slime.has_status_effect(/datum/status_effect/fire_handler/wet_stacks/oozeling)
	if(!slime_wetness || slime_wetness?.stacks != slime_wetness.stack_limit)
		if(slime.blood_volume >= BLOOD_VOLUME_OKAY)
			slime.adjust_wet_stacks(1, /datum/status_effect/fire_handler/wet_stacks/oozeling)

			if(slime_wetness?.stacks > (HYDROPHOBIA_WETNESS_STACKS - 1) && slime_wetness?.stacks <= HYDROPHOBIA_WETNESS_STACKS)
				slime.balloon_alert(slime, "membrane restored!")
				playsound(slime, 'sound/items/handling/surgery/organ1.ogg', 80, TRUE)
				slime.visible_message(
					span_notice("[slime]'s body forms an oily outer membrance!"),
					span_nicegreen("Your protective membrance regenerates!"),
				)

		update_hud(slime)


	if(slime.blood_volume < BLOOD_VOLUME_BAD)
		cannibalize_body(slime)

	var/datum/action/innate/regenerate_limbs/regenerate_limbs = locate() in actions
	regenerate_limbs?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	return .

/obj/item/organ/internal/brain/slime/proc/cannibalize_body(mob/living/carbon/human/body)
	if(HAS_TRAIT(body, TRAIT_OOZELING_NO_CANNIBALIZE))
		return
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - body.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!length(limbs_to_consume))
		body.losebreath++
		return
	if(body.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = body.get_bodypart(pick(limbs_to_consume))
	for(var/obj/item/organ/internal/organ in body.get_organs_for_zone(consumed_limb.body_zone))
		organ.Remove(body)
		if(!QDELETED(organ))
			organ.forceMove(body.drop_location())
	consumed_limb.drop_limb()
	body.visible_message(
		span_danger("[body]'s [consumed_limb] rapidly loses its shape, painfully being drawn back into [body.p_their()] body!"),
		span_userdanger("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!")
	)
	qdel(consumed_limb)
	body.blood_volume += 20

/obj/item/organ/internal/brain/slime/proc/on_hud_created(mob/source)
	SIGNAL_HANDLER

	var/datum/hud/slime_hud = source.hud_used
	slime_wetness_display = new(null, slime_hud)
	slime_hud.infodisplay += slime_wetness_display
	slime_hud.show_hud(slime_hud.hud_version)

/obj/item/organ/internal/brain/slime/proc/update_hud(mob/living/carbon/human/slime)
	var/color_value
	var/datum/status_effect/fire_handler/wet_stacks/oozeling/slime_wetness = slime.has_status_effect(/datum/status_effect/fire_handler/wet_stacks/oozeling)
	switch(slime_wetness ? slime_wetness.stacks : 0)
		if(0 to 9)
			color_value = "#d84d54"
		if(10 to 19)
			color_value = "#caffca"
		if(20 to INFINITY)
			color_value = "#5ac745"

	slime_wetness_display?.maptext = FORMAT_SLIME_HUD_MAPTEXT(color_value, slime_wetness?.stacks)

#undef JELLY_REGEN_RATE
#undef JELLY_REGEN_RATE_EMPTY
#undef BLOOD_VOLUME_LOSE_NUTRITION
#undef FORMAT_SLIME_HUD_MAPTEXT
