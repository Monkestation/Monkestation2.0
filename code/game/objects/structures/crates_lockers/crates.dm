/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "crate"
	base_icon_state = "crate"
	req_access = null
	can_weld_shut = TRUE
	icon_welded = "welded_crate"
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	dense_when_open = TRUE
	//One quarter chance of ashing things inside.
	ash_chance = 25
	delivery_icon = "deliverycrate"
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	drag_slowdown = 0
	door_anim_time = 0 // no animation
	pass_flags_self = PASSSTRUCTURE | LETPASSTHROW
	/// Doesn't use the broken overlay when broken.
	var/no_broken_overlay = FALSE
	/// Mobs standing on it are nudged up by this amount.
	var/elevation = 14
	/// The same, but when the crate is open
	var/elevation_open = 14
	/// The time spent to climb this crate.
	var/crate_climb_time = 2 SECONDS
	/// The reference of the manifest paper attached to the cargo crate.
	var/obj/item/paper/manifest
	/// Where the Icons for lids are located.
	var/lid_icon = 'icons/obj/storage/crates.dmi'
	/// Icon state to use for lid to display when opened. Leave undefined if there isn't one.
	var/lid_icon_state
	/// Controls the X value of the lid, allowing left and right pixel movement.
	var/lid_x = 0
	/// Controls the Y value of the lid, allowing up and down pixel movement.
	var/lid_y = 0

/obj/structure/closet/crate/Initialize(mapload)
	. = ..()

	var/static/list/crate_paint_jobs
	if(isnull(crate_paint_jobs))
		crate_paint_jobs = list(
		"Internals" = list("icon_state" = "o2crate"),
		"Medical" = list("icon_state" = "medicalcrate"),
		"Radiation" = list("icon_state" = "radiation"),
		"Hydrophonics" = list("icon_state" = "hydrocrate"),
		"Science" = list("icon_state" = "scicrate"),
		"Solar" = list("icon_state" = "engi_e_crate"),
		"Engineering" = list("icon_state" = "engi_crate")
	)
	if(paint_jobs)
		paint_jobs = crate_paint_jobs
	if(icon_state == "[initial(icon_state)]open")
		opened = TRUE
		AddElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	else
		AddElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	if(elevation)
		AddElement(/datum/element/elevation, pixel_shift = elevation)
	update_appearance()
	AddComponent(/datum/component/soapbox)

/obj/structure/closet/crate/Destroy()
	. = ..()
	if(manifest)
		QDEL_NULL(manifest)

/obj/structure/closet/crate/deconstruct(disassembled = TRUE)
	if (!(flags_1 & NODECONSTRUCT_1))
		if(manifest)
			manifest.forceMove(drop_location(src))
			manifest = null
	..()

/obj/structure/closet/crate/examine(mob/user)
	. = ..()
	if(manifest)
		. += span_notice("You can remove the attached paper with a sharp edged object.")
		. += manifest.examine(user)
	else
		. += span_notice("You can attach a piece of paper to it.")

/obj/structure/closet/crate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!istype(mover, /obj/structure/closet))
		var/obj/structure/closet/crate/locatedcrate = locate(/obj/structure/closet/crate) in get_turf(mover)
		if(locatedcrate) //you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
			if(opened) //if we're open, allow entering regardless of located crate openness
				return TRUE
			if(!locatedcrate.opened) //otherwise, if the located crate is closed, allow entering
				return TRUE

/obj/structure/closet/crate/update_icon_state()
	icon_state = "[isnull(base_icon_state) ? initial(icon_state) : base_icon_state][opened ? "open" : ""]"
	return ..()

