#define PROXIMITY_NONE ""
#define PROXIMITY_ON_SCREEN "_red"
#define PROXIMITY_NEAR "_yellow"

/**
 * Multitool -- A multitool is used for hacking electronic devices.
 *
 */




/obj/item/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors. You can activate it in-hand to locate the nearest APC."
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "multitool"
	inhand_icon_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_MULTITOOL
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	drop_sound = 'sound/items/handling/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/multitool_pickup.ogg'
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5, /datum/material/glass= SMALL_MATERIAL_AMOUNT * 0.2)
	custom_premium_price = PAYCHECK_COMMAND * 3
	toolspeed = 1
	usesound = 'sound/weapons/empty.ogg'
	var/datum/weakref/buffer // simple machine buffer for device linkage
	var/mode = 0
	var/apc_scanner = TRUE
	COOLDOWN_DECLARE(next_apc_scan)
	///the component buffer
	var/datum/weakref/component_buffer

/obj/item/multitool/examine(mob/user)
	. = ..()
	. += span_notice("Its buffer [buffer?.resolve() ? "contains [buffer.resolve()]." : "is empty."]")

/obj/item/multitool/storage_insert_on_interaction(datum/storage, atom/storage_holder, mob/user)
	return !isitem(storage_holder) || !(user?.istate & (ISTATE_HARM | ISTATE_SECONDARY))

/obj/item/multitool/attack_self(mob/user, list/modifiers)
	if(!apc_scanner)
		return

	scan_apc(user)

/obj/item/multitool/attack_self_secondary(mob/user, modifiers)
	. = ..()

	if(. || !apc_scanner)
		return

	scan_apc(user)

/obj/item/multitool/proc/scan_apc(mob/user)
	if(!COOLDOWN_FINISHED(src, next_apc_scan))
		return

	COOLDOWN_START(src, next_apc_scan, 2 SECONDS)

	var/area/local_area = get_area(user)
	var/obj/machinery/power/apc/power_controller = local_area?.apc
	if(!power_controller)
		user.balloon_alert(user, "couldn't find apc!")
		return

	var/dist = get_dist(src, power_controller)
	var/dir = get_dir(user, power_controller)
	var/balloon_message
	var/arrow_color

	switch(dist)
		if (0)
			user.balloon_alert(user, "found apc!")
			return
		if(1 to 5)
			arrow_color = COLOR_GREEN
		if(6 to 10)
			arrow_color = COLOR_YELLOW
		if(11 to 15)
			arrow_color = COLOR_ORANGE
		else
			arrow_color = COLOR_RED

	user.balloon_alert(user, balloon_message)

	var/datum/hud/user_hud = user.hud_used
	if(!user_hud || !istype(user_hud, /datum/hud) || !islist(user_hud.infodisplay))
		return

	var/atom/movable/screen/multitool_arrow/arrow = new(null, user_hud)
	arrow.color = arrow_color
	arrow.screen_loc = around_player
	arrow.transform = matrix(dir2angle(dir), MATRIX_ROTATE)

	user_hud.infodisplay += arrow
	user_hud.show_hud(user_hud.hud_version)

	QDEL_IN(arrow, 1.5 SECONDS)

/obj/item/multitool/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts the [src] to [user.p_their()] chest. It looks like [user.p_theyre()] trying to pulse [user.p_their()] heart off!"))
	return OXYLOSS//theres a reason it wasn't recommended by doctors

/**
 * Sets the multitool internal object buffer
 *
 * Arguments:
 * * buffer - the new object to assign to the multitool's buffer
 */
/obj/item/multitool/proc/set_buffer(datum/buffer)
	src.buffer = WEAKREF(buffer)

/**
 * Sets the multitool component buffer
 *
 * Arguments:
 * * buffer - the new object to assign to the multitool's component buffer
 */
/obj/item/multitool/proc/set_component_buffer(datum/component_buffer)
	src.component_buffer = WEAKREF(component_buffer)

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.

/obj/item/multitool/ai_detect
	apc_scanner = FALSE
	/// How close the AI is to us
	var/detect_state = PROXIMITY_NONE
	/// Range at which the closest AI makes the multitool glow red
	var/rangealert = 8 //Glows red when inside
	/// Range at which the closest AI makes the multitool glow yellow
	var/rangewarning = 20 //Glows yellow when inside
	/// Is our HUD on
	var/hud_on = FALSE

	// static scan stuff
	/// hud object that the fake static images use
	var/obj/effect/overlay/ai_detect_hud/camera_unseen/hud_obj
	/// fake static image
	var/list/image/static_images = list()
	/// the client that we shoved those images to
	var/datum/weakref/static_viewer
	/// timerid for the timer that makes em disappear
	var/static_disappear_timer
	/// cooldown for actually doing a static scan
	COOLDOWN_DECLARE(static_scan_cd)

