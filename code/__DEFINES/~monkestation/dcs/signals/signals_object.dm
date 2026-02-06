///flag to block the qdel that normally happens when a projectile is blocked
#define PROJECTILE_INTERRUPT_BLOCK_QDEL (4<<0)

///sent by the ark SS whenever an anchoring crystal charges (/obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
#define COMSIG_ANCHORING_CRYSTAL_CHARGED "anchoring_crystal_charged"

///sent by the ark SS whenever an anchoring crystal is created (/obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
#define COMSIG_ANCHORING_CRYSTAL_CREATED "anchoring_crystal_created"
