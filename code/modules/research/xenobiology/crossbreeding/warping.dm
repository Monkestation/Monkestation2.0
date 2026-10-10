/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "warping"
	effect = "warping"
	///what runes will be drawn depending on the crossbreed color
	var/obj/effect/warped_rune/runepath
	///time it takes to store the rune back into the crossbreed
	var/storing_time = 5 SECONDS
	///time it takes to draw the rune
	var/drawing_time = 5 SECONDS
	var/max_cooldown = 30 SECONDS
	/// Can you tap a slime extract on this to set its color?
	var/keyable = FALSE
	/// The slime color this is set to.
	var/key_color
	/// The rune this drew, so drawing again replaces it.
	var/datum/weakref/drawn_rune_ref
	COOLDOWN_DECLARE(cooldown)

/obj/item/slimecross/warping/examine(mob/user)
	. = ..()
	if(!keyable)
		return
	if(key_color)
		. += span_notice("It is attuned to [key_color].")
	else
		. += span_notice("Tap a slime extract on it to attune it to that color.")

/obj/item/slimecross/warping/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!keyable || !istype(tool, /obj/item/slime_extract))
		return NONE
	for(var/slime_color in GLOB.slime_colors_to_types)
		var/datum/slime_type/slime_type = GLOB.slime_colors_to_types[slime_color]
		if(slime_type::core_type != tool.type)
			continue
		key_color = slime_color
		show_warping_key(slime_color)
		balloon_alert(user, "attuned to [slime_color]")
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Outlines this in the rgb of the given slime color.
/atom/movable/proc/show_warping_key(key_color)
	var/datum/slime_type/key_type = GLOB.slime_colors_to_types[key_color]
	add_filter("warping_key", 1, outline_filter(1, key_type::rgb_code))

/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "rune_grey"
	move_resist = INFINITY //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	/// Sound played when the rune activates.
	var/dir_sound = 'sound/effects/phasein.ogg'
	/// Whether the rune triggers when something steps on it.
	var/activated_on_step = FALSE
	///is only used for bluespace crystal erasing as of now
	var/storing_time = 5 SECONDS
	///Nearly all runes needs to know which turf they are on
	var/turf/rune_turf
	/// Whether the rune deletes itself once it has activated.
	var/remove_on_activation = TRUE
	/// If TRUE, the rune starts processing on SSobj when it's made.
	var/uses_process = FALSE
	/// The slime color the rune is set to.
	var/key_color

/obj/effect/warped_rune/Initialize(mapload, key_color)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_appearance(UPDATE_OVERLAYS)
	rune_turf = get_turf(src)
	RegisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_rune))
	if(key_color)
		src.key_color = key_color
	if(uses_process)
		START_PROCESSING(SSobj, src)

/obj/effect/warped_rune/update_overlays()
	. = ..()
	. += "blank"

/obj/effect/warped_rune/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT)
	rune_turf = null
	return ..()

/obj/effect/warped_rune/examine(mob/user)
	. = ..()
	if(key_color)
		. += span_notice("It is attuned to [key_color].")

/obj/effect/warped_rune/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	rune_turf = get_turf(src)

/// Runes can also be deleted by bluespace crystals relatively fast as an alternative to cleaning them.
/obj/effect/warped_rune/item_interaction(mob/living/user, obj/item/stack/ore/bluespace_crystal/space_crystal, list/modifiers)
	if(!istype(space_crystal))
		return NONE
	if(!do_after(user, storing_time, target = src)) //the time it takes to nullify it depends on the rune too
		return ITEM_INTERACT_BLOCKING
	if(!space_crystal.use(1))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You nullify the effects of the rune with the bluespace crystal!"))
	playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/effect/warped_rune/acid_act()
	. = ..()
	visible_message(span_warning("[src] has been dissolved by the acid."))
	playsound(src, 'sound/items/tools/welder.ogg', 150, TRUE)
	qdel(src)

/obj/effect/warped_rune/proc/clean_rune()
	SIGNAL_HANDLER
	qdel(src)

