/datum/religion_sect/spar
	name = "Sparring"
	quote = "Your next swing must be faster, neophyte. Steel your heart."
	desc = "Spar other crewmembers to gain favor or other rewards. Exchange favor to steel yourself against real battles."
	tgui_icon = "fist-raised"
	altar_icon_state = "convertaltar-orange"
	alignment = ALIGNMENT_NEUT
	rites_list = list(
		/datum/religion_rites/sparring_contract,
		/datum/religion_rites/ceremonial_weapon,
		/datum/religion_rites/declare_arena,
		/datum/religion_rites/tenacious,
		/datum/religion_rites/unbreakable,
	)
	///the one allowed contract. making a new contract dusts the old one
	var/obj/item/sparring_contract/existing_contract
	///places you can spar in. rites can be used to expand this list with new arenas!
	var/list/arenas = list(
		"Recreation Area" = /area/station/commons/fitness/recreation,
		"Chapel" = /area/station/service/chapel,
	)
	///how many matches you've lost with holy stakes. 3 = excommunication
	var/matches_lost = 0
	///past opponents who you've beaten in holy battles. You can't fight them again to prevent favor farming
	var/list/past_opponents = list()

/datum/religion_sect/spar/tool_examine(mob/living/holy_creature)
	return "You have [round(favor)] sparring matches won in [GLOB.deity]'s name to redeem. You have lost [matches_lost] holy matches. You will be excommunicated after losing three matches."

///sparring god rites

/datum/religion_rites/sparring_contract
	name = "Summon Sparring Contract"
	desc = "Turns some paper into a sparring contract."
	invoke_msg = "I will train in the name of my god."
	///paper to turn into a sparring contract
	var/obj/item/paper/contract_target

/datum/religion_rites/sparring_contract/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/paper/could_contract in get_turf(religious_tool))
		if(could_contract.get_total_length()) //blank paper pls
			continue
		contract_target = could_contract
		return ..()
	to_chat(user, span_warning("You need to place blank paper on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/sparring_contract/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/obj/item/paper/blank_paper = contract_target
	var/turf/tool_turf = get_turf(religious_tool)
	contract_target = null
	if(QDELETED(blank_paper) || !(tool_turf == blank_paper.loc)) //check if the same paper is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	blank_paper.visible_message(span_notice("words magically form on [blank_paper]!"))
	playsound(tool_turf, 'sound/effects/pray.ogg', 50, TRUE)
	var/datum/religion_sect/spar/sect = GLOB.religious_sect
	if(sect.existing_contract)
		sect.existing_contract.visible_message(span_warning("[src] fizzles into nothing!"))
		qdel(sect.existing_contract)
	sect.existing_contract = new /obj/item/sparring_contract(tool_turf)
	qdel(blank_paper)
	return TRUE

/datum/religion_rites/declare_arena
	name = "Declare Arena"
	desc = "Declare a new area as fit for sparring. You'll be able to select it in contracts."
	ritual_length = 6 SECONDS
	ritual_invocations = list("I seek new horizons ...")
	invoke_msg = "... may my climb be steep."
	favor_cost = 1 //only costs one holy battle for a new area
	var/area/area_instance

/datum/religion_rites/declare_arena/perform_rite(mob/living/user, atom/religious_tool)
	var/list/filtered = list()
	for(var/area/unfiltered_area as anything in get_sorted_areas())
		if(istype(unfiltered_area, /area/centcom)) //youuu dont need thaaat
			continue
		if(!(unfiltered_area.area_flags & HIDDEN_AREA))
			filtered += unfiltered_area
	area_instance = tgui_input_list(user, "Choose an area to mark as an arena!", "Arena Declaration", filtered)
	if(isnull(area_instance))
		return FALSE
	return ..()

/datum/religion_rites/declare_arena/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/datum/religion_sect/spar/sect = GLOB.religious_sect
	sect.arenas[area_instance.name] = area_instance.type
	to_chat(user, span_warning("[area_instance] is a now an option to select on sparring contracts."))

/datum/religion_rites/ceremonial_weapon
	name = "Forge Ceremonial Gear"
	desc = "Turn some material into ceremonial gear. Ceremonial blades are weak outside of sparring, and are quite heavy to lug around."
	ritual_length = 10 SECONDS
	invoke_msg = "Weapons in your name! Battles with your blood!"
	favor_cost = 0
	///the material that will be attempted to be forged into a weapon
	var/obj/item/stack/sheet/converted

/datum/religion_rites/ceremonial_weapon/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/could_blade in get_turf(religious_tool))
		if(!(GET_MATERIAL_REF(could_blade.material_type) in SSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL]))
			continue
		if(could_blade.amount < 5)
			continue
		converted = could_blade
		return ..()
	to_chat(user, span_warning("You need at least 5 sheets of a material that can be made into items!"))
	return FALSE

/datum/religion_rites/ceremonial_weapon/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	var/obj/item/stack/sheet/used_for_blade = converted
	converted = null
	if(QDELETED(used_for_blade) || !(get_turf(religious_tool) == used_for_blade.loc) || used_for_blade.amount < 5) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	var/material_used = used_for_blade.material_type
	to_chat(user, span_warning("[used_for_blade] reshapes into a ceremonial blade!"))
	if(!used_for_blade.use(5))//use 5 of the material
		return
	var/obj/item/ceremonial_blade/blade = new(altar_turf)
	blade.set_custom_materials(list(GET_MATERIAL_REF(material_used) = SHEET_MATERIAL_AMOUNT * 5))
	return TRUE

/datum/religion_rites/unbreakable
	name = "Become Unbreakable"
	desc = "Your training has made you unbreakable. In times of crisis, you will attempt to keep fighting on."
	ritual_length = 10 SECONDS
	invoke_msg = "My will must be unbreakable. Grant me this boon!"
	favor_cost = 4 //4 duels won

/datum/religion_rites/unbreakable/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_UNBREAKABLE, INNATE_TRAIT))
		to_chat(user, span_warning("Your spirit is already unbreakable!"))
		return FALSE
	return ..()

/datum/religion_rites/unbreakable/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	. = ..()
	to_chat(user, span_nicegreen("You feel [GLOB.deity]'s will to keep fighting pouring into you!"))
	user.AddComponent(/datum/component/unbreakable)

/datum/religion_rites/tenacious
	name = "Become Tenacious"
	desc = "Your training has made you tenacious. In times of crisis, you will be able to crawl faster."
	ritual_length = 10 SECONDS
	invoke_msg = "Grant me your tenacity! I have proven myself!"
	favor_cost = 3 //3 duels won

/datum/religion_rites/tenacious/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	if(HAS_TRAIT_FROM(user, TRAIT_TENACIOUS, INNATE_TRAIT))
		to_chat(user, span_warning("Your spirit is already tenacious!"))
		return FALSE
	return ..()

/datum/religion_rites/tenacious/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	. = ..()
	to_chat(user, span_nicegreen("You feel [GLOB.deity]'s tenacity pouring into you!"))
	user.AddElement(/datum/element/tenacious)
