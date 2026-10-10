/// Source tag on mutations a green pylon hands out.
#define MUTATION_SOURCE_GREEN_PYLON "green_pylon"
// don't get any funny ideas and make these faster.
// 3+ flashes a second is where photosensitive seizures become a risk i think and i'd rather this game be accessible
// outer ring is 20 spots at 24 seconds a turn, so a tile gets under 1 spot a second. these numbers have plenty cozy vibes already, don't fuck with them ~Lucy
#define PYRITE_RAINBOW_PERIOD (8 SECONDS)
#define PYRITE_INNER_SPIN_TIME (16 SECONDS)
#define PYRITE_OUTER_SPIN_TIME (24 SECONDS)
/// Tiles around a pyrite pylon that count as inside it.
#define PYRITE_RAINBOW_RANGE 4
// pyrite_rainbow.dmi is a 11 fucking tiles wide, so it sticks out 5 tiles past the pylon on every side
#define PYRITE_GLOW_RANGE 5
/// Color changes in one full rainbow cycle.
#define PYRITE_RAINBOW_HUE_STEPS 12

/obj/item/slimecross/crystalline
	name = "crystalline extract"
	desc = "It's crystalline."
	effect = "crystalline"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "crystalline"
	effect_desc = "Use to place a pylon."
	///The pylon this extract places.
	var/obj/structure/slime_crystal/crystal_type

/obj/item/slimecross/crystalline/attack_self(mob/user)
	. = ..()

	// Check before the progress bar so they don't wait for nothing
	if(!can_place(user))
		return

	var/user_turf = get_turf(user)

	if(!do_after(user, 7.5 SECONDS, src))
		return

	// check after in case someone placed a crystal in the meantime (im watching you aramix)
	if(!can_place(user))
		return

	new crystal_type(user_turf)
	qdel(src)

/// Whether there's no other pylon within 6 tiles.
/obj/item/slimecross/crystalline/proc/can_place(mob/user)
	if(locate(/obj/structure/slime_crystal) in range(6, get_turf(user)))
		to_chat(user, span_notice("You can't build crystals that close to each other!"))
		return FALSE
	return TRUE

/// Base pylon, one subtype per slime color.
/obj/structure/slime_crystal
	name = "slimic pylon"
	desc = "Glassy, pure, transparent. Powerful artifact that relays the slimecore's influence onto space around it."
	max_integrity = 5
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "slime_pylon"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	///Assoc list of affected mobs, the key is the mob while the value of the map is the number of seconds spent inside of the zone.
	var/list/affected_mobs = list()
	///The slime color this pylon is made from, used for its name and tint.
	var/colour
	///Does it use process?
	var/uses_process = TRUE
	///Does it watch the living mobs in range, and run on_mob_enter/effect/leave on them?
	var/tracks_mobs = FALSE
	///How far the pylon reaches, for the mob tracker and for anything that needs line of sight.
	var/effect_range = 5
	///Watches the living mobs in range when tracks_mobs is set.
	var/datum/proximity_monitor/advanced/slime_crystal/mob_tracker

/obj/structure/slime_crystal/Initialize(mapload, obj/structure/slime_crystal/master_crystal)
	. = ..()
	name = "[colour] slimic pylon"
	if(master_crystal) // This is for rainbow pylons if ya were wondering
		invisibility = INVISIBILITY_MAXIMUM
		max_integrity = 1000
		atom_integrity = 1000
	else
		tint_to_slime_color()
	if(uses_process)
		START_PROCESSING(SSobj, src)
	if(tracks_mobs)
		mob_tracker = new(src, effect_range)

/obj/structure/slime_crystal/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/affected_mob as anything in affected_mobs)
		remove_affected_mob(affected_mob)
	QDEL_NULL(mob_tracker)
	return ..()

/// Tints the pylon to its slime's color, or gives it the slime's visual effect.
/obj/structure/slime_crystal/proc/tint_to_slime_color()
	var/datum/slime_type/slime_type = GLOB.slime_colors_to_types[colour]
	if(!slime_type)
		return
	if(slime_type::visual_effect)
		add_visual_effect(slime_type::visual_effect)
		return
	var/list/hsl = rgb2num(slime_type::rgb_code, COLORSPACE_HSL)
	var/list/paint = list(
		0, 0, 0,
		0, 0, 0,
		0, 0, 0.55,
		hsl[1] / 360, hsl[2] / 100, hsl[3] / 100 * 0.55,
	)
	add_atom_colour(color_matrix_filter(paint, FILTER_COLOR_HSL), FIXED_COLOUR_PRIORITY)

/obj/structure/slime_crystal/process(seconds_per_tick)
	for(var/mob/living/affected_mob as anything in affected_mobs)
		affected_mobs[affected_mob] += seconds_per_tick
		on_mob_effect(affected_mob, seconds_per_tick)

/// Starts tracking a mob, and calls on_mob_enter on it.
/obj/structure/slime_crystal/proc/add_affected_mob(mob/living/arrived)
	if(arrived in affected_mobs)
		return
	affected_mobs[arrived] = 0
	RegisterSignal(arrived, COMSIG_QDELETING, PROC_REF(on_affected_mob_deleted))
	on_mob_enter(arrived)

/// Stops tracking a mob, and calls on_mob_leave on it.
/obj/structure/slime_crystal/proc/remove_affected_mob(mob/living/gone)
	if(!(gone in affected_mobs))
		return
	affected_mobs -= gone
	UnregisterSignal(gone, COMSIG_QDELETING)
	on_mob_leave(gone)

