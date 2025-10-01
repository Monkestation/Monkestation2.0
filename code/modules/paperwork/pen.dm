/* Pens!
 * Contains:
 * Pens
 * Sleepy Pens
 * Parapens
 * Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*0.1)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "#000000" //what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT
	var/requires_gravity = TRUE // can you use this to write in zero-g
	embedding = list(embed_chance = 50)
	sharpness = SHARP_POINTY
	var/dart_insert_icon = 'icons/obj/weapons/guns/toy.dmi'
	var/dart_insert_casing_icon_state = "overlay_pen"
	var/dart_insert_projectile_icon_state = "overlay_pen_proj"
	/// If this pen can be clicked in order to retract it
	var/can_click = TRUE

/obj/item/pen/Initialize(mapload)
	. = ..()
	/* MONKE EDIT
	AddComponent(/datum/component/dart_insert, \
		dart_insert_icon, \
		dart_insert_casing_icon_state, \
		dart_insert_icon, \
		dart_insert_projectile_icon_state, \
		CALLBACK(src, PROC_REF(get_dart_var_modifiers))\
	)
	AddElement(/datum/element/tool_renaming)
	RegisterSignal(src, COMSIG_DART_INSERT_ADDED, PROC_REF(on_inserted_into_dart))
	RegisterSignal(src, COMSIG_DART_INSERT_REMOVED, PROC_REF(on_removed_from_dart))
	*/ // MONKE EDIT
	if (!can_click)
		return
	create_transform_component()
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/// Proc that child classes can override to have custom transforms, like edaggers or pendrivers
/obj/item/pen/proc/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		sharpness_on = NONE, \
		inhand_icon_change = FALSE, \
		w_class_on = w_class, \
	)
/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Clicks the pen to make an annoying sound. Clickity clickery click!
 */
/obj/item/pen/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "clicked")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE, -3)
	icon_state = initial(icon_state) + (active ? "_retracted" : "")
	update_appearance(UPDATE_ICON)

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/proc/on_inserted_into_dart(datum/source, obj/projectile/dart, mob/user, embedded = FALSE)
	SIGNAL_HANDLER

/obj/item/pen/proc/get_dart_var_modifiers()
	return list(
		"damage" = max(5, throwforce),
		"speed" = max(0, throw_speed - 3),
		"embedding" = embedding,
		"armour_penetration" = armour_penetration,
		"wound_bonus" = wound_bonus,
		"bare_wound_bonus" = bare_wound_bonus,
		"demolition_mod" = demolition_mod,
	)

/obj/item/pen/proc/on_removed_from_dart(datum/source, obj/projectile/dart, mob/user)
	SIGNAL_HANDLER

/obj/item/pen/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return BRUTELOSS

/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "#0000FF"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "#FF0000"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "#FFFFFF"

/obj/item/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	icon_state = "pen_4color"
	colour = COLOR_BLACK
	can_click = FALSE

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	. = ..()
	var/chosen_color = "black"
	switch(colour)
		if("#000000")
			colour = "#FF0000"
			chosen_color = "red"
			throw_speed++
		if("#FF0000")
			colour = "#00FF00"
			chosen_color = "green"
			throw_speed = initial(throw_speed)
		if("#00FF00")
			colour = "#0000FF"
			chosen_color = "blue"
		else
			colour = "#000000"
	to_chat(user, span_notice("\The [src] will now write in [chosen_color]."))
	desc = "It's a fancy four-color ink pen, set to [chosen_color]."
	balloon_alert(user, "clicked")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE, -3)

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body. Rumored to work in zero gravity situations."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT
	requires_gravity = FALSE // fancy spess pens
	dart_insert_casing_icon_state = "overlay_fountainpen"
	dart_insert_projectile_icon_state = "overlay_fountainpen_proj"
	can_click = FALSE

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "#696969"
	font = CHARCOAL_FONT
	custom_materials = null
	grind_results = list(/datum/reagent/ash = 5, /datum/reagent/cellulose = 10)
	requires_gravity = FALSE // this is technically a pencil
	can_click = FALSE

