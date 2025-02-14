///from [/datum/move_loop/start_loop] ():
#define COMSIG_MOVELOOP_START "moveloop_start"
///from [/datum/move_loop/stop_loop] ():
#define COMSIG_MOVELOOP_STOP "moveloop_stop"
///from [/datum/move_loop/process] ():
#define COMSIG_MOVELOOP_PREPROCESS_CHECK "moveloop_preprocess_check"
	#define MOVELOOP_SKIP_STEP (1<<0)
#define COMSIG_MOVELOOP_PREPROCESS_SLIP "moveloop_preprocess_slip"
		#define MOVELOOP_PATH_BLOCKED (1<<0) //Path to target has something in the way.
		#define MOVELOOP_BUMPDOOR_PROCEED (1<<1) //Attempt to bump a door and proceed.
///from [/datum/move_loop/process] (result, visual_delay): //Result is an enum value. Enums defined in __DEFINES/movement.dm
#define COMSIG_MOVELOOP_POSTPROCESS "moveloop_postprocess"
///from [/datum/move_loop/process] (result, visual_delay, old_loc, target, datum/move_loop):
#define COMSIG_MOVELOOP_FAILED_STEP "moveloop_failed_step"
//from [/datum/move_loop/has_target/jps/recalculate_path] ():
#define COMSIG_MOVELOOP_JPS_REPATH "moveloop_jps_repath"
///from [/datum/move_loop/has_target/jps/on_finish_pathing]
#define COMSIG_MOVELOOP_JPS_FINISHED_PATHING "moveloop_jps_finished_pathing"
