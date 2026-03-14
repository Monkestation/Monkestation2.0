///flag to block the qdel that normally happens when a projectile is blocked
#define PROJECTILE_INTERRUPT_BLOCK_QDEL (4<<0)

///sent by the ark SS whenever an anchoring crystal charges (/obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
#define COMSIG_ANCHORING_CRYSTAL_CHARGED "anchoring_crystal_charged"

///sent by the ark SS whenever an anchoring crystal is created (/obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
#define COMSIG_ANCHORING_CRYSTAL_CREATED "anchoring_crystal_created"

/// called on implants, before an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_IMPLANT_CHECK_REMOVAL "pre_implant_removed"
	/// Stops the call of removed() on the implant
	#define COMPONENT_STOP_IMPLANT_REMOVAL (1<<0)
