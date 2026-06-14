/**
 * So far, only used by the fishing minigame. Feel free to rename it to something like veryfastprocess
 * if you need one that fires 10 times a second
 */
PROCESSING_SUBSYSTEM_DEF(fishing)
	name = "Fishing"
	wait = 0.05 SECONDS // If you raise it to 0.1 SECONDS, you better also modify [datum/fish_movement/move_fish()]
