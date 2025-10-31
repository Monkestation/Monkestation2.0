/datum/component/material_bane
	dupe_mode = COMPONENT_DUPE_SOURCES
	/// The sizzly noises
	var/datum/looping_sound/grill/sizzle
	/// The proc used to handle the parent [/atom] when processing.
	var/datum/callback/process_effect
	var/list/datum/material/our_bane
	var/bane_power = 0
	var/was_baned = FALSE
	var/damaging
	var/effect_power
	var/max_bane_power
	//1 = 25 points gained per second of holding a bane material
	var/bane_speed_mult

	COOLDOWN_DECLARE(active_message_cooldown)

/datum/component/material_bane/Initialize(our_bane = list(/datum/material/silver), damaging = TRUE, effect_power = 1, max_bane_power = 500, bane_speed_mult = 1)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	src.our_bane = our_bane
	src.damaging = damaging
	src.effect_power = effect_power
	src.max_bane_power = max_bane_power
	src.bane_speed_mult = bane_speed_mult
	sizzle = new(parent)
	START_PROCESSING(SSfastprocess, src)

/datum/component/material_bane/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	if(sizzle)
		QDEL_NULL(sizzle)
	process_effect = null
	return ..()

/datum/component/material_bane/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(weapon_hit_check))
	RegisterSignal(parent, COMSIG_ATOM_HITBY, PROC_REF(thrown_hit_check))
	RegisterSignal(parent, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(check_for_bane_start))
	RegisterSignal(parent, COMSIG_HUMAN_EQUIPPING_ITEM, PROC_REF(check_for_bane_start))
	RegisterSignal(parent, COMSIG_CARBON_EMBED_ADDED, PROC_REF(check_for_bane_start))

/datum/component/material_bane/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_AFTER_ATTACKEDBY, COMSIG_ATOM_HITBY, COMSIG_LIVING_PICKED_UP_ITEM, COMSIG_HUMAN_EQUIPPING_ITEM, COMSIG_CARBON_EMBED_ADDED))


/datum/component/material_bane/process(seconds_per_tick)
	was_baned = FALSE
	process_effect?.InvokeAsync(seconds_per_tick)
	var/mob/living/carbon/human/humholder = parent
	var/num_ouchy_clothes = 0
	for(var/obj/item/bodypart/bodypart as anything in humholder.bodyparts)
		for(var/obj/item/embedded in bodypart.embedded_objects)
			if(is_this_bane(embedded))
				was_baned = TRUE
				bane_power += 20 * seconds_per_tick
				if(SPT_PROB(10, seconds_per_tick))
					humholder.visible_message(span_warning("[humholder] sizzles!"), span_warning("Your body aches agonizingly as [embedded] burns within you!"), span_warning("You hear a meaty sizzling noise, like frying bacon."))
	for(var/obj/item/equippies in humholder.get_equipped_items())
		if(is_this_bane(equippies))
			num_ouchy_clothes += 1
			was_baned = TRUE
			if(SPT_PROB(10, seconds_per_tick))
				humholder.visible_message(span_warning("[humholder] sizzles on contact with [equippies]"), span_warning("You sizzle and twitch as [equippies] painfully scalds you!"), span_warning("You hear a meaty sizzling noise, like frying bacon."))
	bane_power += num_ouchy_clothes * 10
	check_held_shiz(seconds_per_tick)
	do_passive_bane_effects(seconds_per_tick)
	bane_power = clamp(bane_power, 0, max_bane_power)

/datum/component/material_bane/proc/do_passive_bane_effects(seconds_per_tick)
	var/mob/living/carbon/human/humholder = parent
	if(bane_power > 0)
		sizzle.start()
	else
		sizzle.stop()
		STOP_PROCESSING(SSfastprocess, src)
	switch(bane_power)
		if(1 to 100)
			if(SPT_PROB(10, seconds_per_tick))
				humholder.emote("twitch_s")
		if(101 to 200)
			if(SPT_PROB(10, seconds_per_tick))
				humholder.emote("twitch")
		if(201 to 300)
			if(SPT_PROB(10, seconds_per_tick))
				humholder.emote("scream")
				humholder.set_jitter_if_lower(1 MINUTES)
				humholder.adjust_confusion(2 SECONDS)
		if(301 to INFINITY)
			if(SPT_PROB(10, seconds_per_tick))
				humholder.emote("scream")
				humholder.Paralyze(1 SECOND)
				humholder.set_jitter_if_lower(3 MINUTES)
				humholder.adjust_confusion(5 SECONDS)
	if(bane_power > 250 && damaging)
		humholder.take_bodypart_damage(0, (((bane_power / 100) * effect_power) * seconds_per_tick))
	if(!was_baned)
		bane_power = max(bane_power - (25 * seconds_per_tick), 0)

