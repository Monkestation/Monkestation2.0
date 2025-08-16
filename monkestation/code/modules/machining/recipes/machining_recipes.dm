//init functions
/proc/init_machining_recipes()
	. = list()
	for(var/type in subtypesof(/datum/machining_recipe))
		. += new type

/proc/init_machining_recipes_atoms()
	. = list()
	for(var/datum/machining_recipe/recipe as anything in GLOB.machining_recipes)
		// Result
		. |= recipe.result
		// Ingredients
		for(var/atom/req_atom as anything in recipe.reqs)
			. |= req_atom

///Representative icons for the contents of each crafting recipe
/datum/asset/spritesheet_batched/crafting/machining
	name = "machining"

/datum/asset/spritesheet_batched/crafting/machining/create_spritesheets()
	var/id = 1
	for(var/atom in GLOB.machining_recipes_atoms)
		add_atom_icon(atom, id++)

//base object for all machining recipes
/datum/machining_recipe
	//in-game display name. Optional, if not set uses result name
	var/name
	///description displayed in game. Optional, if not set uses result desc
	var/desc
	///type paths of items consumed associated with how many are needed
	var/list/reqs = list()
	///type path of item resulting from this craft
	var/result
	///where it shows up in the crafting UI
	var/category = TAB_GENERAL_PARTS
	///What machining machine it belongs to
	var/machinery_type = MACHINING_LATHE
	///how much time it takes to craft
	var/crafting_time = MACHINING_DELAY_NORMAL
	///how much item to pop out
	var/result_amount = 1
	///determines if the recipe requires specific levels of parts. (ie specifically a femto menipulator vs generic manipulator)
	var/specific_parts = FALSE
	///what tier of machinery required to craft this recipe
	var/upgrade_tier_required = 1
	///what tier of skill required to craft this recipe
	var/machining_skill_required = 0

/datum/machining_recipe/New()
	if(!result)
		return
	var/atom/atom_result = result
	if(!name && result)
		name = capitalize("[initial(atom_result.name)]")
	if(!desc && result)
		desc = initial(atom_result.desc)


///Additional UI data to be passed to the crafting UI for this recipe
/datum/machining_recipe/proc/crafting_ui_data()
	return list()

//recipes for realsies
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

//Type parts
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
	upgrade_tier_required = 2

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
	upgrade_tier_required = 2

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
	upgrade_tier_required = 2

/datum/machining_recipe/bolt
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/firearm_bolt
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 1,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/gunbarrel_pistol
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/gunbarrel_pistol
	reqs = list(
		/obj/item/stack/machining_intermediates/steel = 2,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/gunbarrel_rifle
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/gunbarrel_rifle
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 4,
	)
	upgrade_tier_required = 4

/datum/machining_recipe/gunbarrel_smootbore
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/gunbarrel_smootbore
	reqs = list(
		/obj/item/stack/machining_intermediates/steel = 4,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/bullet_small_casing
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_small_casing
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
	)
	upgrade_tier_required = 2

/datum/machining_recipe/bullet_large_casing
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_large_casing
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
	)
	upgrade_tier_required = 2

/datum/machining_recipe/bullet_small
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_small
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
	)
	upgrade_tier_required = 2

/datum/machining_recipe/bullet_large
	category = TAB_TYPE_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_large
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
	)
	upgrade_tier_required = 2

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
	upgrade_tier_required = 2

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
	upgrade_tier_required = 3

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
	upgrade_tier_required = 4

/datum/machining_recipe/slidepistol
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/slidepistol
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/machining_intermediates/screwbolt = 1,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/firearm_hammer
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/firearm_hammer
	reqs = list(
		/obj/item/stack/machining_intermediates/steel = 1,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/bullet_small_ap
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_small_ap
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 1,
	)
	upgrade_tier_required = 4
	result_amount = 6

/datum/machining_recipe/bullet_large_ap
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_VERY_FAST
	result = /obj/item/machining_intermediates/bullet_large_ap
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 1,
	)
	upgrade_tier_required = 4
	result_amount = 12

