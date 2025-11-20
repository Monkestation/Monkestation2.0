/datum/team/bloodling
	name = "\improper Bloodling"

	/// The "head" of the team, the bloodling which owns all thralls
	var/datum/antagonist/bloodling/master

/datum/team/bloodling/proc/setup_objectives()
	var/datum/objective/aid_ascending_bloodling/ascend_obj = new
	ascend_obj.team = src
	ascend_obj.bling_team = src
	objectives += ascend_obj

/datum/team/bloodling/proc/check_team_win()
	for(var/datum/objective/obj in objectives)
		if(!obj.check_completion())
			return FALSE
	return TRUE

/datum/team/bloodling/roundend_report()
	var/list/parts = list()
	var/victory = check_team_win()

	if(victory) // Epic failure, you summoned your god and then someone killed it.
		parts += "<span class='redtext big'>The bloodling managed to ascend, consuming all the stations biomass!</span>"
	else
		parts += "<span class='redtext big'>The staff managed to stop the bloodling!</span>"

	if(objectives.len)
		parts += "<b>The bloodling and its thralls' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
			count++

	if(!members.len)
		return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

	parts += "<span class='header'>The Bloodling was:</span>"
	parts += printplayer(master.owner)

	var/list/thralls = list()
	for(var/datum/mind/member in members)
		if(member == master.owner)
			continue
		thralls += member

	if(!thralls.len)
		return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

	parts += "<span class='header'>The thralls were:</span>"
	parts += printplayerlist(thralls)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
