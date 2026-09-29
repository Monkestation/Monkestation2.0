/obj/item/weldingtool
	name = "welding tool"
	desc = "A standard edition welder provided by Nanotrasen."
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	inhand_icon_state = "welder"
	worn_icon_state = "welder"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 3
	throwforce = 5
	hitsound = SFX_SWING_HIT
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	drop_sound = 'sound/items/handling/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/weldingtool_pickup.ogg'
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/item_weldingtool
	resistance_flags = FIRE_PROOF
	heat = 3800
	tool_behaviour = TOOL_WELDER
	toolspeed = 1
	wound_bonus = 10
	bare_wound_bonus = 15
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.3,
	)
	/// Whether the welding tool is on or off.
	var/welding = FALSE
	/// Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower).
	var/secured = TRUE
	/// The maximum amount of reagents the welder can hold, if it should hold any.
	var/max_fuel = 30
	/// Does the welder start with maximum fuel?
	var/starting_fuel = TRUE
	/// Whether or not we add an overlay icon based on the ratio of fuel remaining.
	var/change_icons = TRUE
	/// The sound when the welder is turned on.
	var/activation_sound = 'sound/items/welderactivate.ogg'
	/// The sound when the welder is turned off.
	var/deactivation_sound = 'sound/items/welderdeactivate.ogg'
	/// Should it automatically refuel every process?
	var/automatic_refueling = FALSE
	/// Should it process even when off?
	var/always_processing = FALSE

/datum/armor/item_weldingtool
	fire = 100
	acid = 30

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddElement(/datum/element/tool_flash, light_outer_range)
	AddElement(/datum/element/falling_hazard, damage = force, wound_bonus = wound_bonus, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

	if(max_fuel)
		create_reagents(max_fuel)
		if(starting_fuel)
			reagents.add_reagent(/datum/reagent/fuel, reagents.maximum_volume)
	if(always_processing)
		START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/weldingtool/update_icon_state()
	if(welding)
		inhand_icon_state = "[initial(inhand_icon_state)]1"
	else
		inhand_icon_state = "[initial(inhand_icon_state)]"
	return ..()

/obj/item/weldingtool/update_overlays()
	. = ..()
	. += get_charge_overlay()
	if(welding)
		. += "[initial(icon_state)]-on"

/// Gets the charge ratio overlay to include.
/obj/item/weldingtool/proc/get_charge_overlay()
	if(!change_icons)
		return
	var/ratio = reagents ? get_fuel() / max(1, reagents.maximum_volume) : 0
	ratio = CEILING(ratio * 4, 1) * 25
	return "[initial(icon_state)][ratio]"

/obj/item/weldingtool/process(seconds_per_tick)
	if(welding)
		use(1)
		open_flame()
	if(automatic_refueling && reagents && (get_fuel() < reagents.maximum_volume))
		reagents.add_reagent(/datum/reagent/fuel, 1)
		if(change_icons)
			update_appearance(UPDATE_OVERLAYS) // Our new fuel ratio could of reached a threshold, thus need to update everytime we get fuel.
	if(!welding && !always_processing)
		STOP_PROCESSING(SSobj, src)

/obj/item/weldingtool/examine(mob/user)
	. = ..()
	if(!reagents)
		return
	. += list(span_notice("It contains [reagents.total_volume] unit\s of fuel out of [reagents.maximum_volume]."))
	if(automatic_refueling)
		. += span_notice("It automatically refuels itself over time.")
	if(secured)
		. += span_notice("Looks like the fuel tank is currently secured firmly in-place.")
		. += span_notice("You could use a [EXAMINE_HINT("screwdriver")] on it to allow for attaching, modifying and accessing the fuel.")
	else
		. += span_notice("Looks like the fuel tank is loose, allowing for modifying its contents freely and attaching or modifying it.")
		. += span_notice("You could use a [EXAMINE_HINT("screwdriver")] on it to secure it in-place.")

/obj/item/weldingtool/examine_more(mob/user)
	. = ..()
	if(!reagents)
		return
	. += span_notice("You think replacing its fuel with napalm could make the flames last a lot longer.")

/obj/item/weldingtool/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] welds [user.p_their()] every orifice closed! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS

/obj/item/weldingtool/cyborg_unequip(mob/user)
	if(!welding)
		return
	switched_off(user)

/obj/item/weldingtool/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(!istype(tool, /obj/item/stack/rods) || secured)
		return
	var/obj/item/stack/rods/used_rods = tool
	if(!used_rods.use(1))
		to_chat(user, span_warning("You need one rod to start building a flamethrower!"))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/flamethrower/flamethrower_frame = new(get_turf(src))
	if(!remove_item_from_storage(flamethrower_frame, user))
		user.transferItemToLoc(src, flamethrower_frame, TRUE)
	flamethrower_frame.weldtool = src
	add_fingerprint(user)
	to_chat(user, span_notice("You add a rod to a welder, starting to build a flamethrower."))
	return ITEM_INTERACT_SUCCESS

/obj/item/weldingtool/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!secured && interacting_with.is_refillable())
		reagents.trans_to(interacting_with, reagents.total_volume, transferred_by = user)
		to_chat(user, span_notice("You empty [src]'s fuel tank into [interacting_with]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	if(!ishuman(interacting_with))
		return NONE
	if(user.istate & ISTATE_HARM)
		return NONE
	return try_heal_loop(interacting_with, user)

/// Attempts to heal a human's robotic limb with a delay. May loop itself until an attempt fails.
/obj/item/weldingtool/proc/try_heal_loop(atom/interacting_with, mob/living/user, repeating = FALSE)
	var/mob/living/carbon/human/attacked_humanoid = interacting_with
	var/obj/item/bodypart/affecting = attacked_humanoid.get_bodypart(check_zone(user.zone_selected))
	if(isnull(affecting) || !IS_ROBOTIC_LIMB(affecting))
		return NONE
	if(!affecting.brute_dam)
		balloon_alert(user, "limb not damaged")
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] starts to fix some of the dents on [attacked_humanoid == user ? user.p_their() : "[attacked_humanoid]'s"] [affecting.name]."),
		span_notice("You start fixing some of the dents on [attacked_humanoid == user ? "your" : "[attacked_humanoid]'s"] [affecting.name]."))
	var/use_delay = repeating ? 1 SECONDS : 0
	if(user == attacked_humanoid)
		use_delay = 5 SECONDS
	if(!use_tool(attacked_humanoid, user, use_delay, volume = 50, amount = 1))
		return ITEM_INTERACT_BLOCKING
	if(!item_heal_robotic(attacked_humanoid, user, brute_heal = 15, burn_heal = 0))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(try_heal_loop), interacting_with, user, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/weldingtool/screwdriver_act(mob/living/user, obj/item/tool)
	if(welding)
		to_chat(user, span_warning("Turn it off first!"))
		return ITEM_INTERACT_BLOCKING
	secured = !secured
	if(secured)
		to_chat(user, span_notice("You resecure [src] and close the fuel tank."))
		reagents.flags &= ~(OPENCONTAINER)
	else
		to_chat(user, span_notice("[src] can now be attached, modified, and refuelled."))
		reagents.flags |= OPENCONTAINER
	add_fingerprint(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/weldingtool/attack_self(mob/user)
	if(welding)
		switched_off()
		return
	if(!secured)
		to_chat(user, span_warning("[src] can't be turned on while unsecured!"))
		return
	if(reagents.has_reagent(/datum/reagent/toxin/plasma))
		message_admins("[ADMIN_LOOKUPFLW(user)] activated a rigged welder at [AREACOORD(user)].")
		user.log_message("activated a rigged welder", LOG_VICTIM)
		var/plasma_amount = reagents.get_reagent_amount(/datum/reagent/toxin/plasma)
		dyn_explosion(src, plasma_amount / 5, explosion_cause = src) // 20 plasma in a standard welder has a 4 power explosion. No breaches, but enough to kill/dismember the holder.
		qdel(src)
		return
	if(!get_fuel())
		balloon_alert(user, "no fuel!")
		return
	switched_on(user)

/obj/item/weldingtool/afterattack(atom/target, mob/user, click_parameters)
	if(!welding)
		return
	use(2)
	var/turf/location = get_turf(user)
	location.hotspot_expose(700, 50, 1)
	if(QDELETED(target) || !isliving(target)) // Can't ignite something that doesn't exist.
		return
	var/mob/living/attacked_mob = target
	if(!attacked_mob.ignite_mob())
		return
	message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(attacked_mob)] on fire with [src] at [AREACOORD(user)]")
	user.log_message("set [key_name(attacked_mob)] on fire with [src].", LOG_ATTACK)

/obj/item/weldingtool/use(used = 0)
	. = ..()
	if(!. || !welding)
		return FALSE
	if(!consume_fuel(used))
		return FALSE
	if(!get_fuel())
		set_welding(FALSE)
		switched_off()
		return FALSE
	if(change_icons)
		update_appearance(UPDATE_OVERLAYS) // Since our fuel ratio could be different, we need to ensure the overlays are accurate.
	return TRUE

/obj/item/weldingtool/use_tool(atom/target, mob/living/user, delay, amount, volume, datum/callback/extra_checks, interaction_key)
	var/mutable_appearance/sparks = mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, src, ABOVE_LIGHTING_PLANE)
	target.add_overlay(sparks)
	LAZYADD(update_overlays_on_z, sparks)
	. = ..()
	LAZYREMOVE(update_overlays_on_z, sparks)
	target.cut_overlay(sparks)

/obj/item/weldingtool/tool_use_check(mob/living/user, amount)
	if(!welding)
		to_chat(user, span_warning("[src] has to be on to complete this task!"))
		return FALSE
	if(get_fuel() < amount)
		to_chat(user, span_warning("You need more welding fuel to complete this task!"))
		return FALSE
	return TRUE

/obj/item/weldingtool/get_temperature()
	return welding * heat

/obj/item/weldingtool/ignition_effect(atom/ignitable_atom, mob/user)
	if(use_tool(ignitable_atom, user, 0 SECONDS, amount = 1))
		return span_notice("[user] casually lights [ignitable_atom] with [src], what a badass.")
	return ""

/// Returns the amount of fuel in the welder.
/obj/item/weldingtool/proc/get_fuel()
	return reagents.get_multiple_reagent_amounts(list(/datum/reagent/fuel, /datum/reagent/napalm))

/// Uses fuel from the welding tool.
/obj/item/weldingtool/proc/consume_fuel(amount)
	if(!amount)
		return TRUE
	if(reagents.remove_reagent(/datum/reagent/fuel, amount) || reagents.remove_reagent(/datum/reagent/napalm, amount * 0.5))
		return TRUE
	return FALSE

/// Toggles the welding value.
/obj/item/weldingtool/proc/set_welding(new_value)
	if(welding == new_value)
		return
	. = welding
	welding = new_value
	set_light_on(welding)

/// Switches the welder on.
/obj/item/weldingtool/proc/switched_on(mob/user)
	set_welding(TRUE)
	playsound(src, activation_sound, 50, TRUE)
	force = 15
	damtype = BURN
	hitsound = 'sound/items/welder.ogg'
	update_appearance()
	if(!always_processing)
		START_PROCESSING(SSobj, src)

/// Switches the welder off.
/obj/item/weldingtool/proc/switched_off(mob/user)
	set_welding(FALSE)
	playsound(src, deactivation_sound, 50, TRUE)
	force = initial(force)
	damtype = BRUTE
	hitsound = SFX_SWING_HIT
	update_appearance()
	if(!always_processing)
		STOP_PROCESSING(SSobj, src)

/obj/item/weldingtool/empty
	starting_fuel = FALSE

/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.3,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.1,
	)
	max_fuel = 15
	change_icons = FALSE

