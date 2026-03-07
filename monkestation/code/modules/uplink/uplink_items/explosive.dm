/datum/uplink_item/explosives/soap_clusterbang
	surplus = 60

/datum/uplink_item/explosives/explosive_flash
	name = "Explosive Flash"
	desc = "A fake, hollowed out flash that holds a small bombcore. It explodes on usage with a satisfying click."
	cost = 2
	item = /obj/item/assembly/flash/explosive

/datum/uplink_item/explosives/door_charge
	name = "Door Charge"
	desc = "A small charge that can be rigged to a door, causing it to explode when the handle is moved. Tiny OS and microphone installed for taunting your victims."
	cost = 5
	item = /obj/item/traitor_machine_trapper/door_charge

/datum/uplink_item/explosives/china_lake
	name = "China Lake 40mm Grenade Launcher"
	desc = "A robust, 4 round pump-action grenade launcher. Comes preloaded with three 40mm HE shells."
	cost = 10
	item = /obj/item/gun/ballistic/shotgun/china_lake
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)

/datum/uplink_item/explosives/grenade_launcher
	name = "40mm Grenade Launcher"
	desc = "A single round break-operation grenade launcher. Comes preloaded with a 40mm HE shell."
	cost = 5
	item = /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_GANGS)