/// Using the extract on the floor will "draw" the rune.
/obj/item/slimecross/warping/interact_with_atom(turf/open/target, mob/living/user, list/modifiers)
	if(istype(target, runepath)) // Checks if the target is a rune and then if you can store it
		to_chat(user, span_warning("You start to safely erase the [target]..."))
		if(do_after(user, storing_time, target = target))
			to_chat(user, span_warning("[target] erased."))
			qdel(target)
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_FAILURE

	if(!isturf(target) && !isturf(target?.loc))
		return NONE
	target = get_turf(target)

	if(!isopenturf(target) || isgroundlessturf(target))
		to_chat(user, span_warning("you cannot draw a rune here!"))
		return ITEM_INTERACT_FAILURE

	if(locate(/obj/effect/warped_rune) in target) // Check if the target is a floor and if there's a rune on said floor
		to_chat(user, span_warning("There is already a bluespace rune here!"))
		return ITEM_INTERACT_FAILURE

	if(!check_cd(user))
		return ITEM_INTERACT_FAILURE

	if(!do_after(user, drawing_time, target = target))
		return ITEM_INTERACT_FAILURE

	if(!(locate(/obj/effect/warped_rune) in target) && check_cd(user))  // Check one last time if a rune has been drawn during the do_after and if there's enough charges left
		warping_crossbreed_spawn(target,user)
		COOLDOWN_START(src, cooldown, max_cooldown)
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_FAILURE

/// Spawns the rune, taking away one rune charge
/obj/item/slimecross/warping/proc/warping_crossbreed_spawn(atom/target, mob/user)
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
	var/obj/effect/warped_rune/old_rune = drawn_rune_ref?.resolve()
	if(old_rune)
		qdel(old_rune)
	drawn_rune_ref = WEAKREF(new runepath(target, key_color))
	to_chat(user, span_notice("You carefully draw the rune with [src]."))

/obj/item/slimecross/warping/proc/check_cd(user)
	if(COOLDOWN_FINISHED(src, cooldown))
		return TRUE
	if(user)
		to_chat(user, span_warning("[src] is recharging energy."))
	return FALSE

/obj/effect/warped_rune/attack_hand(mob/living/user)
	. = ..()
	do_effect(user)

