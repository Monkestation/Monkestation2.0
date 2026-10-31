SUBSYSTEM_DEF(backrooms)
	name = "Backrooms Procedural Generation"
	// relies on basically everything to be initialized first
	dependencies = list(
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/lighting,
		/datum/controller/subsystem/shuttle,
	)
	flags = SS_NO_FIRE

	/// If the backrooms won't be generated this round, because of the config, low memory mode or unit tests
	var/no_need = FALSE

	/// The generator that made the backrooms
	var/datum/map_generator/dungeon_generator/backrooms_generator
	/// The theme picked for this round's backrooms, a path until it's picked
	var/datum/generator_theme/picked_theme = /datum/generator_theme

	/// Associative list of objects that spawn golden in the backrooms and how much they sell for
	var/list/golden_loot = list(
		/obj/item/statuebust = 1000,
		/obj/item/food/urinalcake = 1000,
		/obj/item/kitchen/spoon = 4000,
		/obj/item/food/burger/rat = 1200,
		/obj/item/extinguisher = 2500,
		/obj/item/toy/plush/lizard_plushie = 5000,
	)

/datum/controller/subsystem/backrooms/PreInit()
#ifdef LOWMEMORYMODE
	no_need = TRUE
#endif
#ifdef UNIT_TESTS // This whole subsystem just introduces a lot of odd confounding variables into unit test situations, so let's just not bother with doing an initialize here.
	no_need = TRUE
#endif

/datum/controller/subsystem/backrooms/Initialize()
	if(!CONFIG_GET(flag/backrooms_enabled))
		no_need = TRUE

	if(no_need)
		return SS_INIT_NO_NEED

	pick_theme()
	generate_backrooms()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BACKROOMS_INITIALIZED)
	spawn_loot()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/backrooms/stat_entry(msg)
	if(no_need)
		msg = "DISABLED"
	else if(!initialized)
		msg = "Generating..."
	else
		msg = "Theme: [picked_theme]"
	return ..()

/// Picks the look of this round's backrooms, weighted by each theme's weight
/datum/controller/subsystem/backrooms/proc/pick_theme()
	var/list/themes = typesof(/datum/generator_theme)
	for(var/datum/generator_theme/possible as anything in themes) //assign the weight
		themes[possible] = initial(possible.weight)

	picked_theme = pick_weight(themes)
	picked_theme = new picked_theme

/// Loads the backrooms z-level, generates the maintenance in it and walls it off
/datum/controller/subsystem/backrooms/proc/generate_backrooms()
	var/datum/map_template/backrooms_template = new("_maps/map_files/generic/MaintStation.dmm", "Backrooms")
	if(!backrooms_template.load_new_z(z_traits = ZTRAITS_BACKROOM_MAINTS)) // failed to load
		message_admins("Backrooms failed to load!")
		log_game("Backrooms failed to load!")
		return

	for(var/area/procedurally_generated/maintenance/the_backrooms/backrooms_area in GLOB.areas)
		backrooms_area.RunTerrainGeneration()
		backrooms_generator = backrooms_area.map_generator
		break

	if(!istype(backrooms_generator))
		return

	var/min_x = backrooms_generator.min_x
	var/max_x = backrooms_generator.max_x
	var/min_y = backrooms_generator.min_y
	var/max_y = backrooms_generator.max_y
	var/z_level = backrooms_generator.z_level

	var/border = /turf/closed/wall
	if(length(picked_theme?.weighted_possible_wall_types)) //make sure the wall matches the theme
		border = pick_weight(picked_theme.weighted_possible_wall_types)

	for(var/turf/current_turf as anything in block(min_x, min_y, z_level, max_x, max_y, z_level))
		if(current_turf.x == min_x || current_turf.x == max_x || current_turf.y == min_y || current_turf.y == max_y)
			current_turf.empty(FALSE, flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
			var/turf/wall = current_turf.place_on_top(border, flags = CHANGETURF_DEFER_CHANGE | CHANGETURF_IGNORE_AIR)
			wall.resistance_flags |= INDESTRUCTIBLE //make the wall indestructible

/// Scatters golden versions of some items around the backrooms that cargo can sell for a lot
/datum/controller/subsystem/backrooms/proc/spawn_loot()
	var/list/backrooms_level = SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)
	if(!length(backrooms_level))
		return
	for(var/i in 1 to rand(20, 50))
		var/turf/destination = find_safe_turf(zlevels = backrooms_level, dense_atoms = FALSE)
		var/item_path = pick(golden_loot)
		var/obj/item/thing = new item_path(destination) //spawn the thing and make it gold
		thing.AddComponent(/datum/component/valuable, golden_loot[item_path])

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Valuable items-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/export/backrooms
	//cost is irrelevant because we overwrite the proc
	unit_name = "golden object"
	export_types = list(/obj/item) //sell any object so long as it has the component

/datum/export/backrooms/applies_to(obj/O, apply_elastic = TRUE)
	if(!O.GetComponent(/datum/component/valuable))
		return FALSE
	return ..()

/datum/export/backrooms/get_cost(obj/O, apply_elastic = TRUE)
	var/datum/component/valuable/value = O.GetComponent(/datum/component/valuable)
	if(!value)
		return 0
	return round(value.cost * get_amount(O))

/// Makes an item golden and worth a set amount of credits when sold through cargo
/datum/component/valuable
	/// How much the item is worth
	var/cost

/datum/component/valuable/Initialize(cost)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.cost = cost

/datum/component/valuable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	var/obj/item/goldplate = parent
	goldplate.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)

/datum/component/valuable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/// Tells people looking at the item that it's valuable
/datum/component/valuable/proc/on_examine(atom/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("This looks valuable, it could probably be sold for a lot.")

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Entrance and exit portal----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/effect/portal/permanent/backrooms
	icon = 'icons/obj/computer.dmi'
	icon_state = "television"

/// Opens a permanent two way portal between its spot and a random spot of the backrooms once they're generated
/obj/effect/spawner/backrooms_portal
	name = "backrooms two way portal spawner"
	icon = 'icons/obj/computer.dmi'
	icon_state = "television"

/obj/effect/spawner/backrooms_portal/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	flags_1 |= INITIALIZED_1
	if(SSbackrooms.no_need || !CONFIG_GET(flag/backrooms_enabled)) // there won't be any backrooms to open a portal to
		return INITIALIZE_HINT_QDEL
	if(SSbackrooms.initialized) // the backrooms are already there
		make_portals()
		return INITIALIZE_HINT_QDEL
	RegisterSignal(SSdcs, COMSIG_GLOB_BACKROOMS_INITIALIZED, PROC_REF(on_backrooms_initialized))
	return INITIALIZE_HINT_NORMAL

/// Makes the portals once the backrooms are generated, then deletes the spawner
/obj/effect/spawner/backrooms_portal/proc/on_backrooms_initialized()
	SIGNAL_HANDLER
	make_portals()
	qdel(src)

/// Links the spawner's spot with a random safe spot of the backrooms
/obj/effect/spawner/backrooms_portal/proc/make_portals()
	var/list/backrooms_level = SSmapping.levels_by_trait(ZTRAIT_PROCEDURAL_MAINTS)
	if(!length(backrooms_level))
		return
	var/turf/way_out = find_safe_turf(zlevels = backrooms_level, dense_atoms = FALSE)
	create_portal_pair(get_turf(src), way_out, _lifespan = -1, newtype = /obj/effect/portal/permanent/backrooms)