/obj/structure/closet/crate/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(manifest)
		var/mutable_appearance/manifest_overlay = mutable_appearance(icon, "manifest")
		manifest_overlay.color = manifest?.color
		. += manifest_overlay
	if(broken && !no_broken_overlay)
		. += "securecrateemag"
	else if(locked)
		. += "securecrater"
	else if(secure)
		. += "securecrateg"
	if(opened && lid_icon_state)
		var/mutable_appearance/lid = mutable_appearance(icon = lid_icon, icon_state = lid_icon_state)
		lid.pixel_x = lid_x
		lid.pixel_y = lid_y
		lid.layer = layer
		. += lid
	if(welded)
		. += icon_welded


/obj/structure/closet/crate/after_open(mob/living/user, force)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	if(elevation != elevation_open)
		if(elevation)
			RemoveElement(/datum/element/elevation, pixel_shift = elevation)
		if(elevation_open)
			AddElement(/datum/element/elevation, pixel_shift = elevation_open)

/obj/structure/closet/crate/after_close(mob/living/user, force)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time * 0.5, climb_stun = 0)
	AddElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	if(elevation != elevation_open)
		if(elevation_open)
			RemoveElement(/datum/element/elevation, pixel_shift = elevation_open)
		if(elevation)
			AddElement(/datum/element/elevation, pixel_shift = elevation)

///Spawns two to six maintenance spawners inside the closet
/obj/structure/closet/proc/populate_with_random_maint_loot()
	SIGNAL_HANDLER

	for (var/i in 1 to rand(2,6))
		new /obj/effect/spawner/random/maintenance(src)

	UnregisterSignal(src, COMSIG_CLOSET_POPULATE_CONTENTS)

/obj/structure/closet/crate/insert(atom/movable/inserted, mapload)
	var/amount_of_contents = length(contents)
	if(manifest)
		amount_of_contents-- // since the manifest is in the contents of the crate
	if(amount_of_contents >= storage_capacity)
		if(!mapload)
			return LOCKER_FULL
		//For maploading, we only return LOCKER_FULL if the movable was otherwise insertable. This way we can avoid logging false flags.
		return insertion_allowed(inserted) ? LOCKER_FULL : FALSE
	if(!insertion_allowed(inserted))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_CLOSET_INSERT, inserted) & COMPONENT_CLOSET_INSERT_INTERRUPT)
		return TRUE
	inserted.forceMove(src)
	return TRUE

/obj/structure/closet/crate/dump_contents()
	if (!contents_initialized)
		contents_initialized = TRUE
		PopulateContents()

	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		if(AM == manifest)
			continue
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/crate/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(opened)
		return
	if(istype(tool, /obj/item/paper) && !manifest)
		to_chat(user, span_notice("You begin attaching [tool] to [src]..."))
		if(!do_after(user, 1 SECOND, target=src))
			return ITEM_INTERACT_BLOCKING
		attach_manifest(tool, user)
		return ITEM_INTERACT_BLOCKING
	if(!manifest)
		return
	if(!(tool.get_sharpness() == SHARP_EDGED))
		return
	to_chat(user, span_notice("You begin cutting [manifest] off of [src]..."))
	if(!do_after(user, 1 SECOND, target=src))
		return ITEM_INTERACT_BLOCKING
	tear_manifest(user)
	return ITEM_INTERACT_BLOCKING

/obj/structure/closet/crate/item_interaction_secondary(mob/living/user, obj/item/attacking_item, list/modifiers)
	. = ..()
	if(!manifest)
		return

	var/list/writing_stats = attacking_item.get_writing_implement_details()

	if(!length(writing_stats))
		return
	if(writing_stats["interaction_mode"] != MODE_STAMPING)
		return
	if(!user.can_read(manifest) || user.is_blind())
		return

	manifest.add_stamp(writing_stats["stamp_class"], rand(1, 300), rand(1, 400), stamp_icon_state = writing_stats["stamp_icon_state"])
	user.visible_message(
		span_notice("[user] quickly stamps [manifest] with [attacking_item] without looking."),
		span_notice("You quickly stamp [manifest] with [attacking_item] without looking."),
	)
	playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
	return ITEM_INTERACT_BLOCKING

