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
	result = /obj/vehicle/sealed/mecha/makeshift_ambulance
	reqs = list(/obj/item/stack/sheet/iron = 30,
		/obj/item/chair = 2,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stack/sheet/cloth = 10,
		/obj/item/stock_parts/cell = 2,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/light/tube = 1,
		/obj/item/toy/crayon/spraycan = 1,
		)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/makeshift_sleeper
	name = "Makeshift Sleeper Module"
	result = /obj/item/mecha_parts/mecha_equipment/medical/sleeper/makeshift
	reqs = list(/obj/item/stock_parts/cell = 1,
		/obj/item/stack/sheet/cloth = 5,
		/obj/item/stack/rods = 10,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/syringe = 1,
		)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/harm_alarm
	name = "Harm Alarm Horn Module"
	result = /obj/item/mecha_parts/mecha_equipment/weapon/honker/makeshift
	reqs = list(/obj/item/stack/sheet/iron = 2,
			/obj/item/stack/cable_coil = 15,
			/obj/item/stock_parts/manipulator = 1,
		)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/scrap_tank
	name = "Trash Tank"
	result = /obj/vehicle/sealed/mecha/trash_tank
	reqs = list(/obj/item/flashlight = 1,
			/obj/item/tank/internals/plasma = 2,
			/obj/item/tank/internals/oxygen = 8,
			/obj/item/stack/cable_coil = 60,
			/obj/item/camera = 1,
			/obj/item/storage/toolbox = 5,
			/obj/item/pipe = 4,
			/obj/item/chair = 1,
			/obj/item/stack/sheet/cloth = 10,
			/obj/item/stack/conveyor = 5,
			/obj/item/stock_parts/cell = 1,
		)
	machinery = list(/obj/machinery/disposal/bin = CRAFTING_MACHINERY_CONSUME)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 20 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/pipegun_breech
	name = "Pipegun Breech"
	result = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/pipegun
	reqs = list(/obj/item/gun/ballistic/rifle/boltaction/pipegun = 1,
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/sheet/glass = 4,
		/obj/item/storage/toolbox = 1,
		)
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/peashooter_breech
	name = "Peahooter Breech"
	result = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/peashooter
	reqs = list(/obj/item/pipe = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 10,
		/obj/item/extinguisher = 1,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/sheet/glass = 4,
		)
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/tank_armor_plating
	name = "Trash Tank Armor Plating"
	result = /obj/item/mecha_parts/mecha_equipment/tankupgrade
	reqs = list(/obj/item/pipe = 20,
		/obj/item/stack/sheet/mineral/wood = 15,
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/cable_coil = 20,
		/obj/item/storage/toolbox = 2,
		/obj/item/tank/internals/oxygen = 3,
		/obj/item/chair = 2,
		)
	tool_behaviors = list(TOOL_WELDER, TOOL_WIRECUTTER, TOOL_CROWBAR)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/pipegun_tank_ammo
	name = "Trash Tank Pipegun Ammobox"
	result = /obj/item/mecha_ammo/makeshift
	reqs = list(/datum/reagent/fuel = 50,
		/obj/item/stack/sheet/iron = 30,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 0.5 SECONDS

/datum/crafting_recipe/peashooter_tank_ammo
	name = "Trash Tank Peashooter Ammobox"
	result = /obj/item/mecha_ammo/makeshift/peashooter
	reqs = list(/datum/reagent/fuel = 30,
		/obj/item/stack/sheet/iron = 20,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 0.5 SECONDS

/datum/crafting_recipe/isg_tank
	name = "Infantry Support Gun Mantlet"
	result = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/infantry_support_gun
	reqs = list(/obj/item/pipe = 4,
		/obj/item/tank/internals/oxygen = 2,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stack/sheet/plasteel = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_WRENCH, TOOL_WIRECUTTER)
	time = 5 SECONDS

/datum/crafting_recipe/isg_tank_ammo
	name = "Infantry Support Gun Ammo"
	result = /obj/item/mecha_ammo/makeshift/isg
	reqs = list(/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/grenade/iedcasing = 3
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER, TOOL_WIRECUTTER)
	time = 0.5 SECONDS
