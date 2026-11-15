#define BASELINE_ACTION_TIME (4 SECONDS)

//Yes most of this stolen from normal forge deal with it

/// The basline for how long an item such as molten glass will be kept workable after heating
#define BASELINE_HEATING_DURATION (25 SECONDS)

/// The amount the forge's temperature will change per process
#define FORGE_DEFAULT_TEMPERATURE_CHANGE 5
/// The maximum temperature the forge can reach
#define MAX_FORGE_TEMP 100
/// The minimum temperature for using the forge
#define MIN_FORGE_TEMP 50
/// The duration that objects heated in the forge are heated for
#define FORGE_HEATING_DURATION (1 MINUTES)

/// Defines for different levels of the forge, ranging from no level (you play like a noob) to legendary
#define FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB 1
#define FORGE_LEVEL_NOVICE 2
#define FORGE_LEVEL_APPRENTICE 3
#define FORGE_LEVEL_JOURNEYMAN 4
#define FORGE_LEVEL_EXPERT 5
#define FORGE_LEVEL_MASTER 6
#define FORGE_LEVEL_LEGENDARY 7

/// The maximum amount of temperature loss decrease that upgrades can give the forge
#define MAX_TEMPERATURE_LOSS_DECREASE 5

/// The chance per piece of wood added that charcoal will form later
#define CHARCOAL_CHANCE 45

/// Defines for the different levels of smoke coming out of the forge, (good, neutral, bad) are all used for baking, (not cooking) is used for when there is no tray in the forge
#define SMOKE_STATE_NONE 0
#define SMOKE_STATE_GOOD 1
#define SMOKE_STATE_NEUTRAL 2
#define SMOKE_STATE_BAD 3
#define SMOKE_STATE_NOT_COOKING 4
/obj/structure/alloy_forge
	name = "alloy forge"
	desc = "A humble smithy for blending two materials into one material with a blend of their stats."
	icon = 'monkestation/code/modules/blueshift/icons/obj/forge_structures.dmi'
	icon_state = "forge_inactive"
	bound_width = 32
	bound_height = 32
	anchored = TRUE
	density = TRUE
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF

	/// What the current internal temperature of the forge is
	var/forge_temperature = 0
	/// What temperature the forge is moving towards
	var/target_temperature = 0
	/// What the minimum target temperature is, used for upgrades
	var/minimum_target_temperature = 0
	/// What is the current reduction for temperature decrease
	var/temperature_loss_reduction = 0
	/// How many seconds of weak fuel (wood) does the forge have left
	var/forge_fuel_weak = 0
	/// How many seconds of strong fuel (coal) does the forge have left
	var/forge_fuel_strong = 0
	/// Cooldown time for processing on the forge
	COOLDOWN_DECLARE(forging_cooldown)
	/// Is the forge in use or not? If true, prevents most interactions with the forge
	var/in_use = FALSE
	/// The current 'level' of the forge, how upgraded is it from one to seven
	var/forge_level = FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB
	/// What smoke particles should be coming out of the forge
	var/smoke_state = SMOKE_STATE_NONE
	/// List of possible choices for the selection radial
	var/list/radial_choice_list = list()
	///Currently used particle type, if any
	var/particle_type

	///the item in our first slot for merging
	var/atom/movable/slot_one_item
	///the item in our second slot for merging
	var/atom/movable/slot_two_item

	var/list/fuels = list(/obj/item/stack/sheet/mineral/wood = FALSE, \
	/obj/item/stack/sheet/mineral/coal = TRUE, \
	/obj/item/stack/sheet/mineral/plasma = TRUE \
	)

/obj/structure/alloy_forge/Initialize(mapload)
	. = ..()
	register_context()
	START_PROCESSING(SSobj, src)
	update_appearance()
	upgrade_forge(forced = TRUE)

/obj/structure/alloy_forge/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/alloy_forge/proc/check_temp()
	if(forge_temperature > target_temperature) // Being above the target temperature will cause the forge to cool down
		forge_temperature -= (FORGE_DEFAULT_TEMPERATURE_CHANGE - temperature_loss_reduction)
		return

	else if((forge_temperature < target_temperature) && (forge_fuel_weak || forge_fuel_strong)) // Being below the target temp, and having fuel, will cause the temp to rise
		forge_temperature += FORGE_DEFAULT_TEMPERATURE_CHANGE
		return

/obj/structure/alloy_forge/proc/check_in_use()
	if(!in_use)
		return

	for(var/mob/living/living_mob in range(1,src))
		if(!living_mob)
			in_use = FALSE

