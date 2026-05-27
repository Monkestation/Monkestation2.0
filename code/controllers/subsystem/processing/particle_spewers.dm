/// Processing subsystem used by particle spewers.
/// Low-priority background subsystem bc they're not exactly the most performant thing.
PROCESSING_SUBSYSTEM_DEF(particle_spewers)
	name = "Particle Spewer Processing"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_PARTICLE_SPEWERS
	stat_tag = "PSP"
