/datum/nanite_program/protocol
	name = "Nanite Protocol"

	///If specified, you may only have one of these protocol types active at once.
	///Selection: (NANITE_PROTOCOL_REPLICATION | NANITE_PROTOCOL_STORAGE)
	var/protocol_class = NONE

/datum/nanite_program/protocol/on_add(datum/component/nanites/_nanites)
	. = ..()
	nanites.protocols += src

/datum/nanite_program/protocol/Destroy()
	if(nanites)
		nanites.protocols -= src
	return ..()

/**
 * Replication Protocols
 */
/datum/nanite_program/protocol/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, heavily boosting replication rate for a few minutes after the initial implantation."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost_duration = 2 MINUTES

/datum/nanite_program/protocol/kickstart/check_conditions()
	if(!(world.time < nanites.start_time + boost_duration))
		return FALSE
	return ..()

/datum/nanite_program/protocol/kickstart/active_effect()
	nanites.adjust_nanites(null, 3.5)

/datum/nanite_program/protocol/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, gradually increasing replication speed over time. \
	The factory decays if the protocol is not active, or if the nanites are disrupted by shocks or EMPs."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/factory_efficiency = 0
	var/max_efficiency = 1000 //Goes up to 2 bonus regen per tick after 16 minutes and 40 seconds

/datum/nanite_program/protocol/factory/on_process()
	if(!activated || !check_conditions())
		factory_efficiency = max(0, factory_efficiency - 5)
	return ..()

/datum/nanite_program/protocol/factory/on_emp(severity)
	. = ..()
	factory_efficiency = max(0, factory_efficiency - 300)

/datum/nanite_program/protocol/factory/on_shock(shock_damage)
	. = ..()
	factory_efficiency = max(0, factory_efficiency - 200)

/datum/nanite_program/protocol/factory/on_minor_shock()
	. = ..()
	factory_efficiency = max(0, factory_efficiency - 100)

/datum/nanite_program/protocol/factory/active_effect()
	factory_efficiency = min(factory_efficiency + 1, max_efficiency)
	nanites.adjust_nanites(null, round(0.002 * factory_efficiency, 0.1))

/datum/nanite_program/protocol/tinker
	name = "Tinker Protocol"
	desc = "Replication Protocol: the nanites learn to use metallic material in the host's bloodstream and stomach to speed up the replication process."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 2
	var/list/datum/reagent/valid_reagents = list(
		/datum/reagent/iron,
		/datum/reagent/copper,
		/datum/reagent/gold,
		/datum/reagent/silver,
		/datum/reagent/mercury,
		/datum/reagent/aluminium,
		/datum/reagent/silicon,
	)

/datum/nanite_program/protocol/tinker/check_conditions()
	if(!nanites.host_mob.reagents)
		return FALSE

	var/found_reagent = FALSE

	var/datum/reagents/R = nanites.host_mob.reagents
	for(var/VR in valid_reagents)
		if(R.has_reagent(VR, 0.5))
			R.remove_reagent(VR, 0.5)
			found_reagent = TRUE
			break
	if(!found_reagent)
		return FALSE
	return ..()

/datum/nanite_program/protocol/tinker/active_effect()
	nanites.adjust_nanites(null, boost)

/datum/nanite_program/protocol/offline
	name = "Offline Production Protocol"
	desc = "Replication Protocol: while the host is asleep or otherwise unconcious, the nanites exploit the reduced interference to replicate more quickly."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 3

/datum/nanite_program/protocol/offline/check_conditions()
	if(nanites.host_mob.stat == CONSCIOUS)
		return FALSE
	return ..()

/datum/nanite_program/protocol/offline/active_effect()
	nanites.adjust_nanites(null, boost)

/**
 * Storage Protocols
 */
/datum/nanite_program/protocol/hive
	name = "Hive Protocol"
	desc = "Storage Protocol: the nanites use a more efficient grid arrangment for volume storage, increasing maximum volume by 250."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_STORAGE
	///How much extra volume the protocol gives the nanite user.
	var/extra_volume = 250

