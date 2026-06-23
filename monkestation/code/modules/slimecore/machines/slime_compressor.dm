#define COMPRESSOR_BASE_EXTRACT_AMOUNT 5
#define COMPRESSOR_BASE_COMPRESS_TIME 40 SECONDS

/obj/machinery/slime_compressor
	name = "slime compressor"
	desc = "Machine used to compress slimes into extracts and crossbreeds."

	icon = 'monkestation/code/modules/slimecore/icons/slime_compressor.dmi'
	icon_state = "compressor"
	base_icon_state = "compressor"

	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/slime_compressor
	anchored = TRUE
	density = TRUE

	/// amount of time it takes to compress, scales with manipulator tier
	var/compress_time = COMPRESSOR_BASE_COMPRESS_TIME

	/// chance to get a bonus crossbreed extract
	var/bonus_extract_chance = 0

	///are we grinding some slimes
	var/active = FALSE

	/// Sound that plays when compressing
	var/datum/looping_sound/microwave/soundloop

	/// Recipes we can choose from
	var/static/list/recipe_choices = list()
	var/static/list/base_choices = list()
	var/static/list/cross_breed_choices = list()
	var/static/list/choice_to_datum = list()

	/// Recipe we have currently set
	var/datum/compressor_recipe/current_recipe

	/// Mobs we have inside the compressor
	var/list/mobs_inside = list()

	/// Base slime required for the recipe (e.g. regenerative has purple as base)
	var/datum/slime_color/base_slime_required
	/// Cross slime required to make the crossbreed
	var/datum/slime_color/cross_slime_required

	var/base_complete = FALSE
	var/cross_complete = FALSE

	COOLDOWN_DECLARE(slime_scream_cooldown)

/obj/machinery/slime_compressor/Initialize(mapload)
	. = ..()
	if(!length(recipe_choices))
		for(var/datum/compressor_recipe/listed as anything in (subtypesof(/datum/compressor_recipe) - typesof(/datum/compressor_recipe/crossbreed)))
			var/datum/compressor_recipe/stored_recipe = new listed
			recipe_choices |= list("[initial(stored_recipe.output_item.name)]" = image(icon = initial(stored_recipe.output_item.icon), icon_state = initial(stored_recipe.output_item.icon_state)))
			choice_to_datum |= list("[initial(stored_recipe.output_item.name)]" = stored_recipe)

	if(!length(cross_breed_choices))
		for(var/datum/compressor_recipe/listed as anything in (subtypesof(/datum/compressor_recipe/crossbreed)))
			var/datum/compressor_recipe/stored_recipe = new listed
			var/obj/item/slimecross/crossbreed = stored_recipe.output_item
			var/image/new_image = image(icon = initial(stored_recipe.output_item.icon), icon_state = initial(stored_recipe.output_item.icon_state))
			new_image.color = return_color_from_string(initial(crossbreed.colour))
			if(initial(crossbreed.colour) == "rainbow")
				new_image.rainbow_effect()
			base_choices |= list("[initial(stored_recipe.output_item.name)]" = new_image)
			cross_breed_choices |= list("[initial(stored_recipe.output_item.name)]" = list())

			for(var/datum/compressor_recipe/subtype as anything in subtypesof(listed))
				var/datum/compressor_recipe/subtype_stored = new subtype
				var/obj/item/slimecross/subtype_breed = subtype_stored.output_item
				var/image/subtype_image = image(icon = initial(subtype_stored.output_item.icon), icon_state = initial(subtype_stored.output_item.icon_state))
				subtype_image.color = return_color_from_string(initial(subtype_breed.colour))
				if(initial(subtype_breed.colour) == "rainbow")
					subtype_image.rainbow_effect()

				cross_breed_choices["[initial(stored_recipe.output_item.name)]"] |= list("[initial(subtype_breed.colour)] [initial(subtype_stored.output_item.name)]" = subtype_image)
				choice_to_datum |= list("[initial(subtype_breed.colour)] [initial(subtype_stored.output_item.name)]" = subtype_stored)

	soundloop = new(src, FALSE)
	register_context()

/obj/machinery/slime_compressor/RefreshParts()
	. = ..()
	var/bonus_chance = 0
	var/compression_speed = 1
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		compression_speed = manipulator.tier
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		bonus_chance = (laser.tier * 15) - 15
	compress_time = COMPRESSOR_BASE_COMPRESS_TIME / compression_speed
	bonus_extract_chance = bonus_chance

/obj/machinery/slime_compressor/Exited(atom/movable/gone, direction)
	if(gone in mobs_inside)
		mobs_inside -= gone
	return ..()

