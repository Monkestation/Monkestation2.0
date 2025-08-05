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


// vendozer crafts, needs book, 6 parts Plus assembly

/datum/crafting_recipe/vendozer
	name = "The Vendozer"
	always_available = FALSE
	result = /obj/vehicle/sealed/mecha/vendozer
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/conveyor = 30,
		/obj/item/stack/sheet/plasteel = 20,
		/obj/item/stack/cable_coil = 20,
		/obj/item/mecha_parts/part/vendozer_fl = 1,
		/obj/item/mecha_parts/part/vendozer_fr = 1,
		/obj/item/mecha_parts/part/vendozer_bl = 1,
		/obj/item/mecha_parts/part/vendozer_br = 1,
		/obj/item/mecha_parts/part/vendozer_eg = 1,
		/obj/item/mecha_parts/part/vendozer_ck = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/vendozer_fl
	name = "Vendozer Front Left Armor Parts"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/vendozer_fl
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 10 SECONDS
	machinery = list(/obj/machinery/vending/tool  = CRAFTING_MACHINERY_CONSUME,/obj/machinery/vending/wardrobe/sec_wardrobe = CRAFTING_MACHINERY_CONSUME)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 15,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/pipe = 6,
		/obj/item/stack/cable_coil = 30,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/vendozer_fr
	name = "Vendozer Front Right Armor Parts"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/vendozer_fr
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 10 SECONDS
	machinery = list(/obj/machinery/vending/cola = CRAFTING_MACHINERY_CONSUME)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 20,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/pipe = 6,
		/obj/item/stack/cable_coil = 30,
		/obj/item/toy/crayon/spraycan = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/vendozer_bl
	name = "Vendozer Back Left Armor Parts"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/vendozer_bl
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 10 SECONDS
	machinery = list(/obj/machinery/vending/drugs = CRAFTING_MACHINERY_CONSUME)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 10,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/cable_coil = 45,
		/obj/item/extinguisher = 2,
		/obj/item/stack/sticky_tape = 5,
		/obj/item/light/tube = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/vendozer_br
	name = "Vendozer Back Right Armor Parts"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/vendozer_br
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 10 SECONDS
	machinery = list(/obj/machinery/vending/snack = CRAFTING_MACHINERY_CONSUME)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 30,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/cable_coil = 15,
		/obj/item/extinguisher = 2,
		/obj/item/stack/sticky_tape = 5,
		/obj/item/light/tube = 1,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/vendozer_eg
	name = "Vendozer Turbine Engine"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/vendozer_eg
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 30 SECONDS
	machinery = list(/obj/machinery/power/turbine/inlet_compressor/constructed  = CRAFTING_MACHINERY_CONSUME, /obj/machinery/power/turbine/core_rotor/constructed  = CRAFTING_MACHINERY_CONSUME, /obj/machinery/power/turbine/turbine_outlet/constructed = CRAFTING_MACHINERY_CONSUME)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 30,
		/obj/item/tank/internals/oxygen = 10,
		/obj/item/stack/sheet/plasteel = 20,
		/obj/item/stack/cable_coil = 60,
		/obj/item/extinguisher = 2,
		/obj/item/stack/sticky_tape = 5,
		/obj/item/light/tube = 4,
		/obj/item/pipe = 10,
	)
	category = CAT_ROBOT

/datum/crafting_recipe/vendozer_ck
	name = "Vendozer Cabin"
	always_available = FALSE
	result = /obj/item/mecha_parts/part/vendozer_ck
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_CROWBAR)
	time = 30 SECONDS
	machinery = list(/obj/machinery/computer/security  = CRAFTING_MACHINERY_CONSUME, /obj/machinery/oven  = CRAFTING_MACHINERY_CONSUME)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 10,
		/obj/item/clothing/mask/gas = 3,
		/obj/item/wallframe/camera = 5,
		/obj/item/stack/sheet/rglass = 10,
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/stack/cable_coil = 20,
		/obj/item/radio = 2,
		/obj/item/gun/ballistic/rifle/boltaction/pipegun = 2,
		/obj/item/light/bulb = 4,
	)
	category = CAT_ROBOT