///Removes the supply manifest from the closet
/obj/structure/closet/crate/proc/attach_manifest(obj/item/paper/manifest_to_attach, mob/user)
	if(manifest)
		return
	if(QDELETED(manifest_to_attach))
		return
	if(!user.transferItemToLoc(manifest_to_attach, src))
		return
	manifest = manifest_to_attach
	update_appearance(UPDATE_OVERLAYS)
	to_chat(user, span_notice("You attach the [manifest] to [src]."))

///Removes the supply manifest from the closet
/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	if(QDELETED(manifest))
		manifest = null
		return
	if(user)
		to_chat(user, span_notice("You remove the [manifest] from [src]."))
	playsound(src, 'sound/items/poster_ripped.ogg', 75, TRUE)

	manifest.forceMove(drop_location(src))
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_appearance()

/obj/structure/closet/crate/preopen
	opened = TRUE
	icon_state = "crateopen"

/obj/structure/closet/crate/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	base_icon_state = "coffin"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 5
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	can_install_electronics = FALSE
	paint_jobs = null
	no_broken_overlay = TRUE
	can_weld_shut = FALSE

/obj/structure/closet/crate/internals
	desc = "An internals crate."
	name = "internals crate"
	icon_state = "o2crate"
	base_icon_state = "o2crate"

/obj/structure/closet/crate/trashcart //please make this a generic cart path later after things calm down a little
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"
	base_icon_state = "trashcart"
	can_install_electronics = FALSE
	paint_jobs = null


/obj/structure/closet/crate/trashcart/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 15)

/obj/structure/closet/crate/trashcart/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, TRUE)

/obj/structure/closet/crate/trashcart/filled

/obj/structure/closet/crate/trashcart/filled/Initialize(mapload)
	. = ..()
	if(mapload)
		new /obj/effect/spawner/random/trash/grime(loc) //needs to be done before the trashcart is opened because it spawns things in a range outside of the trashcart

/obj/structure/closet/crate/trashcart/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(7,15))
		new /obj/effect/spawner/random/trash/garbage(src)
		if(prob(12))
			new /obj/item/storage/bag/trash/filled(src)

/obj/structure/closet/crate/trashcart/laundry
	name = "laundry cart"
	desc = "A large cart for hauling around large amounts of laundry."
	icon_state = "laundry"
	base_icon_state = "laundry"
	elevation = 14
	elevation_open = 14
	can_weld_shut = FALSE

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"
	base_icon_state = "medicalcrate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"
	base_icon_state = "freezer"
	paint_jobs = null

/obj/structure/closet/crate/freezer/before_open(mob/living/user, force)
	. = ..()
	if(!.)
		return FALSE

	toggle_organ_decay(src)
	return TRUE

/obj/structure/closet/crate/freezer/after_close(mob/living/user)
	. = ..()
	toggle_organ_decay(src)

/obj/structure/closet/crate/freezer/Destroy()
	toggle_organ_decay(src)
	return ..()

/obj/structure/closet/crate/freezer/blood
	name = "blood freezer"
	desc = "A freezer containing packs of blood."

