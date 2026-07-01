//These mutations change your overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/epilepsy
	name = "Epilepsy"
	desc = "A genetic defect that sporadically causes seizures."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You get a headache.</span>"
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/epilepsy/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(0.5 * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src), seconds_per_tick))
		trigger_seizure()

/datum/mutation/epilepsy/proc/trigger_seizure()
	if(owner.stat != CONSCIOUS)
		return
	owner.visible_message(span_danger("[owner] starts having a seizure!"), span_userdanger("You have a seizure!"))
	owner.Unconscious(200 * GET_MUTATION_POWER(src))
	owner.set_jitter(2000 SECONDS * GET_MUTATION_POWER(src)) //yes this number looks crazy but the jitter animations are amplified based on the duration.
	owner.add_mood_event("epilepsy", /datum/mood_event/epilepsy)
	addtimer(CALLBACK(src, PROC_REF(jitter_less)), 90)

/datum/mutation/epilepsy/proc/jitter_less()
	if(QDELETED(owner))
		return

	owner.set_jitter(20 SECONDS)

/datum/mutation/epilepsy/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_FLASHED, PROC_REF(get_flashed_nerd))

/datum/mutation/epilepsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_FLASHED)

/datum/mutation/epilepsy/proc/get_flashed_nerd()
	SIGNAL_HANDLER

	if(!prob(30))
		return
	trigger_seizure()


//Unstable DNA induces random mutations!
/datum/mutation/bad_dna
	name = "Unstable DNA"
	desc = "Strange mutation that causes the holder to randomly mutate."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel strange.</span>"
	locked = TRUE

/datum/mutation/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		switch(rand(1,3))
			if(1)
				new_mob = owner.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
			if(2)
				new_mob = owner.random_mutate_unique_identity()
			if(3)
				new_mob = owner.random_mutate_unique_features()
	else
		new_mob = owner.easy_random_mutate(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/cough
	name = "Cough"
	desc = "A chronic cough."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You start coughing.</span>"
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/cough/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(2.5 * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src), seconds_per_tick) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")
		if(GET_MUTATION_POWER(src) > 1)
			var/cough_range = GET_MUTATION_POWER(src) * 4
			var/turf/target = get_ranged_target_turf(owner, turn(owner.dir, 180), cough_range)
			owner.throw_at(target, cough_range, GET_MUTATION_POWER(src))

/datum/mutation/paranoia
	name = "Paranoia"
	desc = "Subject is easily terrified, and may suffer from hallucinations."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel screams echo through your mind...</span>"
	text_lose_indication = "<span class='notice'>The screaming in your mind fades.</span>"

/datum/mutation/paranoia/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(2.5, seconds_per_tick) && owner.stat == CONSCIOUS)
		owner.emote("scream")
		if(prob(25))
			owner.adjust_hallucinations(40 SECONDS)

//Dwarfism shrinks your body and lets you pass tables.
/datum/mutation/dwarfism
	name = "Dwarfism"
	desc = "A mutation believed to be the cause of dwarfism."
	quality = POSITIVE
	difficulty = 16
	instability = 5
	conflicts = list(/datum/mutation/gigantism)
	locked = TRUE // Default intert species for now, so locked from regular pool.
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/dwarfism/setup()
	. = ..()
	if(isnull(owner))
		return

	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_FAST_CLIMBER, GENETIC_MUTATION)

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		ADD_TRAIT(owner, TRAIT_STABLE_DWARF, GENETIC_MUTATION)

/datum/mutation/dwarfism/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DWARF, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

/datum/mutation/dwarfism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return

	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_FAST_CLIMBER, GENETIC_MUTATION)

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		REMOVE_TRAIT(owner, TRAIT_STABLE_DWARF, GENETIC_MUTATION)

	//We're leaving the size traits permanent until someone wants to separate the mutation from customization aspects
	REMOVE_TRAIT(owner, TRAIT_DWARF, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/clumsy
	name = "Clumsiness"
	desc = "A genome that inhibits certain brain functions, causing the holder to appear clumsy. Honk!"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You feel lightheaded.</span>"

/datum/mutation/clumsy/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)

/datum/mutation/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)


//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/tourettes
	name = "Tourette's Syndrome"
	desc = "A chronic twitch that forces the user to scream nonsense." //definitely needs rewriting
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You twitch.</span>"
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/tourettes/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(5 * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src), seconds_per_tick) && owner.stat == CONSCIOUS && !owner.IsStun())
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "MROW", "ANIMES", "LIZZZARD", "HELP")][GET_MUTATION_POWER(src) > 1 ? "!!" : ""]", forced=name)
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)

