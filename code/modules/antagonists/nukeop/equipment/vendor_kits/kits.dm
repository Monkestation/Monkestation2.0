/obj/item/syndicate_voucher
	name = "voucher"
	desc = "A token to redeem equipment. Use it on a Donk Weaponry vendor."
	icon = 'icons/obj/syndicate_voucher.dmi'
	icon_state = "kit"
	w_class = WEIGHT_CLASS_TINY

/obj/item/syndicate_voucher/kit
	name = "kit voucher"
	icon_state = "kit"

/obj/item/syndicate_voucher/utility
	name = "utility voucher"
	icon_state = "utility"

/obj/item/syndicate_voucher/leader
	name = "leader voucher"
	icon_state = "leader"

/datum/voucher_set/syndicate
	description = "If you're seeing this tell a coder."

/datum/voucher_set/syndicate/kit

/datum/voucher_set/syndicate/kit/assault_trooper
	name = "Assault Trooper"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-green"
	set_items = list(
		/obj/item/storage/box/syndie_kit/assault_trooper,
		)

/obj/item/storage/box/syndie_kit/assault_trooper/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/green = 1,
		/obj/item/clothing/suit/space/syndicate/green = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/automatic/rostokov = 1,
		/obj/item/ammo_box/magazine/rostokov10mm = 4,
		/obj/item/grenade/c4/x4 = 4,
		/obj/item/grenade/flashbang = 2,
		/obj/item/grenade/frag = 2,
		/obj/item/grenade/spawnergrenade/manhacks = 1,
		/obj/item/reagent_containers/hypospray/medipen/stimulants = 1,
		/obj/item/clothing/glasses/night = 1,
	),src)

/datum/voucher_set/syndicate/kit/heavy_assault_trooper
	name = "Heavy Assault Trooper"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-green-dark"
	set_items = list(
		/obj/item/storage/box/syndie_kit/heavy_assault_trooper,
		)

/obj/item/storage/box/syndie_kit/heavy_assault_trooper/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/green/dark = 1,
		/obj/item/clothing/suit/space/syndicate/green/dark = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/shield/energy = 1,
		/obj/item/melee/energy/sword/saber = 1,
		/obj/item/gun/ballistic/shotgun/bulldog = 1,
		/obj/item/ammo_box/magazine/m12g = 6,
		/obj/item/ammo_box/magazine/m12g/bioterror = 2,
		/obj/item/ammo_box/magazine/m12g/stun = 2,
		/obj/item/ammo_box/magazine/m12g/meteor = 2,
		/obj/item/grenade/spawnergrenade/manhacks = 1,
		/obj/item/autosurgeon/syndicate/nodrop = 1,
		/obj/item/autosurgeon/syndicate/cyberlink_syndicate = 1,
		/obj/item/clothing/glasses/thermal = 1,
	),src)

/datum/voucher_set/syndicate/kit/sniper
	name = "Sniper"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-green"
	set_items = list(
		/obj/item/storage/box/syndie_kit/sniper,
		)

/obj/item/storage/box/syndie_kit/sniper/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/black/green = 1,
		/obj/item/clothing/suit/space/syndicate/black/green = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/rifle/sniper_rifle/syndicate = 1,
		/obj/item/suppressor = 1,
		/obj/item/ammo_box/magazine/sniper_rounds = 4,
		/obj/item/ammo_box/magazine/sniper_rounds/disruptor = 2,
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator = 2,
		/obj/item/ammo_box/magazine/sniper_rounds/marksman = 2,
		/obj/item/storage/box/smokebomb = 1,
		/obj/item/clothing/glasses/thermal/xray = 1,
	),src)

/datum/voucher_set/syndicate/kit/infiltrator
	name = "Infiltrator"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-blue"
	set_items = list(
		/obj/item/storage/box/syndie_kit/infiltrator,
		)

/obj/item/storage/box/syndie_kit/infiltrator/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/blue = 1,
		/obj/item/clothing/suit/space/syndicate/blue = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/revolver/syndicate = 1,
		/obj/item/ammo_box/a357 = 2,
		/obj/item/pen/sleepy = 1,
		/obj/item/storage/box/syndie_kit/chemical = 1,
		/obj/item/storage/box/syndie_kit/chameleon = 1,
		/obj/item/clothing/shoes/chameleon/noslip = 1,
		/obj/item/chameleon = 1,
		/obj/item/card/emag = 1,
		/obj/item/card/emag/doorjack = 1,
		/obj/item/pinpointer/nuke = 1,
		/obj/item/implanter/freedom = 1,
		/obj/item/implanter/storage = 1,
		/obj/item/reagent_containers/syringe/mulligan = 1,
	),src)

/datum/voucher_set/syndicate/kit/scout
	name = "Scout"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-blue"
	set_items = list(
		/obj/item/storage/box/syndie_kit/scout,
		)

