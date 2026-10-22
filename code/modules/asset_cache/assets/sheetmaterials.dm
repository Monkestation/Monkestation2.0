/datum/asset/spritesheet_batched/sheetmaterials
	name = "sheetmaterials"

/datum/asset/spritesheet_batched/sheetmaterials/create_spritesheets()
	insert_all_icons("", 'icons/obj/stack_objects.dmi')

	// Special case to handle Bluespace Crystals
	insert_icon("polycrystal", uni_icon('icons/obj/telescience.dmi', "polycrystal"))