/obj/structure/slime_crystal/proc/on_affected_mob_deleted(mob/living/source)
	SIGNAL_HANDLER
	remove_affected_mob(source)

/// Called when a mob starts being tracked.
/obj/structure/slime_crystal/proc/on_mob_enter(mob/living/affected_mob)
	return

/// Called every process tick on each tracked mob.
/obj/structure/slime_crystal/proc/on_mob_effect(mob/living/affected_mob, seconds_per_tick)
	return

/// Called when a mob stops being tracked, including when the pylon is destroyed.
/obj/structure/slime_crystal/proc/on_mob_leave(mob/living/affected_mob)
	return

/// Tells the pylon when living mobs walk in or out of range.
/datum/proximity_monitor/advanced/slime_crystal
	edge_is_a_field = TRUE

/datum/proximity_monitor/advanced/slime_crystal/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	. = ..()
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/slime_crystal/setup_field_turf(turf/target)
	. = ..()
	var/obj/structure/slime_crystal/crystal = host
	for(var/mob/living/standing_there in target)
		crystal.add_affected_mob(standing_there)

/datum/proximity_monitor/advanced/slime_crystal/cleanup_field_turf(turf/target)
	. = ..()
	var/obj/structure/slime_crystal/crystal = host
	for(var/mob/living/standing_there in target)
		crystal.remove_affected_mob(standing_there)

/datum/proximity_monitor/advanced/slime_crystal/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(!isliving(movable))
		return
	var/obj/structure/slime_crystal/crystal = host
	crystal.add_affected_mob(movable)

/datum/proximity_monitor/advanced/slime_crystal/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(!isliving(movable))
		return
	if(isturf(movable.loc) && get_dist(movable, host) <= current_range)
		return
	var/obj/structure/slime_crystal/crystal = host
	crystal.remove_affected_mob(movable)

/obj/item/slimecross/crystalline/grey
	crystal_type = /obj/structure/slime_crystal/grey
	colour = SLIME_TYPE_GREY
	effect_desc = "Use to place a pylon that feeds nearby slimes and speeds up their ranch progress."

/obj/structure/slime_crystal/grey
	colour = SLIME_TYPE_GREY
	tracks_mobs = TRUE

/obj/structure/slime_crystal/grey/on_mob_effect(mob/living/basic/slime/affected_mob)
	if(!istype(affected_mob) || !can_see(src, affected_mob, effect_range))
		return
	affected_mob.adjust_nutrition(2)
	affected_mob.feed_passive_ranch_progress(0.5)

/obj/item/slimecross/crystalline/orange
	crystal_type = /obj/structure/slime_crystal/orange
	colour = SLIME_TYPE_ORANGE
	effect_desc = "Use to place a pylon that warms the air and protects those nearby from the cold."

/obj/structure/slime_crystal/orange
	colour = SLIME_TYPE_ORANGE
	tracks_mobs = TRUE

/obj/structure/slime_crystal/orange/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob, TRAIT_RESISTCOLD, REF(src))

/obj/structure/slime_crystal/orange/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_RESISTCOLD, REF(src))

/obj/structure/slime_crystal/orange/process(seconds_per_tick)
	. = ..()
	for(var/turf/open/open_turf in view(effect_range, src))
		if(isspaceturf(open_turf) || open_turf.blocks_air || open_turf.planetary_atmos)
			continue
		var/datum/gas_mixture/gas = open_turf.return_air()
		if(!gas || gas.temperature >= T20C)
			continue
		gas.set_temperature(T20C)
		open_turf.air_update_turf(FALSE, FALSE)

/obj/item/slimecross/crystalline/purple
	crystal_type = /obj/structure/slime_crystal/purple
	colour = SLIME_TYPE_PURPLE
	effect_desc = "Use to place a pylon that slowly heals the wounds and damaged organs of anyone nearby."

/obj/structure/slime_crystal/purple
	colour = SLIME_TYPE_PURPLE
	tracks_mobs = TRUE
	/// Damage healed per tick, on one random damage type.
	var/heal_amount = 2

/obj/structure/slime_crystal/purple/on_mob_effect(mob/living/affected_mob)
	var/list/possible_damage_types = list()
	if(affected_mob.getBruteLoss())
		possible_damage_types += BRUTE
	if(affected_mob.getFireLoss())
		possible_damage_types += BURN
	if(affected_mob.getToxLoss())
		possible_damage_types += TOX
	if(affected_mob.getOxyLoss())
		possible_damage_types += OXY
	if(affected_mob.getCloneLoss())
		possible_damage_types += CLONE

	for(var/organ_slot in list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_LIVER, ORGAN_SLOT_LUNGS))
		var/obj/item/organ/organ = affected_mob.get_organ_slot(organ_slot)
		if(organ?.damage)
			possible_damage_types += organ

	if(!length(possible_damage_types))
		return
	var/damage_type_to_heal = pick(possible_damage_types)
	if(istype(damage_type_to_heal, /obj/item/organ))
		var/obj/item/organ/organ_to_heal = damage_type_to_heal
		organ_to_heal.apply_organ_damage(-heal_amount)
	else
		affected_mob.heal_damage_type(heal_amount, damage_type_to_heal)

	new /obj/effect/temp_visual/heal(get_turf(affected_mob), "#e180ff")

/obj/item/slimecross/crystalline/blue
	crystal_type = /obj/structure/slime_crystal/blue
	colour = SLIME_TYPE_BLUE
	effect_desc = "Use to place a pylon that keeps the air around it breathable."

