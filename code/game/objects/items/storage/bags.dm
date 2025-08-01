#define ORE_BAG_BALOON_COOLDOWN (2 SECONDS)

/*
 * These absorb the functionality of the plant bag, ore satchel, etc.
 * They use the use_to_pickup, quick_gather, and quick_empty functions
 * that were already defined in weapon/storage, but which had been
 * re-implemented in other classes.
 *
 * Contains:
 * Trash Bag
 * Mining Satchel
 * Plant Bag
 * Sheet Snatcher
 * Book Bag
 *      Biowaste Bag
 *
 * -Sayu
 */

//  Generic non-item
/obj/item/storage/bag
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_NORMAL
	storage_type = /datum/storage/bag

/obj/item/storage/bag/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.numerical_stacking = TRUE

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "trashbag"
	inhand_icon_state = "trashbag"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	storage_type = /datum/storage/trash
	///If true, can be inserted into the janitor cart
	var/insertable = TRUE

/obj/item/storage/bag/trash/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_total_storage = 30
	atom_storage.max_slots = 30
	atom_storage.set_holdable(cant_hold_list = list(/obj/item/disk/nuclear))
	atom_storage.supports_smart_equip = FALSE
	RegisterSignal(atom_storage, COMSIG_STORAGE_DUMP_POST_TRANSFER, PROC_REF(post_insertion))

/// If you dump a trash bag into something, anything that doesn't get inserted will spill out onto your feet
/obj/item/storage/bag/trash/proc/post_insertion(datum/storage/source, atom/dest_object, mob/user)
	SIGNAL_HANDLER
	// If there's no item in there, don't do anything
	if(!(locate(/obj/item) in src))
		return

	// Otherwise, we're gonna dump into the dest object
	var/turf/dump_onto = get_turf(dest_object)
	user.visible_message(
		span_notice("[user] dumps the contents of [src] all out on \the [dump_onto]"),
		span_notice("The remaining trash in \the [src] falls out onto \the [dump_onto]"),
	)
	source.remove_all(dump_onto)

/obj/item/storage/bag/trash/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] puts [src] over [user.p_their()] head and starts chomping at the insides! Disgusting!"))
	playsound(loc, 'sound/items/eatfood.ogg', 50, TRUE, -1)
	return TOXLOSS

/obj/item/storage/bag/trash/update_icon_state()
	switch(contents.len)
		if(20 to INFINITY)
			icon_state = "[initial(icon_state)]3"
		if(11 to 20)
			icon_state = "[initial(icon_state)]2"
		if(1 to 11)
			icon_state = "[initial(icon_state)]1"
		else
			icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/storage/bag/trash/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/storage/bag/trash/filled

/obj/item/storage/bag/trash/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(1, 7))
		new /obj/effect/spawner/random/trash/garbage(src)
	update_icon_state()

/obj/item/storage/bag/trash/bluespace
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	inhand_icon_state = "bluetrashbag"
	item_flags = NO_MAT_REDEMPTION

/obj/item/storage/bag/trash/bluespace/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 60
	atom_storage.max_slots = 60

/obj/item/storage/bag/trash/bluespace/cyborg
	insertable = FALSE

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	worn_icon_state = "satchel"
	///If this is TRUE, the holder won't receive any messages when they fail to pick up ore through crossing it
	var/spam_protection = FALSE
	var/mob/listeningTo
	///Cooldown on balloon alerts when picking ore
	COOLDOWN_DECLARE(ore_bag_balloon_cooldown)

/obj/item/storage/bag/ore/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_HUGE
	atom_storage.max_total_storage = 50
	atom_storage.numerical_stacking = TRUE
	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.set_holdable(list(/obj/item/stack/ore))
	atom_storage.silent_for_user = TRUE

/obj/item/storage/bag/ore/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(pickup_ores))
	listeningTo = user

