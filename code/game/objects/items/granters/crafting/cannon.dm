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

/obj/item/book/granter/crafting_recipe/vendozer
	name = "True diary of a demoted engineer"
	desc = "This journal has rage eminating from it. The books about trash cannons must have been fakes, all to hide this..."
	crafting_recipe_types = list(
		/datum/crafting_recipe/vendozer_ck,
		/datum/crafting_recipe/vendozer_eg,
		/datum/crafting_recipe/vendozer_fl,
		/datum/crafting_recipe/vendozer_fr,
		/datum/crafting_recipe/vendozer_bl,
		/datum/crafting_recipe/vendozer_br,
		/datum/crafting_recipe/vendozer,
	)
	icon_state = "book1"
	remarks = list(
		"\"I won't leave one standing wall, one breathing crewmember, one working machine.\"",
		"\"An engine... The turbine! More then enough juice.\"",
		"\"I work with bloodied, bruised hands, nothing will stop me.\"",
		"\"If the supermatter gets loose, then I know god is with me.\"",
		"\"Vending machines are great for armor. Who knew?\"",
		"\"Too large to assemble directly, will need to craft intermediaries.\"",
	)

/obj/item/book/granter/crafting_recipe/vendozer/recoil(mob/living/user)
	to_chat(user, span_warning("The book ignites in rage and fury, incinerating itself before you can read it."))
	qdel(src)

/obj/item/book/granter/crafting_recipe/maintenance_battle_tank
	name = "Redneck's guide to engineering: vol.345, Appalachia Armored Warfare"
	desc = "A very thick and old magazine, you can smell chewing tabbacco and cheap whiskey eminating from the book."
	crafting_recipe_types = list(
		/datum/crafting_recipe/mbt_chassis,
		/datum/crafting_recipe/mbt_engine,
		/datum/crafting_recipe/mbt_tracks,
		/datum/crafting_recipe/mbt_turret,
		/datum/crafting_recipe/mbt_autoloader,
		/datum/crafting_recipe/mbt_gun,
		/datum/crafting_recipe/mbt_accessories,
	)
	icon_state = "book1"
	remarks = list(
		"\"I'd bet you could use reinforced tables for this.\"",
		"\"Making engines is that easy? wow!\"",
		"\"This is just East German technical documents...\"",
		"\"I never knew the strength and certainty of wood.\"",
		"\"Wish I had the next issue, it says its about nuclear bombs.\"",
		"\"It has smoke grenades installed? oooooh.\"",
	)

/obj/item/book/granter/crafting_recipe/maintenance_battle_tank/recoil(mob/living/user)
	to_chat(user, span_warning("The whiskey finally soaks through the last strands of the paper, turning it to mush."))
	qdel(src)