/obj/structure/slime_crystal/blue
	colour = SLIME_TYPE_BLUE

/obj/structure/slime_crystal/blue/process()
	var/static/datum/gas_mixture/base_mix = SSair.parse_gas_string(OPENTURF_DEFAULT_ATMOS)
	for(var/turf/open/open_turf in view(2, src))
		if(isspaceturf(open_turf) || open_turf.blocks_air || open_turf.planetary_atmos)
			continue
		open_turf.copy_air(base_mix.copy())
		open_turf.air_update_turf(update = FALSE, remove = FALSE)

/obj/item/slimecross/crystalline/metal
	crystal_type = /obj/structure/slime_crystal/metal
	colour = SLIME_TYPE_METAL
	effect_desc = "Use to place a pylon that repairs the brute damage of robotic creatures and robotic limbs nearby."

/obj/structure/slime_crystal/metal
	colour = SLIME_TYPE_METAL
	tracks_mobs = TRUE
	/// Brute healed per tick on robotic mobs and limbs.
	var/heal_amount = 3

/obj/structure/slime_crystal/metal/on_mob_effect(mob/living/affected_mob)
	if(affected_mob.mob_biotypes & MOB_ROBOTIC)
		affected_mob.adjustBruteLoss(-heal_amount)
	else if(iscarbon(affected_mob))
		affected_mob.heal_overall_damage(brute = heal_amount, required_bodytype = BODYTYPE_ROBOTIC)

/obj/item/slimecross/crystalline/yellow
	crystal_type = /obj/structure/slime_crystal/yellow
	colour = SLIME_TYPE_YELLOW
	effect_desc = "Use to place a pylon that fully charges power cells used on it. Cells that are already full explode."

/obj/structure/slime_crystal/yellow
	colour = SLIME_TYPE_YELLOW
	light_color = LIGHT_COLOR_DIM_YELLOW //a good, sickly atmosphere
	light_power = 0.75
	light_outer_range = 3
	uses_process = FALSE

/obj/structure/slime_crystal/yellow/item_interaction(mob/living/user, obj/item/stock_parts/power_store/cell, list/modifiers)
	if(!istype(cell))
		return NONE
	if(cell.charge == cell.maxcharge) //Punishment for greed
		to_chat(user, span_danger("You try to charge \the [cell], but it is already fully energized. You are not sure if this was a good idea..."))
		cell.explode()
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You charged \the [cell] on \the [src]!"))
	cell.give(cell.maxcharge)
	cell.update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/crystalline/darkpurple
	crystal_type = /obj/structure/slime_crystal/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_desc = "Use to place a pylon that turns plasma in the air into plasma sheets, and releases burning plasma when destroyed."

/obj/structure/slime_crystal/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	///Moles of plasma pulled out of the air for each sheet.
	var/plasma_per_sheet = 15

/obj/structure/slime_crystal/darkpurple/process()
	var/turf/open/open_turf = get_turf(src)
	if(!istype(open_turf))
		return
	var/datum/gas_mixture/air = open_turf.return_air()
	if(!air || air.moles[/datum/gas/plasma] <= plasma_per_sheet)
		return
	air.moles[/datum/gas/plasma] -= plasma_per_sheet
	air.garbage_collect()
	new /obj/item/stack/sheet/mineral/plasma(open_turf)

/obj/structure/slime_crystal/darkpurple/Destroy()
	atmos_spawn_air("plasma=20;TEMP=500")
	return ..()

/obj/item/slimecross/crystalline/darkblue
	crystal_type = /obj/structure/slime_crystal/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_desc = "Use to place a pylon that dries lubed floors, deletes trash, and washes away blood and dirt in a wide area."

/obj/structure/slime_crystal/darkblue
	colour = SLIME_TYPE_DARK_BLUE

/obj/structure/slime_crystal/darkblue/process(seconds_per_tick)
	for(var/turf/open/open_turf in RANGE_TURFS(5, src))
		if(SPT_PROB(25, seconds_per_tick))
			open_turf.MakeDry(TURF_WET_LUBE)

	for(var/obj/item/trash/trashie in range(5, src))
		if(SPT_PROB(25, seconds_per_tick))
			qdel(trashie)

	for(var/obj/effect/decal/cleanable/mess in range(5, src))
		if(SPT_PROB(25, seconds_per_tick))
			mess.wash(CLEAN_WASH)

/obj/item/slimecross/crystalline/silver
	crystal_type = /obj/structure/slime_crystal/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Use to place a pylon that clears pests and weeds from nearby hydroponics trays and speeds up their growth."

/obj/structure/slime_crystal/silver
	colour = SLIME_TYPE_SILVER

/obj/structure/slime_crystal/silver/process(seconds_per_tick)
	for(var/obj/machinery/growing/tray in range(5, src))
		var/datum/component/plant_growing/plant_growing = tray.GetComponent(/datum/component/plant_growing)
		if(!length(plant_growing?.managed_seeds))
			continue
		if(plant_growing.pest_level)
			plant_growing.adjust_pests(amount = -plant_growing.pest_level)
		if(plant_growing.weed_level)
			plant_growing.adjust_weeds(amount = -plant_growing.weed_level)
		if(SPT_PROB(10, seconds_per_tick))
			plant_growing.increase_work_processes(seconds_per_tick)

/obj/item/slimecross/crystalline/bluespace
	crystal_type = /obj/structure/slime_crystal/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_desc = "Use to place a pylon that teleports whoever touches it to another bluespace pylon. Write on it with a pen to name it."

