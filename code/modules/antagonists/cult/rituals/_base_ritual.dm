
GLOBAL_LIST_INIT(bloodcult_faction_rituals, list(
	/datum/bloodcult_ritual/reach_cap,
	/datum/bloodcult_ritual/convert_station,
	/datum/bloodcult_ritual/produce_constructs,
	/datum/bloodcult_ritual/blind_cameras_multi,
	/datum/bloodcult_ritual/bloodspill,
	/datum/bloodcult_ritual/sacrifice_captain,
	//datum/bloodcult_ritual/cursed_infection,
	))

GLOBAL_LIST_INIT(bloodcult_personal_rituals, list(
	/datum/bloodcult_ritual/blind_cameras,
	/datum/bloodcult_ritual/confuse_crew,
	/datum/bloodcult_ritual/harm_crew,
	/datum/bloodcult_ritual/sacrifice_mouse,
	/datum/bloodcult_ritual/sacrifice_monkey,
	/datum/bloodcult_ritual/altar/simple,
	/datum/bloodcult_ritual/altar/elaborate,
	/datum/bloodcult_ritual/altar/excentric,
	/datum/bloodcult_ritual/altar/unholy,
	/datum/bloodcult_ritual/suicide_tome,
	/datum/bloodcult_ritual/suicide_soulblade,
	))

/datum/bloodcult_ritual
	var/name = "Ritual"
	var/desc = "Lorem Ipsum (you shouldn't be reading this!)"

	var/only_once = FALSE //If TRUE the ritual won't return to the pool of possible rituals after completion
	var/ritual_type = "error"//ritual category. the game tries to assign rituals of diverse categories
	var/difficulty = "easy"//"medium", "hard"
	var/personal = FALSE//FALSE = Faction ritual. TRUE = Personal ritual
	var/datum/antagonist/cult/owner = null//Only really matters if ritual is personal but you can also assign it on key_found on faction ritual to give them extra devotion
	var/reward_achiever = 0//Reward to the cultist who completed the achievement
	var/reward_faction = 0//Reward to every member of the faction

	var/list/keys = list()

//Needs to be TRUE for the Ritual to be assigned
/datum/bloodcult_ritual/proc/pre_conditions(var/datum/antagonist/cult/potential)
	if (potential)
		owner = potential
	return TRUE

//Perform custom ritual setup here
/datum/bloodcult_ritual/proc/init_ritual()

//Called when a cultist is about to hover the corresponding ritual UI button
/datum/bloodcult_ritual/proc/update_desc()
	return

//Perform custom ritual validation checks here
/datum/bloodcult_ritual/proc/key_found(var/extra)
	return TRUE

/datum/bloodcult_ritual/proc/complete()
	owner?.gain_devotion(reward_achiever, DEVOTION_TIER_4)//no key, duh
	if (reward_faction)
		var/datum/team/cult/cult = locate_team(/datum/team/cult)
		for(var/datum/antagonist/cult/cult_datum in cult.members)
			cult_datum.gain_devotion(reward_faction, DEVOTION_TIER_4)//yes this means a larger cult gets more total devotion.

	if (personal)
		message_admins("BLOODCULT: [key_name(owner.owner.current)] has completed the [name] ritual.")
		log_admin("BLOODCULT: [key_name(owner.owner.current)] has completed the [name] ritual.")
	else
		message_admins("BLOODCULT: The [name] ritual has been completed.")
		log_admin("BLOODCULT: The [name] ritual has been completed.")
