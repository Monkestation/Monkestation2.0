/// Biomass from one monkey or monkey cube.
#define BIOMASS_MONKEY_YIELD 0.4
/// Hurt critters are worth less biomass, but never less than this much of their full value.
#define BIOMASS_MINIMUM_CONDITION 0.25
/// How much more biomass we get for each part tier above 1.
#define BIOMASS_PART_EFFICIENCY_STEP 0.25
/// Printing a creature costs its biomass_value times this.
#define BIOMASS_PRINT_COST_MULTIPLIER 2

/// Turns creatures into biomass, and biomass into cubes and creatures.
/obj/machinery/biomass_recycler
	name = "biomass recycler"
	desc = "A machine used for recycling creatures and fabricating dehydrated biomass."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	base_icon_state = "grinder"
	layer = BELOW_OBJ_LAYER
	interaction_flags_mouse_drop = NEED_DEXTERITY
	density = TRUE
	circuit = /obj/item/circuitboard/machine/biomass_recycler

	/// Biomass available for printing cubes and creatures.
	var/biomass = 0
	/// Multiplier applied to biomass gained from recycled creatures.
	var/recycling_efficiency = 1
	/// Items available from the machine's radial menu.
	var/static/list/printable_items = list(
		/obj/item/food/monkeycube = 1,
		/obj/item/stack/biomass = 1,
		/obj/item/slime_breeding_pellet = 2,
	)
	/// Critters you can print right away, no unlocks needed.
	var/static/list/baseline_species = list(/mob/living/basic/cockroach/iceroach)

/obj/machinery/biomass_recycler/post_machine_initialize()
	. = ..()
	for(var/obj/machinery/extract_compressor/compressor in range(COMPRESSOR_LINK_RANGE, src))
		compressor.link_nearest_recycler()

/obj/machinery/biomass_recycler/RefreshParts()
	. = ..()
	var/total_part_tier = 0
	var/part_count = 0
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		total_part_tier += manipulator.tier
		part_count++
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		total_part_tier += matter_bin.tier
		part_count++
	if(!part_count)
		recycling_efficiency = 1
		return
	var/average_part_tier = total_part_tier / part_count
	recycling_efficiency = 1 + (average_part_tier - 1) * BIOMASS_PART_EFFICIENCY_STEP

/obj/machinery/biomass_recycler/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: <b>[biomass]</b> unit\s of biomass at <b>[recycling_efficiency * 100]%</b> recycling efficiency.")
		. += span_notice("Its catalog lists <b>[length(get_printable_species())]</b> printable creature\s. More unlock as slimes mutate.")

/obj/machinery/biomass_recycler/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_unfasten_wrench(user, tool))
		power_change()
		for(var/obj/machinery/extract_compressor/compressor in range(COMPRESSOR_LINK_RANGE, src))
			compressor.link_nearest_recycler()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/biomass_recycler/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[base_icon_state]_open", base_icon_state, tool)

/obj/machinery/biomass_recycler/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/biomass_recycler/update_icon_state()
	. = ..()
	icon_state = panel_open ? "[base_icon_state]_open" : base_icon_state

/// Whether the machine is powered, anchored, and has its panel shut.
/obj/machinery/biomass_recycler/proc/is_available()
	return is_operational && anchored && !panel_open

/obj/machinery/biomass_recycler/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_available())
		return NONE
	if(istype(tool, /obj/item/storage/bag/xeno))
		var/inserted_biomass = 0
		for(var/obj/item/stack/biomass/biomass_cubes in tool)
			inserted_biomass += biomass_cubes.amount
			qdel(biomass_cubes)
		for(var/obj/item/food/monkeycube/monkey_cube in tool)
			inserted_biomass += BIOMASS_MONKEY_YIELD
			qdel(monkey_cube)
		if(!inserted_biomass)
			balloon_alert(user, "no biomass!")
			return ITEM_INTERACT_BLOCKING
		biomass = round(biomass + inserted_biomass, 0.01)
		to_chat(user, span_notice("You empty [inserted_biomass] biomass cube\s from [tool] into [src]."))
		balloon_alert(user, "biomass inserted")
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/food/monkeycube))
		biomass = round(biomass + BIOMASS_MONKEY_YIELD, 0.01)
		qdel(tool)
		to_chat(user, span_notice("You recycle a monkey cube into [BIOMASS_MONKEY_YIELD] biomass."))
		balloon_alert(user, "biomass inserted")
		return ITEM_INTERACT_SUCCESS
	if(!istype(tool, /obj/item/stack/biomass))
		return NONE
	var/obj/item/stack/biomass/biomass_cubes = tool
	var/inserted_biomass = biomass_cubes.amount
	biomass += inserted_biomass
	qdel(biomass_cubes)
	to_chat(user, span_notice("You insert [inserted_biomass] biomass cube\s into [src]."))
	balloon_alert(user, "biomass inserted")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/biomass_recycler/mouse_drop_receive(mob/living/target, mob/living/user, params)
	if(!user.Adjacent(src) || !user.Adjacent(target) || !user.can_perform_action(src))
		return
	recycle(target, user, feedback = TRUE)

/// Returns the base biomass supplied by an eligible creature, scaled by how much it's been nomed on or whacked already
/obj/machinery/biomass_recycler/proc/recycle_value(mob/living/target)
	if(ismonkeybasic(target))
		return BIOMASS_MONKEY_YIELD
	var/mob/living/basic/basic_target = target
	if(!istype(basic_target))
		return 0
	var/condition = basic_target.maxHealth > 0 ? basic_target.health / basic_target.maxHealth : 1
	return basic_target.biomass_value * clamp(condition, BIOMASS_MINIMUM_CONDITION, 1)

