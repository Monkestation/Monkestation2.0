GLOBAL_LIST_INIT(inspectable_diseases, list())
GLOBAL_LIST_INIT(infected_contact_mobs, list())
GLOBAL_LIST_INIT(virusDB, list())

/datum/disease
	//Flags
	var/visibility_flags = 0
	var/disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	var/spread_flags = 0

	//Fluff
	var/form = "Virus"
	var/name = "No disease"
	var/desc = ""
	var/agent = "some microbes"
	var/spread_text = ""
	var/cure_text = ""

	//Stages
	var/stage = 1
	var/max_stages = 4
	/// The probability of this infection advancing a stage every second the cure is not present.
	var/stage_prob = 2

	//Other
	var/list/viable_mobtypes = list() //typepaths of viable mobs
	var/mob/living/affected_mob = null
	var/list/cures = list() //list of cures if the disease has the CURABLE flag, these are reagent ids
	/// The probability of spreading through the air every second
	var/infectivity = 41
	/// The probability of this infection being cured every second the cure is present
	var/cure_chance = 4
	var/carrier = FALSE //If our host is only a carrier
	var/bypasses_immunity = FALSE //Does it skip species virus immunity check? Some things may diseases and not viruses
	var/spreading_modifier = 1
	var/severity = DISEASE_SEVERITY_NONTHREAT
	/// If the disease requires an organ for the effects to function, robotic organs are immune to disease unless inorganic biology symptom is present
	var/required_organ
	var/needs_all_cures = TRUE
	var/list/strain_data = list() //dna_spread special bullshit
	var/infectable_biotypes = MOB_ORGANIC //if the disease can spread on organics, synthetics, or undead
	var/process_dead = FALSE //if this ticks while the host is dead
	var/copy_type = null //if this is null, copies will use the type of the instance being copied
	var/list/symptoms = list() // The symptoms of the disease.

	//the disease's antigens, that the body's immune_system will read to produce corresponding antibodies. Without antigens, a disease cannot be cured.
	var/list/antigen = list()
	//alters a pathogen's propensity to mutate. Set to FALSE to forbid a pathogen from ever mutating.
	var/mutation_modifier = TRUE
	//the antibody concentration at which the disease will fully exit the body
	var/strength = 100
	//the percentage of the strength at which effects will start getting disabled by antibodies.
	var/robustness = 100
	//chance to cure the disease at every proc when the body is getting cooked alive.
	var/max_bodytemperature = T0C+100
	//very low temperatures will stop the disease from activating/progressing
	var/min_bodytemperature = 120
	///split category used for predefined diseases atm
	var/category = DISEASE_NORMAL

	//logging
	var/log = ""
	var/origin = "Unknown"
	var/logged_virusfood = FALSE
	var/fever_warning = FALSE

	//cosmetic
	var/color
	var/pattern = 1
	var/pattern_color

	///pathogenic warfare - If you have a second disease of a form name in the list they will start fighting.
	var/list/can_kill = list("Bacteria")

	//When an opportunity for the disease to spread_flags to a mob arrives, runs this percentage through prob()
	//Ignored if infected materials are ingested (injected with infected blood, eating infected meat)
	var/infectionchance = 20
	var/infectionchance_base = 20

	//ticks increases by [speed] every time the disease activates. Drinking Virus Food also accelerates the process by 10.
	var/ticks = 0
	var/speed = 1

	var/stageprob = 25

	//when spreading to another mob, that new carrier has the disease's stage reduced by stage_variance
	var/stage_variance = -1

	var/uniqueID = 0// 0000 to 9999, set when the pathogen gets initially created
	var/subID = 0// 000 to 9999, set if the pathogen underwent effect or antigen mutation
	var/childID = 0// 01 to 99, incremented as the pathogen gets analyzed after a mutation
	//bitflag showing which transmission types are allowed for this disease
	var/allowed_transmission = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_AIRBORNE

/datum/disease/proc/roll_antigen(list/factors = list())
	if (factors.len <= 0)
		antigen = list(pick(GLOB.all_antigens))
		antigen |= pick(GLOB.all_antigens)
	else
		var/selected_first_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen = list(pick(antigen_family(selected_first_antigen)))

		var/selected_second_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen |= pick(antigen_family(selected_second_antigen))