/obj/item/multitool/ai_detect/examine(mob/user)
	. = ..()
	if(!hud_on)
		return
	. += span_notice("You can right-click to scan for nearby unseen spots. They will be shown for exactly 8 seconds due to battery limitations.")
	switch(detect_state)
		if(PROXIMITY_NONE)
			. += span_green("No AI should be currently looking at you. Keep on your clandestine activities.")
		if(PROXIMITY_NEAR)
			. += span_warning("An AI is getting uncomfortably close. Maybe time to drop what youre doing.")
		if(PROXIMITY_ON_SCREEN)
			. += span_danger("An AI is (probably) looking at you. You should probably hide this.")

/obj/item/multitool/ai_detect/Destroy()
	if(hud_on && ismob(loc))
		remove_hud(loc)
	cleanup_static()
	return ..()

/obj/item/multitool/ai_detect/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	toggle_hud(user)

/obj/item/multitool/ai_detect/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(.)
		return
	scan_unseen(user)

/obj/item/multitool/ai_detect/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(hud_on)
		show_hud(user)

/obj/item/multitool/ai_detect/dropped(mob/living/carbon/human/user)
	. = ..()
	if(hud_on)
		remove_hud(user)
	cleanup_static()

/obj/item/multitool/ai_detect/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][detect_state]"

/obj/item/multitool/ai_detect/process()
	var/old_detect_state = detect_state
	multitool_detect()
	if(detect_state != old_detect_state)
		update_appearance()

/obj/item/multitool/ai_detect/proc/toggle_hud(mob/user)
	hud_on = !hud_on
	if(user)
		to_chat(user, span_notice("You toggle the ai detection feature on [src] [hud_on ? "on" : "off"]."))
	if(hud_on)
		START_PROCESSING(SSfastprocess, src)
		show_hud(user)
	else
		STOP_PROCESSING(SSfastprocess, src)
		detect_state = PROXIMITY_NONE
		update_appearance(UPDATE_ICON)
		remove_hud(user)

/obj/item/multitool/ai_detect/proc/show_hud(mob/user)
	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	hud.show_to(user)

/obj/item/multitool/ai_detect/proc/remove_hud(mob/user)
	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_AI_DETECT]
	hud.hide_from(user)

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)
	detect_state = PROXIMITY_NONE

	for(var/mob/eye/camera/ai/AI_eye as anything in GLOB.camera_eyes)
		if(!AI_eye.ai_detector_visible)
			continue

		var/turf/ai_turf = get_turf(AI_eye)
		var/distance = get_dist(our_turf, ai_turf)

		if(distance == -1) //get_dist() returns -1 for distances greater than 127 (and for errors, so assume -1 is just max range)
			if(ai_turf == our_turf)
				detect_state = PROXIMITY_ON_SCREEN
				break
			continue

		if(distance < rangealert) //ai should be able to see us
			detect_state = PROXIMITY_ON_SCREEN
			break
		if(distance < rangewarning) //ai cant see us but is close
			detect_state = PROXIMITY_NEAR

/obj/item/multitool/ai_detect/proc/scan_unseen(mob/user)
	if(isnull(user?.client)) // the monkey incident of 2564
		return
	if(!COOLDOWN_FINISHED(src, static_scan_cd))
		balloon_alert(user, "recharging!")
		return
	cleanup_static()
	var/turf/our_turf = get_turf(src)
	var/list/datum/camerachunk/chunks = surrounding_chunks(our_turf)

	if(!hud_obj)
		hud_obj = new()
		SET_PLANE_W_SCALAR(hud_obj, PLANE_TO_TRUE(hud_obj.plane), GET_TURF_PLANE_OFFSET(our_turf))

	var/list/new_images = list()
	for(var/datum/camerachunk/chunk as anything in chunks)
		for(var/turf/seen_turf as anything in chunk.obscuredTurfs)
			var/image/img = image(loc = seen_turf, layer = ABOVE_ALL_MOB_LAYER)
			img.vis_contents += hud_obj
			SET_PLANE(img, GAME_PLANE, seen_turf)
			new_images += img
	user.client.images |= new_images
	static_viewer = WEAKREF(user.client)
	balloon_alert(user, "nearby unseen spots shown")
	static_disappear_timer = addtimer(CALLBACK(src, PROC_REF(cleanup_static)), 8 SECONDS, TIMER_STOPPABLE)
	COOLDOWN_START(src, static_scan_cd, 4 SECONDS)