//Deafness makes you deaf.
/datum/mutation/deaf
	name = "Deafness"
	desc = "The holder of this genome is completely deaf."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to hear anything.</span>"

/datum/mutation/deaf/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)

/datum/mutation/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)

//Monified turns you into a monkey.
/datum/mutation/race
	name = "Monkified"
	desc = "A strange genome, believing to be what differentiates monkeys from humans."
	text_gain_indication = span_green("You feel unusually monkey-like.")
	text_lose_indication = span_notice("You feel like your old self.")
	quality = NEGATIVE
	locked = TRUE //Species specific, keep out of actual gene pool
	///The path of the species we turn the player into.
	var/datum/species/species_turned_into = /datum/species/monkey
	///The stored original species that the person has when they turned into the species above.
	var/datum/species/original_species = /datum/species/human
	var/original_name

/datum/mutation/race/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	if(ismonkey(owner))
		return
	original_species = owner.dna.species.type
	original_name = owner.real_name
	owner.monkeyize(monkey_type = species_turned_into)

/datum/mutation/race/on_losing(mob/living/carbon/human/owner)
	if(owner.stat == DEAD)
		return
	. = ..()
	if(.)
		return
	if(QDELETED(owner))
		return

	owner.fully_replace_character_name(null, original_name)
	owner.humanize(original_species)

/datum/mutation/race/simian
	name = "Simianized"
	desc = "A strange genome, the strain that connects the original simian to humanhood."
	text_gain_indication = span_green("You feel unusually simian-like.")
	species_turned_into = /datum/species/monkey/simian

/datum/mutation/glow
	name = "Glowy"
	desc = "You permanently emit a light with a random color and intensity."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin begins to glow softly.</span>"
	instability = 5
	power_coeff = 1
	conflicts = list(/datum/mutation/glow/anti)
	var/glow_power = 2.5
	var/glow_range = 2.5
	var/glow_color

	var/obj/effect/dummy/lighting_obj/moblight/glow

/datum/mutation/glow/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	glow_color = get_glow_color()
	glow = owner.mob_light()
	modify()
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))

/datum/mutation/glow/modify()
	if(!glow)
		return
	glow.set_light_range_power_color(glow_range * GET_MUTATION_POWER(src), glow_power, glow_color)
	glow.set_light_on(TRUE)

// Override modify here without a parent call, because we don't actually give an action.
/datum/mutation/glow/setup()
	if(!glow)
		return

	glow.set_light_range_power_color(glow_range * GET_MUTATION_POWER(src), glow_power, glow_color)

/datum/mutation/glow/proc/on_light_eater(mob/living/carbon/human/source, datum/light_eater)
	SIGNAL_HANDLER
	if(!glow)
		return
	glow.set_light_on(FALSE)
	addtimer(CALLBACK(src, PROC_REF(modify)), 20 SECONDS * GET_MUTATION_SYNCHRONIZER(src), TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds (reduced by sychronizer)
	return COMPONENT_BLOCK_LIGHT_EATER

/datum/mutation/glow/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(glow, COMSIG_LIGHT_EATER_ACT)
	QDEL_NULL(glow)

/// Returns a color for the glow effect
/datum/mutation/glow/proc/get_glow_color()
	return pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE)

/datum/mutation/glow/anti
	name = "Anti-Glow"
	desc = "Your skin seems to attract and absorb nearby light creating 'darkness' around you."
	text_gain_indication = "<span class='notice'>The light around you seems to disappear.</span>"
	glow_power = -1.5
	conflicts = list(/datum/mutation/glow)
	locked = TRUE

/datum/mutation/glow/anti/get_glow_color()
	return COLOR_BLACK

/datum/mutation/strong
	name = "Strength"
	desc = "The user's muscles slightly expand."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel strong.</span>"
	difficulty = 16
	instability = 25
	power_coeff = 1
	var/list/affected_limbs = list(
		BODY_ZONE_L_ARM = null,
		BODY_ZONE_R_ARM = null,
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/datum/mutation/strong/Destroy()
	for(var/body_part in affected_limbs)
		if(!isnull(affected_limbs[body_part]))
			unregister_limb(null, affected_limbs[body_part])
	return ..()

/datum/mutation/strong/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_BORG_PUNCHER, GENETIC_MUTATION)
	RegisterSignal(owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(register_limb))
	RegisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(unregister_limb))
	for(var/body_part in affected_limbs)
		var/obj/item/bodypart/limb = owner.get_bodypart(check_zone(body_part))
		if(!limb)
			continue

		register_limb(owner, limb, initial = TRUE)

