//datums that contain flavor for gangs, might make these have a gameplay effect at some point
/datum/gang_data
	///list of names we can pick from
	var/list/possible_gang_names = list("Syndicate Gang")
	///types of gangs which cannot be picked to be our opposing gang, currently only for lore reasons so if there are for some reason none left we just force a random gang type
	var/list/blacklisted_enemy_gangs = list(/datum/gang_data)
	///titles that can be given to gang bosses
	var/list/gang_boss_titles = list("Level 100 Boss")
	///titles that can be given to gang lieutenants
	var/list/gang_lieutenant_titles = list("Level 50 Lieutenant")
	///member title
	var/member_title = "Level 1 Crook"

//ill impliment these later, for now just the default joke things should work
/*
/datum/gang_data/cybersun
	possible_gang_names = list("Asset Acquisition Group", "External Liquidation Group")
	blacklisted_enemy_gangs = list(/datum/gang_data/gorlex, /datum/gang_data/mi_thirteen, /datum/gang_data/interdyne, /datum/gang_data/waffle)
	gang_boss_titles = list("District Manager", "Local Asset Manager")
	gang_lieutenant_titles = list("Junior Manager", "Assistant Manager")
	member_title = "Employee"

/datum/gang_data/gorlex
	possible_gang_names = list("Funding Squad", "")*/