/obj/structure/alloy_forge/examine(mob/user)
	. = ..()

	if(forge_level < FORGE_LEVEL_LEGENDARY)
		. += span_notice("Using an <b>empty hand</b> on [src] will upgrade it, if your forging skill level is above the current upgrade's level.")

	if(slot_one_item)
		. += span_notice("Contains [slot_one_item] on the left side.")
	if(slot_two_item)
		. += span_notice("Contains [slot_two_item] on the right side.")

	switch(forge_level)
		if(FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB)
			. += span_notice("This forge has not been upgraded yet.")
		if(FORGE_LEVEL_NOVICE)
			. += span_notice("This forge has been upgraded by a novice smith.")
		if(FORGE_LEVEL_APPRENTICE)
			. += span_notice("This forge has been upgraded by an apprentice smith.")
		if(FORGE_LEVEL_JOURNEYMAN)
			. += span_notice("This forge has been upgraded by a journeyman smith.")
		if(FORGE_LEVEL_EXPERT)
			. += span_notice("This forge has been upgraded by an expert smith.")
		if(FORGE_LEVEL_MASTER)
			. += span_notice("This forge has been upgraded by a master smith.")
		if(FORGE_LEVEL_LEGENDARY)
			. += span_hierophant("This forge has been upgraded by a legendary smith.") // Legendary skills give you the greatest gift of all, cool text

	switch(temperature_loss_reduction)
		if(0)
			. += span_notice("[src] will lose heat at a normal rate.")
		if(1)
			. += span_notice("[src] will lose heat slightly slower than usual.")
		if(2)
			. += span_notice("[src] will lose heat a bit slower than usual.")
		if(3)
			. += span_notice("[src] will lose heat much slower than usual.")
		if(4)
			. += span_notice("[src] will lose heat signficantly slower than usual.")
		if(5)
			. += span_notice("[src] will lose heat at a practically negligible rate.")
	. += span_notice("<br>[src] is currently [forge_temperature] degrees hot, going towards [target_temperature] degrees.<br>")
	return .


/obj/structure/alloy_forge/proc/refuel(obj/item/stack/refueling_stack, mob/living/user, is_strong_fuel = FALSE)
	in_use = TRUE
	if(is_strong_fuel)
		if(forge_fuel_strong >= 5 MINUTES)
			fail_message(user, "[src] is full on regular fuel")
			return
	if(forge_fuel_weak >= 5 MINUTES)
		fail_message(user, "[src] is full on weak fuel")
		return
	balloon_alert_to_viewers("refueling...")
	var/obj/item/stack/sheet/stack_sheet = refueling_stack
	if(!do_after(user, 3 SECONDS, target = src) || !stack_sheet.use(1))
		fail_message(user, "stopped fueling")
		return
	if(is_strong_fuel)
		forge_fuel_strong += 5 MINUTES
	else
		forge_fuel_weak += 5 MINUTES
	in_use = FALSE
	balloon_alert(user, "fueled [src]")
	user.mind.adjust_experience(/datum/skill/smithing, 5) // You gain small amounts of experience from useful fueling

	if(prob(CHARCOAL_CHANCE) && !is_strong_fuel)
		to_chat(user, span_notice("[src]'s fuel is packed densely enough to have made some charcoal!"))
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/alloy_forge,spawn_coal)), 1 MINUTES)

/obj/structure/alloy_forge/proc/spawn_coal()
	var/obj/item/stack/sheet/mineral/coal/spawn_coal = new(get_turf(src))
	spawn_coal.name = "charcoal"

/obj/structure/alloy_forge/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item)
		if(held_item.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_RMB] = "Deconstruct."
		if(held_item.type in fuels)
			context[SCREENTIP_CONTEXT_RMB] = "Refuel"
	if((!slot_one_item || !slot_two_item) && (isstack(held_item) || istype(held_item, /obj/item/merged_material)))
		context[SCREENTIP_CONTEXT_LMB] = "Add material to alloy."
	if(slot_one_item && slot_two_item)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Alloy Materials."
	if(slot_one_item || slot_two_item)
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Empty"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/alloy_forge/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, forging_cooldown))
		return

	COOLDOWN_START(src, forging_cooldown, 5 SECONDS)
	check_fuel()
	check_temp()
	check_in_use() // This is here to ensure the forge doesn't remain in_use if it really isn't

	if(check_fuel(just_checking = TRUE))
		set_smoke_state(SMOKE_STATE_NOT_COOKING) // If there is no tray but we have fuel, use the not cooking smoke state
		return

	if(!check_fuel(just_checking = TRUE)) // If there's no fuel, remove it all
		set_smoke_state(SMOKE_STATE_NONE)
		return


