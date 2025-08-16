//upgrade tiers
/datum/machining_recipe/upgrade_tier_1
	name = "Upgrade Tier 1 parts"
	desc = "Crappy rusted and warped machine parts, better then the half decayed parts NT supplied. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/sheet/iron = 10,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t1
	upgrade_tier_required = 1
	machining_skill_required = 1

/datum/machining_recipe/upgrade_tier_2
	name = "Upgrade Tier 2 parts"
	desc = "Dull but workable machine parts, much better then what you could make before. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 10,
		/obj/item/stack/machining_intermediates/steel = 10,
		/obj/item/machining_intermediates/moltenplastic = 4,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t2
	upgrade_tier_required = 2
	machining_skill_required = 2

/datum/machining_recipe/upgrade_tier_3
	name = "Upgrade Tier 3 parts"
	desc = "Shiny and strong machine parts. Able to work with great efficency. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 10,
		/obj/item/stack/machining_intermediates/hardsteel = 5,
		/obj/item/machining_intermediates/universalcircuit = 4,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t3
	upgrade_tier_required = 3
	machining_skill_required = 3

/datum/machining_recipe/upgrade_tier_4
	name = "Upgrade Tier 4 parts"
	desc = "Perfect parts, able to work flawlessly with anything its designed for, which is your machines. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/machining_intermediates/hardsteel = 5,
		/obj/item/machining_intermediates/universalcircuit = 6,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t4
	upgrade_tier_required = 4
	machining_skill_required = 4

//assembly parts
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
	upgrade_tier_required = 3
	reqs = list(
		/obj/item/machining_intermediates/moltenplastic = 1,
		/obj/item/stack/machining_intermediates/smallwire = 5,
		/obj/item/stack/sheet/mineral/gold = 1,
	)

/datum/machining_recipe/smallmotor
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/smallmotor
	upgrade_tier_required = 3
	reqs = list(
		/obj/item/stack/rods = 2,
		/obj/item/stack/machining_intermediates/smallwire = 20,
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
		/obj/item/stack/sheet/plastic = 2
	)

/datum/machining_recipe/steel
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_FURNACE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/stack/machining_intermediates/steel
	upgrade_tier_required = 3
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
	)

/datum/machining_recipe/hardsteel
	category = TAB_GENERAL_PARTS
	machinery_type = MACHINING_FURNACE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/stack/machining_intermediates/hardsteel
	upgrade_tier_required = 4
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