/datum/mutation/strong/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_BORG_PUNCHER, GENETIC_MUTATION)
	UnregisterSignal(owner, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_CARBON_POST_REMOVE_LIMB))
	for(var/body_part in affected_limbs)
		var/obj/item/bodypart/limb = owner.get_bodypart(check_zone(body_part))
		if(!limb)
			continue

		unregister_limb(owner, limb)

/datum/mutation/strong/setup()
	. = ..()
	if(isnull(owner) || GET_MUTATION_POWER(src) == 1)
		return

	for(var/body_part in affected_limbs)
		var/obj/item/bodypart/limb = affected_limbs[body_part]
		limb.unarmed_damage_low += ((2 * GET_MUTATION_POWER(src)) - 2) // Bit cursed? Yep. Works with any mutation power? Yep.
		limb.unarmed_damage_high += ((2 * GET_MUTATION_POWER(src)) - 2)

/datum/mutation/strong/proc/register_limb(mob/living/carbon/human/owner, obj/item/bodypart/new_limb, special, initial = FALSE)
	SIGNAL_HANDLER
	if(new_limb.body_zone == BODY_ZONE_HEAD || new_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[new_limb.body_zone] = new_limb
	RegisterSignal(new_limb, COMSIG_QDELETING, PROC_REF(limb_gone))
	if(initial)
		new_limb.unarmed_damage_low += 2
		new_limb.unarmed_damage_high += 2
		return

	new_limb.unarmed_damage_low += (2 * GET_MUTATION_POWER(src))
	new_limb.unarmed_damage_high += (2 * GET_MUTATION_POWER(src))

/datum/mutation/strong/proc/unregister_limb(mob/living/carbon/human/owner, obj/item/bodypart/lost_limb, special)
	SIGNAL_HANDLER
	if(lost_limb.body_zone == BODY_ZONE_HEAD || lost_limb.body_zone == BODY_ZONE_CHEST)
		return

	affected_limbs[lost_limb.body_zone] = null
	UnregisterSignal(lost_limb, COMSIG_QDELETING)
	lost_limb.unarmed_damage_low -= (2 * GET_MUTATION_POWER(src))
	lost_limb.unarmed_damage_high -= (2 * GET_MUTATION_POWER(src))

/datum/mutation/strong/proc/limb_gone(obj/item/bodypart/deleted_limb)
	SIGNAL_HANDLER
	if(affected_limbs[deleted_limb.body_zone])
		affected_limbs[deleted_limb.body_zone] = null
		UnregisterSignal(deleted_limb, COMSIG_QDELETING)

/datum/mutation/stimmed
	name = "Stimmed"
	desc = "The user's chemical balance is more robust."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel stimmed.</span>"
	difficulty = 16
	instability = 20
	power_coeff = 1

/datum/mutation/stimmed/on_life(seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_STASIS) || owner.stat == DEAD)
		return

	owner.reagents.remove_all(GET_MUTATION_POWER(src) * REM * seconds_per_tick)

/datum/mutation/insulated
	name = "Insulated"
	desc = "The affected person does not conduct electricity."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your fingertips go numb.</span>"
	text_lose_indication = "<span class='notice'>Your fingertips regain feeling.</span>"
	difficulty = 16
	instability = 25

/datum/mutation/insulated/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, GENETIC_MUTATION)

/datum/mutation/insulated/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, GENETIC_MUTATION)

/datum/mutation/fire
	name = "Fiery Sweat"
	desc = "The user's skin will randomly combust, but is generally a lot more resilient to burning."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>You feel hot.</span>"
	text_lose_indication = "<span class='notice'>You feel a lot cooler.</span>"
	difficulty = 14
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/fire/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB((0.05+(100-dna.stability)/19.5) * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src), seconds_per_tick))
		owner.adjust_fire_stacks(2 * GET_MUTATION_POWER(src))
		owner.ignite_mob()

/datum/mutation/fire/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.physiology.burn_mod *= 0.5

/datum/mutation/fire/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 2

/datum/mutation/badblink
	name = "Spatial Instability"
	desc = "The victim of the mutation has a very weak link to spatial reality, and may be displaced. Often causes extreme nausea."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>The space around you twists sickeningly.</span>"
	text_lose_indication = "<span class='notice'>The space around you settles back to normal.</span>"
	difficulty = 18//high so it's hard to unlock and abuse
	instability = 10
	synchronizer_coeff = 1
	energy_coeff = 1
	power_coeff = 1
	var/warpchance = 0

