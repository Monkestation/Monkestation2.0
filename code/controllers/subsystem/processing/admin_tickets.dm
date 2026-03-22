/// The subsystem used to tick admin ticket typing.
PROCESSING_SUBSYSTEM_DEF(admintickets)
	name = "Admin Tickets"
	priority = FIRE_PRIORITY_PROCESS
	flags = SS_NO_INIT | SS_BACKGROUND | SS_HIBERNATE
	runlevels = ALL
