// TAKE_ITEMS / TAKE_CLOSETS / TAKE_HUMANS and TASKING_SEQUENTIAL / TASKING_STRICT
// are defined in code/__DEFINES/big_manipulator.dm (needed before wire datum compile).

#define MIN_SPEED_MULTIPLIER_TIER_1 0.5
#define MIN_SPEED_MULTIPLIER_TIER_2 0.4
#define MIN_SPEED_MULTIPLIER_TIER_3 0.3
#define MIN_SPEED_MULTIPLIER_TIER_4 0.1

#define MAX_SPEED_MULTIPLIER_TIER_1 2
#define MAX_SPEED_MULTIPLIER_TIER_2 3
#define MAX_SPEED_MULTIPLIER_TIER_3 5
#define MAX_SPEED_MULTIPLIER_TIER_4 6

#define MAX_TASKS_TIER_1 6
#define MAX_TASKS_TIER_2 12
#define MAX_TASKS_TIER_3 24
#define MAX_TASKS_TIER_4 32


// How should the worker interact with the point
#define WORKER_SINGLE_USE "SINGLE TIME"
#define WORKER_EMPTY_USE "EMPTY HAND"
#define WORKER_NORMAL_USE "NORMAL"

#define BASE_POWER_USAGE 0.2
#define BASE_INTERACTION_TIME 0.3 SECONDS

// How should overflow should be handled
#define POINT_OVERFLOW_ALLOWED "ALLOW"
#define POINT_OVERFLOW_FILTERS "TO FILTERS"
#define POINT_OVERFLOW_HELD "TO HELD"
#define POINT_OVERFLOW_FORBIDDEN "FORBID"

// What should the manipulator do after there's nothing else to interact with on this point anymore
#define POST_INTERACTION_DROP_AT_POINT "AT DROPOFF"
#define POST_INTERACTION_DROP_AT_MACHINE "AT MACHINE"
#define POST_INTERACTION_DROP_NEXT_FITTING "AT ANY FITTING"
#define POST_INTERACTION_WAIT "CONTINUE"


#define PICKUP_EAGER "Always Pick Up"
#define PICKUP_CAN_WAIT "Wait For Suiting"

#define TASK_TYPE_PICKUP "pickup"
#define TASK_TYPE_DROP "drop"
#define TASK_TYPE_THROW "throw"
#define TASK_TYPE_USE "use"
#define TASK_TYPE_INTERACT "interact"
#define TASK_TYPE_WAIT "wait"

