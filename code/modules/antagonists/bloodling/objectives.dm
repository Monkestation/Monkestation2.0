/datum/objective/bloodling_ascend
	name = "ascend"
	martyr_compatible = TRUE
	admin_grantable = FALSE
	explanation_text = "Use the infect ability on a human you are strangling to burst as a bloodling and begin your ascension!"
	/// List of areas to ascend in
	var/list/ascend_areas = list()

/datum/objective/bloodling_ascend/update_explanation_text()
	..()
	if(!ascend_areas.len)
		return

	var/list/area/ascension_areas = ascend_areas
	var/list/area_names = list()
	for(var/area/ascend_area as anything in ascension_areas)
		area_names += ascend_area.get_original_area_name()

	explanation_text = "Ascend as the ultimate being. You must begin your ascension in either [area_names[1]], [area_names[2]], or [area_names[3]]."

/datum/objective/bloodling_ascend/check_completion()
	var/datum/antagonist/bloodling/bloodling = IS_BLOODLING(owner.current)
	if (!bloodling.is_ascended)
		return FALSE
	return TRUE

/datum/objective/bloodling_thrall
	name = "serve"
	martyr_compatible = TRUE
	admin_grantable = FALSE
	explanation_text = "Serve your master!"
	completed = TRUE

/datum/objective/bloodling_thrall/update_explanation_text()
	..()
	var/datum/antagonist/infested_thrall/our_owner = owner
	if(our_owner.master)
		explanation_text = "Serve your master [our_owner.master]!"
	else
		explanation_text = "Serve your master!"

/datum/objective/aid_ascending_bloodling
	name = "aid ascension"
	martyr_compatible = TRUE
	admin_grantable = FALSE
	explanation_text = "Ensure that the bloodling ascends"
	var/datum/team/bloodling/bling_team

/datum/objective/aid_ascending_bloodling/check_completion()
	var/datum/antagonist/bloodling/bloodling = bling_team.master
	if (!bloodling.is_ascended)
		return FALSE
	return TRUE
