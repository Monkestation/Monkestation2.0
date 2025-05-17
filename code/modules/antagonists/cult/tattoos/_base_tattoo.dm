
/datum/cult_tattoo
	var/name = "cult tattoo"
	var/desc = ""
	var/tier = 0//1, 2 or 3
	var/icon_state = ""
	var/mob/bearer = null
	var/blood_cost = 0

/datum/cult_tattoo/proc/getTattoo(var/mob/M)
	bearer = M

/datum/cult_tattoo/proc/Display()
	return TRUE

/mob/proc/checkTattoo(var/tattoo_name)
	if (!tattoo_name)
		return
	if (!IS_CULTIST(src))
		return
	var/datum/antagonist/cult/cult_datum = mind?.has_antag_datum(/datum/antagonist/cult)
	for (var/tattoo in cult_datum.tattoos)
		var/datum/cult_tattoo/CT = cult_datum.tattoos[tattoo]
		if (CT.name == tattoo_name)
			return CT
	return null