/obj/structure/closet/crate/freezer/blood/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood/a_minus(src)
	new /obj/item/reagent_containers/blood/b_minus(src)
	new /obj/item/reagent_containers/blood/b_plus(src)
	new /obj/item/reagent_containers/blood/o_minus(src)
	new /obj/item/reagent_containers/blood/o_plus(src)
	new /obj/item/reagent_containers/blood/lizard(src)
	new /obj/item/reagent_containers/blood/ethereal(src)
	new /obj/item/reagent_containers/blood/spider(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/chem_pack/saline(src)
		new /obj/item/reagent_containers/blood/random(src)

/obj/structure/closet/crate/freezer/surplus_limbs
	name = "surplus prosthetic limbs"
	desc = "A crate containing an assortment of cheap prosthetic limbs."

/obj/structure/closet/crate/freezer/surplus_limbs/PopulateContents()
	. = ..()
	new /obj/item/bodypart/arm/left/robot/surplus(src)
	new /obj/item/bodypart/arm/left/robot/surplus(src)
	new /obj/item/bodypart/arm/right/robot/surplus(src)
	new /obj/item/bodypart/arm/right/robot/surplus(src)
	new /obj/item/bodypart/leg/left/robot/surplus(src)
	new /obj/item/bodypart/leg/left/robot/surplus(src)
	new /obj/item/bodypart/leg/right/robot/surplus(src)
	new /obj/item/bodypart/leg/right/robot/surplus(src)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation"
	base_icon_state = "radiation"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"
	base_icon_state = "hydrocrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	icon_state = "engi_crate"
	base_icon_state = "engi_crate"

/obj/structure/closet/crate/engineering/fundedsatellites
	name = "budgeted meteor satellites"
	desc = "The lock seems to respond to Centcom's station goal announcements. CAUTION: Do not attempt to break the lock."
	icon_state = "engi_secure_crate"
	base_icon_state = "engi_secure_crate"
	secure = TRUE
	locked = TRUE

/obj/structure/closet/crate/engineering/fundedsatellites/PopulateContents()
	. = ..()
	if(GLOB.station_goals.len)
		for(var/datum/station_goal/station_goal as anything in GLOB.station_goals)
			if(istype(station_goal, /datum/station_goal/station_shield))
				new /obj/item/paper/crumpled/wehavenomoneyhaha(src)
				return
		for(var/i in 1 to 20)
			new /obj/item/meteor_shield_capsule(src)
	else
		new /mob/living/basic/spider/giant(src)

/obj/structure/closet/crate/engineering/fundedsatellites/allowed(user)
	if(GLOB.station_goals.len)
		return TRUE
	return FALSE

/obj/item/paper/crumpled/wehavenomoneyhaha
	name = "note from Centcom's accounting department"
	default_raw_text = "We ran out of budget."

/obj/structure/closet/crate/engineering/electrical
	icon_state = "engi_e_crate"
	base_icon_state = "engi_e_crate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"
	icon_state = "engi_crate"
	base_icon_state = "engi_crate"

/obj/structure/closet/crate/rcd/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)
	new /obj/item/construction/rcd(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"
	base_icon_state = "scicrate"

/obj/structure/closet/crate/mod
	name = "MOD crate"
	icon_state = "scicrate"
	base_icon_state = "scicrate"

/obj/structure/closet/crate/mod/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/mod/core/standard(src)
	for(var/i in 1 to 2)
		new /obj/item/clothing/neck/link_scryer/loaded(src)

/obj/structure/closet/crate/solarpanel_small
	name = "budget solar panel crate"
	icon_state = "engi_e_crate"
	base_icon_state = "engi_e_crate"

/obj/structure/closet/crate/solarpanel_small/PopulateContents()
	..()
	for(var/i in 1 to 13)
		new /obj/item/solar_assembly(src)
	new /obj/item/circuitboard/computer/solar_control(src)
	new /obj/item/paper/guides/jobs/engi/solars(src)
	new /obj/item/electronics/tracker(src)

/obj/structure/closet/crate/goldcrate
	name = "gold crate"

/obj/structure/closet/crate/goldcrate/PopulateContents()
	..()
	new /obj/item/storage/belt/champion(src)

/obj/structure/closet/crate/goldcrate/populate_contents_immediate()
	. = ..()

	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/mineral/gold(src, 1, FALSE)

/obj/structure/closet/crate/silvercrate
	name = "silver crate"

/obj/structure/closet/crate/silvercrate/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/coin/silver(src)

/obj/structure/closet/crate/decorations
	icon_state = "engi_crate"
	base_icon_state = "engi_crate"

/obj/structure/closet/crate/decorations/PopulateContents()
	. = ..()
	for(var/i in 1 to 4)
		new /obj/effect/spawner/random/decoration/generic(src)

/obj/structure/closet/crate/add_to_roundstart_list()
	return