/datum/crafting_recipe/charcoal_stylus
	name = "Charcoal Stylus"
	result = /obj/item/pen/charcoal
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1, /datum/reagent/ash = 30)
	time = 3 SECONDS
	category = CAT_TOOLS

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "#DC143C"
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT*7.5)
	sharpness = SHARP_EDGED
	resistance_flags = FIRE_PROOF
	unique_reskin = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)
	embedding = list("embed_chance" = 75)

/obj/item/pen/fountain/captain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 20 SECONDS, \
	effectiveness = 115, \
	)
	//the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."


///obj/item/pen/fountain/captain/proc/reskin_dart_insert(datum/component/dart_insert/insert_comp)
//	if(!istype(insert_comp)) //You really shouldn't be sending this signal from anything other than a dart_insert component
//		return
//	insert_comp.casing_overlay_icon_state = overlay_reskin[current_skin]
//	insert_comp.projectile_overlay_icon_state = "[overlay_reskin[current_skin]]_proj"
/obj/item/pen/item_ctrl_click(mob/living/carbon/user)
	if(loc != user)
		to_chat(user, span_warning("You must be holding the pen to continue!"))
		return CLICK_ACTION_BLOCKING
	var/deg = tgui_input_number(user, "What angle would you like to rotate the pen head to? (0-360)", "Rotate Pen Head", max_value = 360)
	if(isnull(deg) || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || loc != user)
		return CLICK_ACTION_BLOCKING
	degrees = deg
	to_chat(user, span_notice("You rotate the top of the pen to [deg] degrees."))
	SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)
	return CLICK_ACTION_SUCCESS

/obj/item/pen/attack(mob/living/M, mob/user, params)
	if(force) // If the pen has a force value, call the normal attack procs. Used for e-daggers and captain's pen mostly.
		return ..()
	if(!M.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return FALSE
	to_chat(user, span_warning("You stab [M] with the pen."))
	to_chat(M, span_danger("You feel a tiny prick!"))
	log_combat(user, M, "stabbed", src)
	return TRUE

// Changing name/description of items. Only works if they have the UNIQUE_RENAME object flag set
/obj/item/pen/interact_with_atom(obj/interacting_with, mob/living/user, list/modifiers)
	if(!isobj(interacting_with) || !(interacting_with.obj_flags & UNIQUE_RENAME))
		return NONE
	. = ITEM_INTERACT_BLOCKING
	var/penchoice = tgui_input_list(user, "What would you like to edit?", "Pen Setting", list("Rename", "Description", "Reset"))
	if(QDELETED(interacting_with) || !user.can_perform_action(interacting_with))
		return
	if(penchoice == "Rename")
		var/input = tgui_input_text(user, "What do you want to name [interacting_with]?", "Object Name", html_decode("[interacting_with.name]"), MAX_NAME_LEN)
		var/oldname = interacting_with.name
		if(QDELETED(interacting_with) || !user.can_perform_action(interacting_with))
			return
		if(input == oldname || !input)
			to_chat(user, span_notice("You changed [interacting_with] to... well... [interacting_with]."))
		else
			interacting_with.AddComponent(/datum/component/rename, input, interacting_with.desc)
			to_chat(user, span_notice("You have successfully renamed \the [oldname] to [interacting_with]."))
			interacting_with.update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS

	else if(penchoice == "Description")
		var/input = tgui_input_text(user, "Describe [interacting_with]", "Description", html_decode("[interacting_with.desc]"), 140)
		var/olddesc = interacting_with.desc
		if(QDELETED(interacting_with) || !user.can_perform_action(interacting_with))
			return
		if(input == olddesc || !input)
			to_chat(user, span_notice("You decide against changing [interacting_with]'s description."))
		else
			interacting_with.AddComponent(/datum/component/rename, interacting_with.name, input)
			to_chat(user, span_notice("You have successfully changed [interacting_with]'s description."))
			interacting_with.update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS

	else if(penchoice == "Reset")
		qdel(interacting_with.GetComponent(/datum/component/rename))
		to_chat(user, span_notice("You have successfully reset [interacting_with]'s name and description."))
		interacting_with.update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS

/obj/item/pen/get_writing_implement_details()
	if (HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return null
	return list(
		interaction_mode = MODE_WRITING,
		font = font,
		color = colour,
		use_bold = FALSE,
	)

/*
 * Sleepypens
 */

/obj/item/pen/sleepy/attack(mob/living/M, mob/user, params)
	. = ..()
	if(!.)
		return
	if(!reagents.total_volume)
		return
	if(!M.reagents)
		return
	reagents.trans_to(M, reagents.total_volume, transfered_by = user, methods = INJECT)


/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts") //these won't show up if the pen is off
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_POINTY
	armour_penetration = 20
	bare_wound_bonus = 10
	item_flags = NO_BLOOD_ON_ITEM
	light_system = OVERLAY_LIGHT
	light_outer_range = 1.5
	light_power = 0.75
	light_color = COLOR_SOFT_RED
	light_on = FALSE
	/// The real name of our item when extended.
	var/hidden_name = "energy dagger"
	/// The real desc of our item when extended.
	var/hidden_desc = "It's a normal black ink pe- Wait. That's a thing used to stab people!"
	/// The real icons used when extended.
	var/hidden_icon = "edagger"

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 6 SECONDS, \
	butcher_sound = 'sound/weapons/blade1.ogg', \
	)
	RegisterSignal(src, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))

