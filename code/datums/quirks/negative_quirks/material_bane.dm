#define MATERIAL_BANE_MAX_PASSIVE_PER_CLOTHING 10
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
	var/collective_bane_power = 0

/datum/quirk/material_bane/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_EYECONTACT, PROC_REF(eye_contact))
	RegisterSignal(quirk_holder, COMSIG_MOB_EXAMINATE, PROC_REF(looks_at_floor))
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/material_bane/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE, COMSIG_MOB_SAY))

/datum/quirk/material_bane/on_process(seconds_per_tick)
	var/was_baned = FALSE
	var/mob/living/carbon/human/humholder = quirk_holder
	var/has_gloves = FALSE
	var/amount_ouch_to_cause = 0
	var/num_ouchy_clothes = 0
	for(var/obj/item/equippies in humholder.get_equipped_items())
		var/obj/item/gloves = humholder.gloves
		if(gloves)
			if(!(gloves.body_parts_covered & HANDS) || HAS_TRAIT(gloves, TRAIT_FINGERPRINT_PASSTHROUGH))
				has_gloves = TRUE
		if(equippies.custom_materials)
			for(var/material in equippies.custom_materials)
				var/datum/material/possible_ouch = GET_MATERIAL_REF(material)
				if(istype(possible_ouch, our_bane))
					num_ouchy_clothes += 1
					was_baned = TRUE
					if(prob(10))
						humholder.visible_message(span_warning("[humholder] sizzles on contact with [equippies]"), span_warning("You sizzle and twitch as [equippies] painfully scalds you!"), span_warning("You hear a meaty sizziling noise, like frying bacon."))
		collective_bane_power = max((MATERIAL_BANE_MAX_PASSIVE_PER_CLOTHING * num_ouchy_clothes), collective_bane_power)
					
