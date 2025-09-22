
//spawners and jobs

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon
	name = "syndicate cryogenic sleeper"
	desc = "A reinforced, quadruple-redundant stasis sleeper used by Syndicate forces. You've got no hope of cracking it open."
	prompt_name = "a syndicate agent"
	you_are_text = "You are a Syndicate operative, assigned to an outpost in the frigid wastes of the icemoon."
	flavour_text = "Monitor Nanotrasen activity from afar and protect your base no matter the cost. Do not let it fall into enemy hands."
	important_text = "DO NOT go near active Nanotrasen holdings or personnel, and do not leave the base unless absolutely necessary."
	outfit = /datum/outfit/icemoon_syndicate

/datum/outfit/icemoon_syndicate
	name = "Icemoon Syndicate Agent"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate/coldres
	suit = /obj/item/clothing/suit/hooded/wintercoat/nova/syndicate
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	neck = /obj/item/clothing/neck/large_scarf/syndie
	box = /obj/item/storage/box/survival/syndie
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/icemoon_syndicate/post_equip(mob/living/carbon/human/syndicate, visualsOnly = FALSE) //you will not believe how many times i shot myself before i remembered to put this in
	syndicate.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon/guard
	you_are_text = "You are a Gorlex Marauder, assigned to guard a Syndicate outpost in the frigid wastes of the icemoon."
	prompt_name = "a Gorlex Marauders security guard"
	flavour_text = "Defend your assigned outpost from any intruders using your issued equipment. Enforce cooperation between organisations under the directives of the Captain."
	important_text = "DO NOT go near active Nanotrasen holdings or personnel, and do not leave the base unless absolutely necessary."
	outfit = /datum/outfit/icemoon_syndicate/guard

/datum/outfit/icemoon_syndicate/guard
	name = "Icemoon Syndicate Guard"
	suit = /obj/item/clothing/suit/armor/vest
	back = /obj/item/storage/backpack/security
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	box = /obj/item/storage/box/survival/syndie
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	backpack_contents = list(
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/melee/baton/security/loaded = 1,
		)


/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon/surgeon
	prompt_name = "an Interdyne surgeon"
	you_are_text = "You are an Interdyne surgeon, assigned to a Syndicate outpost in the frigid wastes of the icemoon."
	flavour_text = "Keep your colleagues alive and well and assist scientists where necessary. Enforce proper sanitary practice."
	important_text = "DO NOT go near active Nanotrasen holdings or personnel, and do not leave the base unless absolutely necessary."
	outfit = /datum/outfit/icemoon_syndicate/surgeon

/datum/outfit/icemoon_syndicate/surgeon
	name = "Icemoon Syndicate Surgeon"
	mask = /obj/item/clothing/mask/surgical
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/medic
	belt = /obj/item/defibrillator/compact/combat/loaded
	accessory = /obj/item/clothing/accessory/armband/medblue
	backpack_contents = list(
		/obj/item/storage/medkit/tactical = 1,
	)

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon/researcher
	prompt_name = "a Cybersun scientist"
	you_are_text = "You are a Cybersun researcher, assigned to a Syndicate outpost in the frigid wastes of the icemoon."
	flavour_text = "Perform research and development to better humanity - and the Syndicate. Work together with your colleagues from the other member organisations of the Syndicate."
	important_text = "DO NOT go near active Nanotrasen holdings or personnel, and do not leave the base unless absolutely necessary."
	outfit = /datum/outfit/icemoon_syndicate/researcher

/datum/outfit/icemoon_syndicate/researcher
	name = "Icemoon Syndicate Researcher"
	glasses = /obj/item/clothing/glasses/hud/diagnostic
	accessory = /obj/item/clothing/accessory/armband/science
	backpack_contents = list(
		/obj/item/clipboard = 1,
		/obj/item/pen = 1,
		/obj/item/paper = 1,
		/obj/item/storage/box/beakers = 1,
	)

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon/researcher/interdyne
	prompt_name = "an Interdyne scientist"
	you_are_text = "You are an Interdyne researcher, assigned to a Syndicate outpost in the frigid wastes of the icemoon."
	flavour_text = "Perform medical research and development alongside your colleagues from Cybersun. Assist the base's surgeon."
	outfit = /datum/outfit/icemoon_syndicate/researcher/interdyne

