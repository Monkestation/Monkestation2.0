PROCESSING_SUBSYSTEM_DEF(pollution_emitters)
	name = "Pollution Emitters"
	priority = FIRE_PRIORITY_OBJ
	flags = SS_NO_INIT | SS_HIBERNATE
	dependencies = list(
		/datum/controller/subsystem/pollution,
	)
	wait = 10 SECONDS

/datum/component/pollution_emitter
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Type of the spawned pollutions
	var/pollutant_type
	/// Amount of the pollutants spawned per process
	var/pollutant_amount

/datum/component/pollution_emitter/Initialize(pollutant_type, pollutant_amount)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.pollutant_type = pollutant_type
	src.pollutant_amount = pollutant_amount

/datum/component/pollution_emitter/RegisterWithParent()
	START_PROCESSING(SSpollution_emitters, src)

/datum/component/pollution_emitter/UnregisterFromParent()
	STOP_PROCESSING(SSpollution_emitters, src)

/datum/component/pollution_emitter/process(seconds_per_tick)
	var/turf/my_turf = get_turf(parent)
	my_turf?.pollute_turf(pollutant_type, pollutant_amount)
