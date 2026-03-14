/datum/uplink_category/explosives
	name = "Explosives"
	weight = 3

/datum/uplink_item/explosives
	category = /datum/uplink_category/explosives

/datum/uplink_item/explosives/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	item = /obj/item/grenade/clusterbuster/soap
	cost = 3
	surplus = 60

/datum/uplink_item/explosives/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, sabotage equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	progression_minimum = 5 MINUTES
	item = /obj/item/grenade/c4
	cost = 1

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	progression_minimum = 10 MINUTES
	cost = 8 //20% discount!
	cant_discount = TRUE

/datum/uplink_item/explosives/x4bag
	name = "Bag of X-4 explosives"
	desc = "Contains 3 X-4 shaped plastic explosives. Similar to C4, but with a stronger blast that is directional instead of circular. \
			X-4 can be placed on a solid surface, such as a wall or window, and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. \
			For when you want a controlled explosion that leaves a wider, deeper, hole."
	progression_minimum = 20 MINUTES
	item = /obj/item/storage/backpack/duffelbag/syndie/x4
	cost = 4
	cant_discount = TRUE

/datum/uplink_item/explosives/detomatix
	name = "Detomatix disk"
	desc = "When inserted into a tablet, this cartridge gives you four opportunities to \
			detonate tablets of crewmembers who have their message feature enabled. \
			The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer."
	progression_minimum = 20 MINUTES
	item = /obj/item/computer_disk/virus/detomatix
	cost = 6
	restricted = TRUE

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and Implanter Kit"
	desc = "A box that contains five EMP grenades. Useful to disrupt communications, \
			security's energy weapons and silicon lifeforms when you're in a tight spot."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 2

/datum/uplink_item/explosives/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 3

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb cunningly attached to the lid. The timer needs to be set by opening the box; afterwards, \
			opening the box again will trigger the detonation after the timer has elapsed. Comes with free pizza, for you or your target!"
	progression_minimum = 30 MINUTES
	item = /obj/item/pizzabox/bomb
	cost = 6
	surplus = 30 //monkestation edit: from 8 to 30

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse. Upon detonation, it will create a small hull breach \
			in addition to dealing high amounts of damage to nearby personnel."
	progression_minimum = 30 MINUTES
	item = /obj/item/grenade/syndieminibomb
	cost = 6
	purchasable_from = ~UPLINK_CLOWN_OPS


/datum/uplink_item/explosives/syndicate_bomb/emp
	name = "Syndicate EMP Bomb"
	desc = "A variation of the syndicate bomb designed to produce a large EMP effect."
	progression_minimum = 30 MINUTES
	item = /obj/item/sbeacondrop/emp
	cost = 7

/datum/uplink_item/explosives/syndicate_bomb/emp/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost *= 2

/datum/uplink_item/explosives/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate bomb is a fearsome device capable of massive destruction. It has an adjustable timer, \
		with a minimum of %MIN_BOMB_TIMER seconds, and can be bolted to the floor with a wrench to prevent \
		movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
		transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
		be defused, and some crew may attempt to do so. \
		The bomb core can be pried out and manually detonated with other explosives."
	progression_minimum = 30 MINUTES
	item = /obj/item/sbeacondrop/bomb
	cost = 11

/datum/uplink_item/explosives/syndicate_bomb/New()
	. = ..()
	desc = replacetext(desc, "%MIN_BOMB_TIMER", SYNDIEBOMB_MIN_TIMER_SECONDS)

/datum/uplink_item/explosives/cat
	name = "Feral cat grenade"
	desc = "This grenade is filled with 5 feral cats in stasis. Upon activation, the feral cats are awoken and unleashed unto unlucky bystanders. WARNING: The cats are not trained to discern friend from foe!"
	cost = 5
	item = /obj/item/grenade/spawnergrenade/cat
	surplus = 30

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
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/grenade_launcher
	name = "40mm Grenade Launcher"
	desc = "A single round break-operation grenade launcher. Comes preloaded with a 40mm HE shell."
	cost = 5
	item = /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm
	name = "Box of 40mm HE Grenades"
	desc = "A box of four 40mm HE grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm/rubber
	name = "Box of 40mm Rubber Slug Shells"
	desc = "A box of four 40mm rubber slug shells. For use with a grenade launcher."
	cost = 2
	item = /obj/item/storage/fancy/a40mm_box/rubber
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm/incendiary
	name = "Box of 40mm Incendiary Grenades"
	desc = "A box of four 40mm incendiary grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box/incendiary
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm/smoke
	name = "Box of 40mm Smoke Grenades"
	desc = "A box of four 40mm smoke grenades. For use with a grenade launcher."
	cost = 1
	item = /obj/item/storage/fancy/a40mm_box/smoke
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm/stun
	name = "Box of 40mm Stun Grenades"
	desc = "A box of four 40mm stun grenades. For use with a grenade launcher."
	cost = 3
	item = /obj/item/storage/fancy/a40mm_box/stun
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm/hedp
	name = "Box of 40mm HEDP Grenades"
	desc = "A box of four 40mm HEDP grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box/hedp
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/a40mm/frag
	name = "Box of 40mm Fragmentation Grenades"
	desc = "A box of four 40mm fragmentation grenades. For use with a grenade launcher."
	cost = 5
	item = /obj/item/storage/fancy/a40mm_box/frag
	purchasable_from = ~UPLINK_CLOWN_OPS
