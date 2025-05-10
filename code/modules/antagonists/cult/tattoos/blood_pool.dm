
/datum/cult_tattoo/bloodpool
	name = TATTOO_POOL
	desc = "All blood costs reduced by 20%. Tributes are split with other bearers of this mark."
	icon_state = "bloodpool"
	tier = 1

/datum/cult_tattoo/bloodpool/getTattoo(var/mob/M)
	..()
	var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		GLOB.blood_communion.Add(cult_datum)
		cult_datum.blood_pool = TRUE

/datum/cult_tattoo/bloodpool/Display()//Since that tattoo is now unlocked fairly early, better let cultists hide it easily by leaving the pool
	var/datum/antagonist/cult/cult_datum = bearer.mind?.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		return cult_datum.blood_pool
