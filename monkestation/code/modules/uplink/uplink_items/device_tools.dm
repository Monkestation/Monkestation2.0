/datum/uplink_item/device_tools/encryptionkey
	purchasable_from = ~UPLINK_GANGS //dont want people getting confused as this is what the communicator upgrade is for

/datum/uplink_item/device_tools/syndietome
	purchasable_from = ~UPLINK_GANGS //its a team antag so this seems a bit strong

/datum/uplink_item/device_tools/syndicate_teleporter
	purchasable_from = ~UPLINK_GANGS

/datum/uplink_item/device_tools/doorjack
	purchasable_from = ~UPLINK_GANGS

/datum/uplink_item/device_tools/suspiciousphone
	purchasable_from = ~UPLINK_GANGS

/datum/uplink_item/device_tools/hypnotic_flash
	purchasable_from = ~UPLINK_GANGS

/datum/uplink_item/device_tools/hypnotic_grenade
	purchasable_from = ~UPLINK_GANGS

/datum/uplink_item/device_tools/tram_remote
	surplus = 40

/datum/uplink_item/device_tools/rad_laser
	surplus = 40

/datum/uplink_item/device_tools/hacked_linked_surgery
	name = "Syndicate Surgery Implant"
	desc = "A powerful brain implant, capable of uploading perfect, forbidden surgical knowledge to its users mind, \
		allowing them to do just about any surgery, anywhere, without making any (unintentional) mistakes. \
		Comes with a syndicate autosurgeon for immediate self-application."
	cost = 12
	item = /obj/item/autosurgeon/syndicate/hacked_linked_surgery
	surplus = 50

/datum/uplink_item/device_tools/compressionkit
	name = "Bluespace Compression Kit"
	desc = "A modified version of a BSRPED that can be used to reduce the size of most items while retaining their original functions! \
			Does not work on storage items. \
			Recharge using bluespace crystals. \
			Comes with 5 charges."
	item = /obj/item/compression_kit
	cost = 4