/obj/effect/warped_rune/proc/do_effect(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(remove_on_activation)
		playsound(rune_turf, dir_sound, 20, TRUE)
		to_chat(user, (span_notice("[src] fades.")))
		qdel(src)

/obj/effect/warped_rune/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER

	if(activated_on_step)
		playsound(rune_turf, dir_sound, vol = 20, vary = TRUE)
		visible_message(span_notice("[src] fades."))
		qdel(src)

/obj/effect/warped_rune/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

/obj/item/slimecross/warping/grey
	colour = SLIME_TYPE_GREY
	effect_desc = "Draws a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace

/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components."
	icon_state = "rune_grey"
	/// Maps each extract type to its /datum/slime_type.
	var/static/list/cores_to_slimes = null
	///extracttype is used to remember the type of the extract on the rune
	var/obj/item/slime_extract/extracttype
	/// How many extracts must be fed to the rune before it can be used.
	var/req_extracts = 8

/obj/effect/warped_rune/greyspace/Initialize(mapload, key_color)
	. = ..()
	if(isnull(cores_to_slimes))
		cores_to_slimes = list()
		for(var/datum/slime_type/slime_datum as anything in subtypesof(/datum/slime_type))
			cores_to_slimes[initial(slime_datum.core_type)] = slime_datum

/obj/effect/warped_rune/greyspace/examine(mob/user)
	. = ..()
	. += span_notice("It needs to absorb [req_extracts] more [extracttype ? "[extracttype::name]" : "slime extract"][req_extracts > 1 ? "s" : ""].")

/obj/effect/warped_rune/greyspace/do_effect(mob/user)
	for(var/obj/item/slime_extract/extract in rune_turf)
		if(extract.type == extracttype || isnull(extracttype)) //check if the extract is the first one or of the right color.
			extracttype = extract.type
			qdel(extract) //destroy the slime extract
			req_extracts--
			if(req_extracts <= 0)
				new /mob/living/basic/slime(rune_turf, cores_to_slimes[extracttype]) //spawn a slime from the extract's color
				req_extracts = initial(req_extracts)
				extracttype = null // reset extracttype to FALSE to allow a new extract type
				return ..()
			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
		else
			to_chat(user, span_warning("Requires a [extracttype ? "[extracttype::name]" : "slime extract"]."))

/obj/item/slimecross/warping/orange
	colour = SLIME_TYPE_ORANGE
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Draws a rune that can summon a bonfire."

/obj/effect/warped_rune/orangespace
	desc = "This can be activated to summon a bonfire."
	icon_state = "rune_orange"

/obj/effect/warped_rune/orangespace/do_effect(mob/user)
	new /obj/structure/bonfire/bluespace(rune_turf)
	return ..()

/obj/structure/bonfire/bluespace/Initialize(mapload)
	. = ..()
	start_burning()

/obj/structure/bonfire/bluespace/check_oxygen()
	return TRUE

/obj/item/slimecross/warping/purple
	colour = SLIME_TYPE_PURPLE
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = "Draws a rune that may be activated to summon two random medical items."

/obj/effect/warped_rune/purplespace
	desc = "This can be activated to summon two random medical items."
	icon_state = "rune_purple"

/obj/effect/warped_rune/purplespace/do_effect(mob/user)
	var/list/medical = list(
		/obj/item/stack/medical/gauze,
		/obj/item/reagent_containers/medipen,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/storage/pill_bottle/mutadone,
		/obj/item/storage/pill_bottle/potassiodide,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/blood_filter,
	)
	for(var/index in 1 to 2)
		var/path = pick_n_take(medical)
		new path(rune_turf)
	return ..()

/obj/item/slimecross/warping/blue
	colour = SLIME_TYPE_BLUE
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "Draws a rune that may be activated to wash and dry everything around it, and put out any fires."

/obj/effect/warped_rune/cyanspace
	icon_state = "rune_blue"
	desc = "This can be activated to wash and dry everything around it, and put out any fires."

/obj/effect/warped_rune/cyanspace/do_effect(mob/user)
	var/list/soaked_turfs = RANGE_TURFS(1, src)
	// washing our own tile erases us, and then the rest of this would run on a dead rune. so fade first
	. = ..()
	for(var/turf/open/soaked_turf in soaked_turfs)
		soaked_turf.wash(CLEAN_WASH)
		soaked_turf.ClearWet()
		for(var/obj/effect/hotspot/fire in soaked_turf)
			qdel(fire)
		for(var/mob/living/burning_mob in soaked_turf)
			burning_mob.extinguish_mob()

/obj/item/slimecross/warping/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	runepath = /obj/effect/warped_rune/darkcyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "Draws a rune that puts out and cools down whoever steps on it."

/obj/effect/warped_rune/darkcyanspace
	icon_state = "rune_dark_blue"
	desc = "Refreshing!"
	remove_on_activation = FALSE

/obj/effect/warped_rune/darkcyanspace/on_entered(datum/source, atom/movable/arrived, atom/old_loc)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/cooled_mob = arrived
	cooled_mob.extinguish_mob()
	if(cooled_mob.bodytemperature > cooled_mob.standard_body_temperature)
		cooled_mob.adjust_bodytemperature(cooled_mob.standard_body_temperature - cooled_mob.bodytemperature)

/obj/item/slimecross/warping/metal
	colour = SLIME_TYPE_METAL
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that may be activated to create a 3x3 block of walls. Whoever activated it can walk through them."

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "This can be activated to to create a 3x3 block of walls. Whoever activated it can walk through them."
	icon_state = "rune_metal"

/obj/effect/warped_rune/metalspace/do_effect(mob/user)
	for(var/turf/open/walled_turf in RANGE_TURFS(1, src))
		new /obj/effect/forcefield/wizard/warped(walled_turf, user)
	return ..()

/obj/effect/forcefield/wizard/warped
	name = "warped wall"
	desc = "A wall of folded space. Whoever raised it can walk right through."

/obj/item/slimecross/warping/yellow
	colour = SLIME_TYPE_YELLOW
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = "Draws a rune that slowly charges anything left on it."

/obj/effect/warped_rune/yellowspace
	desc = "Anything with a power cell slowly charges while it sits here."
	icon_state = "rune_yellow"
	remove_on_activation = FALSE
	uses_process = TRUE

/obj/effect/warped_rune/yellowspace/process(seconds_per_tick)
	for(var/atom/movable/charging in rune_turf)
		var/obj/item/stock_parts/power_store/cell/cell = charging.get_cell()
		if(cell?.give(STANDARD_CELL_CHARGE * 0.005 * seconds_per_tick))
			charging.update_appearance()

/obj/item/slimecross/warping/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Draw a rune that can transmute plasma into any other material."

/obj/effect/warped_rune/darkpurplespace
	icon_state = "rune_dark_purple"
	desc = "To gain something you must sacrifice something else in return."
	/// Material paths the rune can turn plasma into.
	var/static/list/materials = null

/obj/effect/warped_rune/darkpurplespace/Initialize(mapload, key_color)
	. = ..()
	if(isnull(materials))
		materials = list(
			/obj/item/stack/sheet/iron,
			/obj/item/stack/sheet/glass,
			/obj/item/stack/sheet/mineral/silver,
			/obj/item/stack/sheet/mineral/gold,
			/obj/item/stack/sheet/mineral/uranium,
			/obj/item/stack/sheet/mineral/titanium,
			/obj/item/stack/sheet/mineral/diamond,
			/obj/item/stack/ore/bluespace_crystal/refined
		)

/obj/effect/warped_rune/darkpurplespace/do_effect(mob/user)
	if(locate(/obj/item/stack/sheet/mineral/plasma) in rune_turf)
		var/plasma_amount = 0
		for(var/obj/item/stack/sheet/mineral/plasma/plasma_stack in rune_turf)
			plasma_amount += plasma_stack.amount
			qdel(plasma_stack)
		var/path_material = pick(materials)
		new path_material(rune_turf, plasma_amount)
		return ..()
	else
		to_chat(user, span_warning("Requires plasma!"))

/obj/item/slimecross/warping/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Draws a rune that slowly feeds slimes on it. People get fed too, but only until they stop being hungry."
	runepath = /obj/effect/warped_rune/silverspace

/obj/effect/warped_rune/silverspace
	desc = "This feeds whoever stays on it."
	icon_state = "rune_silver"
	remove_on_activation = FALSE
	uses_process = TRUE

/obj/effect/warped_rune/silverspace/process(seconds_per_tick)
	var/meal = 2 * seconds_per_tick
	for(var/mob/living/hungry_mob in rune_turf)
		if(isslime(hungry_mob))
			hungry_mob.adjust_nutrition(meal)
		else if(iscarbon(hungry_mob) && hungry_mob.nutrition < NUTRITION_LEVEL_FED)
			hungry_mob.adjust_nutrition(min(meal, NUTRITION_LEVEL_FED - hungry_mob.nutrition))

/obj/item/slimecross/warping/bluespace
	colour = SLIME_TYPE_BLUESPACE
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = "Draw a rune that serves as a bluespace container. Tap a slime extract on this first, and the rune opens that color's container instead."
	keyable = TRUE

/obj/effect/warped_rune/bluespace
	desc = "When activated, it gives access to a bluespace container."
	icon_state = "rune_bluespace"
	remove_on_activation = FALSE
	key_color = SLIME_TYPE_BLUESPACE
	/// One shared container per key color.
	var/static/list/obj/item/storage/backpack/holding/bluespace/storages_by_key = list()

/obj/effect/warped_rune/bluespace/Initialize(mapload, key_color)
	. = ..()
	show_warping_key(src.key_color)

/obj/effect/warped_rune/bluespace/Destroy(force)
	var/obj/item/storage/backpack/holding/bluespace/blue_storage = storages_by_key[key_color]
	if(blue_storage?.loc == rune_turf)
		blue_storage.moveToNullspace() // Do not touch the storage please
	return ..()

/obj/effect/warped_rune/bluespace/do_effect(mob/user)
	var/obj/item/storage/backpack/holding/bluespace/blue_storage = storages_by_key[key_color]
	if(QDELETED(blue_storage)) // Why isn't this on init? Linters of course!
		blue_storage = new(rune_turf)
		storages_by_key[key_color] = blue_storage

	blue_storage.forceMove(rune_turf)
	blue_storage.atom_storage.open_storage(user)
	playsound(rune_turf, dir_sound, 20, TRUE)
	return ..()

/obj/item/storage/backpack/holding/bluespace
	name = "warped rune"
	anchored = TRUE
	armor_type = /datum/armor/holding_bluespace
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/datum/armor/holding_bluespace
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/item/slimecross/warping/sepia
	colour = SLIME_TYPE_SEPIA
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = "Draws a rune that holds a dead body still in time, so it does not rot while it lies there."

/obj/effect/warped_rune/sepiaspace
	desc = "A dead body laid here is held still in time until it is moved off or brought back."
	icon_state = "rune_sepia"
	remove_on_activation = FALSE
	uses_process = TRUE

/obj/effect/warped_rune/sepiaspace/Destroy(force)
	for(var/mob/living/body in rune_turf)
		body.remove_status_effect(/datum/status_effect/grouped/stasis, REF(src))
	return ..()

/obj/effect/warped_rune/sepiaspace/process(seconds_per_tick)
	for(var/mob/living/body in rune_turf)
		if(body.stat != DEAD)
			body.remove_status_effect(/datum/status_effect/grouped/stasis, REF(src))
		else if(!body.has_status_effect(/datum/status_effect/grouped/stasis))
			body.apply_status_effect(/datum/status_effect/grouped/stasis, REF(src))

/obj/effect/warped_rune/sepiaspace/on_exited(datum/source, atom/movable/gone, direction)
	. = ..()
	astype(gone, /mob/living)?.remove_status_effect(/datum/status_effect/grouped/stasis, REF(src))

/obj/item/slimecross/warping/cerulean
	colour = SLIME_TYPE_CERULEAN
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = "Draws a rune that creates a hologram of the first living thing that stepped on the tile. The hologram repeats things they said near the rune."

/obj/effect/warped_rune/ceruleanspace
	desc = "A shadow of what once passed these halls, a memory perhaps?"
	icon_state = "rune_cerulean"
	remove_on_activation = FALSE
	///hologram that will be spawned by the rune
	var/obj/effect/overlay/holotile
	///mob the hologram will copy
	var/datum/weakref/holo_host_ref
	///used to remember the recent speech of the holo_host
	var/list/recent_speech

	COOLDOWN_DECLARE(talk_cooldown)

/obj/effect/warped_rune/ceruleanspace/Initialize(mapload, key_color)
	. = ..()
	become_hearing_sensitive()

/obj/effect/warped_rune/ceruleanspace/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range = 0)
	. = ..()
	if(radio_freq || !IS_WEAKREF_OF(speaker, holo_host_ref))
		return
	LAZYADD(recent_speech, raw_message)
	if(length(recent_speech) > 10)
		recent_speech.Cut(1, 2)

