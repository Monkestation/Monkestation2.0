/datum/artifact_fault/tesla_zap
	name = "Energetic Discharge Fault"
	trigger_chance = 12
	visible_message = "discharges a large amount of electricity!"

	research_value = 200

	weight = ARTIFACT_RARE

/datum/artifact_fault/tesla_zap/on_trigger()
	. = ..()
	tesla_zap(our_artifact.holder, rand(4, 7), ZAP_MOB_DAMAGE)