/obj/machinery/slime_compressor/examine(mob/living/user)
	. = ..()
	. += span_warning("Baby slimes seem to yield less extracts per compression...")
	if(!current_recipe)
		return
	if(base_complete && cross_complete)
		. += span_notice("The extract is ready to be made!")
		return
	if(active)
		. += span_notice("The machine is currently working!")
		return
	. += span_notice("The recipe requires:")
	if(!base_complete)
		. += span_notice("[base_slime_required.name] slime as base.")
	if(!cross_complete && cross_slime_required)
		. += span_notice("[cross_slime_required.name] slime for cross.")

/obj/machinery/slime_compressor/update_icon_state()
	. = ..()
	icon_state = active ? "compressor_active" : base_icon_state

/obj/machinery/slime_compressor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(current_recipe)
		context[SCREENTIP_CONTEXT_RMB] = "Cancel current recipe"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Select an extract to make"
		context[SCREENTIP_CONTEXT_RMB] = "Select a crossbreed to make"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/slime_compressor/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/slime_compressor/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[icon_state]_open", initial(icon_state), tool))
		clear_recipe()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/slime_compressor/wrench_act(mob/living/user, obj/item/tool)
	if(active)
		return ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool))
		clear_recipe()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/slime_compressor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !can_interact(user))
		return
	return attack_try_change_recipe(user)

/obj/machinery/slime_compressor/attack_robot(mob/user, modifiers)
	. = ..()
	if(. || !can_interact(user))
		return
	return attack_try_change_recipe(user)

/obj/machinery/slime_compressor/attack_robot_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !can_interact(user))
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	attack_secondary_try_change_recipe(user)

/obj/machinery/slime_compressor/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !can_interact(user))
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	attack_secondary_try_change_recipe(user)

/// Handles the interaction for both attack_hand and attack_robot.
/obj/machinery/slime_compressor/proc/attack_try_change_recipe(mob/living/user)
	if(!anchored)
		balloon_alert(user, "unanchored!")
		return TRUE
	if(!current_recipe)
		if(change_recipe(user))
			return TRUE
	if(!base_complete || (!cross_complete && cross_slime_required))
		return TRUE
	compress_recipe()

/// Handles the interaction for both attack_hand_secondary and attack_robot_secondary .
/obj/machinery/slime_compressor/proc/attack_secondary_try_change_recipe(mob/living/user)
	if(!anchored)
		balloon_alert(user, "unanchored!")
		return
	if(current_recipe && !active)
		clear_recipe()
		balloon_alert_to_viewers("cancelled recipe")
	else
		change_recipe(user, TRUE)

/**
 * Changing recipe
 * Arguments:
 * * cross_breed - if TRUE, will show selection for the crossbreed extracts, if not - regular.
 */
/obj/machinery/slime_compressor/proc/change_recipe(mob/user, cross_breed = FALSE)
	var/choice
	if(cross_breed)
		var/base_choice = show_radial_menu(user, src, base_choices, require_near = TRUE, tooltips = TRUE)
		if(!base_choice)
			return
		choice = show_radial_menu(user, src, cross_breed_choices[base_choice], require_near = TRUE, tooltips = TRUE)
	else
		choice = show_radial_menu(user, src, recipe_choices, require_near = TRUE, tooltips = TRUE)

	if(active || !(choice in choice_to_datum))
		return

	current_recipe = choice_to_datum[choice]
	base_slime_required = current_recipe.base_slime_color
	cross_slime_required = current_recipe.cross_slime_color

	base_complete = FALSE
	cross_complete = FALSE

	balloon_alert_to_viewers("set extract recipe")
	remove_slimes_inside()

/**
 * Clear recipe and update HUD
 */
/obj/machinery/slime_compressor/proc/clear_recipe()
	current_recipe = null
	base_complete = FALSE
	cross_complete = FALSE
	remove_slimes_inside()
	manage_hud_as_needed()

/**
 * Move all mobs in our contents out
 */
/obj/machinery/slime_compressor/proc/remove_slimes_inside()
	for(var/mob/living/victim in mobs_inside)
		if(!isslime(victim))
			continue
		victim.forceMove(get_turf(src))

/**
 * On hit we check if atom is a slime
 * Then we do check_recipe(), and if it passes, complete part of the recipe
 * After, we move the mob inside
 */
