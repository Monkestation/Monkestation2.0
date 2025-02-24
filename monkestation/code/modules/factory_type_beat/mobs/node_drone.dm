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