///Checks the fuel and removes it if just_checking = false
/obj/structure/alloy_forge/proc/check_fuel(just_checking = FALSE)
	if(forge_fuel_strong) // Check for strong fuel (coal) first, as it has more power over weaker fuels
		if(just_checking)
			return TRUE

		forge_fuel_strong -= 5 SECONDS
		target_temperature = 100
		return TRUE

	if(forge_fuel_weak) // If there's no strong fuel, maybe we have weak fuel (wood)
		if(just_checking)
			return TRUE

		forge_fuel_weak -= 5 SECONDS
		target_temperature = 50
		return TRUE

	if(just_checking)
		return FALSE

	target_temperature = minimum_target_temperature // If the forge has no fuel, then we should lowly return to the minimum lowest temp we can do
	return FALSE

/// Sets the type of particles that the forge should be generating
/obj/structure/alloy_forge/proc/set_smoke_state(new_state)
	if(new_state == smoke_state)
		return

	smoke_state = new_state

	if (particle_type)
		remove_shared_particles("[particle_type]_reagent_forge")
		particle_type = null

	switch(smoke_state)
		if(SMOKE_STATE_NONE)
			icon_state = "forge_inactive"
			set_light(0, 0) // If we aren't heating up and thus not on fire, turn the fire light off
			return
		if(SMOKE_STATE_BAD)
			particle_type = /particles/smoke
		if(SMOKE_STATE_NEUTRAL)
			particle_type = /particles/smoke/steam
		if(SMOKE_STATE_GOOD)
			particle_type = /particles/smoke/steam/mild
		if(SMOKE_STATE_NOT_COOKING)
			particle_type = /particles/smoke/mild

	if(particle_type)
		var/obj/effect/abstract/shared_particle_holder/smoke = add_shared_particles(particle_type, "[particle_type]_reagent_forge")
		smoke.particles.position = list(6, 4, 0)

	icon_state = "forge_active"
	set_light(3, 1, LIGHT_COLOR_FIRE)

/obj/structure/alloy_forge/attackby(obj/item/attacking_item, mob/living/user, params)

	if(isstack(attacking_item))
		var/obj/item/stack/stack = attacking_item
		if(!stack.material_type)
			return
		if(stack.amount > 1)
			attacking_item = stack.split_stack(user, 1)

		if(try_add_to_buffer(attacking_item))
			visible_message(span_notice("[user] adds [attacking_item] into the [src]"))
			return
	if(istype(attacking_item, /obj/item/merged_material))
		if(try_add_to_buffer(attacking_item))
			visible_message(span_notice("[user] adds [attacking_item] into the [src]"))
			return
	return ..()

/obj/structure/alloy_forge/attackby_secondary(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_WRENCH)
		deconstruct()
	if(is_type_in_list(item,fuels))
		refuel(item,user,fuels[item])
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/alloy_forge/proc/try_add_to_buffer(obj/item/adder)
	if(!slot_one_item)
		slot_one_item = adder
		adder.forceMove(src)
		return TRUE
	if(!slot_two_item)
		slot_two_item = adder
		adder.forceMove(src)
		return TRUE
	return FALSE

/obj/structure/alloy_forge/click_alt(mob/user)
	if(attempt_material_forge(user))
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/structure/alloy_forge/click_alt_secondary(mob/user)
	if(slot_one_item)
		slot_one_item.forceMove(user.loc)
		slot_one_item = null
	if(slot_two_item)
		slot_two_item.forceMove(user.loc)
		slot_two_item = null

/obj/structure/alloy_forge/proc/attempt_material_forge(mob/user)
	if(!slot_one_item || !slot_two_item)
		return FALSE
	if(forge_temperature < MIN_FORGE_TEMP)
		fail_message(user, "forge too cool")
		return FALSE
	balloon_alert_to_viewers("alloying...")

	var/skill_modifier = user.mind?.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER)

	if(!do_after(user, skill_modifier * 3 SECONDS, target = src))
		fail_message(user, "stopped alloying!")
		return FALSE

	var/obj/item/merged_material/new_material = new(get_turf(src))
	if(isstack(slot_one_item))
		var/obj/item/stack/stack = slot_one_item
		new_material.create_stats_from_material(stack.material_type)
	else
		new_material.create_stats_from_material_stats(slot_one_item.material_stats)

	new_material.combine_material_stats(slot_two_item)

	new_material.name = "[new_material.material_stats.material_name] Ingot"

	QDEL_NULL(slot_one_item)
	QDEL_NULL(slot_two_item)
	return TRUE

