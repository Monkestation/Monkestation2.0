///sent by gang machines whenever their owner changes, this includes if owner was previously unset: (datum/team/gang/new_owner, datum/team_gang/old_owner)
#define COMSIG_GANG_MACHINE_CHANGED_OWNER "g_machine_owner_change"

///sent by object beacons when they are activated: (spawn_override)
#define COMSIG_GANG_OBJECT_BEACON_ACTIVATED "g_obj_beacon_used"

///sent by gang machines when they activate
#define COMSIG_GANG_MACHINE_ACTIVATED "g_machine_activated"