/datum/component/material_bane/proc/check_held_shiz(seconds_per_tick)
	var/mob/living/carbon/human/humholder = parent
	if(humholder.gloves)
		if(!(!(humholder.gloves.body_parts_covered & HANDS) || HAS_TRAIT(humholder.gloves, TRAIT_FINGERPRINT_PASSTHROUGH)))
			return
	for(var/obj/item/held in humholder.held_items)
		if(is_this_bane(held))
			if(damaging && bane_power > 49)
				var/ouchy_arm = (humholder.get_held_index_of_item(held) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
				humholder.apply_damage((((bane_power / 50) * effect_power) * seconds_per_tick), BURN, ouchy_arm)
			if(COOLDOWN_FINISHED(src, active_message_cooldown))
				COOLDOWN_START(src, active_message_cooldown, 1 SECOND)
				switch(bane_power)
					if(0 to 100)
						humholder.visible_message(span_warning("[held] sizzles in [humholder]'s hand."), span_warning("[held] stings as you hold it, slowly burning an imprint into your hand!"))
						humholder.emote("twitch_s")
					if(101 to 200)
						humholder.visible_message(span_warning("[held] is steaming in [humholder]'s hand!"), span_warning("[held] <b>burns</b>! It's getting hard to keep your grip!"))
						humholder.emote("twitch")
					if(201 to 300)
						humholder.visible_message(span_warning("[held] is glowing with heat in [humholder]'s hand!"), span_boldwarning("[held] SEARS YOUR FLESH! OWWW!"))
						humholder.emote("scream")
					if(301 to INFINITY)
						humholder.emote("scream")
						humholder.visible_message(span_warning("[held] is burning feverishly in [humholder]'s hand!"), span_userdanger("ITHURTSITHURTSITHURTSDROPITDROPIT"))
						if(HAS_TRAIT(held, TRAIT_NODROP) && damaging)
							var/uhoh = (humholder.get_held_index_of_item(held) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
							humholder.dropItemToGround(held, TRUE)
							qdel(humholder.get_bodypart(uhoh))
							new /obj/effect/decal/cleanable/ash(get_turf(humholder))
							humholder.visible_message(span_warning("[held] disintegrates [humholder]'s arm as [humholder.p_they()] scream in utter agony!"), span_userdanger("I CANT DROP IT. OHGODOHGODAAAA-"))
							humholder.Paralyze(10 SECONDS)
						else
							humholder.dropItemToGround(held)
							humholder.visible_message(span_warning("[humholder] collapses, [held] falling from their grip!"))
							humholder.Paralyze(5 SECONDS)

			was_baned = TRUE
			bane_power += (25 * seconds_per_tick * bane_speed_mult)

/datum/component/material_bane/proc/on_bane_bonk()
	var/mob/living/carbon/human/humholder = parent
	was_baned = TRUE
	bane_power += rand(25, 100)
	to_chat(humholder, span_danger("OWWWWWWW!! BURNS!!"))
	if(damaging)
		humholder.adjustFireLoss(10)
	if(prob(25))
		humholder.Paralyze(0.5 SECOND)
	else
		humholder.Stun(0.25 SECOND)

/datum/component/material_bane/proc/is_this_bane(atom/thing)
	for(var/material in thing?.custom_materials)
		var/datum/material/possible_ouch = GET_MATERIAL_REF(material)
		if(is_type_in_list(possible_ouch, our_bane))
			return TRUE
	var/datum/component/bane_inducing/ough = thing.GetComponent(/datum/component/bane_inducing)
	for(var/material in ough?.mats_we_pretend_to_be)
		var/datum/material/possible_ouch = GET_MATERIAL_REF(material)
		if(is_type_in_list(possible_ouch, our_bane))
			return TRUE
	return FALSE

/datum/component/material_bane/proc/weapon_hit_check(mob/living/oughed, obj/item/weapon, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(is_this_bane(weapon))
		on_bane_bonk()
		START_PROCESSING(SSfastprocess, src)
	return

/datum/component/material_bane/proc/thrown_hit_check(obj/item/hit, atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(is_this_bane(hitting))
		on_bane_bonk()
		START_PROCESSING(SSfastprocess, src)
	return

/datum/component/material_bane/proc/check_for_bane_start(datum/source, obj/item/maybebane)
	SIGNAL_HANDLER

	if(is_this_bane(maybebane))
		START_PROCESSING(SSfastprocess, src)
	return
