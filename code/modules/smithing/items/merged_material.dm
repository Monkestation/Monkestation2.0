/obj/item/merged_material
	name = "forged metal"
	desc = "A blend of various metals."

	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-runite"

/obj/item/merged_material/examine(mob/user)
	. = ..()
	if(material_stats)
		if(material_stats.flammability >= 60)
			. += "Looks flammable."
		if(material_stats.density >= 60)
			. += "Looks dense."
		if(material_stats.hardness >= 60)
			. += "Looks hard to scratch."

		for(var/datum/material_trait/trait as anything in material_stats.material_traits)
			if(trait.examine_text)
				. += trait.examine_text
