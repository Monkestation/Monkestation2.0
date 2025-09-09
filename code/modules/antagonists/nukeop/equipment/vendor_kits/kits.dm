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
	name = "Assault Trooper (Easy)"
	description = "Move fast and shut down key targets before they have a chance to react. \
		Weapons: Rostokov carbine, energy sword, C4, flashbangs, and frag grenades. \
		Utility: Stimulant medipen."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-green"
	set_items = list(
		/obj/item/storage/box/syndie_kit/assault_trooper,
		)

/obj/item/storage/box/syndie_kit/assault_trooper/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/gun/ballistic/automatic/rostokov = 1,
		/obj/item/ammo_box/magazine/rostokov9mm = 5,
		/obj/item/melee/energy/sword/saber = 1,
		/obj/item/grenade/c4 = 4,
		/obj/item/grenade/flashbang = 2,
		/obj/item/grenade/frag = 2,
		/obj/item/reagent_containers/hypospray/medipen/stimulants = 1,
		/obj/item/clothing/glasses/night = 1,
	),src)

/datum/voucher_set/syndicate/kit/heavy_assault_trooper
	name = "Heavy Assault Trooper (Easy)"
	description = "Lock down tight areas and take bullets for the team. \
		Weapons: Bulldog Autoshotgun, energy sword, and energy shield. \
		Utility: Thermal goggles."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-green-dark"
	set_items = list(
		/obj/item/storage/box/syndie_kit/heavy_assault_trooper,
		)

/obj/item/storage/box/syndie_kit/heavy_assault_trooper/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/shield/energy = 1,
		/obj/item/melee/energy/sword/saber = 1,
		/obj/item/gun/ballistic/shotgun/bulldog = 1,
		/obj/item/ammo_box/magazine/m12g = 2,
		/obj/item/ammo_box/magazine/m12g/slug = 2,
		/obj/item/ammo_box/magazine/m12g/bioterror = 2,
		/obj/item/clothing/glasses/thermal = 1,
	),src)

/datum/voucher_set/syndicate/kit/sniper
	name = "Sniper (Medium)"
	description = "Set up from afar and take out targets outside the team's effective area. \
		Weapons: Anti-materiel sniper rifle and teargas grenades. \
		Utility: Thermal goggles."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-green"
	set_items = list(
		/obj/item/storage/box/syndie_kit/sniper,
		)

/obj/item/storage/box/syndie_kit/sniper/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/elite = 1,
		/obj/item/gun/ballistic/rifle/sniper_rifle/syndicate = 1,
		/obj/item/suppressor = 1,
		/obj/item/ammo_box/magazine/sniper_rounds = 2,
		/obj/item/ammo_box/magazine/sniper_rounds/disruptor = 2,
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator = 1,
		/obj/item/ammo_box/magazine/sniper_rounds/marksman = 1,
		/obj/item/storage/box/teargas = 2,
		/obj/item/clothing/glasses/thermal = 1,
	),src)

/datum/voucher_set/syndicate/kit/infiltrator
	name = "Infiltrator (Hard)"
	description = "Infiltrate the station using the provided tools, track down the disk, and sabotage the station for the coming assault. \
		Weapons: .357 revolver, sleepy pen, and chemical kit. \
		Utility: Chameleon kit, chameleon projector, mulligan syringe, freedom implant, storage implant, infiltrator modsuit, cryptographic sequencer, airlock authentication override card, and disk pinpointer."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-blue"
	set_items = list(
		/obj/item/storage/box/syndie_kit/infiltrator,
		)

/obj/item/storage/box/syndie_kit/infiltrator/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/mod/module/chameleon = 1,
		/obj/item/mod/control/pre_equipped/infiltrator = 1,
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
	name = "Scout (Medium)"
	description = "Use your cloak to get around the station and access areas harder to reach by the rest of the team without going unnoticed. \
		Weapons: PP-96 SMG and energy sword. \
		Utility: Suppressor, cryptographic sequencer, airlock authentication override card, disk pinpointer, experimental Syndicate teleporter, cloaker belt, and security HUD night vision goggles."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-blue"
	set_items = list(
		/obj/item/storage/box/syndie_kit/scout,
		)