/datum/nanite_program/protocol/hive/enable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites + extra_volume)

/datum/nanite_program/protocol/hive/disable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites - extra_volume)

/datum/nanite_program/protocol/zip
	name = "Zip Protocol"
	desc = "Storage Protocol: the nanites are disassembled and compacted when unused, increasing the maximum volume to 1000. However, the process slows down their replication rate slightly."
	use_rate = 0.2
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_STORAGE
	///How much extra volume the protocol gives the nanite user.
	var/extra_volume = 500

/datum/nanite_program/protocol/zip/enable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites + extra_volume)

/datum/nanite_program/protocol/zip/disable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites - extra_volume)

/datum/nanite_program/protocol/free_range
	name = "Free-range Protocol"
	desc = "Storage Protocol: the nanites discard their default storage protocols in favour of a cheaper and more organic approach. Reduces maximum volume to 250, but increases the replication rate by 0.5."
	use_rate = -0.5
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_STORAGE
	///How much extra volume the protocol gives the nanite user. Since this is negative, we take away.
	var/extra_volume = -250

/datum/nanite_program/protocol/free_range/enable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites + extra_volume)

/datum/nanite_program/protocol/free_range/disable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites - extra_volume)

/datum/nanite_program/protocol/unsafe_storage
	name = "S.L.O. Protocol"
	desc = "Storage Protocol: 'S.L.O.P.', or Storage Level Override Protocol, completely disables the safety measures normally present in nanites, \
			allowing them to reach a whopping maximum volume level of 2000, but at the risk of causing damage to the host at nanite concentrations above the standard limit of 500."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_STORAGE
	///How much extra volume the protocol gives the nanite user.
	var/extra_volume = 1500
	///The timer between warnings.
	COOLDOWN_DECLARE(next_warning)

	var/list/volume_warnings_stage_1 = list(
		"You feel a dull pain in your abdomen.",
		"You feel a tickling sensation in your abdomen.",
	)
	var/list/volume_warnings_stage_2 = list(
		"You feel a dull pain in your stomach.",
		"You feel a dull pain when breathing.",
		"Your stomach grumbles.",
		"You feel a tickling sensation in your throat.",
		"You feel a tickling sensation in your lungs.",
		"You feel a tickling sensation in your stomach.",
		"Your lungs feel stiff.",
	)
	var/list/volume_warnings_stage_3 = list(
		"You feel a dull pain in your chest.",
		"You hear a faint buzzing coming from nowhere.",
		"You hear a faint buzzing inside your head.",
		"Your head aches.",
	)
	var/list/volume_warnings_stage_4 = list(
		"You feel a dull pain in your ears.",
		"You feel a dull pain behind your eyes.",
		"You hear a loud, echoing buzz inside your ears.",
		"You feel dizzy.",
		"You feel an itch coming from behind your eyes.",
		"Your eardrums itch.",
		"You see tiny grey motes drifting in your field of view.",
	)
	var/list/volume_warnings_stage_5 = list(
		"You feel sick.",
		"You feel a dull pain from every part of your body.",
		"You feel nauseous.",
	)
	var/list/volume_warnings_stage_6 = list(
		"Your skin itches and burns.",
		"Your muscles ache.",
		"You feel tired.",
		"You feel something skittering under your skin.",
	)

/datum/nanite_program/protocol/unsafe_storage/enable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites + extra_volume)

/datum/nanite_program/protocol/unsafe_storage/disable_passive_effect()
	. = ..()
	nanites.set_max_volume(null, nanites.max_nanites - extra_volume)

