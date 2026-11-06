/datum/scripture/create_structure/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "Summon an anchoring crystal to the station."
	tip = "Oops!" //this is set on New()
	button_icon_state = "Clockwork Obelisk"
	power_cost = STANDARD_CELL_CHARGE * 0.5
	invocation_time = 20 SECONDS
	invocation_text = list("Space shall fold...", "Time shall mold...", "Anchor us here...", "Engine is near!")
	summoned_structure = /obj/structure/destructible/clockwork/anchoring_crystal
	cogs_required = 5
	invokers_required = 3
	category = SPELLTYPE_STRUCTURES
	///The next timestamp the cult can summon a crystal
	var/static/next_crystal_timestamp = 0

/datum/scripture/create_structure/anchoring_crystal/New()
	update_info()
	. = ..()
	RegisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CHARGED, PROC_REF(on_crystal_charged))
	RegisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CREATED, PROC_REF(update_info))

/datum/scripture/create_structure/anchoring_crystal/Destroy(force)
	UnregisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CHARGED)
	UnregisterSignal(SSthe_ark, COMSIG_ANCHORING_CRYSTAL_CREATED)
	return ..()

/datum/scripture/create_structure/anchoring_crystal/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(world.time < next_crystal_timestamp)
		to_chat(invoker, span_warning("The ark will be stable enough to summon another crystal in [DisplayTimeText(next_crystal_timestamp - world.time)]."))
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
	if(SSthe_ark.get_charged_anchor_crystals() != length(SSthe_ark.anchoring_crystals))
		to_chat(invoker, span_warning("Another Anchoring Crystal is already charging!"))
		return FALSE
	return ..()

/datum/scripture/create_structure/anchoring_crystal/invoke_success()
	. = ..()
	next_crystal_timestamp = world.time + ANCHORING_CRYSTAL_COOLDOWN

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