/datum/disease/proc/get_effect(index)
	if(!index)
		return pick(symptoms)
	return symptoms[clamp(index,0,symptoms.len)]

/datum/disease/proc/GetImmuneData(mob/living/mob)
	var/lowest_stage = stage
	var/highest_concentration = 0

	if (mob.immune_system)
		var/immune_system = mob.immune_system.GetImmunity()
		var/list/antibodies = immune_system[2]
		var/subdivision = (strength - ((robustness * strength) / 100)) / max_stages
		//for each antigen, we measure the corresponding antibody concentration in the carrier's immune system
		//the less robust the pathogen, the more likely that further stages' effects won't activate at a given concentration
		for (var/A in antigen)
			var/concentration = antibodies[A]
			highest_concentration = max(highest_concentration,concentration)
			var/i = lowest_stage
			while (i > 0)
				if (concentration > (strength - i * subdivision))
					lowest_stage = i-1
				i--

	return list(lowest_stage,highest_concentration)

/datum/disease/acute/cure(add_resistance = TRUE, mob/living/carbon/target, safe = FALSE)
	target = target || affected_mob || usr
	if(!istype(affected_mob) || QDELING(affected_mob))
		return
	for(var/datum/symptom/symptom in symptoms)
		symptom.disable_effect(target, src, safe)
	target.diseases -= src
	target.med_hud_set_status()
	logger.Log(LOG_CATEGORY_VIRUS, "[affected_mob.name] was cured of virus [real_name()] at [loc_name(affected_mob.loc)]", list("disease_data" = admin_details(), "location" = loc_name(affected_mob.loc)))
	//--Plague Stuff--
	/*
	var/datum/faction/plague_mice/plague = find_active_faction_by_type(/datum/faction/plague_mice)
	if (plague && ("[uniqueID]-[subID]" == plague.diseaseID))
		plague.update_hud_icons()
	*/
	//----------------
	var/list/pathogen_info = filter_disease_by_spread(affected_mob.diseases, required = DISEASE_SPREAD_CONTACT_SKIN)
	if(!length(pathogen_info))
		GLOB.infected_contact_mobs -= affected_mob
		if(affected_mob.pathogen)
			for(var/mob/living/goggle_wearer in GLOB.virus_viewers)
				goggle_wearer.client?.images -= affected_mob.pathogen

	// Add resistance by boosting whichever antigen is needed
	if(add_resistance && target.immune_system)
		var/boosted_antigen
		var/boosted_antigen_level
		for(var/antigen in src.antigen)
			var/level = target.immune_system.antibodies[antigen]
			if(level >= strength)
				return
			else if(!boosted_antigen || (boosted_antigen_level > level))
				boosted_antigen = antigen
				boosted_antigen_level = level
		if(boosted_antigen)
			target.immune_system.antibodies[boosted_antigen] = max(strength + 10, boosted_antigen_level)