/obj/machinery/slime_compressor/hitby(atom/movable/hit_by, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(active)
		return
	if(!isslime(hit_by))
		return ..()
	if(!current_recipe)
		return ..()
	var/mob/living/basic/slime/slime = hit_by
	if(!check_recipe(slime))
		return ..()
	slime.forceMove(src)
	mobs_inside += slime
	manage_hud_as_needed()

/**
 * Check if the slime fits the recipe we have set
 */
/obj/machinery/slime_compressor/proc/check_recipe(mob/living/basic/slime/slime)
	if(!isslime(slime))
		return FALSE
	// Cleaner slimes split very fast so it would make it...too easy
	for(var/datum/slime_trait/trait in slime.slime_traits)
		if(istype(trait,/datum/slime_trait/cleaner))
			say("Slime incompatible!")
			return FALSE
	var/datum/slime_color/color = slime.current_color
	if(istype(color, base_slime_required) && !base_complete)
		if(istype(current_recipe, /datum/compressor_recipe/crossbreed))
			if(slime.slime_flags & ADULT_SLIME)
				base_complete = TRUE
				return TRUE
			say("Slime must be grown!")
			return FALSE
		base_complete = TRUE
		return TRUE
	// Crossbreed extracts can only be made with adult slimes
	else if(istype(color, cross_slime_required) && !cross_complete)
		if(slime.slime_flags & ADULT_SLIME)
			cross_complete = TRUE
			return TRUE
		say("Slime must be grown!")
	return FALSE

/**
 * Set machine to active and start compressing process
 */
/obj/machinery/slime_compressor/proc/compress_recipe()
	active = TRUE
	soundloop.start()
	update_icon_state()

	var/new_compress_time = compress_time
	// Halve compression time for regular extracts
	if(!istype(current_recipe, /datum/compressor_recipe/crossbreed))
		new_compress_time *= 0.5

	if(!machine_do_after_visable(src, new_compress_time, extra_checks = CALLBACK(src, PROC_REF(compressing))))
		active = FALSE
		soundloop.stop()
		clear_recipe()
		update_icon_state()
		return

	finish_compressing()

	manage_hud_as_needed()
	update_icon_state()

/**
 * Finish compressing
 * Deactivates machine, removes everything inside and produces the extracts
 */
/obj/machinery/slime_compressor/proc/finish_compressing()
	if(!istype(current_recipe, /datum/compressor_recipe/crossbreed))
		var/total_extract_amount
		// Slimes that had steroid used on them produce extra
		total_extract_amount += COMPRESSOR_BASE_EXTRACT_AMOUNT

		for(var/mob/living/basic/slime/slime in mobs_inside)
			if(!isslime(slime))
				continue
			total_extract_amount += slime.slime_extract_bonus
			// Baby slimes only make half of the extracts
			if(!(slime.slime_flags & ADULT_SLIME))
				total_extract_amount *= 0.5

		for(var/i in 1 to total_extract_amount)
			new current_recipe.output_item(drop_location())
	else
		new current_recipe.output_item(drop_location())
		// Chance to have a bonus extract based on parts tier
		if(prob(bonus_extract_chance))
			new current_recipe.output_item(drop_location())
	active = FALSE

	for(var/mob/living/victim in mobs_inside)
		qdel(victim)

	clear_recipe()
	soundloop.stop()

	update_icon_state()

/**
 * Checks that happen while compressing
 */
/obj/machinery/slime_compressor/proc/compressing()
	if (!active)
		return FALSE

	// somehow...?
	if(!length(mobs_inside))
		return FALSE

	if(!directly_use_energy(active_power_usage))
		say("Not enough energy!")
		return FALSE

	// Just put the thing here I suppose
	if(COOLDOWN_FINISHED(src, slime_scream_cooldown))
		screams_of_the_damned()
		COOLDOWN_START(src, slime_scream_cooldown, 5 SECONDS)

	return TRUE

// I just carried this over from slime grinder
/obj/machinery/slime_compressor/proc/screams_of_the_damned()
	for(var/mob/living/victim in mobs_inside)
		if(!isslime(victim))
			continue
		var/list/slime_blender = list(
			'monkestation/code/modules/slimecore/sounds/slimeblender1.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender2.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender3.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender4.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender5.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender6.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender7.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender8.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender9.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender10.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender11.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender12.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender14.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender13.ogg',
			'monkestation/code/modules/slimecore/sounds/slimeblender15.ogg',
		)
		playsound(src, pick(slime_blender), rand(35, 50), TRUE, mixer_channel = CHANNEL_VOICES)
		playsound(src, 'sound/machines/blender.ogg', 80, TRUE, mixer_channel = CHANNEL_MACHINERY)

#undef COMPRESSOR_BASE_EXTRACT_AMOUNT
#undef COMPRESSOR_BASE_COMPRESS_TIME
