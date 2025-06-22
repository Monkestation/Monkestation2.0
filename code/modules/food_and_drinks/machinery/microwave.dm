// Microwaving doesn't use recipes, instead it calls the microwave_act of the objects.
// For food, this creates something based on the food's cooked_type

/// Values based on microwave success
#define MICROWAVE_NORMAL 0
#define MICROWAVE_MUCK 1
#define MICROWAVE_PRE 2

/// Values for how broken the microwave is
#define NOT_BROKEN 0
#define KINDA_BROKEN 1
#define REALLY_BROKEN 2

/// The max amount of dirtiness a microwave can be
#define MAX_MICROWAVE_DIRTINESS 100

/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/machines/microwave.dmi'
	icon_state = "map_icon"
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/microwave
	pass_flags = PASSTABLE
	light_color = LIGHT_COLOR_DIM_YELLOW
	light_power = 3
	anchored_tabletop_offset = 6
	//Crimes against humanity
	var/held_w_class = WEIGHT_CLASS_HUGE
	var/held_lh = 'icons/mob/inhands/microwave_held_lh.dmi'
	var/held_rh = 'icons/mob/inhands/microwave_held_rh.dmi'
	var/held_state = "standard"
	var/held_force = 14
	throwforce = 20

	var/wire_disabled = FALSE // is its internal wire cut?
	var/operating = FALSE
	/// How dirty is it?
	var/dirty = 0
	var/dirty_anim_playing = FALSE
	/// How broken is it? NOT_BROKEN, KINDA_BROKEN, REALLY_BROKEN
	var/broken = NOT_BROKEN
	var/open = FALSE
	var/max_n_of_items = 10
	var/efficiency = 0
	var/datum/looping_sound/microwave/soundloop
	var/list/ingredients = list() // may only contain /atom/movables

	var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/static/radial_use = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_use")

	// we show the button even if the proc will not work
	var/static/list/radial_options = list("eject" = radial_eject, "use" = radial_use)
	var/static/list/ai_radial_options = list("eject" = radial_eject, "use" = radial_use, "examine" = radial_examine)

/obj/machinery/microwave/Initialize(mapload)
	. = ..()

	set_wires(new /datum/wires/microwave(src))
	create_reagents(100)
	soundloop = new(src, FALSE)
	update_appearance(UPDATE_ICON)

/obj/machinery/microwave/Exited(atom/movable/gone, direction)
	if(gone in ingredients)
		ingredients -= gone
		if(!QDELING(gone) && ingredients.len && isitem(gone))
			var/obj/item/itemized_ingredient = gone
			if(!(itemized_ingredient.item_flags & NO_PIXEL_RANDOM_DROP))
				itemized_ingredient.pixel_x = itemized_ingredient.base_pixel_x + rand(-6, 6)
				itemized_ingredient.pixel_y = itemized_ingredient.base_pixel_y + rand(-5, 6)
	return ..()


/obj/machinery/microwave/on_deconstruction()
	// eject() // monkestation edit: overrided in module
	return ..()

/obj/machinery/microwave/Destroy()
	QDEL_LIST(ingredients)
	QDEL_NULL(wires)
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/microwave/RefreshParts()
	. = ..()
	efficiency = 0
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		efficiency += micro_laser.tier
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_n_of_items = 10 * matter_bin.tier
		break

/obj/machinery/microwave/examine(mob/user)
	. = ..()
	if(!operating)
		. += span_notice("Right-click [src] to turn it on.")

	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return
	if(operating)
		. += span_notice("\The [src] is operating.")
		return

	if(length(ingredients))
		if(issilicon(user))
			. += span_notice("\The [src] camera shows:")
		else
			. += span_notice("\The [src] contains:")
		var/list/items_counts = new
		for(var/i in ingredients)
			if(isstack(i))
				var/obj/item/stack/S = i
				items_counts[S.name] += S.amount
			else
				var/atom/movable/AM = i
				items_counts[AM.name]++
		for(var/O in items_counts)
			. += span_notice("- [items_counts[O]]x [O].")
	else
		. += span_notice("\The [src] is empty.")

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "[span_notice("The status display reads:")]\n"+\
		"[span_notice("- Capacity: <b>[max_n_of_items]</b> items.")]\n"+\
		span_notice("- Cook time reduced by <b>[(efficiency - 1) * 25]%</b>.")

