
/datum/bloodcult_ritual/bloodspill
	name = "Spill Blood"
	desc = "more blood...need more...<br>on the floors...on the walls..."

	only_once = TRUE
	ritual_type = "bloodspill"
	difficulty = "hard"
	reward_achiever = 0
	reward_faction = 500

	keys = list("bloodspill")

	var/percent_bloodspill = 4//percent of all the station's simulated floors, you should keep it under 5.
	var/target_bloodspill = 1000//actual amount of bloodied floors to reach
	var/max_bloodspill = 0//max amount of bloodied floors simultanously reached

/datum/bloodcult_ritual/bloodspill/init_ritual()
	var/floor_count = 0
	for(var/i = 1 to ((2 * world.view + 1)*32))
		for(var/r = 1 to ((2 * world.view + 1)*32))
			var/turf/tile = locate(i, r, SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
			if(tile && isopenturf(tile) && !isspaceturf(tile.loc) && !istype(tile.loc, /area/station/security/prison))
				floor_count++
	target_bloodspill = round(floor_count * percent_bloodspill / 100)
	target_bloodspill += rand(-20, 20)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult.bloodspill_ritual = src

/datum/bloodcult_ritual/bloodspill/update_desc()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	desc = "more blood...need more...<br>on the floors...on the walls...<br>at least [target_bloodspill - cult.bloody_floors.len] more..."

/datum/bloodcult_ritual/bloodspill/key_found(var/extra)
	if(extra > max_bloodspill)
		max_bloodspill = extra
	if(max_bloodspill >= target_bloodspill)
		return TRUE
	return FALSE

/datum/bloodcult_ritual/bloodspill/complete()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult.bloodspill_ritual = null
	..()