/obj/item/pen/edagger/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		force_on = 18, \
		throwforce_on = 35, \
		throw_speed_on = 4, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		inhand_icon_change = FALSE, \
	)

/obj/item/pen/edagger/suicide_act(mob/living/user)
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.visible_message(span_suicide("[user] forcefully rams the pen into their mouth!"))
	else
		user.visible_message(span_suicide("[user] is holding a pen up to their mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		attack_self(user)
	return BRUTELOSS

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Handles swapping their icon files to edagger related icon files -
 * as they're supposed to look like a normal pen.
 */
/obj/item/pen/edagger/on_transform(obj/item/source, mob/user, active)
	if(active)
		name = hidden_name
		desc = hidden_desc
		icon_state = hidden_icon
		inhand_icon_state = hidden_icon
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
		embedding = list(embed_chance = 100) // Rule of cool
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
		embedding = list(embed_chance = EMBED_CHANCE)

	updateEmbedding()
	if(user)
		balloon_alert(user, "[hidden_name] [active ? "active" : "concealed"]")
	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	set_light_on(active)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/edagger/proc/on_scan(datum/source, mob/user, list/extra_data)
	SIGNAL_HANDLER
	LAZYADD(extra_data[DETSCAN_CATEGORY_ILLEGAL], "Hard-light generator detected.")

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe. Watchers find them very desirable for their diamond exterior."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "digging_pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	force = 3
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.1, /datum/material/diamond=SMALL_MATERIAL_AMOUNT, /datum/material/titanium = SMALL_MATERIAL_AMOUNT*0.1)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.
	font = FOUNTAIN_PEN_FONT
	colour = COLOR_BLUE
	dart_insert_casing_icon_state = "overlay_survivalpen"
	dart_insert_projectile_icon_state = "overlay_survivalpen_proj"
	can_click = FALSE

/obj/item/pen/survival/on_inserted_into_dart(datum/source, obj/item/ammo_casing/dart, mob/user)
	. = ..()
	RegisterSignal(dart.loaded_projectile, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_dart_hit))

/obj/item/pen/survival/on_removed_from_dart(datum/source, obj/item/ammo_casing/dart, obj/projectile/proj, mob/user)
	. = ..()
	if(istype(proj))
		UnregisterSignal(proj, COMSIG_PROJECTILE_SELF_ON_HIT)