/datum/nanite_program/protocol/unsafe_storage/active_effect()
	if(!iscarbon(host_mob))
		if(nanites.nanite_volume < 500 || !prob(10))
			return
		return host_mob.adjustBruteLoss(((max(nanites.nanite_volume - 450, 0) / 450) ** 2 ) * 0.5) // 0.5 -> 2 -> 4.5 -> 8 damage per successful tick

	if(nanites.nanite_volume < 500)
		return

	var/current_stage = 0
	var/list/organs_to_damage = list()

	if(nanites.nanite_volume > 500) //Liver is the main hub of nanite replication and the first to be threatened by excess volume
		if(prob(10))
			organs_to_damage += ORGAN_SLOT_LIVER
		current_stage++
	if(nanites.nanite_volume > 750) //Extra volume spills out in other central organs
		if(prob(10))
			organs_to_damage += ORGAN_SLOT_STOMACH
		if(prob(10))
			organs_to_damage += ORGAN_SLOT_LUNGS
		current_stage++
	if(nanites.nanite_volume > 1000) //Extra volume spills out in more critical organs
		if(prob(20))
			organs_to_damage += ORGAN_SLOT_HEART
		current_stage++
	if(nanites.nanite_volume > 1250) //Excess nanites start invading smaller organs for more space, including sensory organs
		if(prob(30))
			organs_to_damage += ORGAN_SLOT_EYES
		current_stage++
	if(nanites.nanite_volume > 1500) //Nanites start spilling into the bloodstream, causing toxicity
		if(prob(15))
			host_mob.adjustToxLoss(0.5, TRUE, forced = TRUE) //Not healthy for slimepeople either
		current_stage++
	if(nanites.nanite_volume > 1750) //Nanites have almost reached their physical limit, and the pressure itself starts causing tissue damage
		if(prob(15))
			host_mob.adjustBruteLoss(0.75, TRUE)
		current_stage++

	if(length(organs_to_damage))
		var/mob/living/carbon/carbon_host = host_mob
		for(var/organ_slot in organs_to_damage)
			var/obj/item/organ/damaged_organ = carbon_host.get_organ_slot(organ_slot)
			if(damaged_organ)
				damaged_organ.apply_organ_damage(0.75)

	volume_warning(current_stage)

#define MINIMUM_WARNING_COOLDOWN (12 SECONDS)
#define MAXIMUM_WARNING_COOLDOWN (35 SECONDS)

/datum/nanite_program/protocol/unsafe_storage/proc/volume_warning(tier)
	if(!COOLDOWN_FINISHED(src, next_warning))
		return

	var/main_warning
	var/extra_warning

	switch(tier)
		if(1)
			main_warning = pick(volume_warnings_stage_1)
			extra_warning = null
		if(2)
			main_warning = pick(volume_warnings_stage_2)
			extra_warning = pick(volume_warnings_stage_1)
		if(3)
			main_warning = pick(volume_warnings_stage_3)
			extra_warning = pick(volume_warnings_stage_1 + volume_warnings_stage_2)
		if(4)
			main_warning = pick(volume_warnings_stage_4)
			extra_warning = pick(volume_warnings_stage_1 + volume_warnings_stage_2 + volume_warnings_stage_3)
		if(5)
			main_warning = pick(volume_warnings_stage_5)
			extra_warning = pick(volume_warnings_stage_1 + volume_warnings_stage_2 + volume_warnings_stage_3 + volume_warnings_stage_4)
		if(6)
			main_warning = pick(volume_warnings_stage_6)
			extra_warning = pick(volume_warnings_stage_1 + volume_warnings_stage_2 + volume_warnings_stage_3 + volume_warnings_stage_4 + volume_warnings_stage_5)

	if(prob(35))
		to_chat(host_mob, span_warning("[main_warning]"))
		COOLDOWN_START(src, next_warning, rand(MINIMUM_WARNING_COOLDOWN, MAXIMUM_WARNING_COOLDOWN))
		return
	if(extra_warning)
		to_chat(host_mob, span_warning("[extra_warning]"))
		COOLDOWN_START(src, next_warning, rand(MINIMUM_WARNING_COOLDOWN, MAXIMUM_WARNING_COOLDOWN))

#undef MINIMUM_WARNING_COOLDOWN
#undef MAXIMUM_WARNING_COOLDOWN
