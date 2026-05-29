/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	///List of all ai_subtree singletons, key is the typepath while assigned value is a newly created instance of the typepath. See setup_subtrees()
	var/list/datum/ai_planning_subtree/ai_subtrees = list()
	///Assoc List of all AI statuses and all AI controllers with that status.
	var/list/ai_controllers_by_status = list(
		AI_STATUS_ON = list(),
		AI_STATUS_OFF = list(),
		AI_STATUS_IDLE = list(),
	)
	var/list/currentrun = list()
	///Assoc List of all AI controllers and the Z level they are on, which we check when someone enters/leaves a Z level to turn them on/off.
	var/list/ai_controllers_by_zlevel = list()
	/// The average tick cost of all active AI, calculated on fire.
	var/our_cost
	/// The tick cost of all currently processed AI, being summed together
	var/summing_cost

/datum/controller/subsystem/ai_controllers/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	return

/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	return
