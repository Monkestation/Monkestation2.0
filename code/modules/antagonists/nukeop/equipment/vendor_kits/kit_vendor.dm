/obj/machinery/vending/donkweaponry
	name = "\improper Donk Weaponry Vendor"
	desc = "A Donk Co. sponsored weapon dispenser for the Syndicate. Make sure to have your vouchers!"
	icon_state = "syndi"
	panel_type = "panel18"
	product_slogans = "Get your cool guns today!;Trigger a valid hunter today!;Quality weapons for fair prices!"
	product_ads = "Feel robust with your guns!;Make your next murder FUN!;No safeties required!"
	vend_reply = "DEATH TO NANOTRASEN!"
	onstation = FALSE
	products = list(
		/obj/item/trench_tool = 2,
		/obj/item/clothing/glasses/night = 2,
		/obj/item/ammo_box/magazine/m9mm = 3,
		/obj/item/knife/combat = 2,
		/obj/item/grenade/smokebomb = 4,
		/obj/item/climbing_hook/syndicate = 2,
		/obj/item/storage/belt/military = 2,
		/obj/item/storage/belt/holster/nukie = 2,
		/obj/item/radio/headset/syndicate = 2,
		/obj/item/clothing/under/syndicate = 2,
		/obj/item/clothing/under/syndicate/skirt = 2,
		/obj/item/clothing/shoes/sneakers/black = 2,
	)
	contraband = list(
		/obj/item/clothing/neck/large_scarf/syndie = 2,
		/obj/item/storage/backpack/duffelbag/clown/syndie = 1,
		/obj/item/storage/box/syndie_kit/stickers = 1,
	)
	refill_canister = /obj/item/vending_refill/donkweaponry
	armor_type = /datum/armor/vending_donk_weaponry
	resistance_flags = FIRE_PROOF | INDESTRUCTIBLE
	light_mask = "donksoft-light-mask"


/obj/item/vending_refill/donkweaponry
	icon_state = "refill_sec"

/datum/armor/vending_donk_weaponry
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	fire = 100
	acid = 50

/obj/machinery/vending/donkweaponry/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/syndicate_voucher))
		redeem_voucher(weapon, user)
		return
	return ..()

/obj/machinery/vending/donkweaponry/proc/redeem_voucher(obj/item/security_voucher/voucher, mob/redeemer)
	var/static/list/set_types

	var/voucher_set = /datum/voucher_set/syndicate

	if(istype(voucher, /obj/item/syndicate_voucher/kit))
		voucher_set = /datum/voucher_set/syndicate/kit
	if(istype(voucher, /obj/item/syndicate_voucher/utility))
		voucher_set = /datum/voucher_set/syndicate/utility
	if(istype(voucher, /obj/item/syndicate_voucher/leader))
		voucher_set = /datum/voucher_set/syndicate/leader

	set_types = list()
	for(var/datum/voucher_set/static_set as anything in subtypesof(voucher_set))
		set_types[initial(static_set.name)] = new static_set

	var/list/items = list()
	for(var/set_name in set_types)
		var/datum/voucher_set/current_set = set_types[set_name]
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = current_set.icon, icon_state = current_set.icon_state)
		option.info = span_boldnotice(current_set.description)
		items[set_name] = option

	var/selection = show_radial_menu(redeemer, src, items, custom_check = FALSE, radius = 38, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	var/datum/voucher_set/chosen_set = set_types[selection]
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	for(var/item in chosen_set.set_items)
		new item(drop_location())

	SSblackbox.record_feedback("tally", "syndicate_voucher_redeemed", 1, selection)
	qdel(voucher)
