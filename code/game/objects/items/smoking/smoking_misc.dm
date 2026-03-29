///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	grind_results = list(/datum/reagent/phosphorus = 2)
	/// Whether this match has been lit.
	var/lit = FALSE
	/// Whether this match has burnt out.
	var/burnt = FALSE
	/// How long the match lasts in seconds
	var/smoketime = 10 SECONDS

/obj/item/match/process(seconds_per_tick)
	smoketime -= seconds_per_tick * (1 SECONDS)
	if(smoketime <= 0)
		matchburnout()
	else
		open_flame(heat)

/obj/item/match/fire_act(exposed_temperature, exposed_volume)
	matchignite()

/obj/item/match/storage_insert_on_interaction(datum/storage, atom/storage_holder, mob/user)
	return !istype(storage_holder, /obj/item/storage/box/matches)

/obj/item/match/proc/matchignite()
	if(lit || burnt)
		return

	var/turf/my_turf = get_turf(src)
	my_turf.pollute_turf(/datum/pollutant/sulphur, 5)

	playsound(src, 'sound/items/match_strike.ogg', 15, TRUE)
	lit = TRUE
	icon_state = "match_lit"
	damtype = BURN
	force = 3
	hitsound = 'sound/items/welder.ogg'
	inhand_icon_state = "cigon"
	name = "lit [initial(name)]"
	desc = "A [initial(name)]. This one is lit."
	attack_verb_continuous = string_list(list("burns", "singes"))
	attack_verb_simple = string_list(list("burn", "singe"))
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/match/proc/matchburnout()
	if(!lit)
		return

	lit = FALSE
	burnt = TRUE
	damtype = BRUTE
	force = initial(force)
	icon_state = "match_burnt"
	inhand_icon_state = "cigoff"
	name = "burnt [initial(name)]"
	desc = "A [initial(name)]. This one has seen better days."
	attack_verb_continuous = string_list(list("flicks"))
	attack_verb_simple = string_list(list("flick"))
	STOP_PROCESSING(SSobj, src)

/obj/item/match/extinguish()
	. = ..()
	matchburnout()