/obj/item/weldingtool/mini/empty
	starting_fuel = FALSE

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	custom_materials = list(
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.6,
	)
	max_fuel = 60

/obj/item/weldingtool/largetank/empty
	starting_fuel = FALSE

/obj/item/weldingtool/largetank/cyborg
	desc = "An advanced welder designed to be used in robotic systems. Custom framework doubles the speed of welding."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"
	toolspeed = 0.5

/obj/item/weldingtool/largetank/cyborg/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return NONE // No flamethrowers allowed.

/obj/item/weldingtool/hugetank
	name = "upgraded industrial welding tool"
	desc = "An upgraded welder based of the industrial welder."
	icon_state = "upindwelder"
	inhand_icon_state = "upindwelder"
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.2,
	)
	max_fuel = 90

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	light_system = NO_LIGHT_SUPPORT
	light_outer_range = 0
	toolspeed = 0.1
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.25,
		/datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2.5,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT,
	)
	change_icons = FALSE
	automatic_refueling = TRUE
	always_processing = TRUE

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "An experimental welder capable of self-fuel generation and less harmful to the eyes."
	icon_state = "exwelder"
	inhand_icon_state = "exwelder"
	light_outer_range = 1
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.5
	custom_materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 2,
	)
	max_fuel = 60
	change_icons = FALSE
	automatic_refueling = TRUE
	always_processing = TRUE

