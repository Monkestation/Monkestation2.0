/obj/structure/window/fulltile/green_glass_pane
	name = "green glass window"
	desc = "A handcrafted green glass window. At least you can still see through it."
	icon = 'monkestation/code/modules/blueshift/icons/windows.dmi'
	icon_state = "green_glass"
	can_be_unanchored = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

/datum/crafting_recipe/green_glass_pane
	name = "green glass window"
	result = /obj/structure/window/fulltile/green_glass_pane
	time = 0.2 SECONDS
	reqs = list(
		/datum/reagent/iron = 5,
		/obj/item/stack/sheet/glass = 2,
	)
	category = CAT_STRUCTURE
