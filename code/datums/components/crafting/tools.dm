/datum/crafting_recipe/gold_horn
	name = "Golden Bike Horn"
	result = /obj/item/bikehorn/golden
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/bananium = 5,
		/obj/item/bikehorn = 1,
	)
	category = CAT_TOOLS

/datum/crafting_recipe/bonfire
	name = "Bonfire"
	time = 6 SECONDS
	reqs = list(/obj/item/grown/log = 5)
	parts = list(/obj/item/grown/log = 5)
	blacklist = list(/obj/item/grown/log/steel)
	result = /obj/structure/bonfire
	category = CAT_TOOLS

/datum/crafting_recipe/boneshovel
	name = "Serrated Bone Shovel"
	always_available = FALSE
	reqs = list(
		/obj/item/stack/sheet/bone = 4,
		/datum/reagent/fuel/oil = 5,
		/obj/item/shovel/spade = 1,
	)
	result = /obj/item/shovel/serrated
	category = CAT_TOOLS

/datum/crafting_recipe/lasso
	name = "Bone Lasso"
	reqs = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/sheet/sinew = 5,
	)
	result = /obj/item/key/lasso
	category = CAT_TOOLS

/datum/crafting_recipe/ipickaxe
	name = "Improvised Pickaxe"
	reqs = list(
		/obj/item/crowbar = 1,
		/obj/item/knife = 1,
		/obj/item/stack/sticky_tape = 1,
	)
	result = /obj/item/pickaxe/improvised
	category = CAT_TOOLS

/datum/crafting_recipe/makeshift_radio_jammer
	name = "Makeshift Radio Jammer"
	result = /obj/item/jammer/makeshift
	reqs = list(
		/obj/item/universal_scanner = 1,
		/obj/item/encryptionkey = 1,
		/obj/item/stack/cable_coil = 5,
	)
	category = CAT_TOOLS

/datum/crafting_recipe/lantern/pineapple
	name = "Pineapp-o'-lantern"
	result = /obj/item/flashlight/lantern/pineapple
	time = 2 SECONDS
	reqs = list (
		/obj/item/food/grown/pineapple = 1,
		/obj/item/flashlight = 1
		//Doesn't require a lantern like the original version, which adds a cool bit of utility to the recipe because it's not longer super limited.
	)
	category = CAT_TOOLS

/datum/crafting_recipe/shuttle_blueprints
	name = "Crude Shuttle Blueprints"
	result = /obj/item/shuttle_blueprints/crude
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/toy/crayon = CRAFTING_INGREDIENT_USE,
	)
	steps = list(
		"You must use either a a blue crayon, a rainbow crayon, or a spray can.",
		"The crayon or spray can you use must have at least 10 uses remaining."
	)
	time = 10 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/shuttle_blueprints/check_requirements(mob/user, list/collected_requirements)
	var/list/crayons = collected_requirements[/obj/item/toy/crayon]
	for(var/obj/item/toy/crayon/crayon as anything in crayons)
		if(!is_type_in_list(crayon, list(/obj/item/toy/crayon/blue, /obj/item/toy/crayon/rainbow, /obj/item/toy/crayon/spraycan)))
			continue
		if(!crayon.check_empty(user, 10))
			return TRUE

/datum/crafting_recipe/shuttle_blueprints/on_craft_completion(mob/user, atom/result)
	var/static/list/valid_types = list(/obj/item/toy/crayon/blue, /obj/item/toy/crayon/rainbow, /obj/item/toy/crayon/spraycan)
	for(var/valid_type in valid_types)
		var/obj/item/toy/crayon/crayon = locate(valid_type) in range(1)
		if(!crayon)
			continue
		if(crayon.use_charges(user, 10))
			return
