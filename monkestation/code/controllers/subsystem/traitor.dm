//due to the fact we tick more then once per minute this value is not directly given but we instead use some math to get the desired overall amount per minute
#define DESIRED_AREAS_PER_TC_PER_MINUTE 9
#define DESIRED_AREA_PER_THREAT_PER_MINUTE 2
/datum/controller/subsystem/traitor
	///assoc list of areas with values of amounts to multiply their rewards by
	var/list/gang_area_multipliers

/datum/controller/subsystem/traitor/proc/handle_gangs()
	if(!gang_area_multipliers)
		gang_area_multipliers = build_gang_area_values()

	var/list/given_rewards = list()
	for(var/area in GLOB.gang_controlled_areas) //might want to use this to give gangs a printout of their controlled areas
		var/datum/team/gang/area_owner = GLOB.gang_controlled_areas[area]
		var/list/rewards = given_rewards[area_owner]
		var/area_mult = gang_area_multipliers[area] || 0.167 //one sixth
		if(!rewards)
			rewards = list("tc" = 0, "threat" = 0)
			given_rewards[area_owner] = rewards
		//note these values assume we are running on time
		rewards["tc"] += area_mult / DESIRED_AREAS_PER_TC_PER_MINUTE
		rewards["threat"] += area_mult / DESIRED_AREA_PER_THREAT_PER_MINUTE

	for(var/datum/team/gang/gang_team in given_rewards)
		gang_team.unallocated_tc += round(given_rewards[gang_team]["tc"], 0.01)
		gang_team.threat += round(given_rewards[gang_team]["threat"], 0.1) MINUTES //threat is given in minutes
		gang_team.update_handlers()

///Returns an assoc list of areas with what their value multipliers are, if something is not in this list its value will be multiplied by 1
/datum/controller/subsystem/traitor/proc/build_gang_area_values()
	var/list/area_multipliers = list(
	/area/station/command = 2,
	/area/station/security = 2,
	/area/station/ai_monitored = 2,
	/area/station/maintenance = 0.5,
	)
	for(var/area in area_multipliers)
		var/mult = area_multipliers[area]
		for(var/type in typesof(area))
			area_multipliers[type] = mult * 0.167
	return area_multipliers

#undef DESIRED_AREAS_PER_TC_PER_MINUTE
#undef DESIRED_AREA_PER_THREAT_PER_MINUTE