#define MICROWAVE_INGREDIENT_OVERLAY_SIZE 24

/obj/machinery/microwave/update_overlays()
	// When this is the nth ingredient, whats its pixel_x?
	var/static/list/ingredient_shifts = list(
		0,
		3,
		-3,
		4,
		-4,
		2,
		-2,
	)

	. = ..()

	// All of these will use a full icon state instead
	if (panel_open || dirty == MAX_MICROWAVE_DIRTINESS || broken || dirty_anim_playing)
		return .

	var/ingredient_count = 0

	for (var/atom/movable/ingredient as anything in ingredients)
		//MONKESTATION EDIT START
		// quick hack to make any living mobs in the microwave be drawn lying down
		// hopefully this wont't break anything
		var/mob/living/L = ingredient
		var/lying_angle
		if(istype(L))
			lying_angle = L.get_lying_angle()
			L.set_lying_angle(90)
		//MONKESTATION EDIT END
		var/image/ingredient_overlay = image(ingredient, src)
		//MONKESTATION EDIT START
		if(istype(L))
			L.set_lying_angle(lying_angle)
		//MONKESTATION EDIT END

		var/icon/ingredient_icon = icon(ingredient.icon, ingredient.icon_state)

		ingredient_overlay.transform = ingredient_overlay.transform.Scale(
			MICROWAVE_INGREDIENT_OVERLAY_SIZE / ingredient_icon.Width(),
			MICROWAVE_INGREDIENT_OVERLAY_SIZE / ingredient_icon.Height(),
		)

		ingredient_overlay.pixel_y = -4
		ingredient_overlay.layer = FLOAT_LAYER
		ingredient_overlay.plane = FLOAT_PLANE
		ingredient_overlay.blend_mode = BLEND_INSET_OVERLAY
		ingredient_overlay.pixel_x = ingredient_shifts[(ingredient_count % ingredient_shifts.len) + 1]

		ingredient_count += 1

		. += ingredient_overlay

	var/border_icon_state
	var/door_icon_state

	if (open)
		door_icon_state = "door_open"
		border_icon_state = "mwo"
	else if (operating)
		door_icon_state = "door_on"
		border_icon_state = "mw1"
	else
		door_icon_state = "door_off"
		border_icon_state = "mw"

	. += mutable_appearance(
		icon,
		door_icon_state,
		alpha = ingredients.len > 0 ? 128 : 255,
	)

	. += border_icon_state

	if (!open)
		. += "door_handle"

	return .

#undef MICROWAVE_INGREDIENT_OVERLAY_SIZE

/obj/machinery/microwave/update_icon_state()
	if (broken)
		icon_state = "mwb"
	else if (dirty_anim_playing)
		icon_state = "mwbloody1"
	else if (dirty == MAX_MICROWAVE_DIRTINESS)
		icon_state = open ? "mwbloodyo" : "mwbloody"
	else if(operating)
		icon_state = "back_on"
	else if(open)
		icon_state = "back_open"
	else if(panel_open)
		icon_state = "mw-o"
	else
		icon_state = "back_off"

	return ..()

