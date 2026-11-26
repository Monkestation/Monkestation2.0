
/datum/uplink_category/weapon_kits
	name = "Weapon Kits (Recommended)"
	weight = 30

/datum/uplink_item/weapon_kits
	category = /datum/uplink_category/weapon_kits
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/weapon_kits/low_cost/clandestine
	name = "Ansem Pistol Case (Easy/Spare)"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible \
			with suppressors. Comes with three spare magazines."
	item = /obj/item/storage/toolbox/guncase/clandestine
	cost = 7 //this stuff is lying around the base to begin with so its not worth much

/datum/uplink_item/weapon_kits/medium_cost/carbine
	name = "M-90gl Carbine Case (Hard)"
	desc = "A fully-loaded, specialized three-round burst carbine that fires .223 ammunition from a 30 round magazine \
		with a 40mm underbarrel grenade launcher. Use secondary-fire to fire the grenade launcher. Comes with two spare magazines \
		and a box of 40mm HE."
	item = /obj/item/storage/toolbox/guncase/m90gl
	cost = 14

/datum/uplink_item/weapon_kits/medium_cost/bulldog
	name = "Bulldog Shotgun Case (Moderate)"
	desc = "A fully-loaded 2-round burst fire drum-fed shotgun, complete with a secondary magazine you can hotswap. \
		Compatible with all 12g rounds. Designed for close quarter anti-personnel engagements. Comes with four spare magazines."
	item = /obj/item/storage/toolbox/guncase/bulldog
	cost = 8
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/weapon_kits/medium_cost/c20r
	name = "C-20r Submachine Gun Case (Easy)"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun. The C-20r fires .45 rounds with a \
		42-round magazine and is compatible with suppressors. Comes with three spare magazines and a suppressor."
	item = /obj/item/storage/toolbox/guncase/c20r
	cost = 14
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/weapon_kits/medium_cost/revolvercase
	name = "Syndicate Revolver Case (Moderate)"
	desc = "Waffle Co.'s modernized Syndicate revolver. Fires 7 brutal rounds of .357 Magnum. \
		A classic operative weapon, brought to the modern era. Comes with 3 additional speedloaders of .357. Try not to miss."
	cost = 15
	item = /obj/item/storage/toolbox/guncase/revolver

/datum/uplink_item/weapon_kits/high_cost/sword_and_board
	name = "Energy sword and shield combo box (Moderate)"
	desc = "An Energy Shield and sword combo, popular amongst agents that like to get shot in the back."
	cost = 18
	item = /obj/item/storage/toolbox/guncase/sword_and_board

/datum/uplink_item/weapon_kits/high_cost/cqc
	name = "CQC Equipment Case (Very Hard)"
	desc = "Contains a manual that instructs you in the ways of CQC, or Close Quarters Combat. Comes with a stealth implant, a pack of smokes and a discount bandana and a thermal eyepatch."
	item = /obj/item/storage/toolbox/guncase/cqc
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	cost = 15
	surplus = 0
