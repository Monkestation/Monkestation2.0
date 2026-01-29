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

/datum/crafting_recipe/blackcoffin
	name = "Black Coffin"
	result = /obj/structure/closet/crate/coffin/blackcoffin
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/cloth = 1,
		/obj/item/stack/sheet/mineral/wood = 5,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/securecoffin
	name = "Secure Coffin"
	result = /obj/structure/closet/crate/coffin/securecoffin
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/iron = 5,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/meatcoffin
	name = "Meat Coffin"
	result = /obj/structure/closet/crate/coffin/meatcoffin
	tool_behaviors = list(TOOL_KNIFE, TOOL_ROLLINGPIN)
	reqs = list(
		/obj/item/food/meat/slab = 5,
		/obj/item/restraints/handcuffs/cable = 1,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE
	always_available = FALSE //The sacred coffin!

/datum/crafting_recipe/metalcoffin
	name = "Metal Coffin"
	result = /obj/structure/closet/crate/coffin/metalcoffin
	reqs = list(
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/rods = 2,
	)
	time = 10 SECONDS
	category = CAT_STRUCTURE
