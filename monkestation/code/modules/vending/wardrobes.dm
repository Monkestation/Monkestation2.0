/obj/machinery/vending/wardrobe/warden_wardrobe
	name = "\improper WarDrobe"
	desc = "A vending machine for wardens and warden-related clothing! Not to be confused with a wardrobe or the WARDrobe."
	icon = 'monkestation/icons/obj/vending.dmi'
	icon_state = "wardrobe"
	product_ads = "You're better than the rest of them, dress like it!;Error. Item: 'krav maga gloves' not found!;Now with cushioned pants seat!"
	vend_reply = "Thank you for using the SecDrobe!"
	products = list(
		/obj/item/storage/backpack/security = 1,
		/obj/item/storage/backpack/satchel/sec = 1,
		/obj/item/storage/backpack/duffelbag/sec = 1,
		/obj/item/clothing/shoes/jackboots/sec = 1,
		/obj/item/clothing/under/rank/security/warden = 1,
		/obj/item/clothing/under/rank/security/warden/skirt = 1,
		/obj/item/clothing/under/rank/security/warden/formal = 1,
		/obj/item/clothing/under/rank/security/warden/grey = 1,
		/obj/item/clothing/suit/armor/vest/warden = 1,
		/obj/item/clothing/head/hats/warden = 1,
		/obj/item/clothing/head/hats/warden/drill = 1,
		/obj/item/clothing/head/beret/sec/navywarden = 1,
		/obj/item/clothing/suit/hooded/wintercoat/security = 1,
		/obj/item/clothing/mask/bandana/striped/security = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/clothing/gloves/color/red = 1,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/sec_wardrobe
	payment_department = ACCOUNT_SEC
	light_color = COLOR_MOSTLY_PURE_RED

/obj/item/vending_refill/wardrobe/warden_wardrobe
	machine_name = "WarDrobe"