/obj/item/pen/survival/proc/on_dart_hit(obj/projectile/source, atom/movable/firer, atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/mineral_turf = target_turf
		mineral_turf.gets_drilled(firer, TRUE)

/obj/item/pen/destroyer
	name = "Fine Tipped Pen"
	desc = "A pen with an infinitly sharpened tip. Capable of striking the weakest point of a strucutre or robot and annihilating it instantly. Good at putting holes in people too."
	force = 5
	wound_bonus = 100
	demolition_mod = 9000

// screwdriver pen!

/obj/item/pen/screwdriver
	desc = "A pen with an extendable screwdriver tip. This one has a yellow cap."
	icon_state = "pendriver"
	toolspeed = 1.2  // gotta have some downside

/obj/item/pen/screwdriver/get_all_tool_behaviours()
	return list(TOOL_SCREWDRIVER)

/obj/item/pen/screwdriver/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/pen/screwdriver/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		throwforce_on = 5, \
		w_class_on = WEIGHT_CLASS_SMALL, \
		sharpness_on = TRUE, \
		inhand_icon_change = FALSE, \
	)

/obj/item/pen/screwdriver/on_transform(obj/item/source, mob/user, active)
	if(user)
		balloon_alert(user, active ? "extended" : "retracted")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)

	if(!active)
		tool_behaviour = initial(tool_behaviour)
		RemoveElement(/datum/element/eyestab)
	else
		tool_behaviour = TOOL_SCREWDRIVER
		AddElement(/datum/element/eyestab)

	update_appearance(UPDATE_ICON)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/screwdriver/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "_out" : null]"
	inhand_icon_state = initial(inhand_icon_state) //since transforming component switches the icon.

//The Security holopen
/obj/item/pen/red/security
	name = "security pen"
	desc = "This is a red ink pen exclusively provided to members of the Security Department. Its opposite end features a built-in holographic projector designed for issuing arrest prompts to individuals."
	icon_state = "pen_sec"
	COOLDOWN_DECLARE(holosign_cooldown)

/obj/item/pen/red/security/examine(mob/user)
	. = ..()
	. += span_notice("To initiate the surrender prompt, simply click on an individual within your proximity.")

//Code from the medical penlight
/obj/item/pen/red/security/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, holosign_cooldown))
		balloon_alert(user, "not ready!")
		return ITEM_INTERACT_BLOCKING

	var/turf/target_turf = get_turf(interacting_with)
	var/mob/living/living_target = locate(/mob/living) in target_turf

	if(!living_target || (living_target == user))
		return ITEM_INTERACT_BLOCKING

	living_target.apply_status_effect(/datum/status_effect/surrender_timed)
	to_chat(living_target, span_userdanger("[user] requests your immediate surrender! You are given 30 seconds to comply!"))
	new /obj/effect/temp_visual/security_holosign(target_turf, user) //produce a holographic glow
	COOLDOWN_START(src, holosign_cooldown, 30 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/effect/temp_visual/security_holosign
	name = "security holosign"
	desc = "A small holographic glow that indicates you're under arrest."
	icon_state = "sec_holo"
	duration = 60

/obj/effect/temp_visual/security_holosign/Initialize(mapload, creator)
	. = ..()
	playsound(loc, 'sound/machines/chime.ogg', 50, FALSE) //make some noise!
	if(creator)
		visible_message(span_danger("[creator] created a security hologram!"))

/obj/item/pen/monkey
	name = "monkey pen"
	icon_state = "monkey_pen"
	desc = "This pen is shaped like a monkey ."
	colour = "#000000"

/obj/item/pen/banana
	name = "banana pen"
	icon_state = "banana_pen"
	desc = "Its a banana shaped pen!"
	colour = "#000000"

/obj/item/pen/banana/attack_self(mob/living/carbon/user)
	. = ..()
	var/chosen_color = "black"
	switch(colour)
		if("#FFFF00")
			colour = "#FFFF00"
			chosen_color = "yellow"
		else
			colour = "#000000"
	to_chat(user, span_notice("\The [src] will now write in [chosen_color]."))
	desc = "It's a fancy banana pen, set to [chosen_color]."
	balloon_alert(user, "clicked")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE, -3)
