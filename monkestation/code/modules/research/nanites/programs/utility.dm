//Programs that interact with other programs or nanites directly, or have other special purposes.
/datum/nanite_program/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters, also overriding or disabling their cloud sync."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/toxic)

	///The cooldown between pulses.
	COOLDOWN_DECLARE(pulse_cooldown)

/datum/nanite_program/viral/register_extra_settings()
	extra_settings[NES_PROGRAM_OVERWRITE] = new /datum/nanite_extra_setting/type("Add To", list("Overwrite", "Add To", "Ignore"))
	extra_settings[NES_CLOUD_OVERWRITE] = new /datum/nanite_extra_setting/number(0, 0, 100)

/datum/nanite_program/viral/active_effect()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	var/datum/nanite_extra_setting/program = extra_settings[NES_PROGRAM_OVERWRITE]
	var/datum/nanite_extra_setting/cloud = extra_settings[NES_CLOUD_OVERWRITE]
	for(var/mob/living/people_in_range in orange(host_mob, 5))
		if(SEND_SIGNAL(people_in_range, COMSIG_NANITE_IS_STEALTHY))
			continue
		switch(program.get_value())
			if("Overwrite")
				SEND_SIGNAL(people_in_range, COMSIG_NANITE_SYNC, nanites, TRUE)
			if("Add To")
				SEND_SIGNAL(people_in_range, COMSIG_NANITE_SYNC, nanites, FALSE)
		SEND_SIGNAL(people_in_range, COMSIG_NANITE_SET_CLOUD, cloud.get_value())
	COOLDOWN_START(src, pulse_cooldown, 7.5 SECONDS)

/datum/nanite_program/self_scan
	name = "Host Scan"
	desc = "The nanites display a detailed readout of a body scan to the host."
	unique = FALSE
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 50
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/self_scan/register_extra_settings()
	extra_settings[NES_SCAN_TYPE] = new /datum/nanite_extra_setting/type("Medical", list("Medical", "Chemical", "Nanite"))

/datum/nanite_program/self_scan/on_trigger(comm_message)
	if(host_mob.stat == DEAD)
		return

	var/datum/nanite_extra_setting/scanned_nanites = extra_settings[NES_SCAN_TYPE]
	switch(scanned_nanites.get_value())
		if("Medical")
			healthscan(host_mob, host_mob)
		if("Chemical")
			chemscan(host_mob, host_mob)
		if("Nanite")
			SEND_SIGNAL(host_mob, COMSIG_NANITE_SCAN, host_mob, TRUE)

/datum/nanite_program/stealth
	name = "Stealth"
	desc = "The nanites mask their activity from superficial scans, becoming undetectable by HUDs and non-specialized scanners."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = 0.2

/datum/nanite_program/stealth/enable_passive_effect()
	. = ..()
	nanites.stealth = TRUE
	host_mob.hud_set_nanite_indicator(remove = TRUE)

/datum/nanite_program/stealth/disable_passive_effect()
	. = ..()
	nanites.stealth = FALSE
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/reduced_diagnostics
	name = "Reduced Diagnostics"
	desc = "Disables some high-cost diagnostics in the nanites, making them unable to communicate their program list to portable scanners. \
		Doing so saves some power, slightly increasing their replication speed."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = -0.1

/datum/nanite_program/reduced_diagnostics/enable_passive_effect()
	. = ..()
	nanites.diagnostics = FALSE

/datum/nanite_program/reduced_diagnostics/disable_passive_effect()
	. = ..()
	nanites.diagnostics = TRUE

/datum/nanite_program/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/relay/register_extra_settings()
	extra_settings[NES_RELAY_CHANNEL] = new /datum/nanite_extra_setting/number(1, 1, 9999)

/datum/nanite_program/relay/enable_passive_effect()
	. = ..()
	SSnanites.nanite_relays |= src

/datum/nanite_program/relay/disable_passive_effect()
	. = ..()
	SSnanites.nanite_relays -= src

/datum/nanite_program/relay/proc/relay_signal(code, relay_code, source)
	if(!activated)
		return
	if(!host_mob)
		return
	var/datum/nanite_extra_setting/nanite_setting = extra_settings[NES_RELAY_CHANNEL]
	if(relay_code != nanite_setting.get_value())
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, code, source)

/datum/nanite_program/relay/proc/relay_comm_signal(comm_code, relay_code, comm_message)
	if(!activated)
		return
	if(!host_mob)
		return
	var/datum/nanite_extra_setting/nanite_setting = extra_settings[NES_RELAY_CHANNEL]
	if(relay_code != nanite_setting.get_value())
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_COMM_SIGNAL, comm_code, comm_message)