// copied from camera chunks but we are doing a really big edge case here though
/obj/item/multitool/ai_detect/proc/surrounding_chunks(turf/epicenter)
	. = list()
	var/static_range = /mob/eye/camera/ai::static_visibility_range
	var/x1 = max(1, epicenter.x - static_range)
	var/y1 = max(1, epicenter.y - static_range)
	var/x2 = min(world.maxx, epicenter.x + static_range)
	var/y2 = min(world.maxy, epicenter.y + static_range)

	for(var/x = x1; x <= x2; x += CHUNK_SIZE)
		for(var/y = y1; y <= y2; y += CHUNK_SIZE)
			var/datum/camerachunk/chunk = SScameras.generate_chunk(x, y, epicenter.z)
			// removing cameras in build mode didnt affect it and i guess it needs an AI eye to update so we have to do this manually
			// unless we only want to see static in a jank manner only if an eye updates it
			chunk?.update() // UPDATE THE FUCK NOW
			. |= chunk

/obj/item/multitool/ai_detect/proc/cleanup_static()
	if(isnull(hud_obj)) //we never did anything
		return
	var/client/viewer = static_viewer?.resolve()
	viewer?.images -= static_images
	static_images.Cut()
	QDEL_NULL(hud_obj)
	viewer = null
	deltimer(static_disappear_timer)
	static_disappear_timer = null

/obj/item/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "multitool"
	belt_icon_state = "multitool_alien"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/silver = SHEET_MATERIAL_AMOUNT * 1.25, /datum/material/plasma = SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/titanium = SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT)
	toolspeed = 0.1

/obj/item/multitool/cyborg
	name = "electronic multitool"
	desc = "Optimised version of a regular multitool. Streamlines processes handled by its internal microchip."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "toolkit_engiborg_multitool"
	toolspeed = 0.5

//Tricorder
//The tricorder is a child of a multitool, atmosanalyzer and health scaner

/obj/item/multitool/tricorder
	name = "Tricorder"
	desc = "A multifunctional device that can perform a wide range of tasks. Some functionality can be expanded using highly specialized analyzers."
	icon = 'icons/obj/advanced_device.dmi'
	icon_state = "tricorder"
	worn_icon_state = "electronic"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	tool_behaviour = TOOL_MULTITOOL
	usesound = 'sound/weapons/etherealhit.ogg'
	toolspeed = 0.2
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2.5, /datum/material/silver = SMALL_MATERIAL_AMOUNT * 3, /datum/material/gold = SMALL_MATERIAL_AMOUNT * 3)

	var/medical_tricorder = FALSE		// if TRUE tricorder can work as health scaner T1
	var/chemical_tricorder = FALSE		// if TRUE tricorder can work as chemical scaner, but cutted version
	var/long_range_tricorder = FALSE	// if TRUE tricorder can work as long range gas analyzer

////////// Upgrades V1 //////////
/obj/item/multitool/tricorder/item_interaction(mob/living/user, obj/item/item_to_insert, list/modifiers)
	if(istype(item_to_insert, /obj/item/healthanalyzer))
		if(!medical_tricorder)
			medical_tricorder = TRUE
			to_chat(user, span_notice("You connect the improved sensors from the [item_to_insert] to the tricorder."))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			qdel(item_to_insert)
		else
			to_chat(user, span_warning("This modification has already been installed here."))

	if(istype(item_to_insert, /obj/item/ph_meter))
		if(!chemical_tricorder)
			chemical_tricorder = TRUE
			to_chat(user, span_notice("You connect the improved sensors from the [item_to_insert] to the tricorder."))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			qdel(item_to_insert)
		else
			to_chat(user, span_warning("This modification has already been installed here."))

	if(istype(item_to_insert, /obj/item/analyzer/ranged))
		if(!long_range_tricorder)
			long_range_tricorder = TRUE
			to_chat(user, span_notice("You connect the long range sensors from the [item_to_insert] to the tricorder."))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			qdel(item_to_insert)
		else
			to_chat(user, span_warning("This modification has already been installed here."))