/obj/effect/warped_rune/ceruleanspace/process(seconds_per_tick)
	if(QDELETED(holotile))
		return PROCESS_KILL
	if(length(recent_speech) && COOLDOWN_FINISHED(src, talk_cooldown))
		holotile.say(pick(recent_speech))
		COOLDOWN_START(src, talk_cooldown, 10 SECONDS)

/obj/effect/warped_rune/ceruleanspace/on_entered(datum/source, atom/movable/arrived, atom/old_loc)
	. = ..()
	if(isliving(arrived) && !holo_host_ref)
		holo_host_ref = WEAKREF(arrived)

/obj/effect/warped_rune/ceruleanspace/do_effect(mob/user)
	. = ..()
	var/mob/living/holo_host = holo_host_ref?.resolve()
	if(holo_host && !holotile)
		holo_creation(holo_host)
		remove_on_activation = TRUE
		playsound(rune_turf, dir_sound, vol = 20, vary = TRUE)

/// Spawns a hologram that looks like the host, and starts processing.
/obj/effect/warped_rune/ceruleanspace/proc/holo_creation(mob/living/holo_host)
	holotile = new(rune_turf) //setting up the hologram to look like the person that just stepped in
	holotile.appearance = copy_appearance_filter_overlays(holo_host.appearance, recursion = 1)
	holotile.alpha = 200
	holotile.name = "[holo_host.name] (Hologram)"
	holotile.add_atom_colour(color_transition_filter("#77abff"), FIXED_COLOUR_PRIORITY)
	holotile.set_anchored(TRUE)
	holotile.set_density(FALSE)
	COOLDOWN_START(src, talk_cooldown, 10 SECONDS)
	START_PROCESSING(SSobj, src)