/datum/nanite_program/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	use_rate = -0.5 //generates nanites
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/metabolic_synthesis/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/C = host_mob
	if(C.nutrition <= NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return ..()

/datum/nanite_program/metabolic_synthesis/active_effect()
	host_mob.adjust_nutrition(-0.5)

/datum/nanite_program/access
	name = "Subdermal ID"
	desc = "The nanites store the host's ID access rights in a subdermal magnetic strip. Updates when triggered, copying the host's current access."
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 30
	rogue_types = list(/datum/nanite_program/skin_decay)
	///List of all access that the Subdermal ID is currently holding onto.
	var/list/access = list()

/datum/nanite_program/access/on_mob_add()
	. = ..()
	RegisterSignal(host_mob, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_tried_access))

/datum/nanite_program/access/on_mob_remove()
	UnregisterSignal(host_mob, COMSIG_MOB_TRIED_ACCESS)
	return ..()

///Hook we use so the nanite program can be used as access.
/datum/nanite_program/access/proc/on_tried_access(datum/source, atom/movable/locked_thing)
	SIGNAL_HANDLER

	if(!length(access))
		return NONE

	if(!isobj(locked_thing))
		return LOCKED_ATOM_INCOMPATIBLE

	if(locked_thing.check_access_list(access))
		return ACCESS_ALLOWED

	return NONE

///Sets the nanites' list of saved accesses to the cumulative access they currently have in their hands, ID slots, and grabs,
///overwriting what they had there previously.
/datum/nanite_program/access/on_trigger(comm_message)
	var/list/new_access = list()
	var/obj/item/current_item
	//get your hand ID first
	current_item = host_mob.get_active_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	//then your other hand
	current_item = host_mob.get_inactive_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	//then whatever they have grabbed but not their hand, used for mobs without an access card slot
	current_item = host_mob.pulling
	if(current_item)
		new_access += current_item.GetAccess()
	//now we'll check for worn IDs
	if(ishuman(host_mob))
		var/mob/living/carbon/human/human_host = host_mob
		current_item = human_host.wear_id
		if(current_item)
			new_access += current_item.GetAccess()
	//animals & corgis have their own special access card slot, we'll grab those too
	else if(isanimal(host_mob))
		var/mob/living/simple_animal/animal_host = host_mob
		current_item = animal_host.access_card
		if(current_item)
			new_access += current_item.GetAccess()
	else if(iscorgi(host_mob))
		var/mob/living/basic/pet/dog/corgi/corgi_host = host_mob
		current_item = corgi_host.access_card
		if(current_item)
			new_access += current_item.GetAccess()
	access = new_access

/datum/nanite_program/spreading
	name = "Infective Exo-Locomotion"
	desc = "The nanites gain the ability to survive for brief periods outside of the human body, as well as the ability to start new colonies without an integration process; \
			resulting in an extremely infective strain of nanites."
	use_rate = 1.50
	rogue_types = list(/datum/nanite_program/aggressive_replication, /datum/nanite_program/necrotic)
	COOLDOWN_DECLARE(spread_delay)

