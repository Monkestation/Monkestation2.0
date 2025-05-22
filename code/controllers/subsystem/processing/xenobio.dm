PROCESSING_SUBSYSTEM_DEF(xenobio)
	name = "Xenobiology Processing"
	wait = 0.5 SECONDS
	stat_tag = "XP"
	flags = SS_NO_INIT | SS_HIBERNATE | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
