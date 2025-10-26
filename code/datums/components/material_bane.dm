/datum/component/material_bane
	dupe_mode = COMPONENT_DUPE_SOURCES
	/// The sizzly noises
	var/datum/looping_sound/acid/sizzle
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

/datum/component/material_bane/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY)
	UnregisterSignal(parent, COMSIG_ATOM_HITBY)


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
	humholder.has_embedded_objects(TRUE)
	check_held_shiz(seconds_per_tick)
	do_passive_bane_effects(seconds_per_tick)
	bane_power = clamp(bane_power, 0, max_bane_power)

/datum/component/material_bane/proc/do_passive_bane_effects(seconds_per_tick)
	var/mob/living/carbon/human/humholder = parent
	if(bane_power > 0)
		sizzle.start()
	else
		sizzle.stop()
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
	if(bane_power > 250)
		humholder.take_bodypart_damage(0, (((bane_power / 200) * effect_power) * seconds_per_tick))
	if(!was_baned)
		bane_power = max(bane_power - (25 * seconds_per_tick), 0)

/datum/component/material_bane/proc/check_held_shiz(seconds_per_tick)
	var/mob/living/carbon/human/humholder = parent
	if(humholder.gloves)
		if(!(!(humholder.gloves.body_parts_covered & HANDS) || HAS_TRAIT(humholder.gloves, TRAIT_FINGERPRINT_PASSTHROUGH)))
			return
	for(var/obj/item/held in humholder.held_items)
		if(is_this_bane(held))
			if(damaging)
				var/ouchy_arm = (humholder.get_held_index_of_item(held) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
				humholder.apply_damage((((bane_power / 50) * effect_power) * seconds_per_tick), BURN, ouchy_arm)
			if(COOLDOWN_FINISHED(src, active_message_cooldown))
				COOLDOWN_START(src, active_message_cooldown, 1 SECOND)
				switch(bane_power)
					if(0 to 100)
						humholder.visible_message(span_warning("[held] sizzles in [humholder]'s hand."), span_warning("The [held] stings as you hold it, slowly burning an imprint into your hand!"))
						humholder.emote("twitch_s")
					if(101 to 200)
						humholder.visible_message(span_warning("[held] is steaming in [humholder]'s hand!"), span_warning("[held] <b>burns</b>! It's getting hard to keep your grip!"))
						humholder.emote("twitch")
					if(201 to 300)
						humholder.visible_message(span_warning("[held] is glowing with heat in [humholder]'s hand!"), span_boldwarning("The [held] SEARS YOUR FLESH! OWWW!"))
						humholder.emote("scream")
					if(301 to INFINITY)
						humholder.emote("scream")
						humholder.visible_message(span_warning("[held] is burning feverishly in [humholder]'s hand!"), span_userdanger("ITHURTSITHURTSITHURTSDROPITDROPIT"))
						if(HAS_TRAIT(held, TRAIT_NODROP) && damaging)
							var/uhoh = (humholder.get_held_index_of_item(held) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
							humholder.dropItemToGround(held, TRUE)
							qdel(humholder.get_bodypart(uhoh))
							humholder.visible_message(span_warning("[held] disintegrates [humholder]'s arm!"), span_userdanger("I CANT DROP IT. OHGODOHGODAAAA-"))
						else
							humholder.dropItemToGround(held)

			was_baned = TRUE
			bane_power += (25 * seconds_per_tick * bane_speed_mult)

/datum/component/material_bane/proc/on_bane_bonk()
	var/mob/living/carbon/human/humholder = parent
	was_baned = TRUE
	bane_power += rand(25, 100)
	to_chat(humholder, span_warning("Owwwwwww!"))
	if(prob(20))
		humholder.Paralyze(1 SECOND)

/datum/component/material_bane/proc/is_this_bane(atom/thing)
	if(thing.custom_materials)
		for(var/material in thing.custom_materials)
			var/datum/material/possible_ouch = GET_MATERIAL_REF(material)
			if(is_type_in_list(possible_ouch, our_bane))
				return TRUE
	var/datum/component/bane_inducing/ough = thing.GetComponent(/datum/component/bane_inducing)
	if(ough)
		for(var/material in ough.mats_we_pretend_to_be)
			var/datum/material/possible_ouch = GET_MATERIAL_REF(material)
			if(is_type_in_list(possible_ouch, our_bane))
				return TRUE
	return FALSE

/datum/component/material_bane/proc/weapon_hit_check(mob/living/oughed, obj/item/weapon, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(is_this_bane(weapon))
		on_bane_bonk()

/datum/component/material_bane/proc/thrown_hit_check(obj/item/hit, atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(is_this_bane(hitting))
		on_bane_bonk()