///destroys the hologram with the rune
/obj/effect/warped_rune/ceruleanspace/Destroy()
	QDEL_NULL(holotile)
	holo_host_ref = null
	recent_speech = null
	return ..()

/obj/item/slimecross/warping/pyrite
	colour = SLIME_TYPE_PYRITE
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "Draws a rune that dyes any item you touch to it, in a color you pick. The dye washes off."

/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "rune_pyrite"
	remove_on_activation = FALSE

/obj/effect/warped_rune/pyritespace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	// we get the click before the extract does, so leave warping extracts alone or nothing could erase us
	if(. || istype(tool, /obj/item/slimecross/warping))
		return
	var/dye_color = tgui_color_picker(user, "Pick a color for [tool].", name, COLOR_WHITE)
	if(!dye_color || QDELETED(src) || QDELETED(tool) || !user.is_holding(tool) || !user.can_perform_action(src))
		return ITEM_INTERACT_BLOCKING
	tool.add_atom_colour(color_transition_filter(dye_color), WASHABLE_COLOUR_PRIORITY)
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/warping/red
	colour = SLIME_TYPE_RED
	runepath = /obj/effect/warped_rune/redspace
	effect_desc = "Draws a rune that slowly gives blood back to anyone on it who is running low."

/obj/effect/warped_rune/redspace
	desc = "Anyone short on blood slowly gets it back while they stay here."
	icon_state = "rune_red"
	remove_on_activation = FALSE
	uses_process = TRUE

