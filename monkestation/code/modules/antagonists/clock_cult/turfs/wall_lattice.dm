/obj/structure/destructible/clockwork_wall_lattice
	name = "clockwork stabilization lattice"
	desc = "A field of energy around a clockwork wall. If destroyed the wall would quickly implode."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_effects.dmi'
	icon_state = "wall_energy_lattice"
	alpha = 130
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 500

/obj/structure/destructible/clockwork_wall_lattice/play_attack_sound(damage_amount, damage_type, damage_flag)
		. = ..()