/obj/item/storage/bag/ore/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/storage/bag/ore/proc/pickup_ores(mob/living/user)
	SIGNAL_HANDLER

	var/show_message = FALSE
	var/obj/structure/ore_box/box
	var/turf/tile = get_turf(user)

	if(!isturf(tile))
		return

	if(istype(user.pulling, /obj/structure/ore_box))
		box = user.pulling

	if(atom_storage)
		for(var/thing in tile)
			if(!is_type_in_typecache(thing, atom_storage.can_hold))
				continue
			if(box)
				user.transferItemToLoc(thing, box)
				show_message = TRUE
			else if(atom_storage.attempt_insert(thing, user))
				show_message = TRUE
			else
				if(!spam_protection)
					balloon_alert(user, "bag full!")
					spam_protection = TRUE
					continue
	if(show_message)
		playsound(user, SFX_RUSTLE, 50, TRUE)
		if(!COOLDOWN_FINISHED(src, ore_bag_balloon_cooldown))
			return

		COOLDOWN_START(src, ore_bag_balloon_cooldown, ORE_BAG_BALOON_COOLDOWN)
		if (box)
			balloon_alert(user, "scoops ore into box")
			user.visible_message(
				span_notice("[user] offloads the ores beneath [user.p_them()] into [box]."),
				ignored_mobs = user
			)
		else
			balloon_alert(user, "scoops ore into bag")
			user.visible_message(
				span_notice("[user] scoops up the ores beneath [user.p_them()]."),
				ignored_mobs = user
			)

	spam_protection = FALSE

/obj/item/storage/bag/ore/cyborg
	name = "cyborg mining satchel"

/obj/item/storage/bag/ore/holding //miners, your messiah has arrived
	name = "mining satchel of holding"
	desc = "A revolution in convenience, this satchel allows for huge amounts of ore storage. It's been outfitted with anti-malfunction safety measures."
	icon_state = "satchel_bspace"

/obj/item/storage/bag/ore/holding/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = INFINITY
	atom_storage.max_specific_storage = INFINITY
	atom_storage.max_total_storage = INFINITY

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	worn_icon_state = "plantbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plants/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 100
	atom_storage.max_slots = 100
	atom_storage.set_holdable(list(
		/obj/item/seeds,
		/obj/item/food/grown,
		/obj/item/grown,
		/obj/item/reagent_containers/honeycomb,
		/obj/item/graft,
		/obj/item/disk/plantgene,
		/obj/item/paper,
		))
////////

/obj/item/storage/bag/plants/portaseeder
	name = "portable seed extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	icon_state = "portaseeder"

/obj/item/storage/bag/plants/portaseeder/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/storage/bag/plants/portaseeder/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user
)

	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Make seeds"
	return CONTEXTUAL_SCREENTIP_SET


/obj/item/storage/bag/plants/portaseeder/examine(mob/user)
	. = ..()
	. += span_notice("Ctrl-click to activate seed extraction.")

/obj/item/storage/bag/plants/portaseeder/CtrlClick(mob/user)
	if(user.incapacitated())
		return
	for(var/obj/item/plant in contents)
		seedify(plant, 1)

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// sorry sayu your sheet snatcher is now OBSOLETE but i'm leaving it because idc

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	worn_icon_state = "construction_bag" //monkestation edit

	var/capacity = 300; //the number of sheets it can carry.

/obj/item/storage/bag/sheetsnatcher/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_empty = TRUE
	atom_storage.allow_quick_gather = TRUE
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(list(
			/obj/item/stack/sheet
			),
		list(
			/obj/item/stack/sheet/mineral/sandstone,
			/obj/item/stack/sheet/mineral/wood,
			))
	atom_storage.max_total_storage = capacity / 2

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

// -----------------------------
//           Book bag
// -----------------------------

/obj/item/storage/bag/books
	name = "book bag"
	desc = "A bag for books."
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	worn_icon_state = "bookbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/books/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21
	atom_storage.max_slots = 7
	atom_storage.set_holdable(list(
		/obj/item/book,
		/obj/item/spellbook,
		/obj/item/book,
		/obj/item/poster,
	))

/*
 * Trays - Agouri
 */
/obj/item/storage/bag/tray
	name = "serving tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "tray"
	worn_icon_state = "tray"
	desc = "A metal tray to lay food on."
	force = 5
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*1.5)
	custom_price = PAYCHECK_CREW * 0.6