/// lazylist of all bluespace slime pylons
GLOBAL_LIST(bluespace_slime_pylons)

/obj/structure/slime_crystal/bluespace
	colour = SLIME_TYPE_BLUESPACE
	uses_process = FALSE
	///Label set with a pen, shown in the destination list next to the area.
	var/pylon_name

/obj/structure/slime_crystal/bluespace/examine(mob/user)
	. = ..()
	if(length(pylon_name))
		. += span_info("It is labeled \"[html_encode(pylon_name)]\".")

/obj/structure/slime_crystal/bluespace/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!IS_WRITING_UTENSIL(tool))
		return NONE
	var/new_name = tgui_input_text(user, "Enter a name for this pylon, or leave it empty to clear it", "Pylon name", pylon_name, max_length = MAX_NAME_LEN, encode = FALSE)
	if(isnull(new_name) || QDELETED(src) || !user.Adjacent(src))
		return ITEM_INTERACT_BLOCKING
	pylon_name = new_name
	balloon_alert(user, pylon_name ? "pylon named" : "name cleared")
	return ITEM_INTERACT_SUCCESS

/obj/structure/slime_crystal/bluespace/Initialize(mapload)
	. = ..()
	LAZYADD(GLOB.bluespace_slime_pylons, src)

/obj/structure/slime_crystal/bluespace/Destroy()
	LAZYREMOVE(GLOB.bluespace_slime_pylons, src)
	return ..()

/obj/structure/slime_crystal/bluespace/attack_hand(mob/user, list/modifiers)
	var/list/other_pylons = GLOB.bluespace_slime_pylons - src
	if(!LAZYLEN(other_pylons))
		return ..()

	var/list/destinations = list()
	for(var/obj/structure/slime_crystal/bluespace/other_pylon as anything in other_pylons)
		var/area/pylon_area = get_area(other_pylon)
		var/destination_name = length(other_pylon.pylon_name) ? "[other_pylon.pylon_name] ([pylon_area.name])" : "[pylon_area.name] bluespace slimic pylon"
		var/counter = 1
		while(destinations["[destination_name] ([counter])"])
			counter++
		destinations["[destination_name] ([counter])"] = other_pylon

	var/chosen_input = tgui_input_list(user, "What destination do you want to choose", items = destinations)
	var/obj/structure/slime_crystal/bluespace/destination = destinations[chosen_input]
	if(!destination || QDELETED(src) || QDELETED(destination) || !user.Adjacent(src))
		return

	do_teleport(user, destination)

/obj/item/slimecross/crystalline/sepia
	crystal_type = /obj/structure/slime_crystal/sepia
	colour = SLIME_TYPE_SEPIA
	effect_desc = "Use to place a pylon that lets anyone nearby breathe anywhere, ignore pressure, and never fall into crit."

/obj/structure/slime_crystal/sepia
	colour = SLIME_TYPE_SEPIA
	tracks_mobs = TRUE
	uses_process = FALSE
	/// Traits held by everyone inside.
	var/static/list/traits_to_give = list(
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
	)

/obj/structure/slime_crystal/sepia/on_mob_enter(mob/living/affected_mob)
	affected_mob.add_traits(traits_to_give, REF(src))

/obj/structure/slime_crystal/sepia/on_mob_leave(mob/living/affected_mob)
	affected_mob.remove_traits(traits_to_give, REF(src))

/obj/item/slimecross/crystalline/cerulean
	crystal_type = /obj/structure/slime_crystal/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_desc = "Use to place a pylon that grows poly-crystals around it. Harvest them to top up stacks of items."

/obj/structure/slime_crystal/cerulean
	colour = SLIME_TYPE_CERULEAN
	uses_process = FALSE
	/// Poly-crystals currently standing around this pylon.
	var/crystals = 0

/obj/structure/slime_crystal/cerulean/Initialize(mapload)
	. = ..()
	spawn_crystals()

/// Grows poly-crystals nearby until there are 3.
/obj/structure/slime_crystal/cerulean/proc/spawn_crystals()
	var/turf/center = get_turf(src)
	if(!center)
		return
	for(var/turf/candidate as anything in shuffle(RANGE_TURFS(2, center) - center))
		if(crystals >= 3)
			return
		if(candidate.is_blocked_turf() || isspaceturf(candidate))
			continue
		if(locate(/obj/structure/cerulean_slime_crystal) in range(1, candidate))
			continue
		new /obj/structure/cerulean_slime_crystal(candidate, src)
		crystals++

/// Poly-crystal grown by a cerulean pylon.
/obj/structure/cerulean_slime_crystal
	name = "cerulean slime poly-crystal"
	desc = "Translucent and irregular, it can duplicate matter on a whim"
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "cerulean_crystal"
	max_integrity = 5
	/// Current growth stage.
	var/stage = 0
	/// Stage where it's fully grown.
	var/max_stage = 5
	///Stage past which the crystal is solid and drops an item when it breaks.
	var/solid_stage = 3
	///How long each growth stage takes.
	var/growth_time = 120 SECONDS
	/// Weakref to the pylon that grew this.
	var/datum/weakref/pylon

/obj/structure/cerulean_slime_crystal/Initialize(mapload, obj/structure/slime_crystal/cerulean/master_pylon)
	. = ..()
	if(istype(master_pylon))
		pylon = WEAKREF(master_pylon)
	transform *= 1 / (max_stage - 1)
	stage_growth()

