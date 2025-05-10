
/datum/bloodcult_ritual/produce_constructs
	name = "One of each"
	desc = "artificer...<br>wraith...<br>juggernaut..."

	ritual_type = "constructs"
	difficulty = "medium"
	reward_faction = 300

	keys = list("build_construct")

	var/list/types_to_build = list("Artificer", "Wraith", "Juggernaut")

/datum/bloodcult_ritual/produce_constructs/init_ritual()
	types_to_build = list("Artificer", "Wraith", "Juggernaut")

/datum/bloodcult_ritual/produce_constructs/key_found(var/extra)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	for (var/datum/mind/mind in cult.members)
		var/mob/M = mind.current
		if (istype(M, /mob/living/basic/construct))
			var/mob/living/basic/construct/C = M
			types_to_build -= C.construct_type
	if (types_to_build.len <= 0)
		return TRUE
	return FALSE