/datum/disease/proc/activate(mob/living/mob, starved = FALSE, seconds_per_tick)
	if(!affected_mob)
		return_parent()
	if((mob.stat == DEAD) && !process_dead)
		return

	//Searing body temperatures cure diseases, on top of killing you.
	if(mob.bodytemperature > max_bodytemperature)
		cure(add_resistance = FALSE, target = mob)
		return

	if(disease_flags & DISEASE_DORMANT)
		return

	if(!(infectable_biotypes & mob.mob_biotypes))
		return

	if(mob.immune_system)
		if(prob(10 - (robustness * 0.1))) //100 robustness don't auto cure
			mob.immune_system.NaturalImmune()

	if(!mob.immune_system.CanInfect(src))
		cure(target = mob)
		return

	//Freezing body temperatures halt diseases completely
	if(mob.bodytemperature < min_bodytemperature)
		return

	//Virus food speeds up disease progress
	if(!ismouse(mob))
		if(mob.reagents?.has_reagent(/datum/reagent/consumable/virus_food))
			mob.reagents.remove_reagent(/datum/reagent/consumable/virus_food, 0.1)
			if(!logged_virusfood)
				log += "<br />[ROUND_TIME()] Virus Fed ([mob.reagents.get_reagent_amount(/datum/reagent/consumable/virus_food)]U)"
				logged_virusfood=1
			ticks += 10
		else
			logged_virusfood=0
	if(prob(strength * 0.1))
		incubate(mob, 1)

	//Moving to the next stage
	if(ticks > stage*100 && prob(stageprob))
		incubate(mob, 1)
		if(stage < max_stages)
			log += "<br />[ROUND_TIME()] NEXT STAGE ([stage])"
			stage++
		ticks = 0

	//Pathogen killing each others
	for (var/datum/disease/acute/enemy_pathogen as anything in mob.diseases)
		if(enemy_pathogen == src)
			continue

		if ((enemy_pathogen.form in can_kill) && strength > enemy_pathogen.strength)
			log += "<br />[ROUND_TIME()] destroyed enemy [enemy_pathogen.form] #[enemy_pathogen.uniqueID]-[enemy_pathogen.subID] ([strength] > [enemy_pathogen.strength])"
			enemy_pathogen.cure(target = mob)

	// This makes it so that <mob> only ever gets affected by the equivalent of one virus so antags don't just stack a bunch
	if(starved)
		return

	var/list/immune_data = GetImmuneData(mob)

	if(!istype(mob, /mob/living/basic/mouse/plague) && (!carrier)) //plague mice don't trigger effects to not kill em
		for(var/datum/symptom/e in symptoms)
			if (e.can_run_effect(immune_data[1], seconds_per_tick))
				e.run_effect(mob, src)

	//fever is a reaction of the body's immune system to the infection. The higher the antibody concentration (and the disease still not cured), the higher the fever
	if (mob.bodytemperature < mob.bodytemp_heat_damage_limit - 15)//but we won't go all the way to burning up just because of a fever, probably
		var/fever = round((robustness / 100) * (immune_data[2] / 10) * (stage / max_stages))
		switch (mob.mob_size)
			if (MOB_SIZE_TINY)
				mob.bodytemperature += fever*0.2
			if (MOB_SIZE_SMALL)
				mob.bodytemperature += fever*0.5
			if (MOB_SIZE_HUMAN)
				mob.bodytemperature += fever
			if (MOB_SIZE_LARGE)
				mob.bodytemperature += fever*1.5
			if (MOB_SIZE_HUGE)
				mob.bodytemperature += fever*2

		if (fever > 0  && prob(3))
			switch (fever_warning)
				if (0)
					to_chat(mob, span_warning("You feel a fever coming on, your body warms up and your head hurts a bit."))
					fever_warning++
				if (1)
					if (mob.bodytemperature > 320)
						to_chat(mob, span_warning("Your palms are sweaty."))
						fever_warning++
				if (2)
					if (mob.bodytemperature > 335)
						to_chat(mob, span_warning("Your knees are weak."))
						fever_warning++
				if (3)
					if (mob.bodytemperature > 350)
						to_chat(mob, span_warning("Your arms are heavy."))
						fever_warning++

	ticks += speed

//horrible, awful, stolen code from disease/advance. But it WORKS
/datum/disease/acute
	var/list/properties = list()

/// Calls on GenerateProperties and AssignProperties to set a disease severity. From `disease/advance`
/datum/disease/acute/proc/Refresh_Acute(new_name = FALSE)
	GenerateProperties_Acute()
	assign_properties_Acute()

/// Generates the list for the severity with severity defined at 0, then calls on symtomps severity for final.
/datum/disease/acute/proc/GenerateProperties_Acute()
	properties = list("severity" = 0)
	for(var/datum/symptom/S in symptoms)
		if(!S.neutered)
			properties["severity"] = max(properties["severity"], S.severity) // severity is based on the highest severity non-neutered symptom

/datum/disease/acute/proc/assign_properties_Acute()
	if(length(properties))
		set_severity_Acute(properties["severity"])
	else
		CRASH("Our properties were empty or null!")

///sets a serverity level based on the properties["severity"] value of the disease
/datum/disease/acute/proc/set_severity_Acute(level_sev)
	switch(level_sev)

		if(-INFINITY to 0)
			severity = DISEASE_SEVERITY_POSITIVE
		if(1)
			severity = DISEASE_SEVERITY_NONTHREAT
		if(2)
			severity = DISEASE_SEVERITY_MINOR
		if(3)
			severity = DISEASE_SEVERITY_MEDIUM
		if(4)
			severity = DISEASE_SEVERITY_HARMFUL
		if(5)
			severity = DISEASE_SEVERITY_DANGEROUS
		if(6 to INFINITY)
			severity = DISEASE_SEVERITY_BIOHAZARD
		else
			severity = "Unknown"

