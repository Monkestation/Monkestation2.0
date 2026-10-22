/datum/quirk/material_bane
	name = "Material Allergy"
	desc = "For whatever reason (perhaps it was that ancient statue you knocked over yesterday), a certain material is dangerous to you. It'll be extra dangerous to get attacked with and touching it invites a variety of issues."
	icon = FA_ICON_FIRE_ALT
	value = -4
	gain_text = span_danger("You feel scared of a certain material.")
	lose_text = span_notice("Your material allergy fades.")
	medical_record_text = "Patient's body is violently reactive to certain materials."
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_PROCESSES

/datum/quirk/material_bane/add(client/client_source)
	var/bane_mat = client_source?.prefs?.read_preference(/datum/preference/choiced/material_bane) || "Silver"
	var/the_bane_to_do = /datum/material/silver
	switch(bane_mat)
		if("Iron")
			the_bane_to_do = /datum/material/iron
		if("Glass")
			the_bane_to_do = /datum/material/glass
		if("Silver")
			the_bane_to_do = /datum/material/silver
		if("Gold")
			the_bane_to_do = /datum/material/gold
		if("Plastic")
			the_bane_to_do = /datum/material/plastic
		if("Uranium")
			the_bane_to_do = /datum/material/uranium
		if("Diamond")
			the_bane_to_do = /datum/material/diamond
		if("Bluespace Crystal")
			the_bane_to_do = /datum/material/bluespace
		if("Titanium")
			the_bane_to_do = /datum/material/titanium
		if("Wood")
			the_bane_to_do = /datum/material/wood
		if("Plasma")
			the_bane_to_do = /datum/material/plasma

	quirk_holder.AddComponentFrom(QUIRK_TRAIT, /datum/component/material_bane, list(the_bane_to_do), TRUE, 1, 500, 1)

/datum/quirk/material_bane/remove()
	quirk_holder.RemoveComponentSource(QUIRK_TRAIT, /datum/component/material_bane)

