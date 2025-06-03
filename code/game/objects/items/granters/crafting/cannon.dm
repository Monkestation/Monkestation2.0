/obj/item/book/granter/crafting_recipe/trash_cannon
	name = "diary of a demoted engineer"
	desc = "A lost journal. The engineer seems very deranged about their demotion."
	crafting_recipe_types = list(
		/datum/crafting_recipe/trash_cannon,
		/datum/crafting_recipe/trashball,
	)
	icon_state = "book1"
	remarks = list(
		"\"I'll show them! I'll build a CANNON!\"",
		"\"Gunpowder is ideal, but i'll have to improvise...\"",
		"\"I savor the look on the CE's face when I BLOW down the walls to engineering!\"",
		"\"If the supermatter gets loose from my rampage, so be it!\"",
		"\"I'VE GONE COMPLETELY MENTAL!\"",
	)

/obj/item/book/granter/crafting_recipe/trash_cannon/recoil(mob/living/user)
	to_chat(user, span_warning("The book turns to dust in your hands."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/stockade
	name = "Old Caoivish blueprints"
	desc = "Hundreds of years old, its blueprints to make a stockade?"
	crafting_recipe_types = list(
		/datum/crafting_recipe/stockade_chassis,
		/datum/crafting_recipe/stockade_larm,
		/datum/crafting_recipe/stockade_rarm,
		/datum/crafting_recipe/stockade_lleg,
		/datum/crafting_recipe/stockade_armor,
	)
	icon_state = "book1"
	remarks = list(
		"\"Requires 15 steel components.\"",
		"\"37.5m accurate range, 42.5m inaccurate.\"",
		"\"Curved blastshield to prevent decrewing...\"",
		"\"Do not engage Stygian Bolt ever.\"",
		"\"Splash range of 2.5m radius.\"",
	)

/obj/item/book/granter/crafting_recipe/stockade/recoil(mob/living/user)
	to_chat(user, span_warning("The blueprints turns to dust in your hands."))
	qdel(src)
