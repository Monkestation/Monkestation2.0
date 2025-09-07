/obj/item/mcobject/interactor
	name = "interaction component"
	desc = "will either right or left click with the given item."

	icon = 'monkestation/icons/obj/mechcomp.dmi'
	icon_state = "comp_collector"
	base_icon_state = "comp_collector"

	/// Should we right or left click?
	var/right_clicks = FALSE
	/// The dummy human that is doing the clicking.
	var/mob/living/carbon/human/dummy/mechcomp/dummy_human
	/// Image of the held item displayed over the component to see whats going on.
	var/obj/item/held_item
	/// The object typepath we specifically look for when clicking.
	var/atom/desired_path = null
	/// The connected storage component to act as an inventory to grab from.
	var/obj/item/mcobject/messaging/storage/connected_storage
	/// The current stored direction used for interaction.
	var/stored_dir = NORTH
	/// The interaction range defaults to ontop of itself.
	var/range = FALSE
	/// Cooldown to prevent spamming admins with alerts in case something goes HORRIBLY wrong.
	COOLDOWN_DECLARE(admin_alert_cooldown)

/obj/item/mcobject/interactor/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Swap Click", swap_click)
	MC_ADD_CONFIG("Swap Range", set_range)
	MC_ADD_CONFIG("Change Direction", change_dir)
	MC_ADD_CONFIG("Reset Desired Object", reset_desired_path)
	MC_ADD_INPUT("swap click", swap_click_input)
	MC_ADD_INPUT("replace", replace_from_storage)
	MC_ADD_INPUT("drop", drop)
	MC_ADD_INPUT("change direction", change_dir_input)
	MC_ADD_INPUT("interact", use_on)
	create_dummy()

/obj/item/mcobject/interactor/Destroy(force)
	QDEL_NULL(dummy_human) // will automatically handle dropping held items
	connected_storage = null
	return ..()

/obj/item/mcobject/examine(mob/user)
	. = ..()
	. += span_notice("You can right-click with a multitool whilst having a storage component in your buffer to link it.")
	. += span_notice("You can drag [src] over an object whilst you're adjacent to both [src] and the object to make it only click objects of the same type as it.")

/obj/item/mcobject/interactor/drop_location()
	return loc?.drop_location() || ..()

/obj/item/mcobject/interactor/multitool_act_secondary(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	if(!multitool.component_buffer)
		return ..()
	if(!istype(multitool.component_buffer, /obj/item/mcobject/messaging/storage))
		return ..()
	if(check_restrictions(storage = TRUE))
		balloon_alert(user, "storage interaction disabled!")
		return
	connected_storage = multitool.component_buffer
	balloon_alert(user, "successfully linked storage component")

/obj/item/mcobject/interactor/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!isatom(over) || QDELING(over) || !ishuman(usr) || over == src)
		return

	if(!can_interact_with(over.type))
		balloon_alert(usr, "cannot interact with [over]!")
		return

	if(Adjacent(usr, src) && Adjacent(over, usr))
		balloon_alert(usr, "desired object set to [over]")
		desired_path = over.type

/obj/item/mcobject/interactor/proc/check_restrictions(items = FALSE, storage = FALSE)
	. = FALSE
	if(CONFIG_GET(flag/disable_mechcomp_interaction_items))
		drop_dummy_items()
		if(items)
			. = TRUE
	if(CONFIG_GET(flag/disable_mechcomp_interaction_storage))
		connected_storage = null
		if(storage)
			. = TRUE

/obj/item/mcobject/interactor/proc/drop_dummy_items()
	for(var/obj/item/item in dummy_human?.held_items)
		dummy_human.dropItemToGround(item, force = TRUE, silent = TRUE)
	held_item = null

/obj/item/mcobject/interactor/proc/drop(datum/mcmessage/input)
	if(!input || check_restrictions(items = TRUE, storage = TRUE))
		return
	if(connected_storage)
		connected_storage.attempt_insert(held_item)
	else
		drop_dummy_items()
	return TRUE

/obj/item/mcobject/interactor/proc/replace_from_storage(datum/mcmessage/input)
	if(check_restrictions(items = TRUE, storage = TRUE))
		return
	var/input_number = text2num(input.cmd)
	if(!IS_SAFE_NUM(input_number))
		return
	if(QDELETED(connected_storage))
		say("ERROR: No connected storage components!")
		return
	if(input_number > length(connected_storage.contents))
		return

	var/obj/item/listed_item = connected_storage.contents[input_number]
	if(QDELETED(listed_item))
		return
	if(held_item)
		connected_storage.attempt_insert(held_item)
		held_item = null
	return pick_up_item(listed_item)

