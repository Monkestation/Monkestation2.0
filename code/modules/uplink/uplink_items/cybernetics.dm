/datum/uplink_category/cybernetics
	name = "Cybernetics"
	weight = 3

/datum/uplink_item/cybernetics
	category = /datum/uplink_category/cybernetics
	surplus = 0
	cant_discount = FALSE

/datum/uplink_item/cybernetics/sandy
	name = "Sandevistan Bundle"
	desc = "A box containing an autosurgeon for a sandevistan, allowing you to outspeed targets."
	item = /obj/item/autosurgeon/syndicate/sandy
	cost = 10
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/cybernetics/mantis
	name = "Mantis Blade Bundle"
	desc = "A box containing autosurgeons for two mantis blade implants, one for each arm."
	item = /obj/item/storage/box/syndie_kit/mantis
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/mantis/PopulateContents()
	new /obj/item/autosurgeon/syndicate/syndie_mantis(src)
	new /obj/item/autosurgeon/syndicate/syndie_mantis/l(src)

/datum/uplink_item/cybernetics/dualwield
	name = "C.C.M.S Bundle"
	desc = "A box containing an autosurgeon a C.C.M.S implant that lets you dual wield melee weapons."
	item = /obj/item/autosurgeon/syndicate/dualwield
	cost = 8
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/cybernetics/razorwire
	name = "Razorwire Implant"
	desc = "An integrated spool of razorwire, capable of being used as a weapon when whipped at your foes. \
	Two tile range and can anchor further targets to keep them still."
	item = /obj/item/autosurgeon/syndicate/razorwire
	progression_minimum = 15 MINUTES
	cost = 5
	surplus = 20

/datum/uplink_item/cybernetics/hacked_linked_surgery
	name = "Syndicate Surgery Implant"
	desc = "A powerful brain implant, capable of uploading perfect, forbidden surgical knowledge to its users mind, \
		allowing them to do just about any surgery, anywhere, without making any (unintentional) mistakes. \
		Comes with a syndicate autosurgeon for immediate self-application."
	cost = 7
	item = /obj/item/autosurgeon/syndicate/hacked_linked_surgery
	surplus = 50

/datum/uplink_item/cybernetics/hivenode_implanter
	name = "Hive Node Implanter"
	desc = "A Xenomorph hive node. When implanted, allows connection to any Xenomorphs in nearby psionic networks."
	cost = 5 //similar price to binary translator
	item = /obj/item/autosurgeon/syndicate/hivenode


/datum/uplink_item/cybernetics/thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you thermal vision. Comes with only a single-use autosurgeon, a corner cut to achieve a lower price point."
	item = /obj/item/autosurgeon/syndicate/thermal_eyes
	cost = 5
	surplus = 40

/datum/uplink_item/cybernetics/xray
	name = "X-ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/xray_eyes
	cost = 7
	surplus = 30

/datum/uplink_item/cybernetics/autosurgeon
	name = "Syndicate Autosurgeon"
	desc = "A multi-use autosurgeon for implanting whatever you want into yourself. Rip that station apart and make it part of you."
	item = /obj/item/autosurgeon/syndicate
	cost = 3

/datum/uplink_item/cybernetics/polyglot_voicebox
	name = "Syndicate Polyglot Voicebox"
	desc = "A polyglot voicebox which, after replacing the user's tongue will allow them to emulate \
			the tongue of any species. \
			WARNING: The polyglot voicebox does not allow you to speak additional languages"
	cost = 1
	item = /obj/item/autosurgeon/syndicate/polyglot_voicebox
	surplus = 25
