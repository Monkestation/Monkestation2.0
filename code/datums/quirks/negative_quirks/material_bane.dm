/datum/quirk/material_bane
	name = "Material Allergy"
	desc = "For whatever reason (perhaps it was that ancient statue you knocked over yesterday), a certain material is dangerous to you. It'll be extra dangerous to get attacked with and touching it invites a variety of issues."
	icon = FA_ICON_COMMENT_SLASH
	value = -4
	gain_text = span_danger("oo ee oo aa aa ting tang walla walla bing bang")
	lose_text = span_notice("Your material allergy fades.")
	medical_record_text = "Patient's body is violently reactive to certain materials."
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_PROCESSES
	var/datum/material/ourbane = /datum/material/silver
	var/how_yeowched = 0

/datum/quirk/material_bane/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_EYECONTACT, PROC_REF(eye_contact))
	RegisterSignal(quirk_holder, COMSIG_MOB_EXAMINATE, PROC_REF(looks_at_floor))
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/material_bane/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE, COMSIG_MOB_SAY))

/datum/quirk/material_bane/on_process(seconds_per_tick)
	var/mob/living/carbon/human/humholder = quirk_holder
	var/has_gloves = FALSE
	for(var/obj/item/equippies in humholder.get_equipped_items())
		var/obj/item/gloves = humholder.gloves
		if(gloves)
			if(!(gloves.body_parts_covered & HANDS) || HAS_TRAIT(gloves, TRAIT_FINGERPRINT_PASSTHROUGH))
				has_gloves = TRUE
		if(equippies.custom_materials)
			var/ouch_ratio = 0
			var/hurts_us = FALSE
			var/total_mats = 0
			var/how_much_of_ouch = 0 
			for(var/material in equippies.custom_materials)
				var/datum/material/possible_ouch = GET_MATERIAL_REF(material)
				if(istype(possible_ouch, our_bane))
					hurts_us = TRUE
					how_much_of_ouch = equippies.custom_materials[possible_ouch]
				total_mats += equippies.custom_materials[possible_ouch]
			if(hurts_us)
				ouch_ratio = how_much_of_ouch / total_mats
					
