/*

	Advance Disease is a system for Virologist to Engineer their own disease with symptoms that have effects and properties
	which add onto the overall disease.

	If you need help with creating new symptoms or expanding the advance disease, ask for Giacom on #coderbus.

*/

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(list/D_list)
	var/list/diseases = list()

	for(var/datum/disease/advance/A in D_list)
		diseases += A.Copy()

	if(!diseases.len)
		return null
	if(diseases.len <= 1)
		return pick(diseases) // Just return the only entry.

	var/i = 0
	// Mix our diseases until we are left with only one result.
	while(i < 20 && diseases.len > 1)

		i++

		var/datum/disease/advance/D1 = pick(diseases)
		diseases -= D1

		var/datum/disease/advance/D2 = pick(diseases)
		D2.Mix(D1)

	// Should be only 1 entry left, but if not let's only return a single entry
	var/datum/disease/advance/to_return = pick(diseases)
	to_return.Refresh(TRUE)
	return to_return

/proc/SetViruses(datum/reagent/R, list/data)
	if(data)
		var/list/preserve = list()
		if(istype(data) && data["viruses"])
			for(var/datum/disease/A in data["viruses"])
				preserve += A.Copy()
			R.data = data.Copy()
		if(preserve.len)
			R.data["viruses"] = preserve

/proc/AdminCreateVirus(client/user)

	if(!user)
		return

	var/i = VIRUS_SYMPTOM_LIMIT

	var/datum/disease/advance/D = new()
	D.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += SSdisease.list_symptoms.Copy()
	do
		if(user)
			var/symptom = tgui_input_list(user, "Choose a symptom to add ([i] remaining)", "Choose a Symptom", sort_list(symptoms, GLOBAL_PROC_REF(cmp_typepaths_asc)))
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!D.HasSymptom(S))
					D.AddSymptom(S)
					i -= 1
	while(i > 0)

	if(D.symptoms.len > 0)

		var/new_name = tgui_input_text(user, "Name your new disease", "New Name", max_length = MAX_NAME_LEN)
		if(!new_name)
			return
		D.Refresh()
		D.AssignName(new_name) //Updates the master copy
		D.name = new_name //Updates our copy

		var/list/targets = list("Random")
		targets += sort_names(GLOB.human_list)
		var/target = tgui_input_list(user, "Viable human target", "Disease Target", targets)
		if(isnull(target))
			return
		var/mob/living/carbon/human/H
		if(target == "Random")
			for(var/human in shuffle(GLOB.human_list))
				H = human
				var/found = FALSE
				if(!is_station_level(H.z))
					continue
				if(!H.HasDisease(D))
					found = H.ForceContractDisease(D)
					break
				if(!found)
					to_chat(user, "Could not find a valid target for the disease.")
		else
			H = target
			if(istype(H) && D.infectable_biotypes & H.mob_biotypes)
				H.ForceContractDisease(D)
			else
				to_chat(user, "Target could not be infected. Check mob biotype compatibility or resistances.")
				return

		message_admins("[key_name_admin(user)] has triggered a custom virus outbreak of [D.admin_details()] in [ADMIN_LOOKUPFLW(H)]")
		log_virus("[key_name(user)] has triggered a custom virus outbreak of [D.admin_details()] in [H]!")


/datum/disease/advance/proc/totalStageSpeed()
	return properties["stage_rate"]

/datum/disease/advance/proc/totalStealth()
	return properties["stealth"]

/datum/disease/advance/proc/totalResistance()
	return properties["resistance"]

/datum/disease/advance/proc/totalTransmittable()
	return properties["transmittable"]

/**
 *  Make virus visible to heath scanners
 */
/datum/disease/advance/proc/make_visible()
	visibility_flags &= ~HIDDEN_SCANNER
	for(var/datum/disease/advance/virus in SSdisease.active_diseases)
		if(!virus.id)
			stack_trace("Advanced virus ID is empty or null!")
			return

		if(virus.id == id)
			virus.visibility_flags &= ~HIDDEN_SCANNER
