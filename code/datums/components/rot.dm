#define REAGENT_BLOCKER (1<<0)
#define TEMPERATURE_BLOCKER (1<<1)
#define HUSK_BLOCKER (1<<2)

///Makes a thing rotting, carries with it a start delay and some things that can halt the rot, along with infection logic
/datum/component/rot
	///The time we were created, allows for cheese smell
	var/start_time = 0
	///The delay in ticks between the start of rot and effects kicking in
	var/start_delay = 0
	///The time in ticks before a rot component reaches its full effectiveness
	var/scaling_delay = 0
	///How strong is the rot? used for scaling different aspects of the component. Between 0 and 1
	var/strength = 0
	///Is the component active right now?
	var/active = FALSE
	///Bitfield of sources preventing the component from rotting
	var/blockers = NONE

	var/amount = 0

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)



/datum/component/rot/Initialize(delay, scaling, severity)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(isliving(parent))
		var/mob/living/living_parent = parent
		//I think this can break in cases where someone becomes a robot post death, but I uh, I don't know how to account for that
		if(!(living_parent.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
			return COMPONENT_INCOMPATIBLE

	start_delay = delay
	scaling_delay = scaling
	strength = severity

	RegisterSignals(parent, list(COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_ATOM_ATTACK_HAND), PROC_REF(rot_react_touch))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(rot_hit_react))
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
		RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(rot_react))
	if(isliving(parent))
		var/mob/living/living_parent = parent
		RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(react_to_revive)) //mobs stop this when they come to life
		RegisterSignal(parent, COMSIG_LIVING_GET_PULLED, PROC_REF(rot_react_touch))

		RegisterSignal(parent, COMSIG_LIVING_BODY_TEMPERATURE_CHANGE, PROC_REF(check_for_temperature))
		check_for_temperature(parent, living_parent.bodytemperature, living_parent.bodytemperature)
	if(iscarbon(parent))
		var/mob/living/carbon/carbon_parent = parent
		RegisterSignals(carbon_parent.reagents, list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_DEL_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
		), PROC_REF(check_reagent))
		check_reagent(carbon_parent.reagents, null)

		RegisterSignals(parent, list(
			SIGNAL_ADDTRAIT(TRAIT_HUSK),
			SIGNAL_REMOVETRAIT(TRAIT_HUSK),
		), PROC_REF(check_husk_trait))

	start_up(NONE) //If nothing's blocking it, start
	if(new_amount)
		amount = new_amount
	START_PROCESSING(SSprocessing, src)

/datum/component/rot/process()
	var/atom/A = parent

	var/turf/open/T = get_turf(A)
	if(!istype(T) || T.return_air().return_pressure() > (WARNING_HIGH_PRESSURE - 10))
		return
	var/area/area = get_area(T)
	if(area.outdoors)
		return

	var/datum/gas_mixture/turf_air = T.return_air()
	if(!turf_air)
		return
	var/datum/gas_mixture/stank_breath = T.remove_air(1 / turf_air.return_volume() * turf_air.total_moles())
	if(!stank_breath)
		return
	stank_breath.set_volume(1)
	var/oxygen_pp = stank_breath.get_moles(GAS_O2) * R_IDEAL_GAS_EQUATION * stank_breath.return_temperature() / stank_breath.return_volume()

	if(oxygen_pp > 18)
		var/this_amount = min((oxygen_pp - 8) * stank_breath.return_volume() / stank_breath.return_temperature() / R_IDEAL_GAS_EQUATION, amount)
		stank_breath.adjust_moles(GAS_O2, -this_amount)

		var/datum/gas_mixture/stank = new
		stank.set_moles(GAS_MIASMA, this_amount)
		stank.set_temperature(BODYTEMP_NORMAL) // otherwise we have gas below 2.7K which will break our lag generator
		stank_breath.merge(stank)
	T.assume_air(stank_breath)

/datum/component/rot/UnregisterFromParent()
	. = ..()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))

///One of two procs that modifies blockers, this one handles removing a blocker and potentially restarting the rot
/datum/component/rot/proc/start_up(blocker_type)
	blockers &= ~blocker_type //Yeet the type
	if(blockers || active)  //If it's not empty
		return
	start_time = world.time
	active = TRUE

///One of two procs that modifies blockers, this one handles adding a blocker and potentially ending the rot
/datum/component/rot/proc/rest(blocker_type)
	var/old_blockers = blockers
	blockers |= blocker_type
	if(old_blockers || !active) //If it had anything before this
		return
	start_delay = max((start_time + start_delay) - world.time, 0) //Account for the time spent rotting
	active = FALSE