/// Checks machine and creature state without imposing a range on remote vacuum use.
/obj/machinery/biomass_recycler/proc/can_recycle(mob/living/target, mob/living/user, feedback = FALSE)
	if(QDELETED(target) || !isturf(target.loc) || recycle_value(target) <= 0)
		if(feedback)
			user.balloon_alert(user, "cannot recycle")
		return FALSE
	if(!is_available())
		if(feedback)
			user.balloon_alert(user, "recycler unavailable")
		return FALSE
	if(ismonkeybasic(target) && target.stat == CONSCIOUS)
		if(feedback)
			user.balloon_alert(user, "monkey is too alert")
		return FALSE
	if(target.client || target.mind || target.anchored || target.buckled || target.has_buckled_mobs())
		if(feedback)
			user.balloon_alert(user, "cannot recycle")
		return FALSE
	return TRUE

/// Deletes the creature and adds its biomass. Returns FALSE if it can't be recycled.
/obj/machinery/biomass_recycler/proc/recycle(mob/living/target, mob/living/user, feedback = FALSE)
	if(!can_recycle(target, user, feedback))
		return FALSE
	var/target_name = target.name
	var/biomass_yield = round(recycle_value(target) * recycling_efficiency, 0.01)
	target.unequip_everything()
	qdel(target)
	biomass = round(biomass + biomass_yield, 0.01)
	use_energy(active_power_usage)
	playsound(src, 'sound/machines/juicer.ogg', vol = 50, vary = TRUE)
	to_chat(user, span_notice("You recycle [target_name] into [biomass_yield] unit[biomass_yield == 1 ? "" : "s"] of biomass."))
	return TRUE

/// Returns a list of creature type -> biomass cost.
/obj/machinery/biomass_recycler/proc/get_printable_species()
	var/static/list/species_costs
	if(isnull(species_costs))
		species_costs = list()
		for(var/mob/living/basic/mob_type as anything in subtypesof(/mob/living/basic))
			if(mob_type::biomass_value > 0)
				species_costs[mob_type] = mob_type::biomass_value * BIOMASS_PRINT_COST_MULTIPLIER

	. = list(/mob/living/carbon/human/species/monkey = 1)
	for(var/mob_type in baseline_species + GLOB.unlocked_xenofauna)
		.[mob_type] = species_costs[mob_type]

/// Reserves biomass before creation so linked packs cannot overspend it.
/obj/machinery/biomass_recycler/proc/purchase_type(printable_type, turf/spawn_turf)
	var/cost = printable_items[printable_type]
	if(isnull(cost))
		cost = get_printable_species()[printable_type]
	if(isnull(cost) || biomass < cost || !isturf(spawn_turf) || !is_available())
		return

	biomass -= cost
	var/atom/movable/created = new printable_type(spawn_turf)
	if(QDELETED(created))
		biomass += cost
		return
	use_energy(active_power_usage)
	return created

/obj/machinery/biomass_recycler/interact(mob/user)
	var/list/choices = list()
	var/list/types_by_name = list()
	for(var/atom/movable/printable as anything in printable_items)
		choices[printable::name] = image(icon = printable::icon, icon_state = printable::icon_state)
		types_by_name[printable::name] = printable

	var/selection = show_radial_menu(
		user,
		src,
		choices,
		custom_check = CALLBACK(src, PROC_REF(can_continue_print_menu), user),
		require_near = TRUE,
		tooltips = TRUE,
	)
	var/printable_type = types_by_name[selection]
	if(!printable_type || !can_continue_print_menu(user))
		return
	var/atom/movable/created = purchase_type(printable_type, drop_location())
	if(!created)
		user.balloon_alert(user, "not enough biomass")
		return
	playsound(src, 'sound/machines/hiss.ogg', vol = 50, vary = TRUE)
	to_chat(user, span_notice("[src] hisses and dispenses [created]. It has [biomass] unit\s of biomass left."))

/obj/machinery/biomass_recycler/proc/can_continue_print_menu(mob/user)
	return user.Adjacent(src) && user.can_perform_action(src) && is_available()

/// Biomass cubes, one per unit of biomass.
/obj/item/stack/biomass
	name = "biomass cubes"
	desc = "Cubes of condensed green biomass."
	icon = 'icons/obj/xenobiology/slime_rancher/biomass.dmi'
	icon_state = "biomass"
	base_icon_state = "biomass"
	singular_name = "biomass cube"
	max_amount = 50
	merge_type = /obj/item/stack/biomass
	item_flags = parent_type::item_flags | NOBLUDGEON

/obj/item/stack/biomass/update_icon_state()
	. = ..()
	icon_state = amount == 1 ? base_icon_state : "[base_icon_state]_[min(amount, 5)]"

/obj/item/stack/biomass/twenty
	amount = 20

/obj/item/stack/biomass/fifty
	amount = 50

/obj/item/circuitboard/machine/biomass_recycler
	name = "Biomass Recycler"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/biomass_recycler
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/manipulator = 1,
	)
	needs_anchored = FALSE

/datum/design/board/biomass_recycler
	name = "Biomass Recycler Board"
	desc = "The circuit board for a biomass recycler."
	id = "biomass_recycler"
	build_path = /obj/item/circuitboard/machine/biomass_recycler
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

#undef BIOMASS_MINIMUM_CONDITION
#undef BIOMASS_MONKEY_YIELD
#undef BIOMASS_PART_EFFICIENCY_STEP
#undef BIOMASS_PRINT_COST_MULTIPLIER
