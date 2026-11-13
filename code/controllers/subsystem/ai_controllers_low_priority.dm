/// Plans background controllers that are active when unwatched but not critical
AI_CONTROLLER_SUBSYSTEM_DEF(low_priority_ai_controllers)
	name = "AI Controller Ticker (Low)"
	flags = parent_type::flags | SS_BACKGROUND | SS_NO_INIT
	planning_status = AI_STATUS_ON_LOW
	priority = FIRE_PRIORITY_NPC_LOW
