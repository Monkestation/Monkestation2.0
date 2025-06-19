#define BASE_REGEN_PER_SECOND 5
#define EMPOWERED_REGEN_PER_SECOND 10
#define BASE_REGEN_DELAY 30 SECONDS
#define EMPOWERED_REGEN_DELAY 10 SECONDS

/obj/structure/destructible/clockwork_wall_lattice
	name = "clockwork stabilization lattice"
	desc = "A field of energy around a clockwork wall. If destroyed the wall would quickly implode."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_effects.dmi'
	icon_state = "wall_energy_lattice"
	alpha = 130
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 400
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF
	anchored = TRUE
	///The wall we are linked to
	var/turf/closed/wall/clockwork/linked_wall
	///The game tick we start regenerating at
	var/regenerate_at = 0
	///How much do we regenerate per second
	var/regen_per_second = BASE_REGEN_PER_SECOND
	///How long does it take us to start regenerating
	var/regen_delay = BASE_REGEN_DELAY
	break_sound = null

/obj/structure/destructible/clockwork_wall_lattice/Initialize(mapload, atom/link_to)
	. = ..()
	linked_wall = link_to
	if(linked_wall)
		if(!istype(linked_wall))
			stack_trace("clockwork wall lattice at x[src.x], y[src.y], z[src.z] linked to something that was not a clockwork wall([link_to.type])")
		return

	var/turf/our_turf = get_turf(src)
	if(istype(our_turf, /turf/closed/wall/clockwork))
		linked_wall = our_turf

/obj/structure/destructible/clockwork_wall_lattice/Destroy()
	STOP_PROCESSING(SSthe_ark, src)
	if(!QDELETED(linked_wall))
		linked_wall.devastate_wall()
	linked_wall = null
	return ..()

/obj/structure/destructible/clockwork_wall_lattice/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	damage_amount = min(damage_amount, 80) //any single hit is capped to 80 damage
	if(!regenerate_at)
		START_PROCESSING(SSthe_ark, src)
		regenerate_at = world.time + regen_delay
	return ..()

/obj/structure/destructible/clockwork_wall_lattice/process(seconds_per_tick)
	if(world.time > regenerate_at)
		repair_damage(regen_per_second * seconds_per_tick)

	if(atom_integrity >= max_integrity)
		regenerate_at = 0
		return PROCESS_KILL

/obj/structure/destructible/clockwork_wall_lattice/play_attack_sound(damage_amount, damage_type, damage_flag)
	. = ..()

/obj/structure/destructible/clockwork_wall_lattice/proc/empower()

/datum/armor/clockwork_wall_lattice
	melee = 10
	bullet = 40
	laser = 30
	energy = 30
	bomb = 100
	bio = 100

/datum/armor/empowered_clockwork_wall_lattice
	melee = 30
	bullet = 60
	laser = 50
	energy = 50
	bomb = 100
	bio = 100

#undef BASE_REGEN_PER_SECOND
#undef EMPOWERED_REGEN_PER_SECOND
#undef BASE_REGEN_DELAY
#undef EMPOWERED_REGEN_DELAY