/obj/item/mcobject/interactor/proc/change_dir_input(datum/mcmessage/input)
	var/input_number = text2num(input.cmd)
	if(isnull(input_number) || !(input_number in GLOB.alldirs))
		return FALSE
	stored_dir = input_number
	return TRUE

/obj/item/mcobject/interactor/proc/set_range(mob/user, obj/item/tool)
	range = !range
	say("SUCCESS: Will now interact [range ? "1 tile away from" : "on top of"] the component")
	return TRUE

/obj/item/mcobject/interactor/proc/swap_click(mob/user, obj/item/tool)
	right_clicks = !right_clicks
	say("Changed click type to: [right_clicks ? "Right" : "Left"] Clicks")
	return TRUE

/obj/item/mcobject/interactor/proc/change_dir(mob/user, obj/item/tool)
	var/static/list/directions_listed = list("North" = NORTH, "South" = SOUTH, "East" = EAST, "West" = WEST)
	var/direction_choice = tgui_input_list(user, "Select the direction to use", "Interactor Component", list("North", "South", "East", "West"))
	if(isnull(direction_choice) || !(direction_choice in directions_listed))
		return FALSE
	stored_dir = directions_listed[direction_choice]
	return TRUE

/obj/item/mcobject/interactor/proc/reset_desired_path(mob/user, obj/item/tool)
	say("Desired object [desired_path ? "reset" : "not set"]!")
	desired_path = null
	return TRUE

/obj/item/mcobject/interactor/proc/swap_click_input(datum/mcmessage/input)
	if(!input)
		return
	right_clicks = !right_clicks
	say("Changed click type to: [right_clicks ? "Right" : "Left"] Clicks")
	return TRUE

/obj/item/mcobject/interactor/proc/use_on(datum/mcmessage/input)
	set waitfor = FALSE

	if(!input)
		return

	var/turf/selected_turf = get_turf(src)
	if(range)
		selected_turf = get_step(src, stored_dir)

	if(!isnull(held_item) && held_item.loc != dummy_human)
		drop_dummy_items()

	for(var/atom/movable/listed_atom in selected_turf)
		if(!isnull(desired_path) && (desired_path != listed_atom.type))
			continue
		if(isitem(listed_atom) && check_restrictions(items = TRUE))
			continue
		if(!can_interact_with(listed_atom))
			continue
		if(DOING_INTERACTION_WITH_TARGET(dummy_human, listed_atom)) // don't allow potential do_after stacking
			continue

		if(isnull(held_item))
			if(!right_clicks)
				listed_atom.attack_hand(dummy_human)
			else
				dummy_human.istate |= ISTATE_SECONDARY
				listed_atom.attack_hand_secondary(dummy_human)
				dummy_human.istate &= ~ISTATE_SECONDARY
		else
			if(!right_clicks)
				held_item.melee_attack_chain(dummy_human, listed_atom)
			else
				dummy_human.istate |= ISTATE_SECONDARY
				held_item.melee_attack_chain(dummy_human, listed_atom)
				dummy_human.istate &= ~ISTATE_SECONDARY

	check_restrictions(items = TRUE) // just to make sure
	flash()

/obj/item/mcobject/interactor/proc/pick_up_item(obj/item/item)
	if(QDELETED(src) || QDELETED(item) || item == held_item || check_restrictions(items = TRUE) || !can_interact_with(item))
		return FALSE
	if(!isnull(held_item))
		dummy_human.dropItemToGround(held_item, force = TRUE, silent = TRUE)
		held_item = null
	if(!dummy_human.put_in_l_hand(item))
		return FALSE
	held_item = item
	return TRUE

/obj/item/mcobject/interactor/update_overlays()
	. = ..()
	if(!QDELETED(held_item))
		var/mutable_appearance/held_image = mutable_appearance(held_item.icon, held_item.icon_state, ABOVE_OBJ_LAYER, null, FLOAT_PLANE, 70)
		held_image.color = LIGHT_COLOR_BLUE
		. += held_image

/obj/item/mcobject/interactor/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(!can_interact_with(weapon))
		balloon_alert(user, "[weapon] is incompatible!")
		return
	else if(check_restrictions(items = TRUE))
		balloon_alert(user, "holding items is disabled!")
		return
	if(held_item)
		if(connected_storage && !check_restrictions(storage = TRUE))
			connected_storage.attempt_insert(held_item)
		else
			dummy_human?.dropItemToGround(held_item, force = TRUE, silent = TRUE)
	pick_up_item(weapon)