/datum/machining_recipe/lens
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_DRILLPRESS
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/lens
	reqs = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/machining_intermediates/universalcircuit = 1,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/crappyring
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/machining_intermediates/crappyring
	reqs = list(
		/obj/item/stack/sheet/mineral/silver = 3,
		/obj/item/stack/sheet/mineral/titanium = 1,
	)
	upgrade_tier_required = 2

/datum/machining_recipe/fancyring
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_FAST
	result = /obj/item/machining_intermediates/fancyring
	reqs = list(
		/obj/item/stack/sheet/mineral/gold = 3,
		/obj/item/stack/sheet/mineral/titanium = 1,
	)
	upgrade_tier_required = 3

/datum/machining_recipe/axehead
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_LATHE
	crafting_time = MACHINING_DELAY_NORMAL
	result = /obj/item/machining_intermediates/axehead
	reqs = list(
		/obj/item/stack/machining_intermediates/hardsteel = 5,
	)
	upgrade_tier_required = 4

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
	upgrade_tier_required = 3

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
	upgrade_tier_required = 3

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
	upgrade_tier_required = 4

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
	upgrade_tier_required = 4

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
	upgrade_tier_required = 3

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
	upgrade_tier_required = 4

/datum/machining_recipe/mosin
	category = TAB_SPECIFIC_PARTS
	machinery_type = MACHINING_WORKSTATION
	crafting_time = MACHINING_DELAY_EXCRUCIATINGLY_SLOW
	result = /obj/item/gun/ballistic/rifle/boltaction
	reqs = list(
		/obj/item/machining_intermediates/stock_wood = 1,
		/obj/item/machining_intermediates/gunbarrel_rifle = 1,
		/obj/item/machining_intermediates/firearm_bolt = 2,
		/obj/item/stack/sheet/mineral/wood = 4,
		/obj/item/stack/machining_intermediates/screwbolt = 6,
	)
	upgrade_tier_required = 4

