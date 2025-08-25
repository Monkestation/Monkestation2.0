/// The subsystem used for portable turrets, as they're relatively more intensive compared to more other machines, so we don't want them hogging tick usage from everything else.
PROCESSING_SUBSYSTEM_DEF(turrets)
	name = "Turret Processing"
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_HIBERNATE
	wait = 2 SECONDS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