/obj/item/weldingtool/electric
	name = "electrical welding tool"
	desc = "An experimental welding tool capable of welding functionality through the use of electricity. The flame seems almost cold."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "arc_welder"
	light_power = 1
	light_color = LIGHT_COLOR_HALOGEN
	toolspeed = 0.2
	change_icons = FALSE
	activation_sound = 'sound/effects/sparks4.ogg'
	deactivation_sound = 'sound/effects/sparks4.ogg'
	max_fuel = null
	starting_fuel = FALSE
	/// The energy cost per unit of fuel usage. This should never be zero.
	var/power_cost = 0.0025 * STANDARD_CELL_CHARGE // 4000 uses by default.
	/// The cell that we are using to power the welder. Will be created & applied upon initialization.
	var/obj/item/stock_parts/power_store/stored_cell = /obj/item/stock_parts/power_store/cell/high

/obj/item/weldingtool/electric/Initialize(mapload)
	. = ..()
	if(ispath(stored_cell))
		stored_cell = new stored_cell(src)

/obj/item/weldingtool/electric/Destroy(force)
	if(stored_cell)
		QDEL_NULL(stored_cell)
	return ..()

/obj/item/weldingtool/electric/get_charge_overlay()
	if(!change_icons)
		return
	var/ratio = stored_cell ? get_fuel() / max(1, stored_cell.maxcharge / power_cost) : 0
	ratio = CEILING(ratio * 4, 1) * 25
	return "[initial(icon_state)][ratio]"

/obj/item/weldingtool/electric/process(seconds_per_tick)
	if(welding)
		use(1)
	if(automatic_refueling && stored_cell?.used_charge())
		stored_cell.give(power_cost) // Refunds a unit's worth of power.
		if(change_icons)
			update_appearance(UPDATE_OVERLAYS)
	if(!welding && !always_processing)
		STOP_PROCESSING(SSobj, src)

/obj/item/weldingtool/electric/examine(mob/user)
	. = ..()
	if(!stored_cell)
		. += span_notice("It does not have a cell inserted!")
	else
		. += span_notice("It has [stored_cell] inserted with [stored_cell.percent()]% charge left.")
		. += span_notice("[EXAMINE_HINT("Ctrl+Shift+Click")] to eject it.")
	if(automatic_refueling)
		. += span_notice("It automatically charges itself over time.")
	if(secured)
		. += span_notice("Looks like the cell slot is currently secured firmly in-place.")
		. += span_notice("You could use a [EXAMINE_HINT("screwdriver")] on it to allow attachment or modifications.")
	else
		. += span_notice("Looks like the cell slot is loose, allowing for attachment or modifications.")
		. += span_notice("You could use a [EXAMINE_HINT("screwdriver")] on it to secure it in-place.")