/datum/machining_recipe/wylom_amr
    name = "Wylom AMR"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/automatic/wylom
    reqs = list(
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/machining_intermediates/gunbarrel_rifle = 1,
        /obj/item/machining_intermediates/firearm_bolt = 2,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/machining_intermediates/hardsteel = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    upgrade_tier_required = 5

/datum/machining_recipe/wylom_magazine
    name = "Wylom Magazine"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/ammo_box/magazine/wylom
    reqs = list(
        /obj/item/machining_intermediates/moltenplastic = 4,
        /obj/item/stack/rods = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
    )
    upgrade_tier_required = 5

/datum/machining_recipe/c20r
    name = "C-20r"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/automatic/c20r/unrestricted
    reqs = list(
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/machining_intermediates/gunbarrel_rifle = 1,
        /obj/item/machining_intermediates/firearm_bolt = 2,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/machining_intermediates/hardsteel = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
        /obj/item/machining_intermediates/moltenplastic = 2,
		/obj/item/machining_intermediates/bullet_large_ap = 12,
    )
    upgrade_tier_required = 5

/datum/machining_recipe/c20r_magazine
    name = "C-20r Magazine"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/ammo_box/magazine/smgm45
    reqs = list(
        /obj/item/machining_intermediates/moltenplastic = 4,
        /obj/item/stack/rods = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/machining_intermediates/bullet_large_ap = 12,
    )
    upgrade_tier_required = 5

/datum/machining_recipe/revolver_38
    name = ".38 Revolver"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/revolver/c38
    reqs = list(
        /obj/item/machining_intermediates/firearm_hammer = 1,
        /obj/item/machining_intermediates/gunbarrel_pistol = 1,
        /obj/item/machining_intermediates/handle_wood = 1,
        /obj/item/stack/machining_intermediates/steel = 4,
        /obj/item/machining_intermediates/trigger = 1,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/machining_intermediates/bullet_small = 6,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/paco_pistol
    name = "Paco Pistol"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/automatic/pistol/paco/no_mag
    reqs = list(
        /obj/item/machining_intermediates/firearm_bolt = 1,
        /obj/item/machining_intermediates/gunbarrel_pistol = 1,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/machining_intermediates/steel = 4,
        /obj/item/machining_intermediates/trigger = 1,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/paco_magazine
    name = "Paco Magazine"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/ammo_box/magazine/m35
    reqs = list(
        /obj/item/machining_intermediates/moltenplastic = 2,
        /obj/item/stack/rods = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/machining_intermediates/bullet_small = 12,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/disabler_pistol
    name = "Disabler Pistol"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/energy/disabler
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 1,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/machining_intermediates/universalcircuit = 1,
        /obj/item/stock_parts/cell = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 6,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/laser_gun
    name = "Laser Gun"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/energy/laser
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 2,
        /obj/item/machining_intermediates/lens = 1,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/machining_intermediates/universalcircuit = 2,
        /obj/item/stock_parts/cell = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    upgrade_tier_required = 4

/datum/machining_recipe/energy_gun
    name = "Energy Gun"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/energy
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 2,
        /obj/item/machining_intermediates/lens = 2,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/machining_intermediates/universalcircuit = 3,
        /obj/item/stock_parts/cell = 1,
        /obj/item/stack/machining_intermediates/smallwire = 8,
        /obj/item/stack/machining_intermediates/screwbolt = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    upgrade_tier_required = 4

/datum/machining_recipe/makeshift_pulse_gun
    name = "Makeshift Pulse Gun"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_EXCRUCIATINGLY_SLOW
    result = /obj/item/pulsepack
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 8,
        /obj/item/machining_intermediates/lens = 6,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/machining_intermediates/universalcircuit = 4,
        /obj/item/stack/machining_intermediates/hardsteel = 4,
        /obj/item/machining_intermediates/moltenplastic = 6,
    )
    upgrade_tier_required = 5

//etc
/datum/machining_recipe/knockoff_jewelry
    name = "Knockoff Jewelry"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/machining_intermediates/crappyring
    reqs = list(
        /obj/item/machining_intermediates/crappyring = 1,
        /obj/item/stack/sheet/glass = 2,
    )
    upgrade_tier_required = 2

/datum/machining_recipe/quality_jewelry
    name = "Quality Jewelry"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/machining_intermediates/fancyring
    reqs = list(
        /obj/item/machining_intermediates/fancyring = 1,
        /obj/item/stack/sheet/mineral/diamond = 1,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/artisan_jewelry
    name = "Artisan Jewelry"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/machining_intermediates/fancyring
    reqs = list(
        /obj/item/machining_intermediates/fancyring = 1,
        /obj/item/stack/sheet/mineral/gold = 1,
        /obj/item/stack/sheet/mineral/diamond = 3,
    )
    upgrade_tier_required = 4

/datum/machining_recipe/gas_pump
    name = "Gas Pump"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/machinery/portable_atmospherics/pump
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 6,
        /obj/item/stack/sheet/iron = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
    )
    upgrade_tier_required = 2

/datum/machining_recipe/portable_scrubber
    name = "Portable Scrubber"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/machinery/portable_atmospherics/scrubber
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 8,
        /obj/item/stack/sheet/iron = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 6,
    )
    upgrade_tier_required = 2

/datum/machining_recipe/jaws_of_life
    name = "Jaws of Life"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/crowbar/power
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 4,
        /obj/item/stack/machining_intermediates/steel = 2,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
        /obj/item/machining_intermediates/universalcircuit = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/machining_intermediates/handle_polymer = 2,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/hand_drill
    name = "Hand Drill"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/screwdriver/power
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 2,
        /obj/item/stack/machining_intermediates/steel = 1,
        /obj/item/stack/sheet/iron = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
        /obj/item/machining_intermediates/universalcircuit = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/machining_intermediates/handle_polymer = 1,
    )
    upgrade_tier_required = 3

/datum/machining_recipe/fire_axe
    name = "Fire Axe"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/fireaxe
    reqs = list(
        /obj/item/machining_intermediates/axehead = 1,
        /obj/item/machining_intermediates/handle_wood = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
        /obj/item/machining_intermediates/dye = 1,
    )
    upgrade_tier_required = 4

/datum/machining_recipe/sledgehammer
    name = "Sledgehammer"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/melee/sledgehammer
    reqs = list(
        /obj/item/stack/machining_intermediates/steel = 4,
        /obj/item/machining_intermediates/handle_wood = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
    )
    upgrade_tier_required = 2
