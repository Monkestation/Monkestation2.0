/// Captive Xeno has been found dead, regardless of location.
#define CAPTIVE_XENO_DEAD "captive_xeno_dead"
/// Captive Xeno has been found alive and within the captivity area.
#define CAPTIVE_XENO_FAIL "captive_xeno_failed"
/// Captive Xeno has been found alive and outside of the captivity area.
#define CAPTIVE_XENO_PASS "captive_xeno_escaped"

/datum/team/xeno
	name = "\improper Aliens"

//Simply lists them.
/datum/team/xeno/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/xeno
	name = "\improper Xenomorph"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	antagpanel_category = ANTAG_GROUP_XENOS
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	antag_flags = FLAG_ANTAG_CAP_TEAM
	antag_count_points = 4
	var/datum/team/xeno/xeno_team

/datum/antagonist/xeno/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/xeno/create_team(datum/team/xeno/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team)
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/xeno/get_team()
	return xeno_team

/datum/antagonist/xeno/get_preview_icon()
	return finish_preview_icon(icon('icons/mob/nonhuman-player/alien.dmi', "alienh"))

/datum/antagonist/xeno/forge_objectives()
	if(locate(/datum/objective/escape_captivity) in objectives)
		return
	var/datum/objective/advance_hive/objective = new
	objective.owner = owner
	objectives += objective

// xenos in captivity do not count
//SScommunications might not be loaded if captive xenos didn't spawn naturally (2% chance) and instead were placed in the cell by a player
//Any xenomorphs in the captivity area count as captive xenomorphs for research generation, and shouldn't count towards the antag cap
/datum/antagonist/xeno/should_count_for_antag_cap()
	. = ..()
	if(!.)
		return
	if(istype(get_area(owner.current), /area/station/science/xenobiology/cell))
		return FALSE

//Related code for neutered xenomorphs
/datum/antagonist/xeno/neutered
	name = "\improper Neutered Xenomorph"
	antag_flags = FLAG_ANTAG_CAP_IGNORE

/datum/antagonist/xeno/neutered/forge_objectives()
	var/datum/objective/survive/objective = new
	objective.owner = owner
	objectives += objective

/datum/objective/survive/New()


/datum/antagonist/xeno/captive
	name = "\improper Captive Xenomorph"
	///Our associated antagonist team for captive xenomorphs
	var/datum/team/xeno/captive/captive_team

/datum/antagonist/xeno/captive/create_team(datum/team/xeno/captive/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/captive/captive_xeno in GLOB.antagonists)
			if(!captive_xeno.owner || !captive_xeno.captive_team)
				continue
			captive_team = captive_xeno.captive_team
			return
		captive_team = new
		captive_team.progenitor = owner
		antag_flags |= FLAG_ANTAG_CAP_IGNORE
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		captive_team = new_team

/datum/antagonist/xeno/captive/get_team()
	return captive_team

/datum/antagonist/xeno/captive/forge_objectives()
	var/datum/objective/escape_captivity/objective = new
	objective.owner = owner
	objectives += objective
	..()

//Xeno Objectives
/datum/objective/escape_captivity

/datum/objective/escape_captivity/New()
	explanation_text = "Escape from captivity."

/datum/objective/escape_captivity/check_completion()
	if(!istype(get_area(owner.current), SScommunications.captivity_area))
		return TRUE

/datum/objective/advance_hive

/datum/objective/advance_hive/New()
	explanation_text = "Survive and advance the Hive."

/datum/objective/advance_hive/check_completion()
	return owner.current.stat != DEAD

///Captive Xenomorphs team
/datum/team/xeno/captive
	name = "\improper Captive Aliens"
	///The first member of this team, presumably the queen.
	var/datum/mind/progenitor
	var/captive_xenos = 1

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if (HAS_TRAIT(src, TRAIT_NEUTERED)) //skip antagonist assignment if neutered (lamarr)
		mind.add_antag_datum(/datum/antagonist/xeno/neutered)
		return
	if(mind.has_antag_datum(/datum/antagonist/xeno)|| mind.has_antag_datum(/datum/antagonist/xeno/captive))
		return //already has an antag datum, no need to add it again)
	mind.add_antag_datum(/datum/antagonist/xeno)
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/xenomorph))
	mind.special_role = ROLE_ALIEN
	var/area/xenocell = locate(/area/station/science/xenobiology/cell)
	if(xenocell)
		RegisterSignal(xenocell, COMSIG_AREA_ENTERED, PROC_REF(on_xenobio_cell_occupancy_changed))
		RegisterSignal(xenocell, COMSIG_AREA_EXITED, PROC_REF(on_xenobio_cell_occupancy_changed))

/mob/living/carbon/alien/proc/on_xenobio_cell_occupancy_changed()
	var/datum/team/xeno/xeno_team = locate(/datum/team/xeno) in GLOB.antagonist_teams
	var/datum/team/xeno/captive/captive_team = locate(/datum/team/xeno/captive) in GLOB.antagonist_teams
	for(var/datum/mind/alien in xeno_team?.members)
		if(istype(get_area(alien.current), /area/station/science/xenobiology/cell)  && alien.current.stat != DEAD)
			if(!alien.has_antag_datum(/datum/antagonist/xeno/captive))
				alien.add_antag_datum(/datum/antagonist/xeno/captive)
				captive_team.captive_xenos++
				captive_team.add_member(alien)
		else //make sure if they arent in xenobiology that they dont have the captive datum
			if(alien.has_antag_datum(/datum/antagonist/xeno/captive))
				alien.remove_antag_datum(/datum/antagonist/xeno/captive)
				captive_team.captive_xenos--
		xeno_team.add_member(alien) //ensure the alien remains a part of the xeno team

/mob/living/carbon/alien/on_wabbajacked(mob/living/new_mob)
	. = ..()
	if(!mind)
		return
	if(isalien(new_mob))
		return
	mind.remove_antag_datum(/datum/antagonist/xeno)
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/unassigned))
	mind.special_role = null

#undef CAPTIVE_XENO_DEAD
#undef CAPTIVE_XENO_FAIL
#undef CAPTIVE_XENO_PASS