/// Grows one stage, then schedules the next.
/obj/structure/cerulean_slime_crystal/proc/stage_growth()
	if(stage == max_stage)
		return

	if(stage == solid_stage)
		density = TRUE

	stage++

	var/matrix/new_scale = new
	new_scale.Scale(1 / max_stage * stage)
	animate(src, transform = new_scale, time = growth_time)
	addtimer(CALLBACK(src, PROC_REF(stage_growth)), growth_time)

/obj/structure/cerulean_slime_crystal/deconstruct(disassembled = TRUE)
	if(stage > solid_stage)
		var/obj/item/cerulean_slime_crystal/crystal_item = new(get_turf(src))
		if(stage == max_stage)
			crystal_item.amount = rand(1, 3)
	return ..()

/obj/structure/cerulean_slime_crystal/Destroy()
	var/obj/structure/slime_crystal/cerulean/owner_pylon = pylon?.resolve()
	if(owner_pylon)
		owner_pylon.crystals--
		owner_pylon.spawn_crystals()
	return ..()

/// Tops up a stack of items when used on it.
/obj/item/cerulean_slime_crystal
	name = "cerulean slime poly-crystal"
	desc = "Translucent and irregular, it can duplicate matter on a whim"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "cerulean_item_crystal"
	/// Items added to the stack.
	var/amount = 1

/obj/item/cerulean_slime_crystal/interact_with_atom(obj/item/stack/target, mob/living/user, list/modifiers)
	if(!istype(target))
		return NONE
	if(!isliving(user) || istype(target, /obj/item/stack/telecrystal))
		return ITEM_INTERACT_FAILURE

	if(target.amount >= target.max_amount)
		return ITEM_INTERACT_BLOCKING
	target.add(min(amount, target.max_amount - target.amount))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/crystalline/pyrite
	crystal_type = /obj/structure/slime_crystal/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_desc = "Use to place a pylon that sends rainbow ripples across the floors around it and puts everyone nearby in a party mood."

/obj/structure/slime_crystal/pyrite
	colour = SLIME_TYPE_PYRITE
	tracks_mobs = TRUE
	uses_process = FALSE
	effect_range = PYRITE_RAINBOW_RANGE
	light_inner_range = PYRITE_RAINBOW_RANGE
	light_outer_range = PYRITE_GLOW_RANGE + 1
	///The rainbow glow and the spinning spots drawn over the floors around the pylon.
	var/list/obj/effect/abstract/pyrite_rainbow/disco_lights = list()

/obj/structure/slime_crystal/pyrite/Initialize(mapload)
	. = ..()
	for(var/light_type in subtypesof(/obj/effect/abstract/pyrite_rainbow))
		disco_lights += new light_type(get_turf(src))

/obj/structure/slime_crystal/pyrite/on_mob_enter(mob/living/affected_mob)
	affected_mob.add_mood_event(REF(src), /datum/mood_event/pyrite_pylon)

/obj/structure/slime_crystal/pyrite/on_mob_leave(mob/living/affected_mob)
	affected_mob.clear_mood_event(REF(src))

/datum/mood_event/pyrite_pylon
	description = "Woooh, pretty colors, partyyy!!"
	mood_change = 2

/obj/structure/slime_crystal/pyrite/Destroy()
	QDEL_LIST(disco_lights)
	return ..()

/// Base of the floor lights a pyrite pylon draws around itself.
/obj/effect/abstract/pyrite_rainbow
	icon = 'icons/obj/xenobiology/slime_rancher/pyrite_rainbow.dmi'
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	pixel_x = -PYRITE_GLOW_RANGE * ICON_SIZE_X
	pixel_y = -PYRITE_GLOW_RANGE * ICON_SIZE_Y

// otherwise it just goes into like space when a shuttle launches lol
/obj/effect/abstract/pyrite_rainbow/shuttleRotate(rotation, params)
	return

/obj/effect/abstract/pyrite_rainbow/spots
	icon_state = "spots_inner"
	///How long one full turn around the pylon takes.
	var/spin_time = PYRITE_INNER_SPIN_TIME
	/// Whether the spots turn clockwise.
	var/clockwise = TRUE

/obj/effect/abstract/pyrite_rainbow/spots/Initialize(mapload)
	. = ..()
	SpinAnimation(speed = spin_time, clockwise = clockwise, parallel = FALSE)

/obj/effect/abstract/pyrite_rainbow/spots/outer
	icon_state = "spots_outer"
	spin_time = PYRITE_OUTER_SPIN_TIME
	clockwise = FALSE

/obj/effect/abstract/pyrite_rainbow/wash
	icon_state = "wash"

/obj/effect/abstract/pyrite_rainbow/wash/Initialize(mapload)
	. = ..()
	var/step_time = PYRITE_RAINBOW_PERIOD / PYRITE_RAINBOW_HUE_STEPS
	animate(src, color = hue_turn(360 / PYRITE_RAINBOW_HUE_STEPS), time = step_time, loop = -1)
	for(var/step in 2 to PYRITE_RAINBOW_HUE_STEPS)
		animate(color = hue_turn(step * 360 / PYRITE_RAINBOW_HUE_STEPS), time = step_time)

// color_matrix_rotate_hue multiplies the sine by sqrt(3) when it should divide lmao, so it's not actually a hue turn. doing it ourselves
/obj/effect/abstract/pyrite_rainbow/wash/proc/hue_turn(angle)
	var/shared = (1 - cos(angle)) / 3
	var/kept = cos(angle) + shared
	var/forward = shared + sin(angle) / sqrt(3)
	var/backward = shared - sin(angle) / sqrt(3)
	return list(
		kept, forward, backward,
		backward, kept, forward,
		forward, backward, kept,
	)