/datum/nanite_program/spreading/active_effect()
	if(!COOLDOWN_FINISHED(src, spread_delay))
		return
	COOLDOWN_START(src, spread_delay, 8 SECONDS)

	var/list/mob/living/carbon/human/target_hosts = list()
	for(var/mob/living/carbon/human/nearby_humans in oview(5, host_mob))
		if(!prob(25))
			continue
		if(!(nearby_humans.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
			continue
		target_hosts += nearby_humans
	if(!target_hosts.len)
		return
	var/mob/living/carbon/human/infectee = pick(target_hosts)
	if(!(infectee.wear_suit) || prob(100 - infectee.wear_suit.get_armor_rating(BIO)))
		//this will potentially take over existing nanites!
		infectee.AddComponent(/datum/component/nanites, null, 10)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		log_game("[infectee] was infected by spreading nanites by [key_name(host_mob)] at [AREACOORD(infectee)].")

/datum/nanite_program/nanite_sting
	name = "Nanite Sting"
	desc = "When triggered, projects a nearly invisible spike of nanites that attempts to infect a nearby non-host with a copy of the host's nanites cluster."
	can_trigger = TRUE
	trigger_cost = 5
	trigger_cooldown = 100
	rogue_types = list(/datum/nanite_program/glitch, /datum/nanite_program/toxic)

/datum/nanite_program/nanite_sting/on_trigger(comm_message)
	var/list/mob/living/carbon/human/target_hosts = list()
	for(var/mob/living/carbon/human/nearby_humans in oview(1, host_mob))
		var/datum/component/nanites/nanites = nearby_humans.GetComponent(/datum/component/nanites)
		if(!(nearby_humans.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)) || nanites || !nearby_humans.Adjacent(host_mob))
			continue
		target_hosts += nearby_humans
	if(!target_hosts.len)
		consume_nanites(-5)
		return
	var/mob/living/carbon/human/infectee = pick(target_hosts)
	if(!(infectee.wear_suit) || prob(100 - infectee.wear_suit.get_armor_rating(BIO)))
		//unlike with Infective Exo-Locomotion, this can't take over existing nanites, because Nanite Sting only targets non-hosts.
		infectee.AddComponent(/datum/component/nanites, null, 5)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		log_game("[infectee] was infected by a nanite cluster by [key_name(host_mob)] at [AREACOORD(infectee)].")
		to_chat(infectee, span_warning("You feel a tiny prick."))

/datum/nanite_program/mitosis
	name = "Mitosis"
	desc = "The nanites gain the ability to self-replicate, using bluespace to power the process. Becomes more effective the more nanites are already in the host.\
			The replication has also a chance to corrupt the nanite programming due to copy faults - cloud sync is highly recommended."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/mitosis/active_effect()
	var/rep_rate = round(nanites.nanite_volume / 50, 1) //0.5 per 50 nanite volume
	rep_rate *= 0.5
	nanites.adjust_nanites(null, rep_rate)
	if(prob(rep_rate))
		var/datum/nanite_program/fault = pick(nanites.programs)
		if(fault == src)
			return
		fault.software_error()

/datum/nanite_program/dermal_button
	name = "Dermal Button"
	desc = "Displays a button on the host's skin, which can be used to send a signal to the nanites."
	unique = FALSE
	var/datum/action/innate/nanite_button/button

/datum/nanite_program/dermal_button/register_extra_settings()
	extra_settings[NES_SENT_CODE] = new /datum/nanite_extra_setting/number(1, 1, 9999)
	extra_settings[NES_BUTTON_NAME] = new /datum/nanite_extra_setting/text("Button")
	extra_settings[NES_ICON] = new /datum/nanite_extra_setting/type("power", list(
		"blank",
		"one",
		"two",
		"three",
		"four",
		"five",
		"plus",
		"minus",
		"exclamation",
		"question",
		"cross",
		"info",
		"heart",
		"skull",
		"brain",
		"brain_damage",
		"injection",
		"blood",
		"shield",
		"reaction",
		"network",
		"power",
		"radioactive",
		"electricity",
		"magnetism",
		"scan",
		"repair",
		"id",
		"wireless",
		"say",
		"sleep",
		"bomb",
	))

/datum/nanite_program/dermal_button/enable_passive_effect()
	. = ..()
	var/datum/nanite_extra_setting/bn_name = extra_settings[NES_BUTTON_NAME]
	var/datum/nanite_extra_setting/bn_icon = extra_settings[NES_ICON]
	if(!button)
		button = new(src, bn_name.get_value(), bn_icon.get_value())
	button.target = host_mob
	button.Grant(host_mob)

/datum/nanite_program/dermal_button/disable_passive_effect()
	. = ..()
	if(button)
		button.Remove(host_mob)

/datum/nanite_program/dermal_button/on_mob_remove()
	qdel(button)
	return ..()

/datum/nanite_program/dermal_button/proc/press()
	if(activated)
		host_mob.visible_message(
			span_notice("[host_mob] presses a button on [host_mob.p_their()] forearm."),
			span_notice("You press the nanite button on your forearm."),
			null, 2,
		)
		var/datum/nanite_extra_setting/sent_code = extra_settings[NES_SENT_CODE]
		SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, sent_code.get_value(), "a [name] program")

/datum/action/innate/nanite_button
	name = "Button"
	button_icon = 'monkestation/icons/obj/machines/nanites/nanite_actions.dmi'
	button_icon_state = "power_green"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	var/datum/nanite_program/dermal_button/program

/datum/action/innate/nanite_button/New(datum/nanite_program/dermal_button/program, program_name, program_icon)
	..()
	src.program = program
	src.name = program_name
	button_icon_state = "nanite_[program_icon]"

/datum/action/innate/nanite_button/Activate()
	program.press()