/obj/item/match/dropped(mob/user)
	matchburnout()
	return ..()

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!isliving(M))
		return

	if(lit && M.ignite_mob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		user.log_message("set [key_name(M)] on fire with [src]", LOG_ATTACK)

	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(!lit || !cig || (user.istate & ISTATE_HARM))
		..()
		return

	if(cig.lit)
		to_chat(user, span_warning("[cig] is already lit!"))
	if(M == user)
		cig.attackby(src, user)
	else
		cig.light(span_notice("[user] holds [src] out for [M], and lights [cig]."))

/// Finds a cigarette on another mob to help light.
/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(ITEM_SLOT_MASK)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/get_temperature()
	return lit * heat

/obj/item/match/firebrand
	name = "firebrand"
	desc = "An unlit firebrand. It makes you wonder why it's not just called a stick."
	smoketime = 40 SECONDS
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/match/firebrand/Initialize(mapload)
	. = ..()
	matchignite()

//////////////
// Matchbox //
//////////////
/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	desc_controls = "Right-Click the matchbox to take out a match. Right-Click the matchbox with a match to strike the match."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	inhand_icon_state = "zippo"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	worn_icon_state = "lighter"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound = 'sound/items/handling/matchbox_pickup.ogg'
	custom_price = PAYCHECK_CREW * 0.4
	base_icon_state = "matchbox"
	illustration = null

/obj/item/storage/box/matches/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 14
	atom_storage.set_holdable(list(/obj/item/match))
	register_context()

/obj/item/storage/box/matches/PopulateContents()
	for(var/i in 1 to 14)
		new /obj/item/match(src)

/obj/item/storage/box/matches/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Remove match"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/box/matches/item_interaction_secondary(mob/living/user, obj/item/match/match, list/modifiers)
	. = ..()
	if(istype(match))
		match.matchignite()
		return ITEM_INTERACT_SUCCESS

/obj/item/storage/box/matches/attack_hand_secondary(mob/user, list/modifiers)
	quick_remove_item(/obj/item/match, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/storage/box/matches/proc/quick_remove_item(obj/item/grabbies, mob/user)
	var/obj/item/finger = locate(grabbies) in contents
	if(finger)
		atom_storage.remove_single(user, finger, drop_location())
		user.put_in_hands(finger)

/obj/item/storage/box/matches/update_icon_state()
	. = ..()
	switch(length(contents))
		if(10)
			icon_state = base_icon_state
		if(5 to 9)
			icon_state = "[base_icon_state]_almostfull"
		if(1 to 4)
			icon_state = "[base_icon_state]_almostempty"
		if(0)
			icon_state = "[base_icon_state]_e"

///////////////////
// Dried Tobacco //
///////////////////
/obj/item/storage/bag/tobaccopouch
	name = "tobacco pouch"
	desc = "A pouch containing dried tobacco leaves. Sourced from Frank's Hydrofarms."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "tobaccopouch"
	w_class = WEIGHT_CLASS_TINY
	var/spawn_type =/obj/item/food/grown/tobacco

/obj/item/storage/bag/tobaccopouch/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.numerical_stacking = TRUE
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.max_slots = 10
	atom_storage.screen_max_columns = 3
	atom_storage.set_holdable(list(
		/obj/item/food/grown/tobacco,
		))

/obj/item/storage/bag/tobaccopouch/PopulateContents()
	if(spawn_type)
		for(var/i in 1 to 10)
			var/obj/item/food/grown/tobacco/leaf = new spawn_type(src)
			ADD_TRAIT(leaf, TRAIT_DRIED, ELEMENT_TRAIT(type))
			leaf.add_atom_colour(COLOR_DRIED_TAN, FIXED_COLOUR_PRIORITY) //give them the tan just like from the drying rack

/obj/item/storage/bag/tobaccopouch/space
	name = "space tobacco pouch"
	desc = "A pouch containing dried space tobacco leaves. Sourced from Frank's Hydrofarms."
	color = "#40b8ddff"
	spawn_type =/obj/item/food/grown/tobacco/space

/obj/item/storage/bag/tobaccopouch/empty
	spawn_type = null
	desc = "A pouch for holding dried tobacco leaves."

//////////////
// Pipe Box //
//////////////
/obj/item/storage/pipebox
	name = "pipe box"
	desc = "A fancy wooden pipebox for holding everything you need to smoke a pipe."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "pipebox"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT, /datum/material/iron = SMALL_MATERIAL_AMOUNT)
	var/slots = 4
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pipebox/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_slots = slots
	atom_storage.set_holdable(list(/obj/item/storage/bag/tobaccopouch, /obj/item/storage/box/matches, /obj/item/clothing/mask/cigarette/pipe, /obj/item/lighter))

/obj/item/storage/pipebox/PopulateContents()
	generate_items_inside(list(
		/obj/item/storage/bag/tobaccopouch = 2,
		/obj/item/clothing/mask/cigarette/pipe = 1,
	),src)
	if(prob(40))
		new /obj/item/lighter(src)
	else
		new /obj/item/storage/box/matches(src)

/obj/item/storage/pipebox/fancy
	name = "fancy pipe box"
	desc = "A very fancy wooden pipebox with gold engravings for holding everything you need to smoke a pipe in style."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "pipebox_fancy"
	slots = 6
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT, /datum/material/gold = SMALL_MATERIAL_AMOUNT)

/obj/item/storage/pipebox/fancy/PopulateContents()
	generate_items_inside(list(
		/obj/item/storage/bag/tobaccopouch = 2,
		/obj/item/clothing/mask/cigarette/pipe = 1,
		/obj/item/storage/box/matches = 1,
		/obj/item/storage/bag/tobaccopouch/space = 1,
		/obj/item/lighter/commemorative = 1,
	),src)