/obj/effect/warped_rune/redspace/process(seconds_per_tick)
	for(var/mob/living/carbon/drained_mob in rune_turf)
		if(HAS_TRAIT(drained_mob, TRAIT_NOBLOOD) || drained_mob.blood_volume >= BLOOD_VOLUME_NORMAL)
			continue
		drained_mob.blood_volume = min(drained_mob.blood_volume + 2 * seconds_per_tick, BLOOD_VOLUME_NORMAL)

/obj/item/slimecross/warping/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Draws a rune that may be activated to make every slime on it more likely to mutate, like a mutator potion does."
	runepath = /obj/effect/warped_rune/greenspace

/obj/effect/warped_rune/greenspace
	desc = "This can be activated to make the slimes on it more likely to mutate. It will not stack with a mutator potion."
	icon_state = "rune_green"

/obj/effect/warped_rune/greenspace/do_effect(mob/user)
	var/dosed_any = FALSE
	for(var/mob/living/basic/slime/dosed_slime in rune_turf)
		if(dosed_slime.stat == DEAD || dosed_slime.mutator_used || dosed_slime.mutation_chance >= 100)
			continue
		dosed_slime.mutation_chance = min(dosed_slime.mutation_chance + 12, 100)
		dosed_slime.mutator_used = TRUE
		dosed_any = TRUE
	if(!dosed_any)
		to_chat(user, span_warning("Requires a living slime that hasn't had a mutator yet!"))
		return
	return ..()

/* pink rune, makes people slightly happier after walking on it*/
/obj/item/slimecross/warping/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Draws a rune that makes people happier!"
	runepath = /obj/effect/warped_rune/pinkspace

/obj/effect/warped_rune/pinkspace
	desc = "Love is the only reliable source of happiness we have left. But like everything, it comes with a price."
	icon_state = "rune_pink"
	remove_on_activation = FALSE