/datum/mutation/badblink/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(warpchance, seconds_per_tick))
		var/warpmessage = pick(
		span_warning("With a sickening 720-degree twist of [owner.p_their()] back, [owner] vanishes into thin air."),
		span_warning("[owner] does some sort of strange backflip into another dimension. It looks pretty painful."),
		span_warning("[owner] does a jump to the left, a step to the right, and warps out of reality."),
		span_warning("[owner]'s torso starts folding inside out until it vanishes from reality, taking [owner] with it."),
		span_warning("One moment, you see [owner]. The next, [owner] is gone."))
		owner.visible_message(warpmessage, span_userdanger("You feel a wave of nausea as you fall through reality!"))
		var/warpdistance = rand(10, 15) * GET_MUTATION_POWER(src)
		do_teleport(owner, get_turf(owner), warpdistance, channel = TELEPORT_CHANNEL_FREE)
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (warpchance * warpdistance))
		warpchance = 0
		owner.visible_message(span_danger("[owner] appears out of nowhere!"))
	else
		warpchance += 0.0625 * GET_MUTATION_ENERGY(src) * seconds_per_tick

/datum/mutation/acidflesh
	name = "Acidic Flesh"
	desc = "Subject has acidic chemicals building up underneath the skin. This is often lethal."
	quality = NEGATIVE
	text_gain_indication = "<span class='userdanger'>A horrible burning sensation envelops you as your flesh turns to acid!</span>"
	text_lose_indication = "<span class='notice'>A feeling of relief fills you as your flesh goes back to normal.</span>"
	difficulty = 18//high so it's hard to unlock and use on others
	/// The cooldown for the warning message
	COOLDOWN_DECLARE(msgcooldown)
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/acidflesh/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(13 / GET_MUTATION_ENERGY(src), seconds_per_tick))
		if(COOLDOWN_FINISHED(src, msgcooldown))
			to_chat(owner, span_danger("Your acid flesh bubbles..."))
			COOLDOWN_START(src, msgcooldown, 20 SECONDS)
		if(prob(15))
			owner.acid_act(rand(30, 50) * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_userdanger("Your bubbling flesh pops! It burns!"))
			playsound(owner,'sound/weapons/sear.ogg', 50, TRUE)

/datum/mutation/gigantism
	name = "Gigantism"
	desc = "The cells within the subject spread out to cover more area, making the subject appear larger."
	quality = MINOR_NEGATIVE
	difficulty = 12
	conflicts = list(/datum/mutation/dwarfism)
	power_coeff = 1
	var/datum/component/tackling_component

/datum/mutation/gigantism/Destroy()
	if(!QDELETED(tackling_component))
		qdel(tackling_component)
	tackling_component = null
	return ..()

/datum/mutation/gigantism/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1) // Psst, the tackling component's stats are just copied from the gorilla gloves, but doubled stamina cost
		tackling_component = owner.AddComponent(/datum/component/tackler, stamina_cost = 60, base_knockdown = 1.25 SECONDS, range = 5, speed = 1, skill_mod = 2, min_distance = 0)

/datum/mutation/gigantism/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT_FROM(owner, TRAIT_GIANT, QUIRK_TRAIT))
		return FALSE

	ADD_TRAIT(owner, TRAIT_GIANT, GENETIC_MUTATION)

/datum/mutation/gigantism/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_POWER(src) > 1)
		QDEL_NULL(tackling_component)

	REMOVE_TRAIT(owner, TRAIT_GIANT, GENETIC_MUTATION)

/datum/mutation/spastic
	name = "Spastic"
	desc = "Subject suffers from muscle spasms."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>You flinch.</span>"
	text_lose_indication = "<span class='notice'>Your flinching subsides.</span>"
	difficulty = 16
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/spastic/setup()
	. = ..()
	if(isnull(owner))
		return

	var/datum/status_effect/spasms/status_effect = locate(/datum/status_effect/spasms) in owner.status_effects
	if(status_effect)
		status_effect.mutation_synchronizer = GET_MUTATION_SYNCHRONIZER(src)
		status_effect.mutation_power = GET_MUTATION_POWER(src)
		status_effect.mutation_energy = GET_MUTATION_ENERGY(src)

/datum/mutation/spastic/on_acquiring()
	. = ..()
	if(!.)
		return
	owner.apply_status_effect(/datum/status_effect/spasms)

/datum/mutation/spastic/on_losing()
	if(..())
		return
	owner.remove_status_effect(/datum/status_effect/spasms)

/datum/mutation/extrastun
	name = "Two Left Feet"
	desc = "A mutation that replaces the right foot with another left foot. Symptoms include kissing the floor when taking a step."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>Your right foot feels... left.</span>"
	text_lose_indication = "<span class='notice'>Your right foot feels alright.</span>"
	difficulty = 16
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1


