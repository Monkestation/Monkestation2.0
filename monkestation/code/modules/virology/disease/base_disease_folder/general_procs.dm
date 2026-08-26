/proc/filter_disease_by_spread(list/diseases, required = NONE)
	if(!length(diseases))
		return list()

	var/list/viable = list()
	for(var/datum/disease/disease as anything in diseases)
		if(!(disease.spread_flags & required))
			continue
		viable += disease
	return viable

/proc/virus_copylist(list/list)
	if(!length(list))
		return list()
	var/list/L = list()
	for(var/datum/disease/D as anything in list)
		L += D.Copy()
	return L

/datum/disease/proc/randomize_disease(
		min_strength,
		max_strength,
		min_robustness,
		max_robustness,
		list/antigen = list(),
		list/symptom_danger = list(),
		atom/source = null
		)

	//ID
	uniqueID = rand(0, 9999)
	subID = rand(0, 9999)

	//base stats
	strength = rand((min_strength ? min_strength : 1), (max_strength ? max_strength : 100))
	robustness = rand((min_robustness ? min_robustness : 1), (max_robustness ? max_robustness : 100))
	roll_antigen(antigen)

	//effects
	for(var/symptom_stage = 1; symptom_stage <= max_stages; symptom_stage++)
		var/selected_danger
		if(!symptom_danger)
			add_symptom(stage = symptom_stage)
			continue
		else
			selected_danger = GLOB.symptom_danger_levels[pick(symptom_danger)]

		if(!selected_danger)
			return

		add_symptom(danger = selected_danger, stage = symptom_stage)

	//slightly randomized infection chance
	var/variance = initial(infectionchance)/10
	infectionchance = rand(initial(infectionchance)-variance,initial(infectionchance)+variance)
	infectionchance_base = infectionchance

	//cosmetic petri dish stuff - if set beforehand, will not be randomized
	if(!color)
		var/list/randomhexes = list("8","9","a","b","c","d","e")
		color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		pattern = rand(1,6)
		pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"

	//spreading vectors - if set beforehand, will not be randomized
	if(!spread_flags)
		randomize_spread()

	//logging
	log += "<br />[ROUND_TIME()] Created and Randomized<br>"

	//admin panel
	if(origin == "Unknown" && isvirusdish(source) && isturf(source.loc))
		var/turf/source_turf = source.loc
		if(istype(source_turf.loc, /area/centcom))
			origin = "Centcom"
		else if(istype(source_turf.loc, /area/station/medical/virology))
			origin = "Pathology"

	update_global_log()

/**
 * Adds symptom to the disease
 * If symptom is not set, will randomize the symptom instead
 * Arguments:
 * * symtom - symptom we are adding to the disease, if not set will be randomized
 * * danger - if symptom randomized, will add symptom of this danger level; if not set, will randomize danger level
 * * stage - if symptom randomized, will set the symptom to this stage; 1 if not set
 * * log_symptom - if set, will log time, name and occurance chance in disease log
 */
/datum/disease/proc/add_symptom(datum/symptom/symptom, danger, stage, log_symptom = FALSE)
	if(istype(symptom, /datum/symptom))
		stack_trace("Attempted to pass non-symptom datum onto add_symptom()! [symptom]")
		return
	var/datum/symptom/added_symptom
	if(!symptom)
		var/symptom_danger = danger ? danger : pick(GLOB.symptom_danger_levels)
		added_symptom = new_effect(text2num(symptom_danger), stage ? stage : 1)
	else
		added_symptom = symptom
	symptoms += added_symptom
	SEND_SIGNAL(added_symptom, COMSIG_SYMPTOM_ATTACH, src)
	if(!log_symptom)
		return
	log += "<br />[ROUND_TIME()] Added effect [added_symptom.name] ([added_symptom.chance]% Occurence)."

/datum/disease/proc/AddToGoggleView(mob/living/infectedMob)
	if (spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
		GLOB.infected_contact_mobs |= infectedMob
		if (!infectedMob.pathogen)
			infectedMob.pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',infectedMob,"pathogen_contact")
			infectedMob.pathogen.plane = HUD_PLANE
			infectedMob.pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/living/L in GLOB.virus_viewers)
			if (L.client)
				L.client.images |= infectedMob.pathogen
		return

	if (spread_flags & DISEASE_SPREAD_BLOOD)
		GLOB.infected_contact_mobs |= infectedMob
		if (!infectedMob.pathogen)
			infectedMob.pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',infectedMob,"pathogen_blood")
			infectedMob.pathogen.plane = HUD_PLANE
			infectedMob.pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/living/L in GLOB.virus_viewers)
			if (L.client)
				L.client.images |= infectedMob.pathogen
		return

	if(disease_flags & DISEASE_DORMANT)
		GLOB.infected_contact_mobs |= infectedMob
		if (!infectedMob.pathogen)
			infectedMob.pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',infectedMob,"pathogen_blood-old2")
			infectedMob.pathogen.plane = HUD_PLANE
			infectedMob.pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/living/L in GLOB.virus_viewers)
			if (L.client)
				L.client.images |= infectedMob.pathogen
		return


///why do we do essentially a lazy fetching of parent?
///No real reason. This is already being set in spread and infect, however incase affected_mob isn't present this fixes.
///better to have as its not needed for mainline disease processing as mob is passed from the mob itself.
/datum/disease/proc/return_parent()
	if(!affected_mob)
		for(var/mob/living/mob in GLOB.infected_contact_mobs)
			for(var/datum/disease/disease as anything in mob.diseases)
				if(disease != src)
					continue
				affected_mob = mob
				return mob
		return null
	return affected_mob