/datum/outfit/icemoon_syndicate/researcher/interdyne
	name = "Icemoon Syndicate Interdyne Researcher"
	glasses = /obj/item/clothing/glasses/hud/health
	suit = /obj/item/clothing/suit/toggle/labcoat/interdyne

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon/engineer
	prompt_name = "a Waffle Co engineer"
	you_are_text = "You are a Waffle Co engineer, assigned to a Syndicate outpost in the frigid wastes of the icemoon."
	flavour_text = "Maintain and deploy the base's equipment, and repair any damage to the structure. Take responsibility for any digging that occurs."
	important_text = "DO NOT go near active Nanotrasen holdings or personnel, and do not leave the base unless absolutely necessary."
	outfit = /datum/outfit/icemoon_syndicate/engineer

/datum/outfit/icemoon_syndicate/engineer
	name = "Icemoon Syndicate Engineer"
	accessory = /obj/item/clothing/accessory/armband/engine
	head = /obj/item/clothing/head/utility/hardhat/welding/orange
	belt = /obj/item/storage/belt/utility/syndicate
	backpack_contents = list(
		/obj/item/storage/box/emptysandbags = 1,
	)

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/icemoon/captain
	prompt_name = "an MI13 captain"
	name = "syndicate captain's sleeper"
	desc = "A relatively regal stasis sleeper used by officers of the Syndicate coalition. This one bears the insignia (or lack thereof) of MI13."
	you_are_text = "You are an MI13 officer, assigned to coordinate a Syndicate outpost in the frigid wastes of the icemoon."
	flavour_text = "Oversee your outpost's operations, use your chameleon gas mask to impede Nanotrasen activity using radio intelligence, and coordinate your base's crew."
	important_text = "Do not draw Nanotrasen's attention. You hold complete authority over the base and its crew, and are responsible for ensuring that inter-organisational conflict does not occur. You will be held responsible should the base be lost."
	outfit = /datum/outfit/icemoon_syndicate/captain

/datum/outfit/icemoon_syndicate/captain
	name = "Icemoon Syndicate Captain"
	id = /obj/item/card/id/advanced/chameleon/black
	id_trim = /datum/id_trim/chameleon/operative/nuke_leader //if this somehow impacts nukies more than the normal chameleon id, skill issue lmao.
	uniform = /obj/item/clothing/under/syndicate/sniper
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	back = /obj/item/storage/backpack/satchel/leather
	r_pocket = /obj/item/flashlight/lantern/syndicate
	mask = /obj/item/clothing/mask/chameleon/gps
	head = /obj/item/clothing/head/hats/hos/beret/syndicate
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	backpack_contents = list(
		/obj/item/gun/ballistic/revolver/mateba/pindicate = 1,
		/obj/item/ammo_box/a357 = 2,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/megaphone/sec = 1,
		/obj/item/melee/energy/sword/saber/red = 1,
	)

//unique bardrone, meant to run both the kitchen and bar

/obj/effect/mob_spawn/ghost_role/drone/bar/syndicate
	name = "syndicate bardrone shell"
	desc = "A modified shell of a Syndrone used to maintain bars and kitchens. It has, thankfully, been stripped of its wepaons systems."
	mob_name = "Syndicate Bardrone"
	mob_type = /mob/living/basic/drone/snowflake/bardrone/syndicate
	icon_state = "syndrone_item"
	anchored = TRUE
	prompt_name = "syndicate bardrone"
	you_are_text = "You are a Syndicate bardrone."
	flavour_text = "A product of Donk Co, you are designed to maintain an outpost's bar and kitchen whenever its crew are unable to do so - as well as assist in other menial service work, such as cleaning."
	important_text = "You MUST read and follow your laws carefully."
	spawner_job_path = /datum/job/bar_drone