/datum/mutation/extrastun/on_acquiring()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/mutation/extrastun/on_losing()
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/// Triggers on moved(). Randomly makes the owner trip
/datum/mutation/extrastun/proc/on_move()
	SIGNAL_HANDLER

	if(prob(99.25 + (0.25 * GET_MUTATION_SYNCHRONIZER(src) / GET_MUTATION_ENERGY(src)))) // The brawl mutation
		return

	if(owner.buckled || owner.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || owner.throwing || owner.movement_type & (VENTCRAWLING | FLYING | FLOATING))
		return // Remove the 'edge' cases

	to_chat(owner, span_danger("You trip over your own feet."))
	owner.Knockdown((3 SECONDS) * GET_MUTATION_POWER(src))

/datum/mutation/martyrdom
	name = "Internal Martyrdom"
	desc = "A mutation that makes the body destruct when near death. Not damaging, but very, VERY disorienting."
	locked = TRUE
	quality = POSITIVE //not that cloning will be an option a lot but generally lets keep this around i guess?
	text_gain_indication = "<span class='warning'>You get an intense feeling of heartburn.</span>"
	text_lose_indication = "<span class='notice'>Your internal organs feel at ease.</span>"
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/martyrdom/on_acquiring()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(bloody_shower))

/datum/mutation/martyrdom/on_losing()
	. = ..()
	if(.)
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_STATCHANGE)

/datum/mutation/martyrdom/proc/bloody_shower(datum/source, new_stat)
	SIGNAL_HANDLER

	if(new_stat != HARD_CRIT)
		return
	var/list/organs = owner.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)

	for(var/obj/item/organ/I in organs)
		qdel(I)

	explosion(owner, light_impact_range = 2 * GET_MUTATION_POWER(src), adminlog = TRUE, explosion_cause = src)
	for(var/mob/living/carbon/human/splashed in view(2, owner))
		var/obj/item/organ/internal/eyes/eyes = splashed.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes)
			to_chat(splashed, span_userdanger("You are blinded by a shower of blood!"))
			eyes.apply_organ_damage(5)
		else
			to_chat(splashed, span_userdanger("You are knocked down by a wave of... blood?!"))
		splashed.Stun(2 SECONDS)
		splashed.set_eye_blur_if_lower(40 SECONDS)
		splashed.adjust_confusion(3 SECONDS)

	for(var/mob/living/silicon/borgo in view(2, owner))
		to_chat(borgo, span_userdanger("Your sensors are disabled by a shower of blood!"))
		borgo.Paralyze(6 SECONDS)

	// If we are synchronized, we instead of gibbing drop all our blood on the floor and remove the mutation
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.investigate_log("had their brain deleted by the martyrdom mutation.", INVESTIGATE_DEATHS)
		var/turf/blood_turf = get_turf(owner)

		var/blood_amount = min(owner.blood_volume, initial(owner.blood_volume) * 5)
		var/datum/blood_type/blood = owner.get_blood_type()

		blood_turf.add_liquid(blood.reagent_type, blood_amount)
		owner.blood_volume = 0
		dna.remove_mutation(src, sources)
		return

	owner.investigate_log("has been gibbed by the martyrdom mutation.", INVESTIGATE_DEATHS)
	owner.gib()

/datum/mutation/headless
	name = "H.A.R.S."
	desc = "A mutation that makes the body reject the head, the brain receding into the chest. Stands for Head Allergic Rejection Syndrome. Warning: Removing this mutation is very dangerous, though it will regenerate non-vital head organs."
	difficulty = 12 //pretty good for traitors
	quality = NEGATIVE //holy shit no eyes or tongue or ears
	text_gain_indication = "<span class='warning'>Something feels off.</span>"

/datum/mutation/headless/setup()
	. = ..()
	if(isnull(owner))
		return

	var/obj/item/bodypart/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return

	if(GET_MUTATION_POWER(src) > 1)
		chest.receive_damage(10 * GET_MUTATION_POWER(src))

	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Keep in mind, when getting HARS we are guaranteed at LEAST 15 brute damage
		chest.heal_damage(5 / GET_MUTATION_SYNCHRONIZER(src))

/datum/mutation/headless/on_acquiring()
	. = ..()
	if(!.)
		return

	var/obj/item/organ/internal/ears/cat/super/ears = owner.get_organ_slot(ORGAN_SLOT_EARS)
	if(istype(ears)) // why
		return FALSE

	var/obj/item/organ/internal/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.zone = BODY_ZONE_CHEST

	var/obj/item/bodypart/head/head = owner.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		owner.visible_message(span_warning("[owner]'s head splatters with a sickening crunch!"), ignored_mobs = list(owner))
		new /obj/effect/gibspawner/generic(get_turf(owner), owner)
		head.dismember(dam_type = BRUTE, silent = TRUE)
		head.drop_organs()
		qdel(head)

	RegisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, PROC_REF(abort_attachment))