///adds the jolly mood effect along with hug sound effect.
/obj/effect/warped_rune/pinkspace/on_entered(datum/source, mob/living/carbon/human/arrived, atom/old_loc)
	if(istype(arrived))
		arrived.add_mood_event("jolly", /datum/mood_event/jolly)
		playsound(rune_turf, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
		to_chat(arrived, span_notice("You feel happier."))
		activated_on_step = TRUE
	return ..()

/obj/item/slimecross/warping/gold
	colour = SLIME_TYPE_GOLD
	runepath = /obj/effect/warped_rune/goldspace
	effect_desc = "Draw a rune that exchanges objects of this dimension for objects of a parallel dimension."

/obj/effect/warped_rune/goldspace
	icon_state = "rune_gold"
	desc = "This can be activated to transmute valuable items into a random item."
	remove_on_activation = FALSE
	var/target_value = 5000
	var/static/list/common_items = list(
		/obj/item/toy/plush/carpplushie,
		/obj/item/toy/plush/bubbleplush,
		/obj/item/toy/plush/ratplush,
		/obj/item/toy/plush/narplush,
		/obj/item/toy/plush/lizard_plushie,
		/obj/item/toy/plush/snakeplushie,
		/obj/item/toy/plush/nukeplushie,
		/obj/item/toy/plush/slimeplushie,
		/obj/item/toy/plush/awakenedplushie,
		/obj/item/toy/plush/beeplushie,
		/obj/item/toy/plush/moth,
		/obj/item/toy/plush/shark,
		/obj/item/toy/eightball/haunted,
		/obj/item/toy/foamblade,
		/obj/item/toy/katana,
		/obj/item/toy/snappop/phoenix,
		/obj/item/toy/cards/deck/kotahi,
		/obj/item/toy/redbutton,
		/obj/item/toy/toy_xeno,
		/obj/item/toy/reality_pierce,
		/obj/item/toy/xmas_cracker,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted,
		/obj/item/gun/ballistic/automatic/pistol/toy,
		/obj/item/gun/ballistic/shotgun/toy,
		/obj/item/gun/ballistic/shotgun/toy/crossbow,
		/obj/item/clothing/mask/facehugger/toy,
		/obj/item/dualsaber/toy,
		/obj/item/clothing/under/costume/roman,
		/obj/item/clothing/under/costume/pirate,
		/obj/item/clothing/under/costume/kilt/highlander,
		/obj/item/clothing/under/costume/gladiator/ash_walker,
		/obj/item/clothing/under/costume/geisha,
		/obj/item/clothing/under/costume/villain,
		/obj/item/clothing/under/costume/singer/yellow,
		/obj/item/clothing/under/costume/russian_officer,
	)

	var/static/list/uncommon_items = list(
		/obj/item/gun/energy/laser/retro/old,
		/obj/item/storage/toolbox/mechanical/old,
		/obj/item/storage/toolbox/emergency/old,
		/mob/living/basic/pet/dog/corgi/puppy/void,
		/obj/structure/closet/crate/necropolis/tendril,
		/obj/item/card/emagfake,
		/obj/item/flashlight/flashdark,
	)

/obj/effect/warped_rune/goldspace/do_effect(mob/user)
	var/price = 0
	var/list/valuable_items = list()
	for(var/obj/item/offered_item in rune_turf)
		var/datum/export_report/report = export_item_and_contents(offered_item, dry_run = TRUE)
		for(var/exported_type in report.total_amount)
			if(report.total_value[exported_type])
				price += report.total_value[exported_type]
				valuable_items |= offered_item

	if(price >= target_value)
		remove_on_activation = TRUE
		var/path
		if(prob(80))
			path = pick(common_items)
		else
			path = pick(uncommon_items)

		var/atom/movable/prize = new path(rune_turf)
		QDEL_LIST(valuable_items)
		to_chat(user, span_notice("[src] shines and [prize] appears before you."))
	else
		to_chat(user, span_warning("The sacrifice is insufficient."))
	return ..()

//oil
/obj/item/slimecross/warping/oil
	colour = SLIME_TYPE_OIL
	runepath = /obj/effect/warped_rune/oilspace
	effect_desc = "Draws a rune that may be activated to light a 5 second fuse, then explodes. Erasing the rune puts the fuse out."

/obj/effect/warped_rune/oilspace
	icon_state = "rune_oil"
	desc = "This can be activated to light a short fuse. Erase it before the fuse runs out, or stand well back."
	remove_on_activation = FALSE
	/// Whether the fuse is already burning.
	var/fuse_lit = FALSE

/obj/effect/warped_rune/oilspace/do_effect(mob/user)
	. = ..()
	if(fuse_lit)
		return
	fuse_lit = TRUE
	visible_message(span_danger("[src] starts to hiss and smoke. It's going to blow!"))
	playsound(rune_turf, 'sound/effects/fuse.ogg', 100, TRUE)
	// one blink a second, keep it slow for photosensitive folks
	animate(src, alpha = 100, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 255, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(detonate)), 5 SECONDS)

/// Small blast when the fuse runs out, then the rune is gone.
/obj/effect/warped_rune/oilspace/proc/detonate()
	explosion(rune_turf, light_impact_range = 1, flash_range = 1, explosion_cause = src)
	qdel(src)

/obj/item/slimecross/warping/black
	colour = SLIME_TYPE_BLACK
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "Draw a rune that can transmute weapons with a starborne enchantment. A starborne weapon circles whoever drops or throws it, until they grab it again."

/obj/effect/warped_rune/blackspace
	icon_state = "rune_black"
	desc = "Lay a weapon on it, and the weapon will follow you like a tiny moon whenever you let go of it."

/obj/effect/warped_rune/blackspace/attack_hand(mob/living/user)
	to_chat(user, span_brass("[src] demands a weapon to enhance."))

