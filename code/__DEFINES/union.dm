#define CARGO_UNION_NAME "name"
#define CARGO_UNION_LEADER "leader"
#define CARGO_UNION_BANK "bank"

#define ANNOUNCE_START_VOTE "VOTE_STARTED"
#define ANNOUNCE_CREW "ANNOUNCE_TO_CREW"
#define ANNOUNCE_INTO_EFFECT "ANNOUNCE_INTO_EFFECT"
#define ANNOUNCE_DEADLOCK "ANNOUNCE_DEADLOCK"
#define ANNOUNCE_DEADLOCK_END "ANNOUNCE_DEADLOCK_END"
#define ANNOUNCE_DEADLOCK_COMMAND_WIN "ANNOUNCE_DEADLOCK_COMMAND_WIN"
#define ANNOUNCE_FAILURE "ANNOUNCE_FAILURE"

/// Global list of all /datum/union_demand .[path] = demand
GLOBAL_LIST_INIT(union_demands, setup_union_demands())
//This must be below the line above because union demands must be set up first.
GLOBAL_DATUM_INIT(cargo_union, /datum/union, new)

/proc/setup_union_demands()
	. = list()
	for(var/path in subtypesof(/datum/union_demand))
		var/datum/union_demand/demand = new path()
		.[path] = demand