/obj/item/multitool/tricorder/examine(mob/user)
	. = ..()
	. += span_notice("Improved health sensors [medical_tricorder ? "<b>are installed.</b>" : "are <b>not</b> installed."]")
	. += span_notice("Improved chemical sensors [chemical_tricorder ? "<b>are installed.</b>" : "are <b>not</b> installed."]")
	. += span_notice("Long range sensors [long_range_tricorder ? "<b>are installed.</b>" : "are <b>not</b> installed."]")

/obj/item/multitool/tricorder/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] tries to conduct an in-depth analysis of [user.p_them()]self!"))
	return BRUTELOSS

/obj/item/multitool/tricorder/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
////////// Upgrades V2 //////////
	if(istype(interacting_with, /obj/item/healthanalyzer) && can_see(user, interacting_with, 1))
		if(!medical_tricorder)
			medical_tricorder = TRUE
			to_chat(user, span_notice("You connect the improved sensors from the [interacting_with] to the tricorder."))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			qdel(interacting_with)
		else
			to_chat(user, span_warning("This modification has already been installed here."))
		return ITEM_INTERACT_SUCCESS

	if(istype(interacting_with, /obj/item/ph_meter) && can_see(user, interacting_with, 1))
		if(!chemical_tricorder)
			chemical_tricorder = TRUE
			to_chat(user, span_notice("You connect the improved sensors from the [interacting_with] to the tricorder."))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			qdel(interacting_with)
		else
			to_chat(user, span_warning("This modification has already been installed here."))
		return ITEM_INTERACT_SUCCESS

	if(istype(interacting_with, /obj/item/analyzer/ranged) && can_see(user, interacting_with, 1))
		if(!long_range_tricorder)
			long_range_tricorder = TRUE
			to_chat(user, span_notice("You connect the long range sensors from the [interacting_with] to the tricorder."))
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
			qdel(interacting_with)
		else
			to_chat(user, span_warning("This modification has already been installed here."))
		return ITEM_INTERACT_SUCCESS

////////// Prevent scan //////////
	// TCOMs
	if(istype(interacting_with, /obj/machinery/telecomms) && can_see(user, interacting_with, long_range_tricorder? 15 : 1))
		return

////////// Scan //////////
	// Health scan Mob
	if(istype(interacting_with, /mob/living) && can_see(user, interacting_with, 1))
		var/mob/living/mob = interacting_with
		if(medical_tricorder)
			healthscan(user, mob)
		else
			lesserhealthscan(user, mob)

		// Rad scan Mob
		if(SEND_SIGNAL(mob, COMSIG_GEIGER_COUNTER_SCAN, user, src) & COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL)
			return ITEM_INTERACT_SUCCESS
		to_chat(user, span_notice("[isliving(mob) ? "Subject" : "Target"] is free of radioactive contamination."))
		return ITEM_INTERACT_SUCCESS

	// Anomaly
	if(istype(interacting_with, /obj/effect/anomaly) && can_see(user, interacting_with, long_range_tricorder? 15 : 1))
		var/obj/effect/anomaly/anomaly = interacting_with
		anomaly.analyzer_act(user, src)
		return ITEM_INTERACT_SUCCESS

	// Chem scan item
	if(chemical_tricorder)
		if(is_reagent_container(interacting_with))
			var/obj/item/reagent_containers/cont = interacting_with
			if(!LAZYLEN(cont.reagents.reagent_list))
				return NONE
			var/list/out_message = list()
			to_chat(user, "<i>The chemistry meter beeps and displays:</i>")
			out_message += "<b>Total volume: [round(cont.volume, 0.01)], Current temperature: [round(cont.reagents.chem_temp, 0.1)]K Total pH: [round(cont.reagents.ph, 0.01)]\n"
			out_message += "Chemicals found in [interacting_with.name]:</b>\n"
			if(cont.reagents.is_reacting)
				out_message += "[span_warning("A reaction appears to be occuring currently.")]<span class='notice'>\n"
			for(var/datum/reagent/reagent in cont.reagents.reagent_list)
				if(reagent.purity < reagent.inverse_chem_val && reagent.inverse_chem) //If the reagent is impure
					var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
					out_message += "[span_warning("Inverted reagent detected: ")]<span class='notice'><b>[round(reagent.volume, 0.01)]u of [inverse_reagent.name]</b>, <b>Purity:</b> [round(1 - reagent.purity, 0.000001)*100]%, <b>Overdose:</b> [inverse_reagent.overdose_threshold]u, <b>Current pH:</b> [reagent.ph].\n"
				else
					out_message += "<b>[round(reagent.volume, 0.01)]u of [reagent.name]</b>, <b>Purity:</b> [round(reagent.purity, 0.000001)*100]%, <b>Overdose:</b> [reagent.overdose_threshold]u, <b>Current pH:</b> [reagent.ph].\n"
			to_chat(user, boxed_message(span_notice("[out_message.Join()]")))
			SEND_SIGNAL(interacting_with, COMSIG_ON_REAGENT_SCAN, user)
			return ITEM_INTERACT_SUCCESS

	// Atmos scan 1
	if(!HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION) && can_see(user, interacting_with, long_range_tricorder? 15 : 1))
		atmos_scan(user, (interacting_with.return_analyzable_air() ? interacting_with : get_turf(interacting_with)))
		return ITEM_INTERACT_SUCCESS