/obj/item/slimecross/crystalline/red
	crystal_type = /obj/structure/slime_crystal/red
	colour = SLIME_TYPE_RED
	effect_desc = "Use to place a pylon that soaks up nearby blood. Use a beaker on it to take blood out, or touch it to turn stored blood into meat and organs."

/obj/structure/slime_crystal/red
	colour = SLIME_TYPE_RED
	/// Blood stored, in units.
	var/blood_amount = 0
	/// Most blood it can store, in units.
	var/max_blood_amount = 300
	///Blood spent to make one organ or slab of meat.
	var/organ_cost = 100
	///Blood handed over per beaker click.
	var/beaker_dose = 10

/obj/structure/slime_crystal/red/examine(mob/user)
	. = ..()
	. += span_info("It has [blood_amount]u of blood stored.")

/obj/structure/slime_crystal/red/process()
	if(blood_amount == max_blood_amount)
		return

	for(var/obj/effect/decal/cleanable/blood/blood_around_us in range(3, src))
		if(blood_amount == max_blood_amount)
			return
		blood_amount++
		new /obj/effect/temp_visual/cult/turf/floor(get_turf(blood_around_us))
		qdel(blood_around_us)

/obj/structure/slime_crystal/red/attack_hand(mob/user, list/modifiers)
	if(blood_amount < organ_cost)
		return ..()

	blood_amount -= organ_cost
	var/static/list/product_types = list(
		/obj/item/food/meat/slab,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
	)
	var/product_type = pick(product_types)
	new product_type(get_turf(src))

/obj/structure/slime_crystal/red/item_interaction(mob/living/user, obj/item/reagent_containers/cup/beaker/item_beaker, list/modifiers)
	if(!istype(item_beaker))
		return NONE
	if(blood_amount < beaker_dose)
		to_chat(user, span_warning("Not enough blood stored in the crystal!"))
		return ITEM_INTERACT_BLOCKING

	if(!item_beaker.is_refillable() || (item_beaker.reagents.total_volume + beaker_dose > item_beaker.reagents.maximum_volume))
		return ITEM_INTERACT_BLOCKING
	blood_amount -= beaker_dose
	item_beaker.reagents.add_reagent(/datum/reagent/blood, beaker_dose)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/crystalline/green
	crystal_type = /obj/structure/slime_crystal/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Use to place a pylon that stores one of your mutations when touched. Everyone nearby gains it, but slowly loses their other mutations."

/obj/structure/slime_crystal/green
	colour = SLIME_TYPE_GREEN
	tracks_mobs = TRUE
	///Type path of the mutation handed out to everyone inside, copied from whoever last touched the pylon.
	var/datum/mutation/stored_mutation
	///How often a mob inside loses one of its other mutations.
	var/strip_interval = 2 MINUTES

/obj/structure/slime_crystal/green/examine(mob/user)
	. = ..()
	if(stored_mutation)
		. += span_info("It currently stores [stored_mutation::name]")
	else
		. += span_info("It doesn't hold any mutations")

/obj/structure/slime_crystal/green/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!iscarbon(user) || !user.has_dna())
		return
	var/mob/living/carbon/carbon_user = user
	if(!length(carbon_user.dna.mutations))
		return
	var/datum/mutation/chosen_mutation = pick(carbon_user.dna.mutations)
	// strip the old one first or whoever's inside keeps it forever
	for(var/mob/living/affected_mob as anything in affected_mobs)
		on_mob_leave(affected_mob)
	stored_mutation = chosen_mutation.type

/obj/structure/slime_crystal/green/on_mob_effect(mob/living/affected_mob, seconds_per_tick)
	if(!iscarbon(affected_mob) || !affected_mob.has_dna() || !stored_mutation || HAS_TRAIT(affected_mob, TRAIT_BADDNA))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.dna.add_mutation(stored_mutation, MUTATION_SOURCE_GREEN_PYLON)

	var/time_inside = affected_mobs[affected_mob] SECONDS
	if(floor(time_inside / strip_interval) == floor((time_inside - seconds_per_tick SECONDS) / strip_interval))
		return

	var/list/other_mutations = list()
	for(var/datum/mutation/mutation as anything in carbon_mob.dna.mutations)
		if(!istype(mutation, stored_mutation))
			other_mutations += mutation.type

	if(length(other_mutations))
		carbon_mob.dna.remove_mutation(pick(other_mutations), GLOB.standard_mutation_sources)

/obj/structure/slime_crystal/green/on_mob_leave(mob/living/affected_mob)
	if(!stored_mutation || !iscarbon(affected_mob) || !affected_mob.has_dna())
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	carbon_mob.dna.remove_mutation(stored_mutation, MUTATION_SOURCE_GREEN_PYLON)

/obj/item/slimecross/crystalline/pink
	crystal_type = /obj/structure/slime_crystal/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Use to place a pylon that makes everyone nearby a pacifist."

/obj/structure/slime_crystal/pink
	colour = SLIME_TYPE_PINK
	tracks_mobs = TRUE
	uses_process = FALSE

/obj/structure/slime_crystal/pink/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob, TRAIT_PACIFISM, REF(src))

/obj/structure/slime_crystal/pink/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_PACIFISM, REF(src))

/obj/item/slimecross/crystalline/gold
	crystal_type = /obj/structure/slime_crystal/gold
	colour = SLIME_TYPE_GOLD
	effect_desc = "Use to place a pylon that turns whoever touches it into a random pet, until they wander away from it."

