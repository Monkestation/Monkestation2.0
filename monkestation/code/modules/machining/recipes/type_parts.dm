/datum/machining_recipe/insulation
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/insulation
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
	)

/datum/machining_recipe/sewingsupplies
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/sewingsupplies
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/rods = 1,
	)

/datum/machining_recipe/softarmor
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/softarmor
	reqs = list(
		/obj/item/stack/sheet/cloth = 10,
		/obj/item/stack/sheet/leather = 4,
		/obj/item/machining_intermediates/sewingsupplies = 1,
	)
	machining_skill_required = 2

/datum/machining_recipe/hardarmor
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/hardarmor
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/machining_intermediates/hardsteel = 4,
		/obj/item/machining_intermediates/sewingsupplies = 1,
	)
	machining_skill_required = 2

/datum/machining_recipe/handle_wood
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/handle_wood
	reqs = list(
		/obj/item/machining_intermediates/shapedwood = 1,
		/obj/item/stack/rods = 1,
	)

/datum/machining_recipe/handle_polymer
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/handle_polymer
	reqs = list(
		/obj/item/machining_intermediates/moltenplastic = 1,
		/obj/item/stack/rods = 1,
	)

/datum/machining_recipe/stock_wood
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/stock_wood
	result_amount = 1
	reqs = list(
		/obj/item/machining_intermediates/shapedwood = 2,
	)

/datum/machining_recipe/stock_polymer
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/stock_polymer
	result_amount = 1
	reqs = list(
		/obj/item/machining_intermediates/moltenplastic = 2,
	)

/datum/machining_recipe/triggermechanism
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/trigger
	reqs = list(
		/obj/item/stack/sheet/iron = 3,
		/obj/item/stack/machining_intermediates/screwbolt = 2,
		/obj/item/machining_intermediates/moltenplastic = 1,
		/obj/item/stack/machining_intermediates/smallwire = 4,
	)
	machining_skill_required = 2

/datum/machining_recipe/bolt
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/firearm_bolt
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/gunbarrel_pistol
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/gunbarrel_pistol
	reqs = list(
		/obj/item/stack/machining_intermediates/steel = 2,
	)
	machining_skill_required = 3

/datum/machining_recipe/gunbarrel_rifle
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/gunbarrel_rifle
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 4,
	)
	machining_skill_required = 4

/datum/machining_recipe/gunbarrel_smootbore
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/gunbarrel_smootbore
	reqs = list(
		/obj/item/stack/machining_intermediates/steel = 4,
	)
	machining_skill_required = 3

/datum/machining_recipe/bullet_small_casing
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_small_casing
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
	)
	machining_skill_required = 2

/datum/machining_recipe/bullet_large_casing
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_large_casing
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
	)
	machining_skill_required = 2

/datum/machining_recipe/bullet_small
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_small
	result_amount = 6
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/machining_intermediates/bullet_small_casing = 1,
	)
	machining_skill_required = 2

/datum/machining_recipe/bullet_large
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_large
	result_amount = 6
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/machining_intermediates/bullet_large_casing = 1,
	)
	machining_skill_required = 2
