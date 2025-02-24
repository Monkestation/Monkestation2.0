#define FLY_IN_STATE 1
#define FLY_OUT_STATE 2
#define NEUTRAL_STATE 3

/**
 * Mining drones that are spawned when starting a ore vent's wave defense minigame.
 * They will latch onto the vent to defend it from lavaland mobs, and will flee if attacked by lavaland mobs.
 * If the drone survives, they will fly away to safety as the vent spawns ores.
 * If the drone dies, the wave defense will fail.
 */

/mob/living/basic/node_drone
	name = "NODE drone"
	desc = "Standard in-atmosphere drone, used by Nanotrasen to operate and excavate valuable ore vents."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining.dmi'
	icon_state = "mining_node_active"
	icon_living = "mining_node_active"
	icon_dead = "mining_node_active"

	ai_controller = null //datum/ai_controller/basic_controller/node_drone

	/// What status do we currently track for icon purposes?
	var/flying_state = NEUTRAL_STATE
	/// Weakref to the vent the drone is currently attached to.
	var/obj/structure/ore_vent/attached_vent = null

/mob/living/basic/node_drone/proc/arrive(obj/structure/ore_vent/parent_vent)
	attached_vent = parent_vent
	flying_state = FLY_IN_STATE
	update_appearance(UPDATE_ICON_STATE)
	pixel_z = 400
	animate(src, pixel_z = 0, time = 2 SECONDS, easing = QUAD_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
