PROCESSING_SUBSYSTEM_DEF(cooldown_actions)
	name = "Cooldown Action Processing"
	priority = FIRE_PRIORITY_DEFAULT
	flags = SS_BACKGROUND | SS_KEEP_TIMING | SS_NO_INIT | SS_HIBERNATE
	wait = 0.2 SECONDS
	stat_tag = "CA"
