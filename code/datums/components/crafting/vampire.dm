/datum/crafting_recipe/vassalrack
	name = "Vassalization Rack"
	result = /obj/structure/vampire/vassalrack
	time = 5 SECONDS

	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 6,
	)

	category = CAT_VAMPIRE
	always_available = FALSE
	one_per_turf = TRUE
	// crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/candelabrum
	name = "Candelabrum"
	result = /obj/structure/vampire/candelabrum
	time = 5 SECONDS

	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/rods = 3,
		/obj/item/flashlight/flare/candle = 2,
	)

	category = CAT_VAMPIRE
	always_available = FALSE
	one_per_turf = TRUE
	// crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/bloodthrone
	name = "Blood Throne"
	result = /obj/structure/vampire/bloodthrone
	time = 5 SECONDS

	reqs = list(
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/rods = 2,
	)

	category = CAT_VAMPIRE
	always_available = FALSE
	one_per_turf = TRUE
	// crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_MUST_BE_LEARNED
