/// Used for the movement of accelerated particles (the things used for singulo/tesla setups)
PROCESSING_SUBSYSTEM_DEF(accelerated_particles)
	name = "Accelerated Particles"
	wait = 0.1 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_HIBERNATE
	stat_tag = "ACP"
