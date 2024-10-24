PROCESSING_SUBSYSTEM_DEF(mind_ui)
	name = "Mind UI Processing"
	init_order = INIT_ORDER_AIR
	flags = SS_NO_FIRE
	wait = 1 SECONDS

/datum/controller/subsystem/processing/mind_ui/Initialize()
	init_mind_ui()
	return SS_INIT_SUCCESS
