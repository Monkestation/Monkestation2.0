/**
 * Base for all bouldertech industry machines.
 */
/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "ore_redemption"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	anchored = TRUE
	density = TRUE

	/// What is the efficiency of minerals produced by the machine?
	var/refining_efficiency = 1
	/// How many resources we can process.
	var/resources_processing_count = 2
	/// How many resources can we hold maximum?
	var/resources_held_max = 1
	/// What sound plays when a thing operates?
	var/usage_sound = 'sound/machines/mining/wooping_teleport.ogg'
	/// Silo link to its materials list.
	var/datum/component/remote_materials/silo_materials = null
	/// Mining points held by the machine for miners. If null will not collect points.
	var/points_held = null
	///The action verb to display to players
	var/action = "processing"

	/// Cooldown associated with the sound played for collecting mining points.
	COOLDOWN_DECLARE(sound_cooldown)
	/// Cooldown associated with taking in processable resources.
	COOLDOWN_DECLARE(accept_cooldown)

/obj/machinery/bouldertech/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/bouldertech/post_machine_initialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/bouldertech/Destroy()
	silo_materials = null
	var/list/current_resources = typecache_filter_list(contents, can_process_resource(null, TRUE))
	if(length(current_resources))
		for(var/obj/item/resource in current_resources)
			remove_resource(current_resources)
	return ..()