/datum/disease/Destroy()
	. = ..()
	if(affected_mob)
		remove_disease()
	//SSdisease.active_diseases.Remove(src)

//add this disease if the host does not already have too many
/datum/disease/proc/try_infect(mob/living/infectee, make_copy = TRUE)
	infect(infectee, make_copy)
	return TRUE

//add the disease with no checks
/datum/disease/proc/infect(mob/living/infectee, make_copy = TRUE)
	var/datum/disease/D = make_copy ? Copy() : src
	if(!istype(D))
		return
	LAZYADD(infectee.diseases, D)
	D.affected_mob = infectee
	//SSdisease.active_diseases += D //Add it to the active diseases list, now that it's actually in a mob and being processed.

	D.after_add()
	infectee.med_hud_set_status()

	var/turf/source_turf = get_turf(infectee)
	log_virus("[key_name(infectee)] was infected by virus: [src.admin_details()] at [loc_name(source_turf)]")


///Proc to process the disease and decide on whether to advance, cure or make the sympthoms appear. Returns a boolean on whether to continue acting on the symptoms or not.
/datum/disease/proc/stage_act(seconds_per_tick, times_fired)
	var/slowdown = HAS_TRAIT(affected_mob, TRAIT_VIRUS_RESISTANCE) ? 0.5 : 1 // spaceacillin slows stage speed by 50%

	if(required_organ)
		if(!has_required_infectious_organ(affected_mob, required_organ))
			return FALSE

	var/cure_mod
	var/bad_immune = HAS_TRAIT(affected_mob, TRAIT_IMMUNODEFICIENCY) ? 2 : 1

	if(has_cure())
		cure_mod = cure_chance / bad_immune
		if(SPT_PROB(cure_mod, seconds_per_tick))
			update_stage(max(stage - 1, 1))

		if(disease_flags & CURABLE && SPT_PROB(cure_mod, seconds_per_tick))
			cure()
			return FALSE
	else if(SPT_PROB(stage_prob*slowdown*bad_immune, seconds_per_tick))
		update_stage(min(stage + 1, max_stages))

	return !carrier


/datum/disease/proc/update_stage(new_stage)
	stage = new_stage

/datum/disease/proc/has_cure()
	if(!(disease_flags & CURABLE))
		return FALSE

	. = cures.len
	for(var/C_id in cures)
		if(!affected_mob.reagents.has_reagent(C_id))
			.--
	if(!. || (needs_all_cures && . < cures.len))
		return FALSE

//Airborne spreading
/datum/disease/proc/spread(force_spread = 0)
	if(!affected_mob)
		return

	if(!(spread_flags & DISEASE_SPREAD_AIRBORNE) && !force_spread)
		return

	if(HAS_TRAIT(affected_mob, TRAIT_VIRUS_RESISTANCE) || (affected_mob.satiety > 0 && prob(affected_mob.satiety/10)) || HAS_TRAIT(affected_mob, TRAIT_NOBREATH) || affected_mob.check_airborne_sterility())
		return

	if((affected_mob.stat == DEAD) && process_dead == FALSE) // Only create clouds if we process our dead.
		return

	affected_mob.spread_airborne_diseases()

/proc/disease_air_spread_walk(turf/start, turf/end)
	if(!start || !end)
		return FALSE
	while(TRUE)
		if(end == start)
			return TRUE
		var/turf/Temp = get_step_towards(end, start)
		if(!TURFS_CAN_SHARE(end, Temp)) //Don't go through a wall
			return FALSE
		end = Temp

/datum/disease/proc/IsSame(datum/disease/D)
	if(istype(D, type))
		return TRUE
	return FALSE

/datum/disease/proc/cure(add_resistance = TRUE, mob/living/carbon/target, safe = FALSE) // monkestation edit: AAAAAAAAAAAAA
	if(affected_mob)
		if(add_resistance && (disease_flags & CAN_RESIST))
			LAZYOR(affected_mob.disease_resistances, GetDiseaseID())
	qdel(src)