/obj/structure/alloy_forge/proc/fail_message(mob/living/user, message)
	balloon_alert(user, message)
	in_use = FALSE

/obj/structure/alloy_forge/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	upgrade_forge(user)

/obj/structure/alloy_forge/attack_robot(mob/living/user)
	. = ..()
	upgrade_forge(user)
///Upgrades the forge.
/obj/structure/alloy_forge/proc/upgrade_forge(mob/living/user, forced = FALSE)
	var/level_to_upgrade_to

	if(forced || !user) // This is to make sure the ready subtype of forge still works
		level_to_upgrade_to = forge_level
	else
		level_to_upgrade_to = user.mind.get_skill_level(/datum/skill/smithing)

	if((forge_level == level_to_upgrade_to) && !forced)
		to_chat(user, span_notice("[src] was already upgraded by your level of expertise!"))
		return

	switch(level_to_upgrade_to) // Remember to carry things over from past levels in case someone skips levels in upgrading
		if(SKILL_LEVEL_NONE)
			if(!forced)
				to_chat(user, span_notice("You'll need some forging skills to really understand how to upgrade [src]."))
			return

		if(SKILL_LEVEL_NOVICE)
			if(!forced)
				to_chat(user, span_notice("With some experience, you've come to realize there are some easily fixable spots with poor insulation..."))
			temperature_loss_reduction = 1
			forge_level = FORGE_LEVEL_NOVICE

		if(SKILL_LEVEL_APPRENTICE)
			if(!forced)
				to_chat(user, span_notice("Further insulation and protection of the thinner areas means [src] will lose heat just that little bit slower."))
			temperature_loss_reduction = 2
			forge_level = FORGE_LEVEL_APPRENTICE

		if(SKILL_LEVEL_JOURNEYMAN)
			if(!forced)
				to_chat(user, span_notice("Some careful placement and stoking of the flame will allow you to keep at least the embers burning..."))
			minimum_target_temperature = 25 // Will allow quicker reheating from having no fuel
			temperature_loss_reduction = 3
			forge_level = FORGE_LEVEL_JOURNEYMAN

		if(SKILL_LEVEL_EXPERT)
			if(!forced)
				to_chat(user, span_notice("[src] has become nearly perfect, able to hold heat for long enough that even a piece of wood can outmatch the longevity of lesser forges."))
			temperature_loss_reduction = 4
			minimum_target_temperature = 25
			forge_level = FORGE_LEVEL_EXPERT

		if(SKILL_LEVEL_MASTER)
			if(!forced)
				to_chat(user, span_notice("The perfect forge for a perfect metalsmith, with your knowledge it should bleed heat so slowly, that not even you will live to see [src] cool."))
			temperature_loss_reduction = MAX_TEMPERATURE_LOSS_DECREASE
			minimum_target_temperature = 25
			forge_level = FORGE_LEVEL_MASTER

	playsound(src, 'sound/items/weapons/parry.ogg', 50, TRUE) // Play a feedback sound to really let players know we just did an upgrade


/obj/structure/alloy_forge/deconstruct(disassembled)
	new /obj/item/stack/sheet/mineral/stone/ten(get_turf(src))
	return ..()

#undef BASELINE_ACTION_TIME

#undef BASELINE_HEATING_DURATION

#undef FORGE_DEFAULT_TEMPERATURE_CHANGE
#undef MAX_FORGE_TEMP
#undef MIN_FORGE_TEMP
#undef FORGE_HEATING_DURATION

#undef FORGE_LEVEL_YOU_PLAY_LIKE_A_NOOB
#undef FORGE_LEVEL_NOVICE
#undef FORGE_LEVEL_APPRENTICE
#undef FORGE_LEVEL_JOURNEYMAN
#undef FORGE_LEVEL_EXPERT
#undef FORGE_LEVEL_MASTER
#undef FORGE_LEVEL_LEGENDARY

#undef MAX_TEMPERATURE_LOSS_DECREASE

#undef CHARCOAL_CHANCE


#undef SMOKE_STATE_NONE
#undef SMOKE_STATE_GOOD
#undef SMOKE_STATE_NEUTRAL
#undef SMOKE_STATE_BAD
#undef SMOKE_STATE_NOT_COOKING
