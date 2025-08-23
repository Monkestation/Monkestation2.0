PROCESSING_SUBSYSTEM_DEF(fastprocess)
	name = "Fast Processing"
	wait = 0.2 SECONDS
	stat_tag = "FP"
	flags = parent_type::flags & ~SS_HIBERNATE // don't waste time with hibernate checking, so many things use this so it's practically guaranteed to always have something queued

PROCESSING_SUBSYSTEM_DEF(actualfastprocess)
	name = "Actual Fast Processing"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	stat_tag = "AFP"

PROCESSING_SUBSYSTEM_DEF(pathogen_processing)
	name = "Pathogen Cloud Processing"
	wait = 1 SECONDS
	stat_tag = "PC"