/obj/item/storage/box/syndie_kit/scout/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/black/blue = 1,
		/obj/item/clothing/suit/space/syndicate/black/blue = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 1,
		/obj/item/suppressor = 1,
		/obj/item/ammo_box/magazine/plastikov10mm = 1,
		/obj/item/melee/energy/sword/saber = 1,
		/obj/item/card/emag = 1,
		/obj/item/card/emag/doorjack = 1,
		/obj/item/pinpointer/nuke = 1,
		/obj/item/storage/belt/military/assault/cloak = 1,
		/obj/item/clothing/glasses/hud/security/night = 1,
	),src)

/datum/voucher_set/syndicate/kit/grenadier
	name = "Grenadier"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black"
	set_items = list(
		/obj/item/storage/box/syndie_kit/grenadier,
		)

/obj/item/storage/box/syndie_kit/grenadier/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/black = 1,
		/obj/item/clothing/suit/space/syndicate/black = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/shotgun/china_lake/restricted = 1,
		/obj/item/storage/belt/grenade/grenadier = 1,
		/obj/item/clothing/glasses/sunglasses/big = 1,
	),src)

/obj/item/storage/belt/grenade/grenadier/PopulateContents()
	generate_items_inside(list(
		/obj/item/grenade/chem_grenade/facid = 1,
		/obj/item/grenade/empgrenade = 5,
		/obj/item/grenade/frag = 6,
		/obj/item/grenade/flashbang = 6,
		/obj/item/grenade/gluon = 5,
		/obj/item/grenade/smokebomb = 5,
		/obj/item/grenade/syndieminibomb = 2,
		/obj/item/multitool = 1,
		/obj/item/screwdriver = 1,
		/obj/item/ammo_casing/a40mm/hedp = 4,
		/obj/item/ammo_casing/a40mm/frag = 4,
		/obj/item/ammo_casing/a40mm/stun = 4,
		/obj/item/ammo_casing/a40mm = 8,
		/obj/item/ammo_casing/a40mm/rubber = 8,
		/obj/item/ammo_casing/a40mm/smoke = 8,
	),src)

/datum/voucher_set/syndicate/kit/medic
	name = "Medic"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-med"
	set_items = list(
		/obj/item/storage/box/syndie_kit/medic,
		)

/obj/item/storage/box/syndie_kit/medic/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/black/med = 1,
		/obj/item/clothing/suit/space/syndicate/black/med = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 1,
		/obj/item/ammo_box/magazine/plastikov10mm = 1,
		/obj/item/storage/medkit/combat = 1,
		/obj/item/storage/medkit/combat/surgery = 1,
		/obj/item/defibrillator/compact/combat/loaded = 1,
		/obj/item/reagent_containers/hypospray/medipen/advanced = 1,
		/obj/item/gun/medbeam = 1,
		/obj/item/autosurgeon/syndicate/hacked_linked_surgery =1,
		/obj/item/autosurgeon/syndicate/cyberlink_syndicate = 1,
		/obj/item/clothing/gloves/latex/nitrile = 1,
		/obj/item/clothing/glasses/hud/health/night/science = 1,
	),src)

/datum/voucher_set/syndicate/kit/engineer
	name = "Engineer"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-engie"
	set_items = list(
		/obj/item/storage/box/syndie_kit/engineer,
		)

/obj/item/storage/box/syndie_kit/engineer/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/black/engie = 1,
		/obj/item/clothing/suit/space/syndicate/black/engie = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 1,
		/obj/item/ammo_box/magazine/plastikov10mm = 1,
		/obj/item/storage/belt/utility/syndicate = 1,
		/obj/item/construction/rcd/combat = 1,
		/obj/item/extinguisher/advanced = 1,
		/obj/item/forcefield_projector/combat = 1,
		/obj/item/storage/toolbox/emergency/turret/nukie/explosives = 1,
		/obj/item/autosurgeon/skillchip/syndicate/engineer = 1,
		/obj/item/clothing/glasses/hud/diagnostic/night = 1,
	),src)

/datum/voucher_set/syndicate/utility

/datum/voucher_set/syndicate/leader

/datum/voucher_set/syndicate/leader/kit
	name = "Leader"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-red"
	set_items = list(
		/obj/item/storage/box/syndie_kit/leader,
		)


/obj/item/storage/box/syndie_kit/leader/PopulateContents()
	generate_items_inside(list(
		/obj/item/clothing/head/helmet/space/syndicate/black/red = 1,
		/obj/item/clothing/suit/space/syndicate/black/red = 1,
		/obj/item/tank/jetpack/harness = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 2,
		/obj/item/ammo_box/magazine/plastikov10mm = 4,
		/obj/item/wrench/combat = 1,
		/obj/item/storage/medkit/combat = 1,
		/obj/item/book/granter/martial/cqc = 1,
		/obj/item/book/granter/gun_mastery = 1,
		/obj/item/language_manual/codespeak_manual/unlimited = 1,
		/obj/item/clothing/glasses/thermal = 1,
		/obj/item/clothing/glasses/hud/health/night = 1,
	),src)