/obj/item/storage/bag/tray/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY //Plates are required bulky to keep them out of backpacks
	atom_storage.set_holdable(list(
		/obj/item/clothing/mask/cigarette,
		/obj/item/food,
		/obj/item/kitchen,
		/obj/item/lighter,
		/obj/item/organ,
		/obj/item/plate,
		/obj/item/reagent_containers/condiment,
		/obj/item/reagent_containers/cup,
		/obj/item/rollingpaper,
		/obj/item/storage/box/gum,
		/obj/item/storage/box/matches,
		/obj/item/storage/fancy,
		/obj/item/trash,
		)) //Should cover: Bottles, Beakers, Bowls, Booze, Glasses, Food, Food Containers, Food Trash, Organs, Tobacco Products, Lighters, and Kitchen Tools.
	atom_storage.insert_preposition = "on"
	atom_storage.max_slots = 7

/obj/item/storage/bag/tray/attack(mob/living/M, mob/living/user)
	. = ..()
	// Drop all the things. All of them.
	var/list/obj/item/oldContents = contents.Copy()
	atom_storage.remove_all(user)
	// Make each item scatter a bit
	for(var/obj/item/tray_item in oldContents)
		do_scatter(tray_item)

	if(prob(50))
		playsound(M, 'sound/items/trayhit1.ogg', 50, TRUE)
	else
		playsound(M, 'sound/items/trayhit2.ogg', 50, TRUE)

	if(ishuman(M))
		if(prob(10))
			M.Paralyze(40)
	update_appearance()

/obj/item/storage/bag/tray/proc/do_scatter(obj/item/tray_item)
	var/delay = rand(2,4)
	var/datum/move_loop/loop = SSmove_manager.move_rand(tray_item, list(NORTH,SOUTH,EAST,WEST), delay, timeout = rand(1, 2) * delay, flags = MOVEMENT_LOOP_START_FAST)
	//This does mean scattering is tied to the tray. Not sure how better to handle it
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(change_speed))

/obj/item/storage/bag/tray/proc/change_speed(datum/move_loop/source)
	SIGNAL_HANDLER
	var/new_delay = rand(2, 4)
	var/count = source.lifetime / source.delay
	source.lifetime = count * new_delay
	source.delay = new_delay

/obj/item/storage/bag/tray/update_overlays()
	. = ..()
	for(var/obj/item/I in contents)
		var/mutable_appearance/I_copy = new(I)
		I_copy.plane = FLOAT_PLANE
		I_copy.layer = FLOAT_LAYER
		. += I_copy

/obj/item/storage/bag/tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance()

/obj/item/storage/bag/tray/Exited(atom/movable/gone, direction)
	. = ..()
	update_appearance()

/obj/item/storage/bag/tray/cafeteria
	name = "cafeteria tray"
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "foodtray"
	desc = "A cheap metal tray to pile today's meal onto."

/*
 * Chemistry bag
 */

/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "bag"
	worn_icon_state = "chembag"
	desc = "A bag for storing pills, patches, and bottles."
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/chemistry/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 50
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/chem_pack,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/glass/waterbottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		))

/*
 *  Biowaste bag (mostly for virologists)
 */

/obj/item/storage/bag/bio
	name = "bio bag"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "biobag"
	worn_icon_state = "biobag"
	desc = "A bag for the safe transportation and disposal of biowaste and other virulent materials."
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/bio/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 25
	atom_storage.set_holdable(list(
		/obj/item/bodypart,
		/obj/item/food/monkeycube,
		/obj/item/healthanalyzer,
		/obj/item/organ,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/reagent_containers/syringe,
		/obj/item/weapon/virusdish,//Monkestation Addition
		/obj/item/food/monkeycube/mouse,//Monkestation Addition
		/obj/item/disk/disease,
		))

/*
 *  Science bag (mostly for xenobiologists)
 */