/datum/component/rot/proc/react_to_revive()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/rot/proc/check_reagent(datum/reagents/source, datum/reagent/modified)
	SIGNAL_HANDLER
	if(modified && !istype(modified, /datum/reagent/toxin/formaldehyde) && !istype(modified, /datum/reagent/cryostylane))
		return
	if(source.has_reagent(/datum/reagent/toxin/formaldehyde, 15) || source.has_reagent(/datum/reagent/cryostylane))
		rest(REAGENT_BLOCKER)
		return
	start_up(REAGENT_BLOCKER)

/datum/component/rot/proc/check_for_temperature(datum/source, old_temp, new_temp)
	SIGNAL_HANDLER
	if(new_temp <= T0C-10)
		rest(TEMPERATURE_BLOCKER)
		return
	start_up(TEMPERATURE_BLOCKER)

/datum/component/rot/proc/check_husk_trait()
	SIGNAL_HANDLER
	if(HAS_TRAIT(parent, TRAIT_HUSK))
		rest(HUSK_BLOCKER)
		return
	start_up(HUSK_BLOCKER)

/datum/component/rot/proc/rot_hit_react(datum/source, obj/item/hit_with, mob/living/attacker, params)
	SIGNAL_HANDLER
	rot_react_touch(source, attacker)

/datum/component/rot/proc/rot_react_touch(datum/source, mob/living/react_to)
	SIGNAL_HANDLER
	rot_react(source, react_to, pick(GLOB.arm_zones))

/// Triggered when something enters the component's parent.
/datum/component/rot/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	rot_react(source, arrived)

///The main bit of logic for the rot component, does a temperature check and has a chance to infect react_to
/datum/component/rot/proc/rot_react(source, mob/living/react_to, target_zone = null)
	SIGNAL_HANDLER
	if(!isliving(react_to))
		return

	// Don't infect if you're chilled (I'd like to link this with the signals, but I can't come up with a good way to pull it off)
	var/atom/atom_parent = parent
	var/datum/gas_mixture/our_mix = atom_parent.return_air()
	if(our_mix?.temperature <= T0C-10)
		return

	if(!active)
		return

	var/time_delta = world.time - start_time
	// Wait a bit before decaying
	if(time_delta < start_delay)
		return

	var/time_scaling = min((time_delta - start_delay) / scaling_delay, 1)

	if(!prob(strength * 1 * time_scaling))
		return

	//We're running just under the "worst disease", since we don't want these to be too strong
	var/virus_choice = pick(WILD_ACUTE_DISEASES)
	var/list/anti = list(
		ANTIGEN_BLOOD	= 2,
		ANTIGEN_COMMON	= 2,
		ANTIGEN_RARE	= 0,
		ANTIGEN_ALIEN	= 0,
	)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 1,
		EFFECT_DANGER_FLAVOR	= 2,
		EFFECT_DANGER_ANNOYING	= 2,
		EFFECT_DANGER_HINDRANCE	= 0,
		EFFECT_DANGER_HARMFUL	= 0,
		EFFECT_DANGER_DEADLY	= 0,
	)
	var/datum/disease/acute/disease = new virus_choice
	disease.makerandom(list(20,50),list(30,50),anti,bad,src)

	var/note = "Rot Infection Contact [key_name(react_to)]"
	react_to.try_contact_infect(disease, note = note)

/datum/component/rot/gibs/Initialize(new_amount)
	START_PROCESSING(SSprocessing, src)
	if(new_amount)
		amount = new_amount
	..()


/datum/component/rot/corpse
	amount = MIASMA_CORPSE_MOLES

/datum/component/rot/corpse/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

/datum/component/rot/corpse/process()
	var/mob/living/carbon/deadbody = parent
	if(deadbody.stat != DEAD)
		qdel(src)
		return

	// Wait a bit before decaying
	if(world.time - deadbody.timeofdeath < 2 MINUTES)
		return

	// Properly stored corpses shouldn't create miasma
	if(istype(deadbody.loc, /obj/structure/closet/crate/coffin)|| istype(deadbody.loc, /obj/structure/closet/body_bag) || istype(deadbody.loc, /obj/structure/bodycontainer))
		return

	// No decay if formaldehyde in corpse or when the corpse is charred
	if(C.reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 15) || HAS_TRAIT(C, TRAIT_HUSK))
		return

	// Also no decay if corpse chilled or not organic/undead
	if(C.bodytemperature <= T0C-10 || (!(deadbody.mob_biotypes & (MOB_ORGANIC | MOB_UNDEAD))))
		return

	..()

/datum/component/rot/gibs
	var/amount = MIASMA_GIBS_MOLES

#undef REAGENT_BLOCKER
#undef TEMPERATURE_BLOCKER
#undef HUSK_BLOCKER
