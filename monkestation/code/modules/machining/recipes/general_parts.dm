/datum/machining_recipe/screwbolt
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/stack/machining_intermediates/screwbolt
	result_amount = 2
	reqs = list(
		/obj/item/stack/rods = 2,
	)

/datum/machining_recipe/smallwire
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/stack/machining_intermediates/smallwire
	result_amount = 5
	reqs = list(
		/obj/item/stack/cable_coil = 5,
	)

/datum/machining_recipe/universalcircuit
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/universalcircuit
	result_amount = 2
	machining_skill_required = 2
	reqs = list(
		/obj/item/machining_intermediates/moltenplastic = 2,
		/obj/item/stack/machining_intermediates/smallwire = 6,
		/obj/item/stack/sheet/mineral/gold = 1,
	)

/datum/machining_recipe/smallmotor
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/smallmotor
	machining_skill_required = 3
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/stack/machining_intermediates/smallwire = 15,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 4,
	)

/datum/machining_recipe/igniter
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/assembly/igniter
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 1,
	)

/datum/machining_recipe/moltenplastic
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_FURNACE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/moltenplastic
	reqs = list(
		/obj/item/stack/sheet/plastic = 1
	)

/datum/machining_recipe/steel
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_FURNACE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/stack/machining_intermediates/steel
	machining_skill_required = 3
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
	)

/datum/machining_recipe/hardsteel
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_FURNACE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/stack/machining_intermediates/hardsteel
	machining_skill_required = 4
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/sheet/mineral/titanium = 1,
	)

/datum/machining_recipe/shapedwood
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_TABLESAW
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/shapedwood
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 5,
	)

/datum/machining_recipe/woodplanks
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_TABLESAW
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/stack/sheet/mineral/wood
	result_amount = 10
	reqs = list(
		/obj/item/grown/log = 1,
	)
