/obj/structure/ore_vent
	name = "ore vent"
	desc = "An ore vent, brimming with underground ore. Scan with an advanced mining scanner to start extracting ore from it."
	icon = 'monkestation/code/modules/factory_type_beat/icons/terrain.dmi'
	icon_state = "ore_vent"
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //This thing will take a beating.
	anchored = TRUE
	density = TRUE

/obj/structure/ore_vent/random

/obj/structure/ore_vent/random/icebox //The one that shows up on the top level of icebox

/obj/structure/ore_vent/random/icebox/lower

/obj/structure/ore_vent/boss

/obj/structure/ore_vent/boss/icebox