/obj/machinery/microwave/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(dirty >= MAX_MICROWAVE_DIRTINESS)
		return FALSE
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/crowbar_act(mob/living/user, obj/item/tool)
	if(operating)
		return
	if(!default_deconstruction_crowbar(tool))
		return
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/screwdriver_act(mob/living/user, obj/item/tool)
	if(operating)
		return
	if(dirty >= MAX_MICROWAVE_DIRTINESS)
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/microwave/attackby(obj/item/O, mob/living/user, params)
	if(operating)
		return

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(broken > NOT_BROKEN)
		if(broken == REALLY_BROKEN && O.tool_behaviour == TOOL_WIRECUTTER) // If it's broken and they're using a TOOL_WIRECUTTER
			user.visible_message(span_notice("[user] starts to fix part of \the [src]."), span_notice("You start to fix part of \the [src]..."))
			if(O.use_tool(src, user, 20))
				user.visible_message(span_notice("[user] fixes part of \the [src]."), span_notice("You fix part of \the [src]."))
				broken = KINDA_BROKEN // Fix it a bit
		else if(broken == KINDA_BROKEN && O.tool_behaviour == TOOL_WELDER) // If it's broken and they're doing the wrench
			user.visible_message(span_notice("[user] starts to fix part of \the [src]."), span_notice("You start to fix part of \the [src]..."))
			if(O.use_tool(src, user, 20))
				user.visible_message(span_notice("[user] fixes \the [src]."), span_notice("You fix \the [src]."))
				broken = NOT_BROKEN
				update_appearance()
				return FALSE //to use some fuel
		else
			balloon_alert(user, "it's broken!")
			return TRUE
		return

	if(istype(O, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/clean_spray = O
		if(clean_spray.reagents.has_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this))
			clean_spray.reagents.remove_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this,1)
			playsound(loc, 'sound/effects/spray3.ogg', 50, TRUE, -6)
			user.visible_message(span_notice("[user] cleans \the [src]."), span_notice("You clean \the [src]."))
			dirty = 0
			update_appearance()
		else
			to_chat(user, span_warning("You need more space cleaner!"))
		return TRUE

	if(istype(O, /obj/item/soap) || istype(O, /obj/item/reagent_containers/cup/rag))
		var/cleanspeed = 50
		if(istype(O, /obj/item/soap))
			var/obj/item/soap/used_soap = O
			cleanspeed = used_soap.cleanspeed
		user.visible_message(span_notice("[user] starts to clean \the [src]."), span_notice("You start to clean \the [src]..."))
		if(do_after(user, cleanspeed, target = src))
			user.visible_message(span_notice("[user] cleans \the [src]."), span_notice("You clean \the [src]."))
			dirty = 0
			update_appearance()
		return TRUE

	if(dirty >= MAX_MICROWAVE_DIRTINESS) // The microwave is all dirty so can't be used!
		balloon_alert(user, "it's too dirty!")
		return TRUE

	if(istype(O, /obj/item/storage))
		var/obj/item/storage/T = O
		var/loaded = 0

		if(!istype(O, /obj/item/storage/bag/tray))
			// Non-tray dumping requires a do_after
			to_chat(user, span_notice("You start dumping out the contents of [O] into [src]..."))
			if(!do_after(user, 2 SECONDS, target = T))
				return

		for(var/obj/S in T.contents)
			if(!IS_EDIBLE(S))
				continue
			if(ingredients.len >= max_n_of_items)
				balloon_alert(user, "it's full!")
				return TRUE
			if(T.atom_storage.attempt_remove(S, src))
				loaded++
				ingredients += S
		if(loaded)
			to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
			update_appearance()
		return

	if(O.w_class <= WEIGHT_CLASS_NORMAL && !istype(O, /obj/item/storage) && !(user.istate & ISTATE_HARM))
		if(ingredients.len >= max_n_of_items)
			balloon_alert(user, "it's full!")
			return TRUE
		if(!user.transferItemToLoc(O, src))
			balloon_alert(user, "it's stuck to your hand!")
			return FALSE

		ingredients += O
		user.visible_message(span_notice("[user] adds \a [O] to \the [src]."), span_notice("You add [O] to \the [src]."))
		update_appearance()
		return

	//MONKESTATION EDIT START
	if (istype(O, /obj/item/riding_offhand))
		var/obj/item/riding_offhand/riding = O
		return stuff_mob_in(riding.rider, user)
	//MONKESTATION EDIT END
	return ..()

