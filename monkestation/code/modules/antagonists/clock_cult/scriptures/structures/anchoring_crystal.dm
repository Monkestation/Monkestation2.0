/datum/scripture/create_structure/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "Summon an anchoring crystal to the station."
	tip = "Oops!" //this is set on New()
	button_icon_state = "Clockwork Obelisk"
	power_cost = 500
	invocation_time = 20 SECONDS
	invocation_text = list("Space shall fold...", "Time shall mold...", "Anchor us here...", "Engine is near!")
	summoned_structure = /obj/structure/destructible/clockwork/anchoring_crystal
	cogs_required = 5
	invokers_required = 3
	category = SPELLTYPE_STRUCTURES
	///how long in seconds until the scripture can be invoked again, pretty much a cooldown
	var/static/time_until_invokable = 0
	///the list of
	var/static/list/valid_areas

/datum/scripture/create_structure/anchoring_crystal/New()
	update_info()
	. = ..()
	RegisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CHARGED, PROC_REF(on_crystal_charged))
	RegisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CREATED, PROC_REF(update_info))

/datum/scripture/create_structure/anchoring_crystal/Destroy(force)
	UnregisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CHARGED)
	UnregisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CREATED)
	return ..()

/datum/scripture/create_structure/anchoring_crystal/process(seconds_per_tick)
	time_until_invokable = time_until_invokable - (seconds_per_tick SECONDS)
	if(time_until_invokable <= 0)
		var/datum/scripture/create_structure/anchoring_crystal/global_datum = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
		STOP_PROCESSING(SSprocessing, global_datum)
		time_until_invokable = 0

/datum/scripture/create_structure/anchoring_crystal/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(time_until_invokable)
		to_chat(invoker, span_warning("The ark will be stable enough to summon another crystal in [time_until_invokable] seconds."))
		return FALSE

	if(SSthe_ark.charged_anchoring_crystals && !SSthe_ark.valid_crystal_areas[get_area(invoker)])
		var/list/area_list = list()
		for(var/area/added_area in SSthe_ark.valid_crystal_areas)
			area_list += SSthe_ark.valid_crystal_areas[added_area]
		to_chat(invoker, span_warning("This cystal can only be summoned in [english_list(area_list)]."))
		return FALSE

	var/area/checked_area = get_area(invoker)
	if(!(checked_area?.area_flags & VALID_TERRITORY))
		to_chat(invoker, span_warning("You cannot summon an anchoring crystal here!"))
		return FALSE
	return TRUE

/datum/scripture/create_structure/anchoring_crystal/invoke()
	if(time_until_invokable) //check again in case they try and make two at once
		var/datum/scripture/create_structure/anchoring_crystal/scripture = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
		START_PROCESSING(SSprocessing, scripture) //make sure we dont brick somehow
		to_chat(invoker, span_warning("Another Anchoring Crystal is already charging!"))
		return FALSE
	. = ..()

/datum/scripture/create_structure/anchoring_crystal/invoke_success()
	. = ..()
	time_until_invokable = ANCHORING_CRYSTAL_COOLDOWN
	var/datum/scripture/create_structure/anchoring_crystal/scripture = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
	START_PROCESSING(SSprocessing, scripture)

/datum/scripture/create_structure/anchoring_crystal/proc/on_crystal_charged()
	SIGNAL_HANDLER
	if(SSthe_ark.charged_anchoring_crystals >= ANCHORING_CRYSTALS_TO_SUMMON + 2)
		unique_lock()
		return

/datum/scripture/create_structure/anchoring_crystal/proc/update_info()
	SIGNAL_HANDLER
	tip = "With this crystal [anchoring_crystal_charge_message()]"
	if(!SSthe_ark.charged_anchoring_crystals)
		return

	if(!length(SSthe_ark.valid_crystal_areas))
		desc = "We cannot summon any more anchoring crystals to the station."
	else
		var/list/area_list = list()
		for(var/area/added_area in SSthe_ark.valid_crystal_areas)
			area_list += SSthe_ark.valid_crystal_areas[added_area]
		desc = "Summon an anchoring crystal to the station, it can be summoned in [english_list(area_list)]."
