/// Non-background subsystem to prevent cheesing megafauna via server lag, albeit still lower priority than carbon mobs.
MOBS_SUBSYSTEM_DEF(megafauna)
	name = "Megafauna Mobs"
	priority = FIRE_PRIORITY_MEGAFAUNA_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT | SS_HIBERNATE
