/obj/machinery/vending/access/command
	name = "\improper Command Outfitting Station"
	desc = "A vending machine for specialised clothing for members of Command."
	product_ads = "File paperwork in style!;It's red so you can't see the blood!;You have the right to be fashionable!;Now you can be the fashion police you always wanted to be!"
	icon = 'monkestation/icons/obj/vending.dmi'
	icon_state = "commdrobe"
	light_mask = "wardrobe-light-mask"
	vend_reply = "Thank you for using the CommDrobe!"

	refill_canister = /obj/item/vending_refill/wardrobe/comm_wardrobe
	payment_department = ACCOUNT_CMD
	light_color = COLOR_COMMAND_BLUE

	products = list(
		/obj/item/clothing/head/hats/imperial = 5,
		/obj/item/clothing/head/hats/imperial/grey = 5,
		/obj/item/clothing/head/hats/imperial/white = 2,
		/obj/item/clothing/head/hats/imperial/red = 5,
		/obj/item/clothing/head/hats/imperial/helmet = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic/grey = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic/pants = 5,
		/obj/item/clothing/under/rank/captain/nova/imperial/generic/red = 5,
	)

/obj/item/vending_refill/wardrobe/comm_wardrobe
	machine_name = "CommDrobe"

/obj/machinery/vending/access/command/build_access_list(list/inventory)
	inventory[ACCESS_CAPTAIN] = list(
		// CAPTAIN
		/obj/item/clothing/head/hats/caphat = 1,
		/obj/item/clothing/head/caphat/beret = 1,
		/obj/item/clothing/head/caphat/beret/alt = 1,
		/obj/item/clothing/head/hats/imperial/cap = 1,
		/obj/item/clothing/under/rank/captain = 1,
		/obj/item/clothing/under/rank/captain/skirt = 1,
		/obj/item/clothing/under/rank/captain/dress = 1,
		/obj/item/clothing/under/rank/captain/nova/kilt = 1,
		/obj/item/clothing/under/rank/captain/nova/imperial = 1,
		/obj/item/clothing/head/hats/caphat/parade = 1,
		/obj/item/clothing/under/rank/captain/parade = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/captains_formal = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/jacket = 1,
		/obj/item/clothing/suit/jacket/capjacket = 1,
		/obj/item/clothing/neck/cloak/cap = 1,
		/obj/item/clothing/neck/mantle/capmantle = 1,
		/obj/item/storage/backpack/captain = 1,
		/obj/item/storage/backpack/satchel/cap = 1,
		/obj/item/storage/backpack/duffelbag/captain = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	inventory[ACCESS_BLUESHIELD] = list(
		// BLUESHIELD
		/obj/item/clothing/head/beret/blueshield = 1,
		/obj/item/clothing/head/beret/blueshield/navy = 1,
		/obj/item/clothing/under/rank/blueshield = 1,
		/obj/item/clothing/under/rank/blueshield/skirt = 1,
		/obj/item/clothing/under/rank/blueshield/turtleneck = 1,
		/obj/item/clothing/under/rank/blueshield/turtleneck/skirt = 1,
		/obj/item/clothing/suit/armor/vest/blueshield = 1,
		/obj/item/clothing/suit/armor/vest/blueshield/jacket = 1,
		/obj/item/clothing/neck/mantle/bsmantle = 1,
		/obj/item/storage/backpack/blueshield = 1,
		/obj/item/storage/backpack/satchel/blueshield = 1,
		/obj/item/storage/backpack/duffelbag/blueshield = 1,
		/obj/item/clothing/shoes/laceup = 1,
	)
	inventory[ACCESS_HOP] = list( // Best head btw
		/obj/item/clothing/head/hats/hopcap = 1,
		/obj/item/clothing/head/hopcap/beret = 1,
		/obj/item/clothing/head/hopcap/beret/alt = 1,
		/obj/item/clothing/head/hats/imperial/hop = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/turtleneck = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/turtleneck/skirt = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/parade = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/parade/female = 1,
		/obj/item/clothing/under/rank/civilian/head_of_personnel/nova/imperial = 1,
		/obj/item/clothing/suit/armor/vest/hop/hop_formal = 1,
		/obj/item/clothing/neck/cloak/hop = 1,
		/obj/item/clothing/neck/mantle/hopmantle = 1,
		/obj/item/storage/backpack/head_of_personnel = 1,
		/obj/item/storage/backpack/satchel/head_of_personnel = 1,
		/obj/item/storage/backpack/duffelbag/head_of_personnel = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	inventory[ACCESS_CMO] = list(
		/obj/item/clothing/head/beret/medical/cmo = 1,
		/obj/item/clothing/head/beret/medical/cmo/alt = 1,
		/obj/item/clothing/head/hats/imperial/cmo = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt = 1,
		/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck = 1,
		/obj/item/clothing/neck/cloak/cmo = 1,
		/obj/item/clothing/neck/mantle/cmomantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	inventory[ACCESS_RD] = list(
		/obj/item/clothing/head/beret/science/rd = 1,
		/obj/item/clothing/head/beret/science/rd/alt = 1,
		/obj/item/clothing/under/rank/rnd/research_director = 1,
		/obj/item/clothing/under/rank/rnd/research_director/skirt = 1,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck = 1,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt = 1,
		/obj/item/clothing/neck/cloak/rd = 1,
		/obj/item/clothing/neck/mantle/rdmantle = 1,
		/obj/item/clothing/suit/toggle/labcoat = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	inventory[ACCESS_CE] = list(
		/obj/item/clothing/head/beret/engi/ce = 1,
		/obj/item/clothing/head/hats/imperial/ce = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer/skirt = 1,
		/obj/item/clothing/under/rank/engineering/chief_engineer/nova/imperial = 1,
		/obj/item/clothing/neck/cloak/ce = 1,
		/obj/item/clothing/neck/mantle/cemantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)
	inventory[ACCESS_HOS] = list(
		/obj/item/clothing/head/hats/hos/cap = 1,
		/obj/item/clothing/head/hats/hos/beret/navyhos = 1,
		/obj/item/clothing/head/hats/imperial/hos = 1,
		/obj/item/clothing/under/rank/security/head_of_security/alt = 1,
		/obj/item/clothing/under/rank/security/head_of_security/alt/skirt = 1,
		/obj/item/clothing/suit/jacket/hos/blue = 1,
		/obj/item/clothing/under/rank/security/head_of_security/parade = 1,
		/obj/item/clothing/suit/armor/hos/hos_formal = 1,
		/obj/item/clothing/neck/cloak/hos = 1,
		/obj/item/clothing/neck/mantle/hosmantle = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)

	inventory[ACCESS_QM] = list(
		/obj/item/radio/headset/heads/qm = 1,
	)

/obj/machinery/vending/access/wardrobe_cargo
	name = "CargoDrobe"
	desc = "A highly advanced vending machine for buying cargo related clothing for free."
	icon_state = "cargodrobe"
	product_ads = "Upgraded Assistant Style! Pick yours today!;These shorts are comfy and easy to wear, get yours now!"
	vend_reply = "Thank you for using the CargoDrobe!"

	products = list(
		/obj/item/storage/bag/mail = 3,
		/obj/item/clothing/suit/hooded/wintercoat/cargo = 3,
		/obj/item/clothing/under/rank/cargo/tech = 3,
		/obj/item/clothing/under/rank/cargo/tech/skirt = 3,
		/obj/item/clothing/shoes/sneakers/black = 3,
		/obj/item/clothing/gloves/fingerless = 3,
		/obj/item/clothing/head/beret/cargo = 3,
		/obj/item/clothing/mask/bandana/striped/cargo = 3,
		/obj/item/clothing/head/soft = 3,
		/obj/item/radio/headset/headset_cargo = 3,
	)
	premium = list(
		/obj/item/clothing/under/rank/cargo/miner = 3,
		/obj/item/clothing/head/costume/mailman = 1,
		/obj/item/clothing/under/misc/mailman = 1,
	)
	contraband = list(
		/obj/item/clothing/under/wonka = 1,
		/obj/item/clothing/head/wonka = 1,
		/obj/item/cane = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/cargo_wardrobe
	default_price = /obj/machinery/vending/wardrobe::default_price
	extra_price = /obj/machinery/vending/wardrobe::extra_price
	payment_department = ACCOUNT_CAR
	panel_type = /obj/machinery/vending/wardrobe::panel_type
	light_mask = /obj/machinery/vending/wardrobe::light_mask

/obj/item/vending_refill/wardrobe/cargo_wardrobe
	machine_name = "CargoDrobe"

/obj/machinery/vending/access/wardrobe_cargo/build_access_list(list/inventory)
	inventory[ACCESS_QM] = list(
		/obj/item/clothing/head/beret/cargo/qm = 1,
		/obj/item/clothing/head/beret/cargo/qm/alt = 1,
		/obj/item/clothing/neck/cloak/qm = 1,
		/obj/item/clothing/neck/mantle/qm = 1,
		/obj/item/clothing/under/rank/cargo/qm = 1,
		/obj/item/clothing/under/rank/cargo/qm/skirt = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/gorka = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/turtleneck/skirt = 1,
		/obj/item/clothing/suit/brownfurrich = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/casual = 1,
		/obj/item/clothing/suit/toggle/jacket/supply/head = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/formal = 1,
		/obj/item/clothing/under/rank/cargo/qm/nova/formal/skirt = 1,
		/obj/item/clothing/shoes/sneakers/brown = 1,
	)

/obj/machinery/vending/access/engi_wardrobe
	name = "EngiDrobe"
	desc = "A vending machine renowned for vending industrial grade clothing."
	icon_state = "engidrobe"
	product_ads = "Guaranteed to protect your feet from industrial accidents!;Afraid of radiation? Then wear yellow!"
	vend_reply = "Thank you for using the EngiDrobe!"

	products = list(
		/obj/item/clothing/accessory/pocketprotector = 3,
		/obj/item/storage/backpack/duffelbag/engineering = 3,
		/obj/item/storage/backpack/industrial = 3,
		/obj/item/storage/backpack/satchel/eng = 3,
		/obj/item/clothing/suit/hooded/wintercoat/engineering = 3,
		/obj/item/clothing/under/rank/engineering/engineer = 3,
		/obj/item/clothing/under/rank/engineering/engineer/skirt = 3,
		/obj/item/clothing/under/rank/engineering/engineer/hazard = 3,
		/obj/item/clothing/suit/hazardvest = 3,
		/obj/item/clothing/shoes/workboots = 3,
		/obj/item/clothing/head/beret/engi = 3,
		/obj/item/clothing/mask/bandana/striped/engineering = 3,
		/obj/item/clothing/head/utility/hardhat = 3,
		/obj/item/clothing/head/utility/hardhat/welding = 3,
		/obj/item/radio/headset/headset_eng = 3,
		/obj/item/clothing/under/rank/engineering/engineer/nova/trouser = 3,
		/obj/item/clothing/under/rank/engineering/engineer/nova/utility = 3,
		/obj/item/clothing/under/rank/engineering/engineer/nova/hazard_chem = 3,
		/obj/item/clothing/under/misc/overalls = 3,
		/obj/item/clothing/suit/toggle/jacket/engi = 3,
		/obj/item/clothing/head/utility/hardhat/orange = 2,
		/obj/item/clothing/head/utility/hardhat/welding/orange = 2,
		/obj/item/clothing/head/utility/hardhat/dblue = 2,
		/obj/item/clothing/head/utility/hardhat/welding/dblue = 2,
		/obj/item/clothing/head/utility/hardhat/red = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/engi_wardrobe
	light_color = COLOR_VIVID_YELLOW
	default_price = /obj/machinery/vending/wardrobe::default_price
	extra_price = /obj/machinery/vending/wardrobe::extra_price
	payment_department = ACCOUNT_ENG
	panel_type = /obj/machinery/vending/wardrobe::panel_type
	light_mask = /obj/machinery/vending/wardrobe::light_mask

/obj/item/vending_refill/wardrobe/engi_wardrobe
	machine_name = "EngiDrobe"

/obj/machinery/vending/access/engi_wardrobe/build_access_list(list/inventory)
	inventory[ACCESS_TCOMMS_ADMIN] = list(
		/obj/item/clothing/under/rank/engineering/signal_tech = 2,
		/obj/item/clothing/suit/hooded/wintercoat/engineering/signal_tech = 2,
		/obj/item/clothing/gloves/color/black = 2,
	)