/obj/item/storage/bag/xeno
	name = "science bag"
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "xenobag"
	worn_icon_state = "xenobag"
	desc = "A bag for the storage and transport of anomalous materials."
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/xeno/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 25
	atom_storage.set_holdable(list(
//MONKESTATION EDIT START
		/obj/item/autoslime,
//MONKESTATION EDIT END
		/obj/item/bodypart,
		/obj/item/food/deadmouse,
		/obj/item/food/monkeycube,
		/obj/item/organ,
		/obj/item/petri_dish,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/syringe,
//MONKESTATION EDIT START
		/obj/item/slimecross,
//MONKESTATION EDIT END
		/obj/item/slime_extract,
		/obj/item/swab,
		/obj/item/stack/biomass // monke: make science bags able to hold biomass cubes
		))

/obj/item/storage/bag/construction
	name = "construction bag"
	icon = 'icons/obj/tools.dmi'
	icon_state = "construction_bag"
	worn_icon_state = "construction_bag"
	desc = "A bag for storing small construction components."
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/construction

/obj/item/storage/bag/harpoon_quiver
	name = "harpoon quiver"
	desc = "A quiver for holding harpoons."
	icon = 'icons/obj/weapons/bows/quivers.dmi'
	icon_state = "quiver"
	inhand_icon_state = null
	worn_icon_state = "harpoon_quiver"

/obj/item/storage/bag/harpoon_quiver/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	atom_storage.max_slots = 40
	atom_storage.max_total_storage = 100
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/caseless/harpoon
		))

/obj/item/storage/bag/harpoon_quiver/PopulateContents()
	for(var/i in 1 to 40)
		new /obj/item/ammo_casing/caseless/harpoon(src)

/obj/item/storage/bag/rebar_quiver
	name = "rebar quiver"
	icon = 'icons/obj/weapons/bows/quivers.dmi'
	icon_state = "rebar_quiver"
	worn_icon_state = "rebar_quiver"
	inhand_icon_state = "rebar_quiver"
	desc = "A oxygen tank cut in half, used for holding sharpened rods for the rebar crossbow."
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE|ITEM_SLOT_NECK
	resistance_flags = FLAMMABLE
	storage_type = /datum/storage/bag/rebar_quiver

/obj/item/storage/bag/rebar_quiver/syndicate
	icon_state = "syndie_quiver_0"
	worn_icon_state = "syndie_quiver_0"
	inhand_icon_state = "holyquiver"
	base_icon_state = "syndie_quiver"
	desc = "A specialized quiver meant to hold any kind of bolts intended for use with the rebar crossbow. \
		Clearly a better design than a cut up oxygen tank..."
	slot_flags = ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/reload_rebar)
	storage_type = /datum/storage/bag/rebar_quiver/syndicate

/obj/item/storage/bag/rebar_quiver/syndicate/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/storage/bag/rebar_quiver/syndicate/PopulateContents()
	for(var/to_fill in 1 to 20)
		new /obj/item/ammo_casing/rebar/syndie(src)

/obj/item/storage/bag/rebar_quiver/syndicate/update_icon_state()
	. = ..()
	switch(contents.len)
		if(0)
			icon_state = "[base_icon_state]" + "_0"
		if(1 to 7)
			icon_state = "[base_icon_state]" + "_1"
		if(8 to 13)
			icon_state = "[base_icon_state]" + "_2"
		if(14 to 20)
			icon_state = "[base_icon_state]" + "_3"

/obj/item/storage/bag/rebar_quiver/syndicate/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/reload_rebar))
		reload_held_rebar(user)

/obj/item/storage/bag/rebar_quiver/syndicate/proc/reload_held_rebar(mob/user)
	if(!contents.len)
		user.balloon_alert(user, "no bolts left!")
		return
	var/obj/held_item = user.get_active_held_item()
	if(!istype(held_item, /obj/item/gun/ballistic/rifle/rebarxbow))
		user.balloon_alert(user, "no held crossbow!")
		return
	var/obj/item/gun/ballistic/rifle/rebarxbow/held_crossbow = held_item
	if(length(held_crossbow.magazine.stored_ammo) >= held_crossbow.magazine.max_ammo)
		user.balloon_alert(user, "no more room!")
		return
	if(!do_after(user, 1.2 SECONDS, user, IGNORE_USER_LOC_CHANGE))
		return

	var/obj/item/ammo_casing/rebar/ammo_to_load = contents[1]
	held_crossbow.attackby(ammo_to_load, user)

#undef ORE_BAG_BALOON_COOLDOWN