/obj/structure/slime_crystal/gold
	colour = SLIME_TYPE_GOLD
	tracks_mobs = TRUE
	uses_process = FALSE

/obj/structure/slime_crystal/gold/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(!istype(user))
		return

	var/static/list/pet_types = list(
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/dog/bullterrier,
		/mob/living/basic/pet/fox,
		/mob/living/simple_animal/pet/cat/kitten,
		/mob/living/simple_animal/pet/cat/space,
		/mob/living/basic/pet/penguin/emperor,
	)
	var/pet_type = pick(pet_types)
	var/mob/living/chosen_pet = new pet_type(get_turf(user))
	chosen_pet.apply_status_effect(/datum/status_effect/shapechange_mob, user, user)

/obj/structure/slime_crystal/gold/on_mob_leave(mob/living/affected_mob)
	affected_mob.remove_status_effect(/datum/status_effect/shapechange_mob)

/obj/item/slimecross/crystalline/oil
	crystal_type = /obj/structure/slime_crystal/oil
	colour = SLIME_TYPE_OIL
	effect_desc = "Use to place a pylon that stops anyone nearby from slipping. It slowly makes oil or welding fuel: use a beaker on it to take some, or touch it to switch the liquid."

/obj/structure/slime_crystal/oil
	colour = SLIME_TYPE_OIL
	tracks_mobs = TRUE
	/// Liquid stored, in units.
	var/oil_amount = 100
	/// Most liquid it can store, in units.
	var/max_oil_amount = 100
	///Oil regained per second.
	var/regen_rate = 0.5
	///Oil handed over per beaker click.
	var/beaker_dose = 10
	///Reagent type poured into beakers, flipped by clicking the pylon with an empty hand.
	var/datum/reagent/dispensed_reagent = /datum/reagent/fuel/oil

/obj/structure/slime_crystal/oil/examine(mob/user)
	. = ..()
	. += span_info("It has [round(oil_amount)]u of [dispensed_reagent::name] stored.")

/obj/structure/slime_crystal/oil/process(seconds_per_tick)
	oil_amount = min(oil_amount + regen_rate * seconds_per_tick, max_oil_amount)

/obj/structure/slime_crystal/oil/on_mob_enter(mob/living/affected_mob)
	ADD_TRAIT(affected_mob, TRAIT_NO_SLIP_ALL, REF(src))

/obj/structure/slime_crystal/oil/on_mob_leave(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_NO_SLIP_ALL, REF(src))

/obj/structure/slime_crystal/oil/attack_hand(mob/user, list/modifiers)
	. = ..()
	dispensed_reagent = (dispensed_reagent == /datum/reagent/fuel/oil) ? /datum/reagent/fuel : /datum/reagent/fuel/oil
	balloon_alert(user, "now dispensing [dispensed_reagent::name]")

/obj/structure/slime_crystal/oil/item_interaction(mob/living/user, obj/item/reagent_containers/cup/beaker/item_beaker, list/modifiers)
	if(!istype(item_beaker))
		return NONE
	if(oil_amount < beaker_dose)
		to_chat(user, span_warning("Not enough [dispensed_reagent::name] stored in the crystal!"))
		return ITEM_INTERACT_BLOCKING

	if(!item_beaker.is_refillable() || (item_beaker.reagents.total_volume + beaker_dose > item_beaker.reagents.maximum_volume))
		return ITEM_INTERACT_BLOCKING
	oil_amount -= beaker_dose
	item_beaker.reagents.add_reagent(dispensed_reagent, beaker_dose)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/crystalline/black
	crystal_type = /obj/structure/slime_crystal/black
	colour = SLIME_TYPE_BLACK
	effect_desc = "Use to place a pylon that turns you into an oozeling when touched, and back again if you touch it a second time. Oozelings nearby slowly regain blood and heal."

/obj/structure/slime_crystal/black
	colour = SLIME_TYPE_BLACK
	tracks_mobs = TRUE
	///Species type each person had before this pylon made them an oozeling, keyed by weakref.
	var/list/original_species = list()
	///Blood an oozeling inside regains per second.
	var/blood_regen = 3
	///Brute and burn healed per second on an oozeling inside.
	var/heal_amount = 0.5

/obj/structure/slime_crystal/black/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(!istype(user))
		return
	INVOKE_ASYNC(src, PROC_REF(offer_transformation), user)

/// Asks the user whether to become an oozeling, or to change back.
/obj/structure/slime_crystal/black/proc/offer_transformation(mob/living/carbon/human/user)
	var/reverting = isoozeling(user)
	var/datum/weakref/user_ref = WEAKREF(user)
	if(reverting && !original_species[user_ref])
		user.balloon_alert(user, "already an oozeling!")
		return

	var/question = reverting ? "Return to your original form?" : "Become an oozeling? Touch the pylon again to turn back."
	if(tgui_alert(user, question, "[src]", list("Yes", "No")) != "Yes")
		return
	// the prompt can sit open for ages
	if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src) || isoozeling(user) != reverting)
		return

	if(reverting)
		user.set_species(original_species[user_ref])
		original_species -= user_ref
		return

	var/datum/species/previous_species = user.dna.species.type
	user.set_species(pick(subtypesof(/datum/species/oozeling)))
	// set_species silently does nothing on species-locked mobs
	if(isoozeling(user))
		original_species[user_ref] = previous_species

