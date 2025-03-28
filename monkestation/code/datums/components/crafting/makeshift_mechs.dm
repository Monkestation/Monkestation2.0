/datum/crafting_recipe/lockermech
	name = "Locker Mech"
	result = /obj/vehicle/sealed/mecha/working/ripley/lockermech
	reqs = list(/obj/item/stack/cable_coil = 20,
				/obj/item/stack/sheet/iron = 10,
				/obj/item/storage/toolbox = 2, // For feet
				/obj/item/tank/internals/oxygen = 1, // For air
				/obj/item/electronics/airlock = 1, //You are stealing the motors from airlocks
				/obj/item/extinguisher = 1, //For bastard pnumatics
				/obj/item/paper = 5, //Cause paper is the best for making a mech airtight obviously
				/obj/item/flashlight = 1, //For the mech light
				/obj/item/stack/rods = 4, //to mount the equipment
				/obj/item/chair = 2) //For legs
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 20 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechdrill
	name = "Makeshift exosuit drill"
	result = /obj/item/mecha_parts/mecha_equipment/drill/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/surgicaldrill = 1)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechclamp
	name = "Makeshift exosuit clamp"
	result = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/wirecutters = 1) //Don't ask, its just for the grabby grabby thing
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/ambulance
	name = "Porta Potty Ambulance"
	result = /obj/vehicle/sealed/mecha/working/makeshift_ambulance
	reqs = list(/obj/item/stack/sheet/iron = 30,
		/obj/item/chair = 2,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stack/sheet/cloth = 10,
		/obj/item/stock_parts/cell = 2,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/light/tube,
		/obj/item/toy/crayon/spraycan,
		)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH)
	time = 20 SECONDS
	category = CAT_ROBOT