/datum/mutation/headless/on_losing()
	. = ..()
	if(.)
		return TRUE
	var/obj/item/organ/internal/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain) //so this doesn't instantly kill you. we could delete the brain, but it lets people cure brain issues they /really/ shouldn't be
		brain.zone = initial(brain.zone)
	UnregisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB)
	var/successful = owner.regenerate_limb(BODY_ZONE_HEAD)
	if(!successful)
		stack_trace("HARS mutation head regeneration failed! (usually caused by headless syndrome having a head)")
		return TRUE
	owner.dna.species.regenerate_organs(owner, replace_current = FALSE, excluded_zones = list(BODY_ZONE_CHEST)) //replace_current needs to be FALSE to prevent weird adding and removing mutation healing
	owner.apply_damage(damage = 50, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD) //and this to DISCOURAGE organ farming, or at least not make it free.
	owner.visible_message(span_warning("[owner]'s head returns with a sickening crunch!"), span_warning("Your head regrows with a sickening crack! Ouch."))
	new /obj/effect/gibspawner/generic(get_turf(owner), owner)


/datum/mutation/headless/proc/abort_attachment(datum/source, obj/item/bodypart/new_limb, special) //you aren't getting your head back
	SIGNAL_HANDLER

	if(istype(new_limb, /obj/item/bodypart/head))
		return COMPONENT_NO_ATTACH

// Soft crit is disabed
/datum/mutation/inexorable
	name = "Inexorable"
	desc = "Your body can push on beyond the limits of normal human endurance. \
		However, pushing it too far can cause severe damage to your body."
	quality = POSITIVE
	// instability = POSITIVE_INSTABILITY_MODERATE // AWAITING TG#83439
	instability = 25
	text_gain_indication = span_notice("You feel inexorable.")
	text_lose_indication = span_notice("You suddenly feel more human.")
	difficulty = 24
	synchronizer_coeff = 1
	// mutation_traits = list(TRAIT_NOSOFTCRIT, TRAIT_ANALGESIA, TRAIT_NO_PAIN_EFFECTS) // AWAITING TG#83439

/datum/mutation/inexorable/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return
	acquirer.add_traits(list(TRAIT_NOSOFTCRIT, TRAIT_ANALGESIA), GENETIC_MUTATION)
	RegisterSignal(acquirer, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(check_health))
	check_health()

/datum/mutation/inexorable/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE)
	owner.remove_traits(list(TRAIT_NOSOFTCRIT, TRAIT_ANALGESIA), GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_SOFTSPOKEN, REF(src))

/datum/mutation/inexorable/proc/check_health(...)
	SIGNAL_HANDLER
	if(owner.health > owner.crit_threshold || owner.stat != CONSCIOUS)
		REMOVE_TRAIT(owner, TRAIT_SOFTSPOKEN, REF(src))
	else
		ADD_TRAIT(owner, TRAIT_SOFTSPOKEN, REF(src))

/datum/mutation/inexorable/on_life(seconds_per_tick, times_fired)
	if(owner.health > owner.crit_threshold || owner.stat != CONSCIOUS || HAS_TRAIT(owner, TRAIT_STASIS))
		return
	var/multiplier = GET_MUTATION_SYNCHRONIZER(src)
	if(HAS_TRAIT(owner, TRAIT_NOCRITDAMAGE))
		multiplier *= 0.5
	// Gives you 30 seconds of being in soft crit... give or take
	if(HAS_TRAIT(owner, TRAIT_TOXIMMUNE) || HAS_TRAIT(owner, TRAIT_TOXINLOVER))
		owner.adjustBruteLoss(1 * seconds_per_tick * multiplier, forced = TRUE, updating_health = FALSE)
	else
		owner.adjustToxLoss(0.5 * seconds_per_tick * multiplier, forced = TRUE, updating_health = FALSE)
		owner.adjustBruteLoss(0.5 * seconds_per_tick * multiplier, forced = TRUE, updating_health = FALSE)
	// Offsets suffocation but not entirely
	owner.adjustOxyLoss(-0.5 * seconds_per_tick, forced = TRUE)