/mob/living/basic/drone/snowflake/bardrone/syndicate
	name = "Syndicate Bardrone"
	desc = "A modified Syndrone used to tend bars and help make food to feed crews."
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	picked = TRUE //its a modified syndicate drone chassis
	faction = list(FACTION_NEUTRAL, ROLE_SYNDICATE)
	health = 120
	maxHealth = 120
	initial_language_holder = /datum/language_holder/syndicate //they don't really need universal if all they're doing is helping the base
	laws = "1. Serve drinks and food.\n\
		2. Maintain your workplace's functionality and dispose of any fauna who may threaten it if the need arises.\n\
		3. Assist your base's crew with menial service-related tasks, such as cleaning and cooking.\n\
		4. Do NOT involve yourself in the affairs of others outside of your base or harm other sentient beings under any circumstances."

	unique_name = FALSE // disables the (123) number suffix
	default_storage = null
	flavortext = \
	"\n<big><span class='warning'>LAW EXPLANATION FOR SYNDICATE BAR DRONES</span></big>\n"+\
	"<span class='notice'>You are meant to assist your base's crew in maintenance (such as cooking and cleaning) and keep them well-fed. You are authorised to attack planetary fauna if necessary. </span>\n"+\
	"<span class='notice'>BARDRONE GUIDELINES</span>\n"+\
	"<span class='notice'>     -Do not harm people. Harming fauna, however, is allowed if they are damaging the bar. The rest of the base is not your concern, as long as the bar is functional.</span>\n"+\
	"<span class='notice'>     -Do not interact with anyone outside of your base.</span>\n"+\
	"<span class='notice'>     -Do not get into altercations with other players, remove yourself from the situation. </span>\n"+\
	"<span class='notice'>     -Do not protect the bar from sentient agressors. </span>\n"+\
	"<span class='notice'>     -You may set up another bar at your base with permission of the crew. Don't monopolize resources - the base only has so much.</span>\n"+\
	"<span class='warning'>These rules are at admin discretion and will be heavily enforced. If you have questions about these rules AHELP it.</span>\n"

//secure weapon(s)
/obj/item/gun/ballistic/revolver/mateba/pindicate
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo. This one has a Syndicate serpent engraved on the grip."
	pin = /obj/item/firing_pin/implant/pindicate

//fluff

/obj/machinery/computer/terminal/icemoon_syndicate
	name = "syndicate terminal"
	desc = "A terminal used by Syndicate outposts to handle certain pieces of complex equipment."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	tguitheme = "syndicate"
	light_color = COLOR_SOFT_RED
	content = list("No connection.")
	upperinfo = "Property of Cybersun Industries."

/obj/machinery/computer/terminal/icemoon_syndicate/bunker
	name = "syndicate bunker terminal"
	desc = "A terminal used for emergency communications inside the base's bunker. How old is this?"
	upperinfo = "Syndix 3.11 Mail Client"
	content = list("<center><b>icemoon_base_bunker@cybersun.co.jp</b></center> <BR> Reminder from Command - Do not lock the door on your comrades. <BR> <BR> Your session has expired. Please log in.")

/obj/machinery/computer/terminal/icemoon_syndicate/cargo
	name = "syndicate cargo platform controller"
	desc = "A terminal used to control the cargo platforms responsible for moving supplies in and out of the Syndicate's Icemoon base."
	upperinfo = "cybersun_cargoman.exe - Critical Error"
	content = list("<center><b>CRITICAL ERROR!</b></center> <BR> <BR> Contact lost with external station. Please attempt to retrieve un-shipped cargo manually if possible and contact a qualified Cybersun Industries technician immediately.")

/obj/item/paper/syndicate_icemoon

/obj/item/paper/syndicate_icemoon/radiation_warning
	default_raw_text = "Tritium burn-mixes are highly discouraged due to the low levels of radiation shielding inside the base. Please avoid. Thanks."
