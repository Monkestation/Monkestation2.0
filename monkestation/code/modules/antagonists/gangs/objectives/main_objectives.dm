/datum/objective/highest_gang_threat
	name = "Highest threat level"
	explanation_text = "Have more threat level then any other gang."

/datum/objective/highest_gang_threat/check_completion()
	var/static/datum/team/gang/highest_threat_gang
	if(!highest_threat_gang)
		var/highest_threat = 0
		for(var/tag in GLOB.all_gangs_by_tag)
			var/datum/team/gang/gang_team = GLOB.all_gangs_by_tag[tag]
			if(gang_team.threat > highest_threat)
				highest_threat = gang_team.threat
				highest_threat_gang = gang_team
	return team == highest_threat_gang
