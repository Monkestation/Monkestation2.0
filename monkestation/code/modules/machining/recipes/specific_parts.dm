//specific parts
/datum/machining_recipe/suitsensors
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/suitsensors
	reqs = list(
		/obj/item/machining_intermediates/universalcircuit = 2,
		/obj/item/stack/machining_intermediates/smallwire = 4,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/cloth = 2,
	)

/datum/machining_recipe/dyes
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_FURNACE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/dye
	reqs = list(
		/obj/item/machining_intermediates/moltenplastic = 2,
	)

/datum/machining_recipe/shoes
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/shoes/sneakers/black
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/machining_intermediates/insulation = 1,
	)

/datum/machining_recipe/jumpsuit
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/under/color/grey
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/machining_intermediates/insulation = 1,
		/obj/item/machining_intermediates/sewingsupplies = 1,
		/obj/item/machining_intermediates/suitsensors = 1,
	)

/datum/machining_recipe/winterjacket
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/suit/hooded/wintercoat
	reqs = list(
		/obj/item/stack/sheet/cloth = 8,
		/obj/item/machining_intermediates/insulation = 4,
		/obj/item/machining_intermediates/sewingsupplies = 2,
	)
	machining_skill_required = 2

/datum/machining_recipe/hardened_exosuit_parts
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DROPHAMMER
	crafting_time = MACHINING_DELAY_SLOW
	result = /obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/machining_intermediates/steel = 10,
		/obj/item/machining_intermediates/moltenplastic = 2,
	)
	machining_skill_required = 3

/datum/machining_recipe/hardened_exosuit_plating
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DROPHAMMER
	crafting_time = MACHINING_DELAY_SLOW
	result = /obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/machining_intermediates/hardsteel = 8,
		/obj/item/stack/machining_intermediates/steel = 4,
	)
	machining_skill_required = 4

/datum/machining_recipe/slidepistol
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/slidepistol
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/machining_intermediates/screwbolt = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/firearm_hammer
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/firearm_hammer
	reqs = list(
		/obj/item/stack/machining_intermediates/steel = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/lens
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/lens
	reqs = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/machining_intermediates/universalcircuit = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/lasercavity
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/lasercavity
	reqs = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/machining_intermediates/universalcircuit = 1,
		/obj/item/stock_parts/micro_laser = 4,
	)
	machining_skill_required = 2

/datum/machining_recipe/crappyring
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/machining_intermediates/crappyring
	reqs = list(
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/stack/sheet/mineral/titanium = 1,
	)
	machining_skill_required = 2

/datum/machining_recipe/fancyring
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/machining_intermediates/fancyring
	reqs = list(
		/obj/item/stack/sheet/mineral/gold = 2,
		/obj/item/stack/sheet/mineral/titanium = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/axehead
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/axehead
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 10,
	)
	machining_skill_required = 4

/datum/machining_recipe/bodyarmor
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/suit/armor/vest
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/machining_intermediates/softarmor = 4,
		/obj/item/stack/sheet/leather = 2,
		/obj/item/machining_intermediates/sewingsupplies = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/helmet
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/head/helmet
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/machining_intermediates/softarmor = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/machining_intermediates/sewingsupplies = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/bodyarmor_bulletproof
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/suit/armor/bulletproof
	reqs = list(
		/obj/item/machining_intermediates/hardarmor = 2,
		/obj/item/machining_intermediates/softarmor = 4,
		/obj/item/stack/sheet/cloth = 6,
		/obj/item/machining_intermediates/sewingsupplies = 2,
	)
	machining_skill_required = 4

/datum/machining_recipe/helmet_bulletproof
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_TAILOR
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/clothing/head/helmet/alt
	reqs = list(
		/obj/item/machining_intermediates/hardarmor = 2,
		/obj/item/machining_intermediates/softarmor = 2,
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/rglass = 2,
		/obj/item/machining_intermediates/sewingsupplies = 2,
	)
	machining_skill_required = 4

/datum/machining_recipe/forged_exosuit_parts
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DROPHAMMER
	crafting_time = MACHINING_DELAY_SLOW
	result = /obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part/forged
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 8,
		/obj/item/stack/machining_intermediates/smallwire = 10,
		/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_part = 1,
		/obj/item/machining_intermediates/suitsensors = 1,
	)
	machining_skill_required = 3

/datum/machining_recipe/forged_exosuit_plating
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DROPHAMMER
	crafting_time = MACHINING_DELAY_SLOW
	result = /obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate/forged
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/machining_intermediates/steel = 10,
		/obj/item/mecha_parts/mecha_equipment/armor/hardened_exosuit_plate = 1,
		/obj/item/stack/sheet/mineral/gold = 2,
		/obj/item/stack/sheet/mineral/silver = 2,
		/obj/item/stack/sheet/mineral/titanium = 8,
	)
	machining_skill_required = 4