/obj/machinery/bouldertech/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = CONTEXTUAL_SCREENTIP_SET

	var/list/acceptables = list()
	for(var/obj/item/resource as anything in can_process_resource(return_typecache = TRUE))
		acceptables += resource.name
	if(length(acceptables))
		context[SCREENTIP_CONTEXT_MISC] = "Machine accepts: " + english_list(acceptables)

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Remove Resource"
		return

	if(can_process_resource(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Insert [held_item.name]"
	else if(!isnull(points_held) && (istype(held_item, /obj/item/card/id) && points_held > 0))
		context[SCREENTIP_CONTEXT_LMB] = "Claim mining points, Currently [points_held] avaliable."
	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]Anchor"
	else if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		if(istype(src, /obj/machinery/bouldertech/flatpack))
			context[SCREENTIP_CONTEXT_LMB] = "Repack Machine"
		else
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"

/obj/machinery/bouldertech/examine(mob/user)
	. = ..()
	if(!isnull(points_held))
		. += span_notice("The machine reads that it has [span_bold("[points_held] mining points")] stored. Swipe an ID to claim them.")
	. += span_notice("Click to remove a stored resource.")

	var/list/current_resources = typecache_filter_list(contents, can_process_resource(null, TRUE))
	. += span_notice("Storage capacity = <b>[length(current_resources)]/[resources_held_max] resources</b>.")
	. += span_notice("Can process up to <b>[resources_processing_count] resources</b> at a time.")

	if(anchored)
		. += span_notice("It's [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("It needs to be [EXAMINE_HINT("anchored")] to start operations.")
	. += span_notice("Its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")

	if(panel_open)
		if(istype(src, /obj/machinery/bouldertech/flatpack))
			. += span_notice("The whole machine can be [EXAMINE_HINT("pried")] back into its pack.")
		else
			. += span_notice("The whole machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/bouldertech/update_icon_state()
	. = ..()
	if(src.type == /obj/machinery/bouldertech)
		var/suffix = ""
		if(!anchored || !is_operational || (machine_stat & (BROKEN | NOPOWER)) || panel_open)
			suffix = "-off"
		icon_state ="[initial(icon_state)][suffix]"

/obj/machinery/bouldertech/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		if(anchored)
			begin_processing()
		else
			end_processing()
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/bouldertech/screwdriver_act(mob/living/user, obj/item/tool)
	if(src.type == /obj/machinery/bouldertech)
		if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-off", initial(icon_state), tool))
			update_appearance(UPDATE_ICON_STATE)
			return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/bouldertech/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/bouldertech/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored)
		return FALSE
	if(istype(mover, /obj/item) && can_process_resource(mover))
		return can_accept_resource(mover)
	return ..()

/**
 * Can we process the resource, checks only the resources state & machines capacity
 * Arguments
 *
 * * obj/item/new_resource - the resource we are checking
 */
/obj/machinery/bouldertech/proc/can_accept_resource(obj/item/new_resource)
	PRIVATE_PROC(TRUE)
	SHOULD_BE_PURE(TRUE)

	//machine not operational
	if(!anchored || panel_open || !is_operational || (machine_stat & (BROKEN | NOPOWER)))
		return FALSE

	//not a valid resource
	if(!istype(new_resource) || QDELETED(new_resource))
		return FALSE

	//someone is still processing this. Can we generalize this for all objects this machine may take?
	if(istype(new_resource, /obj/item/boulder) || istype(new_resource, /obj/item/processing))
		if(!isnull(new_resource.vars["processed_by"]))
			return FALSE

	//no space to hold resources
	var/list/current_resources = typecache_filter_list(contents, can_process_resource(new_resource, TRUE))
	if(length(current_resources) >= resources_held_max)
		return FALSE

	//did we cooldown enough to accept a resource
	return COOLDOWN_FINISHED(src, accept_cooldown)

/**
 * Accepts a resource into the machine. Used when a resource is first placed into the machine.
 * Arguments
 *
 * * obj/item/new_resource - the resource to accept
 */
/obj/machinery/bouldertech/proc/accept_resource(obj/item/new_resource)
	if(!can_accept_resource(new_resource))
		return FALSE

	new_resource.forceMove(src)

	COOLDOWN_START(src, accept_cooldown, 1.5 SECONDS)

	return TRUE

/obj/machinery/bouldertech/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

	if(!can_process_resource(atom_movable))
		return

	INVOKE_ASYNC(src, PROC_REF(accept_resource), atom_movable)


/**
 * Looks for a boost to the machine's efficiency, and applies it if found.
 * Applied more on the chemistry integration but can be used for other things if desired.
 */
/obj/machinery/bouldertech/proc/check_for_boosts()
	PROTECTED_PROC(TRUE)

	refining_efficiency = initial(refining_efficiency) //Reset refining efficiency to 100%.

/**
 * Checks if this machine can process this material
 * Arguments
 *
 * * datum/material/mat - the material to process
 */
/obj/machinery/bouldertech/proc/can_process_material(datum/material/mat)
	PROTECTED_PROC(TRUE)

	return FALSE

/**
 * Checks if this machine can process this resource object or return a typecache of what it can process.
 * Arguments
 *
 * * obj/item/res - the resource object to process
 * * return_typecache - returns current processables typecache if TRUE, will ignore res if TRUE.
 */
/obj/machinery/bouldertech/proc/can_process_resource(obj/item/res, return_typecache = FALSE)
	PROTECTED_PROC(TRUE)
	return return_typecache ? list() : FALSE

/obj/machinery/bouldertech/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(panel_open)
		return ..()

	if(can_process_resource(attacking_item))
		. = TRUE
		if(!accept_resource(attacking_item))
			balloon_alert_to_viewers("cannot accept!")
			return
		balloon_alert_to_viewers("accepted")
		return

	if(istype(attacking_item, /obj/item/card/id) && !isnull(points_held))
		. = TRUE
		if(points_held <= 0)
			balloon_alert_to_viewers("no points to claim!")
			if(!COOLDOWN_FINISHED(src, sound_cooldown))
				return
			COOLDOWN_START(src, sound_cooldown, 1.5 SECONDS)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, FALSE)
			return

		var/obj/item/card/id/id_card = attacking_item
		var/amount = tgui_input_number(user, "How many mining points do you wish to claim? ID Balance: [id_card.registered_account.mining_points], stored mining points: [points_held]", "Transfer Points", max_value = points_held, min_value = 0, round_value = 1)
		if(!amount)
			return
		if(amount > points_held)
			amount = points_held
		id_card.registered_account.mining_points += amount
		points_held = round(points_held - amount)
		to_chat(user, span_notice("You claim [amount] mining points from \the [src] to [id_card]."))
		return

	return ..()

/obj/machinery/bouldertech/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || panel_open)
		return
	if(!anchored)
		balloon_alert(user, "anchor it first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(panel_open)
		balloon_alert(user, "close panel!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/list/current_resources = typecache_filter_list(contents, can_process_resource(null, TRUE))
	if(!length(current_resources))
		balloon_alert_to_viewers("no resources to remove!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!remove_resource(pick(current_resources)))
		balloon_alert_to_viewers("no space to remove!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Accepts a boulder into the machinery, then converts it into minerals.
 * If the boulder can be fully processed by this machine, we take the materials, insert it into the silo, and destroy the boulder.
 * If the boulder has materials left, we make a copy of the boulder to hold the processable materials, take the processable parts, and eject the original boulder.
 * @param chosen_boulder The boulder to be broken down into minerals.
 */
/obj/machinery/bouldertech/proc/breakdown_boulder(obj/item/boulder/chosen_boulder)
	PROTECTED_PROC(TRUE)

	if(QDELETED(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE

	if(chosen_boulder.durability > 0)
		chosen_boulder.durability -= 1
		if(chosen_boulder.durability > 0)
			return FALSE

	//if boulders are kept inside because there is no space to eject them, then they could be reprocessed, lets avoid that
	if(!chosen_boulder.processed_by)
		check_for_boosts()
		//here we loop through the boulder's ores
		var/list/rejected_mats = list()
		//var/list/accepted_mats = list()
		var/new_points_held = 0
		//Maybe add MOVABLE_PHYSICS_PRECISION for less than 1 efficiency
		//insert_item
		for(var/datum/material/possible_mat as anything in chosen_boulder.custom_materials)
			var/quantity = chosen_boulder.custom_materials[possible_mat] * refining_efficiency
			if(!can_process_material(possible_mat) || !silo_materials.mat_container.insert_amount_mat(quantity, possible_mat))
				rejected_mats[possible_mat] = quantity / max(refining_efficiency, 1)
				continue
			else
				new_points_held = round(new_points_held + (quantity * possible_mat.points_per_unit * MINING_POINT_MACHINE_MULTIPLIER))
		use_energy(active_power_usage)
		points_held = points_held + new_points_held

		//puts back materials that couldn't be processed
		chosen_boulder.set_custom_materials(rejected_mats)

		//break the boulder down if we have processed all its materials
		if(!length(chosen_boulder.custom_materials))
			playsound(loc, usage_sound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			if(istype(chosen_boulder, /obj/item/boulder/artifact))
				points_held = round((points_held + MINER_POINT_MULTIPLIER) * MINING_POINT_MACHINE_MULTIPLIER) /// Artifacts give bonus points!
			chosen_boulder.break_apart()
			return TRUE //We've processed all the materials in the boulder, so we can just destroy it in break_apart.
		chosen_boulder.processed_by = src
	//eject the boulder since we are done with it
	remove_resource(chosen_boulder)

/**
 * Accepts an exotic into the machinery, override this to handle nonboulder resource behavior.
 * @param chosen_exotic The exotic resource to be broken down into minerals.
 */
/obj/machinery/bouldertech/proc/breakdown_exotic(obj/item/chosen_exotic)
	PROTECTED_PROC(TRUE)

	if(QDELETED(chosen_exotic))
		return FALSE
	if(chosen_exotic.loc != src)
		return FALSE

	if(istype(chosen_exotic, /obj/item/processing/refined_dust))
		var/obj/item/processing/exotic = chosen_exotic
		if(!exotic.processed_by)
			check_for_boosts()
			//here we loop through the exotics's ores
			var/list/rejected_mats = list()
			var/new_points_held = 0

			for(var/datum/material/possible_mat as anything in exotic.custom_materials)
				var/quantity = exotic.custom_materials[possible_mat]
				if(!can_process_material(possible_mat) || !silo_materials.mat_container.insert_amount_mat(quantity, possible_mat))
					rejected_mats[possible_mat] = quantity
					continue
				else
					new_points_held = round(new_points_held + (quantity * possible_mat.points_per_unit * MINING_POINT_MACHINE_MULTIPLIER))
			use_energy(active_power_usage)
			points_held = points_held + new_points_held

			//puts back materials that couldn't be processed
			exotic.set_custom_materials(rejected_mats)
			exotic.set_colors() // Set new dust color

			//break the exotic down if we have processed all its materials
			if(!length(exotic.custom_materials))
				playsound(loc, usage_sound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				qdel(exotic)
				return TRUE //We've processed all the materials in the boulder, so we can just destroy.
			exotic.processed_by = src
		//eject the boulder since we are done with it
		remove_resource(exotic)
	return FALSE

/obj/machinery/bouldertech/process()
	if(!anchored || panel_open || !is_operational || (machine_stat & (BROKEN | NOPOWER)))
		return

	var/resources_found = FALSE
	var/resources_processed = resources_processing_count
	var/list/obj/item/current_resources = typecache_filter_list(contents, can_process_resource(null, TRUE))
	for(var/obj/item/potential_resource in current_resources)
		if(resources_processed <= 0)
			break //Try again next time
		resources_found = TRUE
		resources_processed--

		if(istype(potential_resource, /obj/item/boulder))
			resources_found = !breakdown_boulder(potential_resource)
		else
			resources_found = !breakdown_exotic(potential_resource)

	//when the boulder is removed it plays sound and displays a balloon alert. don't overlap when that happens
	if(resources_found)
		playsound(loc, usage_sound, 29, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		balloon_alert_to_viewers(action)

/**
 * Ejects a resource from the machine. Used when a resource is finished processing, or when a resource can't be processed.
 * Arguments
 *
 * * obj/item/specific_resource - the resource to remove
 */
/obj/machinery/bouldertech/proc/remove_resource(obj/item/specific_resource)
	PROTECTED_PROC(TRUE)
	if(QDELETED(specific_resource))
		return TRUE

	for(var/obj/item/blocking_item in can_process_resource(specific_resource, TRUE))
		if(locate(blocking_item) in loc) //There is a resource in our loc. it has be removed so we don't clog up our loc with even more resources
			return FALSE

	if(istype(specific_resource, /obj/item/boulder))
		boulder_removal(specific_resource)
	else
		exotic_removal(specific_resource)

	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/**
 * Override to handle boulder resource removal.
 * Arguments
 *
 * * obj/item/boulder/specific_boulder - the boulder to handle and remove
 */
/obj/machinery/bouldertech/proc/boulder_removal(obj/item/boulder/specific_boulder)
	PROTECTED_PROC(TRUE)
	//Reset durability to little random lower value cause we have crushed it so many times
	var/size = specific_boulder.boulder_size
	if(size == BOULDER_SIZE_SMALL)
		specific_boulder.durability = rand(2, BOULDER_SIZE_SMALL - 1)
	else
		specific_boulder.durability = rand(BOULDER_SIZE_SMALL, size - 1)
	specific_boulder.processed_by = src //so we don't take in the boulder again after we just ejected it
	specific_boulder.forceMove(drop_location())
	specific_boulder.processed_by = null //now since move is done we can safely clear the reference

/**
 * Override to handle exotic resource removal.
 * Arguments
 *
 * * obj/item/specific_resource - the resource to handle and remove
 */
/obj/machinery/bouldertech/proc/exotic_removal(obj/item/specific_resource)
	PROTECTED_PROC(TRUE)
	if(istype(specific_resource, /obj/item/processing))
		var/obj/item/processing/mat_holder = specific_resource
		mat_holder.processed_by = src //so we don't take in the exotic again after we just ejected it
		mat_holder.forceMove(drop_location())
		mat_holder.processed_by = null //now since move is done we can safely clear the reference