/obj/item/storage/box/syndie_kit/scout/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 1,
		/obj/item/suppressor = 1,
		/obj/item/ammo_box/magazine/plastikov9mm/red = 2,
		/obj/item/melee/energy/sword/saber = 1,
		/obj/item/card/emag = 1,
		/obj/item/card/emag/doorjack = 1,
		/obj/item/pinpointer/nuke = 1,
		/obj/item/storage/box/syndie_kit/syndicate_teleporter = 1,
		/obj/item/storage/belt/military/assault/cloak = 1,
		/obj/item/clothing/glasses/hud/security/night = 1,
	),src)

/datum/voucher_set/syndicate/kit/grenadier
	name = "Grenadier (Very Hard)"
	description = "Blow up everything and anything owned by Nanotrasen and clear the way for the team. \
		Weapons: China Lake 40mm grenade launcher and a fuckton of grenades. \
		Utility: Kickass looking sunglasses."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black"
	set_items = list(
		/obj/item/storage/box/syndie_kit/grenadier,
		)

/obj/item/storage/box/syndie_kit/grenadier/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/elite = 1,
		/obj/item/gun/ballistic/shotgun/china_lake/restricted = 1,
		/obj/item/storage/belt/grenade/grenadier = 1,
		/obj/item/clothing/glasses/sunglasses/big = 1,
	),src)

/obj/item/storage/belt/grenade/grenadier/PopulateContents()
	generate_items_inside(list(
		/obj/item/grenade/c4 = 6,
		/obj/item/grenade/c4/x4 = 4,
		/obj/item/grenade/chem_grenade/facid = 2,
		/obj/item/grenade/empgrenade = 5,
		/obj/item/grenade/frag = 10,
		/obj/item/grenade/flashbang = 6,
		/obj/item/grenade/gluon = 5,
		/obj/item/grenade/smokebomb = 6,
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
	name = "Medic (Hard)"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	description = "Keep the team alive and revive them when they fall. \
		Weapons: PP-96 SMG. \
		Utility: Medical beamgun, combat medical kit, combat surgical kit, combat defibrillator, double use stimulant medipen, Syndicate surgical serverlink, and medical HUD night vision goggles."
	icon_state = "syndicate-helm-black-med"
	set_items = list(
		/obj/item/storage/box/syndie_kit/medic,
		)

/obj/item/storage/box/syndie_kit/medic/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 1,
		/obj/item/ammo_box/magazine/plastikov9mm/red = 2,
		/obj/item/storage/medkit/tactical/premium = 1,
		/obj/item/storage/medkit/combat/surgery = 1,
		/obj/item/reagent_containers/hypospray/medipen/advanced = 1,
		/obj/item/gun/medbeam = 1,
		/obj/item/autosurgeon/syndicate/hacked_linked_surgery =1,
		/obj/item/clothing/gloves/latex/nitrile = 1,
	),src)

/datum/voucher_set/syndicate/kit/engineer
	name = "Engineer (Medium)"
	description = "Secure the decryption zone, repair the nuke, and provide cover for the rest of the team. \
		Weapons: PP-96 SMG and X4 (in toolbox). \
		Utility: Full toolbelt with combat wrench, 9mm deployable turret, advanced fire extinguisher, combat forcefield projector, circuit skillchip, and diagnostic HUD night vision goggles."
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-engie"
	set_items = list(
		/obj/item/storage/box/syndie_kit/engineer,
		)

/obj/item/storage/box/syndie_kit/engineer/PopulateContents()
	generate_items_inside(list(
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 1,
		/obj/item/ammo_box/magazine/plastikov9mm/red = 2,
		/obj/item/storage/belt/utility/syndicate = 1,
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
		/obj/item/mod/module/energy_shield = 1,
		/obj/item/gun/ballistic/automatic/plastikov/refurbished = 2,
		/obj/item/ammo_box/magazine/plastikov9mm/red = 2,
		/obj/item/wrench/combat = 1,
		/obj/item/grenade/spawnergrenade/manhacks = 1,
		/obj/item/book/granter/gun_mastery = 1,
		/obj/item/language_manual/codespeak_manual/unlimited = 1,
	),src)