/obj/structure/slime_crystal/black/on_mob_effect(mob/living/affected_mob, seconds_per_tick)
	if(!isoozeling(affected_mob))
		return
	affected_mob.blood_volume = min(affected_mob.blood_volume + blood_regen * seconds_per_tick, BLOOD_VOLUME_NORMAL)
	affected_mob.heal_overall_damage(brute = heal_amount * seconds_per_tick, burn = heal_amount * seconds_per_tick)

/obj/item/slimecross/crystalline/lightpink
	crystal_type = /obj/structure/slime_crystal/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_desc = "Use to place a pylon that lets ghosts spawn as lightgeists, which vanish if they leave its area."

/obj/structure/slime_crystal/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	tracks_mobs = TRUE
	uses_process = FALSE

/mob/living/basic/lightgeist/slime
	name = "crystalline lightgeist"

/obj/structure/slime_crystal/lightpink/attack_ghost(mob/dead/observer/ghost)
	. = ..()
	if(. || !isobserver(ghost))
		return
	var/datum/mind/ghost_mind = ghost.mind
	var/mob/living/basic/lightgeist/slime/lightgeist = new(get_turf(src))
	lightgeist.PossessByPlayer(ghost.ckey)
	lightgeist.add_traits(list(TRAIT_MUTE, TRAIT_EMOTEMUTE), REF(src))
	if(ghost_mind)
		lightgeist.AddComponent(/datum/component/temporary_body, ghost_mind, ghost_mind.current, TRUE)

/obj/structure/slime_crystal/lightpink/on_mob_leave(mob/living/affected_mob)
	if(istype(affected_mob, /mob/living/basic/lightgeist/slime))
		qdel(affected_mob)

/obj/item/slimecross/crystalline/adamantine
	crystal_type = /obj/structure/slime_crystal/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_desc = "Use to place a pylon that hardens humans nearby, giving them extra damage resistance."

/obj/structure/slime_crystal/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	tracks_mobs = TRUE
	uses_process = FALSE
	///Damage resistance added while a human is inside.
	var/resistance_bonus = 10

/obj/structure/slime_crystal/adamantine/on_mob_enter(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.physiology?.damage_resistance += resistance_bonus

/obj/structure/slime_crystal/adamantine/on_mob_leave(mob/living/affected_mob)
	if(!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/human = affected_mob
	human.physiology?.damage_resistance -= resistance_bonus

/obj/item/slimecross/crystalline/rainbow
	crystal_type = /obj/structure/slime_crystal/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Use to place a pylon that takes other crystalline extracts and gains the effect of each one inserted."

/obj/structure/slime_crystal/rainbow
	colour = SLIME_TYPE_RAINBOW
	uses_process = FALSE
	///Pylons made from the inserted cores, keyed by their pylon type.
	var/list/inserted_cores = list()

/obj/structure/slime_crystal/rainbow/examine(mob/user)
	. = ..()
	if(!length(inserted_cores))
		. += span_info("It has no cores inserted.")
		return
	var/list/core_colors = list()
	for(var/core_type in inserted_cores)
		var/obj/structure/slime_crystal/core = inserted_cores[core_type]
		core_colors += core.colour
	. += span_info("It has a [english_list(core_colors)] core[length(core_colors) > 1 ? "s" : ""] inserted.")

/// Eats the extract and adds its pylon as a core. FALSE if it has that core already.
/obj/structure/slime_crystal/rainbow/proc/insert_core(obj/item/slimecross/crystalline/slimecross)
	if(inserted_cores[slimecross.crystal_type])
		return FALSE
	var/obj/structure/slime_crystal/core = new slimecross.crystal_type(get_turf(src), src)
	inserted_cores[slimecross.crystal_type] = core
	RegisterSignal(core, COMSIG_QDELETING, PROC_REF(on_core_deleted))
	qdel(slimecross)
	return TRUE

/obj/structure/slime_crystal/rainbow/proc/on_core_deleted(obj/structure/slime_crystal/source)
	SIGNAL_HANDLER
	inserted_cores -= source.type

/obj/structure/slime_crystal/rainbow/Destroy()
	for(var/core_type in inserted_cores)
		qdel(inserted_cores[core_type])
	return ..()

/obj/structure/slime_crystal/rainbow/attack_hand(mob/user, list/modifiers)
	for(var/core_type in inserted_cores)
		var/obj/structure/slime_crystal/core = inserted_cores[core_type]
		core.attack_hand(user)
	return ..()

/obj/structure/slime_crystal/rainbow/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/slimecross/crystalline) && !istype(tool, /obj/item/slimecross/crystalline/rainbow))
		var/obj/item/slimecross/crystalline/core_extract = tool
		if(!insert_core(core_extract))
			balloon_alert(user, "already has [core_extract.colour] core inserted")
			return ITEM_INTERACT_BLOCKING
		balloon_alert(user, "inserted [core_extract.colour] core")
		return ITEM_INTERACT_SUCCESS

	. = NONE
	for(var/core_type in inserted_cores)
		var/obj/structure/slime_crystal/core = inserted_cores[core_type]
		var/result = core.item_interaction(user, tool, modifiers)
		if(result == ITEM_INTERACT_SUCCESS || !.)
			. = result

#undef MUTATION_SOURCE_GREEN_PYLON
#undef PYRITE_RAINBOW_PERIOD
#undef PYRITE_INNER_SPIN_TIME
#undef PYRITE_OUTER_SPIN_TIME
#undef PYRITE_RAINBOW_RANGE
#undef PYRITE_GLOW_RANGE
#undef PYRITE_RAINBOW_HUE_STEPS
