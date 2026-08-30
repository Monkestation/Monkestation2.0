/datum/team/cortical_borers
	name = "Cortical Borer Hive"
	member_name = "Cortical Borer"

/datum/team/cortical_borers/New(starting_members)
	. = ..()
	name = "[capitalize(pick(GLOB.adjectives))] [name]" // Make sure we have some distinct name if another hive existed

/datum/team/cortical_borers/proc/create_objectives()
	var/list/objectives_to_give = list(
		/datum/objective/borer_survive,
		/datum/objective/borer/produce_egg,
		/datum/objective/borer/willing_hosts,
		/datum/objective/borer/learn_chemicals,
	)
	for(var/datum/objective/borer/objective as anything in objectives_to_give)
		add_objective(new objective)

/datum/team/cortical_borers/add_member(datum/mind/new_member, datum/antagonist/cortical_borer/antag)
	..()
	if(istype(antag))
		antag.team = src

	for(var/datum/objective/objective as anything in objectives)
		antag.objectives |= objective
		antag.update_static_data_for_all_viewers()

	if(isnull(new_member.current))
		return

	var/mob/living/basic/cortical_borer/borer = new_member.current
	if(istype(borer))
		borer.calculate_maturation_speed()

/datum/team/cortical_borers/roundend_report()
	var/list/report = list()
	report += span_header("\The [name]:")
	report += "The [member_name]s were:"
	report += printborerlist(members)

	if(length(objectives))
		report += span_header("They had the following objectives:")
		var/win = TRUE
		var/objective_count = 0
		for(var/datum/objective/objective as anything in objectives)
			objective_count++
			if(!objective.check_completion())
				win = FALSE
			report += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
		if(win)
			report += span_greentext("The [name] was successful!")
		else
			report += span_redtext("The [name] has failed!")

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/cortical_borers/proc/printborerlist(list/players)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M as anything in players)
		parts += "<li>[printborer(M)]</li>"
	parts += "</ul>"
	return parts.Join()

/datum/team/cortical_borers/proc/printborer(datum/mind/mind)
	var/text = "<b>[mind.name]</b> " // We need to bold with <b> because span_bold() isn't supported
	var/show_key = GLOB.roundend_hidden_ckeys[ckey(mind.key)]
	if(show_key)
		text = "<b>[mind.key]</b> was [text]and "

	var/mob/living/basic/cortical_borer/borer = mind.current
	if(!borer)
		text += span_redtext("had their body destroyed.")
		return text

	if(borer.stat != DEAD)
		text += span_greentext("survived")
	else
		text += span_redtext("died")

	if(!istype(borer))
		return text

	text += " <b>["producing [borer.children_produced] borers."]</b><br>"
	var/datum/action/cooldown/borer/evolution_tree/action = locate() in borer.actions
	if(action)
		var/list/string_of_genomes = list()
		for(var/datum/borer_evolution/evolution as anything in action.completed_evolutions)
			string_of_genomes += evolution.name
		text += "They had the following evolutions: [english_list(string_of_genomes)]"
	else
		text += "The borer was incapable of evolution."
	return text