/datum/mutation/radproof
	name = "Radproof"
	desc = "Adapts the host's body to be better suited at preventing cancer caused by radioactivity at the expense of it's ability to handle toxic matter."
	quality = POSITIVE
	text_gain_indication = span_warning("You can't feel it in your bones!")
	instability = 35
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/radproof/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_RADIMMUNE, GENETIC_MUTATION)
	owner.physiology?.tox_mod *= 1.5

/datum/mutation/radproof/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, GENETIC_MUTATION)
	owner.physiology?.tox_mod /= 1.5
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.tox_mod /= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_RADHEALING, GENETIC_MUTATION)

/datum/mutation/radproof/setup()
	. = ..()
	if(isnull(owner))
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.physiology?.tox_mod *= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_RADHEALING, GENETIC_MUTATION)

/datum/mutation/thickskin
	name = "Thick skin"
	desc = "The user's skin acquires a leathery texture, and becomes more resilient to embeds."
	quality = POSITIVE
	text_gain_indication = span_notice("Your skin feels dry and heavy.")
	text_lose_indication = span_notice("Your skin feels soft again...")
	instability = 30
	difficulty = 18
	power_coeff = 1

/datum/mutation/thickskin/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_EMBED_RESISTANCE, GENETIC_MUTATION)

/datum/mutation/thickskin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	REMOVE_TRAIT(owner, TRAIT_EMBED_RESISTANCE, GENETIC_MUTATION)

/datum/mutation/hypermarrow
	name = "Hyperactive Bone Marrow"
	desc = "A mutation that stimulates the subject's bone marrow causes it to work three times faster than usual."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones ache for a moment.")
	text_lose_indication = span_notice("You feel something in your bones calm down.")
	instability = 20
	difficulty = 12
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/hypermarrow/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(gain_blood))

/datum/mutation/hypermarrow/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		UnregisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/mutation/hypermarrow/proc/gain_blood(mob/living/carbon/human/gene_owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER // Btw the signal sender handles if our owner gets the no_blood trait after being injected
	if(gene_owner.stat == DEAD)
		return

	if(gene_owner.blood_volume <= BLOOD_VOLUME_NORMAL)
		gene_owner.blood_volume += (2 * GET_MUTATION_POWER(src) * seconds_per_tick - 1)
		gene_owner.adjust_nutrition((GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src) * seconds_per_tick - 0.8) * HUNGER_FACTOR)

/datum/mutation/bloodyhell // Technically could be easily made a child of bone marrow, but signals dont like that.
	name = "Polycythemia"
	desc = "A mutation that stimulates the subjects bone marrow's blood production capability and removes the subject's bone marrow's usual safeties against overproducing blood."
	quality = NEGATIVE
	text_gain_indication = span_warning("For a brief moment you feel a pain in your heart as you feel it beating faster.")
	text_lose_indication = span_notice("You feel your heart slowing down to its usual speed.")
	instability = 15
	conflicts = list(/datum/mutation/anemia)
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/bloodyhell/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(gain_blood))

/datum/mutation/bloodyhell/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		UnregisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/mutation/bloodyhell/proc/gain_blood(mob/living/carbon/human/gene_owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(gene_owner.stat == DEAD)
		return

	if(gene_owner.blood_volume > (BLOOD_VOLUME_NORMAL * 1.4))
		// We actually NEED to add effects here because normally you get NO downsides for excess blood
		var/blood_difference = (gene_owner.blood_volume / BLOOD_VOLUME_MAXIMUM) * 100
		if(SPT_PROB(blood_difference, seconds_per_tick))
			if(prob(20))
				to_chat(gene_owner, span_warning("You feel bloated."))
			gene_owner.adjustOxyLoss(floor(blood_difference / 20))

	if(gene_owner.blood_volume < BLOOD_VOLUME_MAXIMUM)
		gene_owner.blood_volume += (2 * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src) * seconds_per_tick)

/datum/mutation/anemia
	name = "Anemia"
	desc = "This mutation causes damage to the oxygen carrying properties of blood cells to a high degree in the subject."
	quality = NEGATIVE
	text_gain_indication = span_warning("You feel slightly woozy for a moment.") // No lose indicator, its a slow recovery
	instability = 10
	conflicts = list(/datum/mutation/bloodyhell)
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/anemia/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	RegisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD, PROC_REF(lose_blood))

/datum/mutation/anemia/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		UnregisterSignal(owner, COMSIG_HUMAN_ON_HANDLE_BLOOD)

