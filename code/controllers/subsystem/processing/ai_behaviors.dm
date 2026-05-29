/// The subsystem used to tick [/datum/ai_behavior] instances. Handling the individual actions an AI can take like punching someone in the fucking NUTS
PROCESSING_SUBSYSTEM_DEF(ai_behaviors)
	name = "AI Behavior Ticker"
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND | SS_HIBERNATE
	priority = FIRE_PRIORITY_NPC_ACTIONS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 1
	///List of all ai_behavior singletons, key is the typepath while assigned value is a newly created instance of the typepath. See SetupAIBehaviors()
	var/list/ai_behaviors
	///List of all targeting_strategy singletons, key is the typepath while assigned value is a newly created instance of the typepath. See SetupAIBehaviors()
	var/list/targeting_strategies

/datum/controller/subsystem/processing/ai_behaviors/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/ai_behaviors/Recover()
	return