/obj/item/multitool/tricorder/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	// Chem scan Mob
	if(istype(interacting_with, /mob/living) && can_see(user, interacting_with, 1))
		var/mob/living/mob = interacting_with
		if(medical_tricorder && !user.is_blind())
			chemscan(user, mob)

////////// Long range scan //////////
/obj/item/multitool/tricorder/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION) && can_see(user, interacting_with, long_range_tricorder? 15 : 1))
		if((get_dist(user, interacting_with) > 1) && long_range_tricorder)
			interacting_with.Beam(user, icon='icons/effects/beam_advanced.dmi', icon_state = "med_scan", time = 5)
			playsound(src, 'sound/items/pip.ogg', 25, FALSE, 2)
		return interact_with_atom(interacting_with, user, modifiers)

	//If medical_tricorder is set to FALSE then the tricorder will not be as effective as a regular medical scanner
/obj/item/proc/lesserhealthscan(mob/user, mob/living/M)
	if(isliving(user) && (user.incapacitated() || user.is_blind()))
		return
	//Damage specifics
	var/oxy_damage = M.getOxyLoss()
	var/tox_damage = M.getToxLoss()
	var/fire_damage = M.getFireLoss()
	var/brute_damage = M.getBruteLoss()
	var/brain_status = M.get_organ_loss(ORGAN_SLOT_BRAIN)

	// Status Readout
	// Tricorder can detect damage but can only give estimates in most cases
	//Temperature
	to_chat(user, span_info("Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)"))
	//Brute
	to_chat(user, "\t <font color='#ff0202'>*</font> Brute: <font color='#FF8000'>[brute_damage > 100 ? "<font color='#ff0202'>Critical</font>" : brute_damage > 75 ? "Serious" : brute_damage > 50 ? "High" : brute_damage > 25 ? "Medium" : brute_damage > 0 ? "Low" : "<font color='#00aeff'>Null</font>"] level</font></span>")
	//Burn
	to_chat(user, "\t <font color='#FF8000'>*</font> Burn: <font color='#FF8000'>[fire_damage > 100 ? "<font color='#ff0202'>Critical</font>" : fire_damage > 75 ? "Serious" : fire_damage > 50 ? "High" : fire_damage > 25 ? "Medium" : fire_damage > 0 ? "Low" : "<font color='#00aeff'>Null</font>"] level</font></span>")
	//Oxygen
	to_chat(user, "\t <font color='#00aeff'>*</font> Oxygen: <font color='#FF8000'>[oxy_damage > 100 ? "<font color='#ff0202'>Critical</font>" : oxy_damage > 75 ? "Serious" : oxy_damage > 50 ? "High" : oxy_damage > 25 ? "Medium" : oxy_damage > 0 ? "Low" : "<font color='#00aeff'>Null</font>"] level</font></span>")
	//Toxin
	to_chat(user, "\t <font color='#33ff00'>*</font> Toxins: <font color='#FF8000'>[tox_damage > 100 ? "<font color='#ff0202'>Critical</font>" : tox_damage > 75 ? "Serious" : tox_damage > 50 ? "High" : tox_damage > 25 ? "Medium" : tox_damage > 0 ? "Low" : "<font color='#00aeff'>Null</font>"] level</font></span>")
	//Brain
	to_chat(user, "\t <font color='#ed0dd9'>*</font> Brain: <font color='#FF8000'>[brain_status >= 200 ? "<font color='#ff0202'>Critical Damaged</font>" : brain_status > 100 ? "High Damaged" : brain_status > 0 ? "Low Damaged" : "<font color='#00aeff'>Normal</font>"]</font></span>")

#undef PROXIMITY_NEAR
#undef PROXIMITY_NONE
#undef PROXIMITY_ON_SCREEN