/obj/effect/warped_rune/blackspace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. || istype(tool, /obj/item/slimecross/warping))
		return
	if(HAS_TRAIT(tool, TRAIT_STARBORNE))
		to_chat(user, span_warning("[tool] is already starborne. It cannot be enchanted further!"))
		return ITEM_INTERACT_BLOCKING
	if(isclothing(tool) || !tool.force || (tool.item_flags & (NOBLUDGEON | ABSTRACT)))
		to_chat(user, span_brass("You cannot upgrade [tool]."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_brass("You begin placing [tool] onto [src]."))
	if(!do_after(user, 6 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE)
	tool.AddElement(/datum/element/starborne)
	to_chat(user, span_notice("[tool] glows beautifully like the stars!"))
	do_effect(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/warping/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	runepath = /obj/effect/warped_rune/lightpinkspace
	effect_desc = "Draws a rune that makes whoever stands on it peaceful, for as long as they stay on it."

/obj/effect/warped_rune/lightpinkspace
	desc = "Peace and love."
	icon_state = "rune_light_pink"
	remove_on_activation = FALSE

/obj/effect/warped_rune/lightpinkspace/Initialize(mapload, key_color)
	. = ..()
	for(var/mob/living/calmed_mob in rune_turf)
		ADD_TRAIT(calmed_mob, TRAIT_PACIFISM, REF(src))

/obj/effect/warped_rune/lightpinkspace/Destroy(force)
	for(var/mob/living/calmed_mob in rune_turf)
		REMOVE_TRAIT(calmed_mob, TRAIT_PACIFISM, REF(src))
	return ..()

/obj/effect/warped_rune/lightpinkspace/on_entered(datum/source, atom/movable/arrived, atom/old_loc)
	. = ..()
	if(isliving(arrived))
		ADD_TRAIT(arrived, TRAIT_PACIFISM, REF(src))

/obj/effect/warped_rune/lightpinkspace/on_exited(datum/source, atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		REMOVE_TRAIT(gone, TRAIT_PACIFISM, REF(src))

/obj/item/slimecross/warping/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	runepath = /obj/effect/warped_rune/adamantinespace
	effect_desc = "Draw a rune that can summon reflective fields."

/obj/effect/warped_rune/adamantinespace
	desc = "This can be activated to summon reflective fields."
	icon_state = "rune_adamantine"

/obj/structure/reflector/box/anchored/mob_pass/CanAllowThrough(atom/movable/mover, border_dir)
	return isliving(mover) || ..()

/obj/effect/warped_rune/adamantinespace/do_effect(mob/user)
	for(var/turf/open/reflector_turf in RANGE_TURFS(1, src) - rune_turf)
		var/obj/structure/reflector/box/anchored/mob_pass/reflector = new (reflector_turf)
		reflector.set_angle(dir2angle(get_dir(src, reflector)))
		reflector.admin = TRUE
		QDEL_IN(reflector, 5 MINUTES)
	activated_on_step = TRUE
	return ..()

/* Used to teleport anything over it to a unique room similar to hilbert's hotel.*/

/obj/item/slimecross/warping/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Draws a rune that works as a door to a pocket room. Walk onto it to go in. Tap a slime extract on this first, and the rune leads to that color's room instead."
	runepath = /obj/effect/warped_rune/rainbowspace
	keyable = TRUE

/obj/effect/warped_rune/rainbowspace
	icon_state = "rune_rainbow"
	desc = "This is where I go when I want to be alone. Yet they keep clawing at the walls until everything crumbles."
	remove_on_activation = FALSE
	key_color = SLIME_TYPE_RAINBOW
	/// The pocket room this rune leads to.
	var/datum/warped_room/room

///creates the warped room and place an exit rune to exit the room
/obj/effect/warped_rune/rainbowspace/Initialize(mapload, key_color)
	. = ..()
	room = LAZYACCESS(GLOB.warped_rooms, src.key_color) || new /datum/warped_room(src.key_color)
	room.runes += src
	update_appearance(UPDATE_OVERLAYS)
	open_window()

/obj/effect/warped_rune/rainbowspace/update_overlays()
	. = ..()
	if(!room)
		return
	var/mutable_appearance/swirl = room.swirl()
	var/mutable_appearance/swirl_glow = emissive_appearance(swirl.icon, swirl.icon_state, src)
	swirl_glow.pixel_w = swirl.pixel_w
	swirl_glow.pixel_z = swirl.pixel_z
	. += swirl
	. += swirl_glow
	. += emissive_appearance(icon, icon_state, src)

/obj/effect/warped_rune/rainbowspace/Destroy()
	room?.runes -= src
	room = null
	return ..()

/// Shows the room's window on the rune, if the room has one.
/obj/effect/warped_rune/rainbowspace/proc/open_window()
	if(room.window)
		vis_contents += room.window

/obj/effect/warped_rune/rainbowspace/on_entered(datum/source, atom/movable/arrived, atom/old_loc)
	. = ..()
	if(room.lets_through(arrived, old_loc, rune_turf))
		// next tick, not now, bc we're in the middle of the step still
		addtimer(CALLBACK(room, TYPE_PROC_REF(/datum/warped_room, send_in), arrived, src), 0)