/obj/item/mcobject/interactor/proc/can_interact_with(atom/target)
	/// Base typecache of items forbidden from being held and used.
	var/static/list/interaction_blacklist
	if(isnull(interaction_blacklist))
		interaction_blacklist = typecacheof(list(
			/obj/item/bodybag,
			/obj/item/holochip,
			/obj/item/mcobject,
			/obj/item/plate,
			/obj/item/stack/monkecoin,
			/obj/item/stack/spacecash,
		))

	if(isnull(target))
		return FALSE

	// Allow checking plain paths, if we ever just wanna check the typecache.
	if(!ispath(target))
		if(QDELING(target))
			return FALSE
		if(target == dummy_human || target == src)
			return FALSE
		if(target.invisibility > SEE_INVISIBLE_LIVING || target.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			return FALSE
		if(HAS_TRAIT(target, TRAIT_MECHCOMP_INTERACTION_BANNED))
			return FALSE
	if(is_type_in_typecache(target, interaction_blacklist))
		return FALSE
	var/list/config_blacklist = CONFIG_GET(str_list/blacklist_mechcomp_interaction)
	if(is_type_in_typecache(target, config_blacklist))
		return FALSE
	return TRUE

/obj/item/mcobject/interactor/proc/create_dummy()
	if(QDELETED(src))
		return
	if(!QDELETED(dummy_human))
		QDEL_NULL(dummy_human)
	dummy_human = new(src)
	RegisterSignal(dummy_human, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(on_dummy_pickup))
	RegisterSignal(dummy_human, COMSIG_QDELETING, PROC_REF(on_dummy_qdel))

/obj/item/mcobject/interactor/proc/on_dummy_pickup(datum/source, obj/item/item)
	SIGNAL_HANDLER
	if(!can_interact_with(item))
		if(COOLDOWN_FINISHED(src, admin_alert_cooldown))
			message_admins("Interaction component at [ADMIN_VERBOSEJMP(src)] tried to pick up [item] ([item.type]), even though this should not be possible!")
			COOLDOWN_START(src, admin_alert_cooldown, 20 SECONDS)
		stack_trace("Interaction component at [COORD(src)] tried to pick up [item] ([item.type]), even though this should not be possible!")
		addtimer(CALLBACK(src, PROC_REF(drop_dummy_items)), 0.1 SECONDS)
		return
	if(held_item == item)
		return // already holding this
	RegisterSignals(item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING), PROC_REF(on_held_item_dropped))
	held_item = item
	update_appearance(UPDATE_OVERLAYS)

/obj/item/mcobject/interactor/proc/on_dummy_qdel(datum/source)
	SIGNAL_HANDLER
	if(source != dummy_human)
		return
	drop_dummy_items()
	UnregisterSignal(dummy_human, list(COMSIG_LIVING_PICKED_UP_ITEM, COMSIG_QDELETING))
	dummy_human = null

/obj/item/mcobject/interactor/proc/on_held_item_dropped(obj/item/item)
	SIGNAL_HANDLER
	if(item != held_item)
		return
	UnregisterSignal(item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))
	held_item = null
	update_appearance(UPDATE_OVERLAYS)

/// Dummy human subtype used by the interaction mechcomp component.
/// To avoid ruining the illusion, they are unable to hear, speak, or emote,
/// and will runtime if they somehow try to move outside of their interaction component.
/mob/living/carbon/human/dummy/mechcomp
	name = "interaction component"
	invisibility = INVISIBILITY_ABSTRACT

/mob/living/carbon/human/dummy/mechcomp/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mcobject/interactor))
		stack_trace("Attempted to initialize [type] outside of interaction component")
		return INITIALIZE_HINT_QDEL
	name = src::name
	real_name = src::name
	dna?.real_name = src::name

/mob/living/carbon/human/dummy/mechcomp/abstract_move(atom/destination)
	if(!move_sanity_check(destination))
		return FALSE
	return ..()

/mob/living/carbon/human/dummy/mechcomp/Move(atom/new_loc, direct)
	if(!move_sanity_check(new_loc))
		return FALSE
	return ..()

/mob/living/carbon/human/dummy/mechcomp/can_hear()
	return FALSE

/mob/living/carbon/human/dummy/mechcomp/can_speak(allow_mimes)
	return FALSE

/mob/living/carbon/human/dummy/mechcomp/emote(act, m_type, message, intentional, force_silence)
	return FALSE

/mob/living/carbon/human/dummy/mechcomp/proc/move_sanity_check(atom/destination)
	if(isnull(destination) || istype(destination, /obj/item/mcobject/interactor))
		return TRUE
	CRASH("Interaction component dummy somehow tried to move outside of an interaction component, to [destination] ([destination.type]) at [COORD(destination)]")
