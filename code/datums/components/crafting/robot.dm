/datum/crafting_recipe/ed209
	name = "ED209"
	result = /mob/living/simple_animal/bot/secbot/ed209
	reqs = list(
		/obj/item/robot_suit = 1,
		/obj/item/clothing/head/helmet = 1,
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/bodypart/leg/left/robot = 1,
		/obj/item/bodypart/leg/right/robot = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/assembly/prox_sensor = 1,
	)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 6 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/secbot
	name = "Secbot"
	result = /mob/living/simple_animal/bot/secbot
	reqs = list(
		/obj/item/assembly/signaler = 1,
		/obj/item/clothing/head/helmet/sec = 1,
		/obj/item/melee/baton/security/ = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/arm/right/robot = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	time = 6 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/cleanbot
	name = "Cleanbot"
	result = /mob/living/basic/bot/cleanbot
	reqs = list(
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/arm/right/robot = 1,
	)
	parts = list(/obj/item/reagent_containers/cup/bucket = 1)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/floorbot
	name = "Floorbot"
	result = /mob/living/simple_animal/bot/floorbot
	reqs = list(
		/obj/item/storage/toolbox = 1,
		/obj/item/stack/tile/iron = 10,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/arm/right/robot = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/medbot
	name = "Medbot"
	result = /mob/living/basic/bot/medbot
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/medkit = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/arm/right/robot = 1,
	)
	parts = list(
		/obj/item/storage/medkit = 1,
		/obj/item/healthanalyzer = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/medbot/on_craft_completion(mob/user, atom/result)
	var/mob/living/basic/bot/medbot/bot = result
	var/obj/item/storage/medkit/medkit = bot.contents[3]
	bot.medkit_type = medkit
	bot.health_analyzer = bot.contents[4]

	if (istype(medkit, /obj/item/storage/medkit/fire))
		bot.skin = "ointment"
	else if (istype(medkit, /obj/item/storage/medkit/toxin))
		bot.skin = "tox"
	else if (istype(medkit, /obj/item/storage/medkit/o2))
		bot.skin = "o2"
	else if (istype(medkit, /obj/item/storage/medkit/brute))
		bot.skin = "brute"
	else if (istype(medkit, /obj/item/storage/medkit/advanced))
		bot.skin = "advanced"

	bot.damage_type_healer = initial(medkit.damagetype_healed) ? initial(medkit.damagetype_healed) : BRUTE
	bot.update_appearance()

/datum/crafting_recipe/honkbot
	name = "Honkbot"
	result = /mob/living/simple_animal/bot/secbot/honkbot
	reqs = list(
		/obj/item/storage/box/clown = 1,
		/obj/item/bodypart/arm/right/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bikehorn = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/firebot
	name = "Firebot"
	result = /mob/living/simple_animal/bot/firebot
	reqs = list(
		/obj/item/extinguisher = 1,
		/obj/item/bodypart/arm/right/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/clothing/head/utility/hardhat/red = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/vibebot
	name = "Vibebot"
	result = /mob/living/simple_animal/bot/vibebot
	reqs = list(
		/obj/item/light/bulb = 2,
		/obj/item/bodypart/head/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/toy/crayon = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/hygienebot
	name = "Hygienebot"
	result = /mob/living/basic/bot/hygienebot
	reqs = list(
		/obj/item/bot_assembly/hygienebot = 1,
		/obj/item/stack/ducts = 1,
		/obj/item/assembly/prox_sensor = 1,
	)
	tool_behaviors = list(TOOL_WELDER)
	time = 4 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/vim
	name = "Vim"
	result = /obj/vehicle/sealed/car/vim
	reqs = list(
		/obj/item/clothing/head/helmet/space/eva = 1,
		/obj/item/bodypart/leg/left/robot = 1,
		/obj/item/bodypart/leg/right/robot = 1,
		/obj/item/flashlight = 1,
		/obj/item/assembly/voice = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 6 SECONDS //Has a four second do_after when building manually
	category = CAT_ROBOT

/datum/crafting_recipe/aitater
	name = "intelliTater"
	result = /obj/item/aicard/aitater
	time = 3 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/aicard = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/stack/cable_coil = 5,
	)
	parts = list(/obj/item/aicard = 1)
	category = CAT_ROBOT

/datum/crafting_recipe/aitater/aispook
	name = "intelliLantern"
	result = /obj/item/aicard/aispook
	reqs = list(
		/obj/item/aicard = 1,
		/obj/item/food/grown/pumpkin = 1,
		/obj/item/stack/cable_coil = 5,
	)

/datum/crafting_recipe/aitater/on_craft_completion(mob/user, atom/result)
	var/obj/item/aicard/new_card = result
	var/obj/item/aicard/base_card = result.contents[1]
	var/mob/living/silicon/ai = base_card.AI

	if(ai)
		base_card.AI = null
		ai.forceMove(new_card)
		new_card.AI = ai
		new_card.update_appearance()
	qdel(base_card)

/datum/crafting_recipe/mod_core_standard
	name = "MOD core (Standard)"
	result = /obj/item/mod/core/standard
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/organ/internal/heart/ethereal = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/mod_core_ethereal
	name = "MOD core (Ethereal)"
	result = /obj/item/mod/core/ethereal
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 10 SECONDS
	reqs = list(
		/datum/reagent/consumable/liquidelectricity = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/syringe = 1,
	)
	category = CAT_ROBOT

// Kingspire parts

/datum/crafting_recipe/kingspire_engine
	name = "Kingspire Mk.1 Engine"
	result = /obj/item/mecha_parts/part/kingspire_right_arm
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH)
	time = 30 SECONDS
	reqs = list(
		/datum/reagent/fuel/oil = 20,
		/obj/item/stack/cable_coil = 60,
		/obj/item/stack/rods = 8,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/assembly/igniter = 6,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_cupola
	name = "Kingspire Mk.1 Drivers cupola"
	result = /obj/item/mecha_parts/part/kingspire_torso
	tool_behaviors = list(TOOL_WELDER)
	time = 15 SECONDS
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/sheet/plasteel = 10,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_transmission
	name = "Kingspire Mk.1 transmission"
	result = /obj/item/mecha_parts/part/kingspire_left_arm
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 20 SECONDS
	reqs = list(
		/datum/reagent/fuel/oil = 20,
		/obj/item/stack/rods = 12,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/iron = 10,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_turret
	name = "Kingspire Mk.1 Turret"
	result = /obj/item/mecha_parts/part/kingspire_armor
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 30 SECONDS
	reqs = list(
		/obj/item/gun/ballistic/automatic/malone = 1,
		/obj/item/stack/rods = 4,
		/obj/item/pipe = 2,
		/obj/item/stack/sheet/plasteel = 20,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_ltrack
	name = "Kingspire Mk.1 <b>LEFT</b> Track"
	result = /obj/item/mecha_parts/part/kingspire_left_leg
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/rods = 16,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/conveyor = 4,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_rtrack
	name = "Kingspire Mk.1 <b>RIGHT</b> Track"
	result = /obj/item/mecha_parts/part/kingspire_right_leg
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/rods = 16,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/conveyor = 4,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_hydraulics
	name = "Kingspire Mk.1 Hydraulic equipment"
	result = /obj/item/circuitboard/mecha/kingspire/peripherals
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 10 SECONDS
	reqs = list(
		/datum/reagent/fuel/oil = 10,
		/obj/item/stack/rods = 2,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/stock_parts/manipulator = 2,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_seats
	name = "Kingspire Mk.1 Seating"
	result = /obj/item/circuitboard/mecha/kingspire/targeting
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/sheet/cloth = 10,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/kingspire_radio
	name = "Kingspire Mk.1 Radio set"
	result = /obj/item/circuitboard/mecha/kingspire/main
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/cable_coil = 20,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/light/tube = 2,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/radio = 2,
	)
	category = CAT_ROBOT

// T5 Percutio crafts

/datum/crafting_recipe/percutio_engine
	name = "T5 Percutio Engine"
	result = /obj/item/mecha_parts/part/percutio_right_arm
	tool_behaviors = list(TOOL_WELDER)
	time = 15 SECONDS
	reqs = list(
		/datum/reagent/fuel/oil = 20,
		/obj/item/stack/cable_coil = 40,
		/obj/item/stack/rods = 6,
		/obj/item/pipe = 6,
		/obj/item/stack/sheet/plasteel = 8,
		/obj/item/assembly/igniter = 6,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_lights
	name = "T5 Percutio Headlights"
	result = /obj/item/mecha_parts/part/percutio_left_arm
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_CROWBAR)
	time = 20 SECONDS
	reqs = list(
		/obj/item/light/bulb = 2,
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/iron = 4,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_turret
	name = "T5 Percutio Turret"
	result = /obj/item/mecha_parts/part/percutio_armor
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 30 SECONDS
	reqs = list(
		/obj/item/gun/ballistic/automatic/neville = 1,
		/obj/item/stack/rods = 6,
		/obj/item/pipe = 2,
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_wheels
	name = "T5 Percutio Wheels"
	result = /obj/item/mecha_parts/part/percutio_left_leg
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/rods = 16,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/sheet/plastic = 20,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_transmission
	name = "T5 Percutio transmission"
	result = /obj/item/mecha_parts/part/percutio_right_leg
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 20 SECONDS
	reqs = list(
		/datum/reagent/fuel/oil = 20,
		/obj/item/stack/rods = 20,
		/obj/item/pipe = 6,
		/obj/item/stack/sheet/iron = 8,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_hydraulics
	name = "T5 Percutio Hydraulic equipment"
	result = /obj/item/circuitboard/mecha/percutio/peripherals
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 10 SECONDS
	reqs = list(
		/datum/reagent/fuel/oil = 20,
		/obj/item/stack/rods = 2,
		/obj/item/pipe = 6,
		/obj/item/stack/sheet/iron = 12,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_seats
	name = "T5 Percutio Seating"
	result = /obj/item/circuitboard/mecha/percutio/targeting
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/pipe = 6,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/sheet/cloth = 10,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/percutio_tank
	name = "T5 Percutio Fuel tank"
	result = /obj/item/circuitboard/mecha/percutio/main
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 15,
		/obj/item/light/tube = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/stockade_chassis
	name = "Balfour Stockade Carriage"
	always_available = FALSE
	result = /obj/item/mecha_parts/chassis/stockade
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/stack/rods = 20,
		/obj/item/pipe = 4,
		/obj/item/stack/sheet/cloth = 2,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/stockade_larm
	name = "Balfour Stockade Gunshield"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/stockade_left_arm
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/sheet/plasteel = 20,
		/obj/item/stack/rods = 5,
		/obj/item/pipe = 4,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/stockade_rarm
	name = "Balfour Stockade Ammo fabrication device"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/stockade_right_arm
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/plastitanium = 10,
		/obj/item/stock_parts/manipulator = 6,
		/obj/item/pipe = 4,
		/datum/reagent/fuel/oil = 20,
		/datum/reagent/gunpowder = 100,
		/obj/item/stack/sheet/bluespace_crystal = 5,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/stockade_lleg
	name = "Balfour Stockade Wheels"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/stockade_left_leg
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 20,
		/obj/item/stack/sheet/iron = 15,
		/obj/item/pipe = 4,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/stockade_armor
	name = "Balfour Stockade 75mm Cannon"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/stockade_armor
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/plastitanium = 10,
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/sheet/plasteel = 20,
		/obj/item/pipe = 8,
		/obj/item/stack/cable_coil = 5,
		/obj/item/assembly/igniter = 1,
	)
	category = CAT_ROBOT