/obj/item/weldingtool/electric/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stock_parts/power_store/cell))
		if(stored_cell)
			to_chat(user, span_notice("[src] already has a cell inside of it."))
			return ITEM_INTERACT_BLOCKING
		if(!user.temporarilyRemoveItemFromInventory(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand!"))
			return ITEM_INTERACT_BLOCKING
		playsound(src, 'sound/weapons/magout.ogg', 40, TRUE)
		stored_cell = tool
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/weldingtool/electric/screwdriver_act(mob/living/user, obj/item/tool)
	if(welding)
		to_chat(user, span_warning("Turn it off first!"))
		return ITEM_INTERACT_BLOCKING
	secured = !secured
	if(secured)
		to_chat(user, span_notice("You resecure [src] and close cell slot."))
	else
		to_chat(user, span_notice("[src] can now be attached or modified."))
	add_fingerprint(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/weldingtool/electric/attack_self(mob/user)
	if(welding)
		switched_off()
		return
	if(!secured)
		to_chat(user, span_warning("[src] can't be turned on while unsecured!"))
		return
	if(!stored_cell)
		balloon_alert(user, "no cell!")
		return
	if(!get_fuel())
		balloon_alert(user, "no charge!")
		return
	switched_on(user)

/obj/item/weldingtool/electric/get_fuel()
	if(!stored_cell)
		return 0
	return ROUND_UP(stored_cell.charge / power_cost)

// We use power instead of fuel.
/obj/item/weldingtool/electric/consume_fuel(amount = 0)
	if(!amount)
		return TRUE
	if(stored_cell?.use(power_cost * amount))
		return TRUE
	return FALSE

/obj/item/weldingtool/electric/click_ctrl_shift(mob/user)
	if(!can_interact(user) || !stored_cell)
		return
	if(secured)
		to_chat(user, span_notice("[src]'s cell slot needs to be unsecured first!"))
		return
	to_chat(user, span_notice("You remove [stored_cell] from [src]!"))
	playsound(src, 'sound/weapons/magout.ogg', 40, TRUE)
	user.put_in_hands(stored_cell)
	stored_cell = null
	if(welding)
		switched_off()

/obj/item/weldingtool/electric/arc_welder
	name = "arc welding tool"
	desc = "A specialized welding tool utilizing high powered arcs of electricity to weld things together. \
		Compared to other electrically-powered welders, this model is slow and highly power inefficient, \
		but it still gets the job done and chances are you printed this bad boy off for free."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "arc_welder"
	usesound = 'monkestation/code/modules/blueshift/sounds/arc_welder/arc_welder.ogg'
	light_outer_range = 2
	light_power = 0.75
	toolspeed = 1
	power_cost = 0.01 * STANDARD_CELL_CHARGE  // 1000 uses by default.

/obj/item/weldingtool/electric/arc_welder/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/item/weldingtool/electric/raynewelder
	name = "laser welding tool"
	desc = "A Rayne corp laser cutter and welder. This Laser welder has a built in safety to turn off outside Nanotrasens designated shipbreaking area."
	icon = 'icons/obj/rayne_corp/rayne.dmi'
	icon_state = "raynewelder"
	inhand_icon_state = "raynewelder"
	lefthand_file = 'icons/mob/inhands/equipment/engineering_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/engineering_righthand.dmi'
	light_power = 1
	light_color = LIGHT_COLOR_FLARE
	toolspeed = 0.2
	power_cost = 0.002 * STANDARD_CELL_CHARGE // 5000 uses by default.

/obj/item/weldingtool/electric/raynewelder/hacked
	name = "modified laser welding tool"
	desc = "A Rayne corp laser cutter and welder. This one seems to have been refitted by the Syndicate for general salvage use, though the removal of its safety measures has slightly reduced its efficiency."
	toolspeed = 0.3
	power_cost = 0.0025 * STANDARD_CELL_CHARGE // 4000 uses by default.