/obj/machinery/microwave/attack_hand_secondary(mob/user, list/modifiers)
	if(user.can_perform_action(src, ALLOW_SILICON_REACH))
		if(!length(ingredients))
			balloon_alert(user, "it's empty!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		cook(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/microwave/ui_interact(mob/user)
	. = ..()

	if(operating || panel_open || !anchored || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	if(!length(ingredients))
		if(isAI(user))
			examine(user)
		else
			balloon_alert(user, "it's empty!")
		return

	var/choice = show_radial_menu(user, src, isAI(user) ? ai_radial_options : radial_options, require_near = !issilicon(user))

	// post choice verification
	if(operating || panel_open || !anchored || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	usr.set_machine(src)
	switch(choice)
		if("eject")
			// monkestation edit start: microwave "enhancements"
			if (!can_eject)
				balloon_alert(user, "the lock is stuck!")
				return
			// monkestation end
			eject()
		if("use")
			cook(user)
		if("examine")
			examine(user)

/obj/machinery/microwave/proc/eject()
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/movable_ingredient as anything in ingredients)
		movable_ingredient.forceMove(drop_loc)
	open()
	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)

/**
 * Begins the process of cooking the included ingredients.
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook(mob/cooker)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(operating || broken > 0 || panel_open || !anchored || dirty >= MAX_MICROWAVE_DIRTINESS)
		return

	if(wire_disabled)
		audible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	if(cooker && HAS_TRAIT(cooker, TRAIT_CURSED) && prob(7))
		muck()
		return
	if(prob(max((5 / efficiency) - 5, dirty * 5))) //a clean unupgraded microwave has no risk of failure
		muck()
		return

	// How many items are we cooking that aren't already food items
	var/non_food_ingedients = length(ingredients)
	for(var/atom/movable/potential_fooditem as anything in ingredients)
		if(IS_EDIBLE(potential_fooditem))
			non_food_ingedients--
		/* monkestation: uncomment whenever this is ported
		if(istype(potential_fooditem, /obj/item/modular_computer/pda) && prob(75))
			pda_failure = TRUE
			notify_ghosts(
				"[cooker] has overheated their PDA!",
				source = src,
				notify_flags = NOTIFY_CATEGORY_NOFLASH,
				header = "Hunger Games: Catching Fire",
			)
		*/

	// If we're cooking non-food items we can fail randomly
	if(length(non_food_ingedients) && prob(min(dirty * 5, 100)))
		start_can_fail(cooker)
		return

	start(cooker)

/obj/machinery/microwave/proc/wzhzhzh()
	visible_message(span_notice("\The [src] turns on."), null, span_hear("You hear a microwave humming."))
	operating = TRUE

	set_light(1.5)
	soundloop.start()
	update_appearance()

/obj/machinery/microwave/proc/spark()
	visible_message(span_warning("Sparks fly around [src]!"))
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()

/**
 * The start of the cook loop
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start(mob/cooker)
	wzhzhzh()
	loop(MICROWAVE_NORMAL, 10, cooker = cooker)

/**
 * The start of the cook loop, but can fail (result in a splat / dirty microwave)
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start_can_fail(mob/cooker)
	wzhzhzh()
	loop(MICROWAVE_PRE, 4, cooker = cooker)

/obj/machinery/microwave/proc/muck()
	wzhzhzh()
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	dirty_anim_playing = TRUE
	update_appearance()
	loop(MICROWAVE_MUCK, 4)

/**
 * The actual cook loop started via [proc/start] or [proc/start_can_fail]
 *
 * * type - the type of cooking, determined via how this iteration of loop is called, and determines the result
 * * time - how many loops are left, base case for recursion
 * * wait - deciseconds between loops
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/loop(type, time, wait = max(12 - 2 * efficiency, 2), mob/cooker) // standard wait is 10
	if((machine_stat & BROKEN) && type == MICROWAVE_PRE)
		pre_fail()
		return

	if(time <= 0 || !length(ingredients))
		switch(type)
			if(MICROWAVE_NORMAL)
				loop_finish(cooker)
			if(MICROWAVE_MUCK)
				muck_finish()
			if(MICROWAVE_PRE)
				pre_success(cooker)
		return
	time--
	use_power(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(loop), type, time, wait, cooker), wait)

/obj/machinery/microwave/power_change()
	. = ..()
	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject(force = TRUE) // monkestation edit: microwave "enhancements"

/**
 * Called when the loop is done successfully, no dirty mess or whatever
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/loop_finish(mob/cooker)
	operating = FALSE

	var/cursed_chef = cooker && HAS_TRAIT(cooker, TRAIT_CURSED)
	var/metal_amount = 0
	var/shouldnt_open = FALSE // monkestation edit: microwave "enhancements"
	var/dont_eject = FALSE // monkestation edit: microwave "enhancements"
	for(var/obj/item/cooked_item in ingredients)
		// monkestation original start
			// var/sigreturn = cooked_item.microwave_act(src, cooker, randomize_pixel_offset = ingredients.len)
			// if(sigreturn & COMPONENT_MICROWAVE_SUCCESS)
			// 	if(isstack(cooked_item))
			// 		var/obj/item/stack/cooked_stack = cooked_item
			// 		dirty += cooked_stack.amount
			// 	else
			// 		dirty++
		// monkestation original end
		// monkestation start: microwave "enhancements"
		var/sigreturn = cooked_item.microwave_act(src, cooker, randomize_pixel_offset = ingredients.len)
		if(sigreturn & COMPONENT_MICROWAVE_SUCCESS)
			var/should_dirty = !(sigreturn & COMPONENT_MICROWAVE_DONTDIRTY)
			if(isstack(cooked_item))
				var/obj/item/stack/cooked_stack = cooked_item
				if (should_dirty) dirty += cooked_stack.amount
			else
				if (should_dirty) dirty++
		if (sigreturn & COMPONENT_MICROWAVE_DONTEJECT)
			dont_eject = TRUE
		if (sigreturn & COMPONENT_MICROWAVE_DONTOPEN)
			shouldnt_open = TRUE
		// monkestation end

		metal_amount += (cooked_item.custom_materials?[GET_MATERIAL_REF(/datum/material/iron)] || 0)

	if(cursed_chef && prob(5))
		spark()
		broken = REALLY_BROKEN
		explosion(src, light_impact_range = 2, flame_range = 1)

	if(metal_amount)
		spark()
		broken = REALLY_BROKEN
		if(cursed_chef || prob(max(metal_amount / 2, 33))) // If we're unlucky and have metal, we're guaranteed to explode
			explosion(src, heavy_impact_range = 1, light_impact_range = 2)
	else if (!dont_eject) // monkestation edit: microwave "enhancements" - + if (!dont_eject)
		dump_inventory_contents()

	after_finish_loop(dontopen = shouldnt_open) // monkestation edit: microwave "enhancements" - () -> (dontopen = shouldnt_open)

/obj/machinery/microwave/proc/pre_fail()
	broken = REALLY_BROKEN
	operating = FALSE
	spark()
	after_finish_loop()

/obj/machinery/microwave/proc/pre_success(mob/cooker)
	loop(MICROWAVE_NORMAL, 10, cooker = cooker)

/obj/machinery/microwave/proc/muck_finish()
	visible_message(span_warning("\The [src] gets covered in muck!"))

	dirty = MAX_MICROWAVE_DIRTINESS
	dirty_anim_playing = FALSE
	operating = FALSE

	after_finish_loop()

/obj/machinery/microwave/proc/after_finish_loop()
	set_light(0)
	soundloop.stop()
	open()

/obj/machinery/microwave/proc/open()
	open = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(close)), 0.8 SECONDS)

/obj/machinery/microwave/proc/close()
	open = FALSE
	update_appearance()

/// Type of microwave that automatically turns it self on erratically. Probably don't use this outside of the holodeck program "Microwave Paradise".
/// You could also live your life with a microwave that will continously run in the background of everything while also not having any power draw. I think the former makes more sense.
/obj/machinery/microwave/hell
	desc = "Cooks and boils stuff. This one appears to be a bit... off."
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/microwave/hell/Initialize(mapload)
	. = ..()
	//We want there to be some chance of them getting a working microwave (eventually).
	if(prob(95))
		//The microwave should turn off asynchronously from any other microwaves that initialize at the same time. Keep in mind this will not turn off, since there is nothing to call the proc that ends this microwave's looping
		addtimer(CALLBACK(src, PROC_REF(wzhzhzh)), rand(0.5 SECONDS, 3 SECONDS))

/obj/machinery/microwave/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))
		var/mob/living/living_target = hit_atom
		var/blocked = living_target.run_armor_check(attack_flag = MELEE)
		if(iscarbon(living_target))
			var/mob/living/carbon/carbon_target = living_target
			carbon_target.take_bodypart_damage(throwforce, 0, check_armor = TRUE, wound_bonus = 5)
		else
			living_target.apply_damage(throwforce, BRUTE, blocked = blocked, forced = FALSE, attack_direction = get_dir(get_turf(src), living_target))
		living_target.Knockdown(1.5 SECONDS)
		playsound(src, 'sound/effects/bang.ogg', 40)
	else
		playsound(hit_atom, 'sound/weapons/genhit.ogg',80 , TRUE, -1)
	return ..()

/obj/machinery/microwave/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(src.anchored || src.flags_1 & NODECONSTRUCT_1)
			return
		if(!usr.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
			return
		microwave_try_pickup(usr)

/obj/machinery/microwave/proc/microwave_try_pickup(mob/living/user, instant=FALSE)
	if(!ishuman(user))
		return
	if(!user.get_empty_held_indexes())
		to_chat(user, span_warning("Your hands are full!"))
		return FALSE
	user.visible_message(span_notice("[user] starts picking up [src]!"), span_notice("You start picking up [src]..."))
	if(!do_after(user, 3 SECONDS, target = src))
		return FALSE
	if(src.anchored)
		return FALSE
	microwave_pickup(user)
	return TRUE

/obj/machinery/microwave/proc/microwave_pickup(mob/living/user)
	var/obj/item/microwave_holder/holder = new(get_turf(src), src, held_state, held_lh, held_rh, held_force, throwforce)
	user.visible_message(span_warning("[user] picks up [src]!"), span_warning("You pick up [src]!"))
	user.put_in_hands(holder)

//Hit them with the michaelwave // Holder so we can pick it up
/obj/item/microwave_holder
	name = "bugged michaelwave"
	desc = "Yell at coders."
	icon = null
	icon_state = ""
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
	attack_verb_simple = list("smack", "strike", "crack", "beat")
	var/obj/machinery/microwave/held_microwave
	var/destroying = FALSE

/obj/item/microwave_holder/Initialize(mapload, obj/machinery/microwave/michaelwave, held_state, lh_icon, rh_icon, held_force, held_throwforce)
	if(held_state)
		inhand_icon_state = held_state
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	if(held_force)
		force = held_force
	if(held_throwforce)
		throwforce = held_throwforce
	deposit(michaelwave)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = force, force_wielded = force)
	. = ..()

/obj/item/microwave_holder/Destroy()
	destroying = TRUE
	if(held_microwave)
		release(FALSE)
	return ..()

/obj/item/microwave_holder/proc/deposit(obj/machinery/microwave/michelwave)
	if(!istype(michelwave))
		return FALSE
	michelwave.setDir(SOUTH)
	update_visuals(michelwave)
	held_microwave = michelwave
	michelwave.forceMove(src)
	name = michelwave.name
	desc = michelwave.desc
	return TRUE

/obj/item/microwave_holder/proc/update_visuals(obj/machinery/microwave/mangowave)
	appearance = mangowave.appearance

/obj/item/microwave_holder/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		release()
		return

	var/mob/living/throw_microwave = held_microwave
	release()
	return throw_microwave

/obj/item/microwave_holder/dropped(mob/living/user)
	..()
	if(held_microwave && isturf(loc))
		//user.visible_message(span_notice("[user] suddenly drops [src]."), span_notice("You suddenly drop [src]."))
		release()

/obj/item/microwave_holder/proc/release(del_on_release = TRUE, display_messages = TRUE)
	if(!held_microwave)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	var/mob/living/released_microwave = held_microwave
	held_microwave = null // stops the held microwave from being release()'d twice.
	if(isliving(loc))
		var/mob/living/microwave_carrier = loc
		microwave_carrier.dropItemToGround(src)
	released_microwave.forceMove(drop_location())
	released_microwave.setDir(SOUTH)
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE

/obj/item/microwave_holder/Exited(atom/movable/gone, direction)
	. = ..()
	if(held_microwave && held_microwave == gone)
		release()

#undef MICROWAVE_NORMAL
#undef MICROWAVE_MUCK
#undef MICROWAVE_PRE


#undef NOT_BROKEN
#undef KINDA_BROKEN
#undef REALLY_BROKEN

#undef MAX_MICROWAVE_DIRTINESS