/datum/disease/proc/Copy()
	//note that stage is not copied over - the copy starts over at stage 1
	var/static/list/copy_vars = list(
		"name",
		"visibility_flags",
		"disease_flags",
		"spread_flags",
		"form",
		"desc",
		"agent",
		"spread_text",
		"cure_text",
		"max_stages",
		"stage_prob",
		"viable_mobtypes",
		"cures",
		"infectivity",
		"cure_chance",
		"required_organ",
		"bypasses_immunity",
		"spreading_modifier",
		"severity",
		"needs_all_cures",
		"strain_data",
		"infectable_biotypes",
		"process_dead",
		"mutation_modifier",
		"strength",
		"robustness",
		"max_bodytemperature",
		"min_bodytemperature",
		"log",
		"origin",
		"logged_virusfood",
		"fever_warning",
		"color",
		"pattern",
		"pattern_color",
		"can_kill",
		"infectionchance",
		"infectionchance_base",
		"ticks",
		"speed",
		"subID",
		"uniqueID",
		"childID",
		"stageprob",
		"antigen",
		)

	var/datum/disease/D = copy_type ? new copy_type() : new type()
	if(disease_flags & DISEASE_COPYSTAGE)
		D.stage = stage

	for(var/V in copy_vars)
		var/val = vars[V]
		if(islist(val))
			var/list/L = val
			val = L.Copy()
		D.vars[V] = val

	var/list/new_symptoms = list()
	for(var/datum/symptom/symptom as anything in symptoms)
		var/datum/symptom/copied_symptom = symptom.Copy()
		new_symptoms += copied_symptom
		SEND_SIGNAL(copied_symptom, COMSIG_SYMPTOM_ATTACH, D)

	D.symptoms = new_symptoms

	return D

/datum/disease/proc/after_add()
	SHOULD_CALL_PARENT(TRUE)
	if(isnull(affected_mob))
		return
	if(HAS_TRAIT(affected_mob, TRAIT_IMMUNODEFICIENCY))
		if(disease_flags & DISEASE_DORMANT)
			disease_flags &= ~DISEASE_DORMANT
		for(var/datum/symptom/symptom as anything in symptoms)
			symptom.power *= 2


/datum/disease/proc/GetDiseaseID()
	return "[type]"

/datum/disease/proc/remove_disease()
	LAZYREMOVE(affected_mob.diseases, src) //remove the datum from the list
	affected_mob.med_hud_set_status()
	affected_mob = null

/**
 * Checks the given typepath against the list of viable mobtypes.
 *
 * Returns TRUE if the mob_type path is derived from of any entry in the viable_mobtypes list.
 * Returns FALSE otherwise.
 *
 * Arguments:
 * * mob_type - Type path to check against the viable_mobtypes list.
 */
/datum/disease/proc/is_viable_mobtype(mob_type)
	for(var/viable_type in viable_mobtypes)
		if(ispath(mob_type, viable_type))
			return TRUE

	// Let's only do this check if it fails. Did some genius coder pass in a non-type argument?
	if(!ispath(mob_type))
		stack_trace("Non-path argument passed to mob_type variable: [mob_type]")

	return FALSE

/// Checks if the mob has the required organ and it's not robotic or affected by inorganic biology
/datum/disease/proc/has_required_infectious_organ(mob/living/carbon/target, required_organ_slot)
	if(!iscarbon(target))
		return FALSE

	var/obj/item/organ/target_organ = target.get_organ_slot(required_organ_slot)
	if(!istype(target_organ))
		return FALSE

	// robotic organs are immune to disease unless 'inorganic biology' symptom is present
	if(IS_ROBOTIC_ORGAN(target_organ) && !(infectable_biotypes & MOB_ROBOTIC))
		return FALSE

	return TRUE

//Use this to compare severities
/proc/get_disease_severity_value(severity)
	switch(severity)
		if(DISEASE_SEVERITY_POSITIVE)
			return 1
		if(DISEASE_SEVERITY_NONTHREAT)
			return 2
		if(DISEASE_SEVERITY_MINOR)
			return 3
		if(DISEASE_SEVERITY_MEDIUM)
			return 4
		if(DISEASE_SEVERITY_HARMFUL)
			return 5
		if(DISEASE_SEVERITY_DANGEROUS)
			return 6
		if(DISEASE_SEVERITY_BIOHAZARD)
			return 7
