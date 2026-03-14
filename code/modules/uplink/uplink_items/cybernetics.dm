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
	item = /obj/item/autosurgeon/organ/syndicate/sandy
	cost = 10
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/cybernetics/mantis
	name = "Mantis Blade Bundle"
	desc = "A box containing autosurgeons for two mantis blade implants, one for each arm."
	item = /obj/item/storage/box/syndie_kit/mantis
	cost = 12
	purchasable_from = UPLINK_TRAITORS

/obj/item/storage/box/syndie_kit/mantis/PopulateContents()
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis(src)
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis/l(src)

/datum/uplink_item/cybernetics/dualwield
	name = "C.C.M.S Bundle"
	desc = "A box containing an autosurgeon a C.C.M.S implant that lets you dual wield melee weapons."
	item = /obj/item/autosurgeon/organ/syndicate/dualwield
	cost = 10
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/cybernetics/razorwire
	name = "Razorwire Implant"
	desc = "An integrated spool of razorwire, capable of being used as a weapon when whipped at your foes. \
	Two tile range and can anchor further targets to keep them still."
	item = /obj/item/autosurgeon/organ/syndicate/razorwire
	progression_minimum = 15 MINUTES
	cost = 5
	surplus = 20

/datum/uplink_item/cybernetics/hacked_linked_surgery
	name = "Syndicate Surgery Implant"
	desc = "A powerful brain implant, capable of uploading perfect, forbidden surgical knowledge to its users mind, \
		allowing them to do just about any surgery, anywhere, without making any (unintentional) mistakes. \
		Comes with a syndicate autosurgeon for immediate self-application."
	cost = 10
	item = /obj/item/autosurgeon/syndicate/hacked_linked_surgery
	surplus = 50

/datum/uplink_item/cybernetics/hivenode_implanter
	name = "Hive Node Implanter"
	desc = "A Xenomorph hive node. When implanted, allows connection to any Xenomorphs in nearby psionic networks."
	cost = 5 //similar price to binary translator
	item = /obj/item/autosurgeon/syndicate/organ/hivenode


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
	cost = 10
	surplus = 30