/datum/mutation/anemia/proc/lose_blood(mob/living/carbon/human/gene_owner, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(gene_owner.stat == DEAD)
		return

	if(gene_owner.blood_volume > BLOOD_VOLUME_SAFE - (75 * GET_MUTATION_POWER(src) * GET_MUTATION_SYNCHRONIZER(src)))
		gene_owner.blood_volume -= (seconds_per_tick)

/datum/mutation/densebones
	name = "Bone Densification"
	desc = "A mutation that gives the subject a rare form of increased bone density, making their entire body harder to wound."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones get denser.")
	text_lose_indication = span_notice("You feel your bones get lighter.")
	instability = 25
	difficulty = 16
	power_coeff = 1

/datum/mutation/densebones/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)

/datum/mutation/densebones/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	REMOVE_TRAIT(owner, TRAIT_HARDLY_WOUNDED, GENETIC_MUTATION)

/datum/mutation/cerebral
	name = "Cerebral Neuroplasticity"
	desc = "A mutation that reorganizes the subject's brain, giving them more stamina while allowing for a slightly quicker recovery speed if exhausted."
	locked = TRUE
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your brain get sturdier.")
	text_lose_indication = span_notice("You feel your brain getting weaker. ")
	instability = 60
	power_coeff = 1

/datum/mutation/cerebral/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	owner.physiology?.stamina_mod *= 0.7
	owner.physiology?.stun_mod *= 0.85

/datum/mutation/cerebral/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	owner.physiology?.stamina_mod /= 0.7
	owner.physiology?.stun_mod /= 0.85
	if(GET_MUTATION_POWER(src) > 1)
		owner.physiology?.stamina_mod /= 0.85
		owner.physiology?.stun_mod /= 0.925

/datum/mutation/cerebral/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		owner.physiology?.stamina_mod *= 0.85
		owner.physiology?.stun_mod *= 0.925

/datum/mutation/fat
	name = "Obesity"
	desc = "A strange mutation that forces the body to rapidly produce lipid tissue."
	quality = NEGATIVE
	text_gain_indication = span_notice("You feel blubbery and lethargic!")
	text_lose_indication = span_notice("You feel fit!")

/datum/mutation/fat/on_life(seconds_per_tick, times_fired)
	if(HAS_TRAIT(owner, TRAIT_STASIS) || owner.stat == DEAD)
		return

	if(owner.nutrition <= NUTRITION_LEVEL_FAT)
		owner.nutrition += 25 * seconds_per_tick

/datum/mutation/no_fingerprints
	name = "Invisible Fingerprints"
	desc = "Subjects finger tips melt into a singular smooth structure, causing their fingerprints to be impossible to detect."
	quality = POSITIVE
	text_gain_indication = span_notice("Your fingers feel numb.")
	text_lose_indication = span_notice("Your fingers no longer feel numb.")
	instability = 10

/datum/mutation/no_fingerprints/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_NO_FINGERPRINTS, GENETIC_MUTATION)

/datum/mutation/no_fingerprints/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_NO_FINGERPRINTS, GENETIC_MUTATION)

/datum/mutation/no_breath
	name = "Automatic Respiration"
	desc = "Subjects lungs begin to recycle CO2 into oxygen aided with melting the subjects airpipe shut making them have no need for air."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel no need to breathe.")
	text_lose_indication = span_notice("You feel the need to breathe, once more.")
	instability = 30
	difficulty = 14

/datum/mutation/no_breath/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/no_breath/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/dizzy
	name = "Dizzy"
	desc = "Causes the subjects cerebellum to shut down in certain places causing dizzyness."
	quality = NEGATIVE
	text_gain_indication = span_danger("You suddenly start feeling very dizzy...")
	text_lose_indication = span_notice("You regain your balance.")
	instability = 15
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/dizzy/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(2.5 / GET_MUTATION_ENERGY(src), seconds_per_tick))
		to_chat(owner, span_warning("[pick("You feel dizzy.", "Your head spins.")]"))
		owner.adjust_dizzy_up_to(1 MINUTES * GET_MUTATION_SYNCHRONIZER(src) * GET_MUTATION_POWER(src), 3 MINUTES)

/datum/mutation/ear_cancer
	name = "Tinnitus"
	desc = "Causes the subjects to constantly hear a ringing noise."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_warning("You start hearing ringing in your ears.")
	text_lose_indication = span_notice("You no longer bleed from your ears.")
	instability = 5
	synchronizer_coeff = 1

/datum/mutation/ear_cancer/on_life(seconds_per_tick, times_fired)
	var/obj/item/organ/internal/ears/ears = owner.get_organ_slot(ORGAN_SLOT_EARS) // RIP THEM OUT TO STOP THE NOISE
	if(ears && SPT_PROB(5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick))
		to_chat(owner, span_warning("Your ears start to ring!"))
		SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg', 0, 1, 0, 250))
