/datum/armament_entry/company_import/bms
	category = BASSETT_MOTOR_SOCIETY_NAME
	company_bitflag = CARGO_COMPANY_BMS



/datum/armament_entry/company_import/bms/light // unrestricted, but very very expensive
	subcategory = "Small Arms"

/datum/armament_entry/company_import/bms/light/cascadier
	item_type = /obj/item/gun/ballistic/automatic/pistol/cascadier
	cost = PAYCHECK_COMMAND * 9

/datum/armament_entry/company_import/bms/light/argenti
	item_type = /obj/item/gun/ballistic/automatic/argenti
	cost = PAYCHECK_COMMAND * 22

/datum/armament_entry/company_import/bms/light/hangman
	item_type = /obj/item/gun/ballistic/automatic/hangman
	cost = PAYCHECK_COMMAND * 20

/datum/armament_entry/company_import/bms/heavy // restricted, this shits scary
	subcategory = "Support weapons"
	restricted = TRUE

/datum/armament_entry/company_import/bms/heavy/ignifist
	item_type = /obj/item/gun/ballistic/ignifist
	cost = PAYCHECK_COMMAND * 12

/datum/armament_entry/company_import/bms/heavy/malone
	item_type = /obj/item/gun/ballistic/automatic/malone
	cost = PAYCHECK_COMMAND * 36

/datum/armament_entry/company_import/bms/heavy/neville
	item_type = /obj/item/gun/ballistic/automatic/neville
	cost = PAYCHECK_COMMAND * 44

/datum/armament_entry/company_import/bms/heavy/lamentum
	item_type = /obj/item/deployable_lamentum_folded
	cost = PAYCHECK_COMMAND * 48

/datum/armament_entry/company_import/bms/tanks // No shit that the tank is restricted
	subcategory = "Armored Vehicles"
	restricted = TRUE

/datum/armament_entry/company_import/bms/tanks/kingspire
	item_type = /obj/vehicle/sealed/mecha/kingspire
	cost = PAYCHECK_COMMAND * 380

/datum/armament_entry/company_import/bms/tanks/ratcatcherbelt
	item_type = /obj/item/mecha_ammo/makeshift/lighttankmg
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/bms/magazines // feed the war machine
	subcategory = "Magazines"
	cost = PAYCHECK_CREW*3

/datum/armament_entry/company_import/bms/magazines/cascadier
	item_type = /obj/item/ammo_box/magazine/cascadier
	cost = PAYCHECK_CREW*1.5

/datum/armament_entry/company_import/bms/magazines/argenti
	item_type = /obj/item/ammo_box/magazine/argenti

/datum/armament_entry/company_import/bms/magazines/hangman
	item_type = /obj/item/ammo_box/magazine/hangman

/datum/armament_entry/company_import/bms/magazines/neville
	item_type = /obj/item/ammo_box/magazine/neville
	cost = PAYCHECK_COMMAND*4

/datum/armament_entry/company_import/bms/magazines/malone
	item_type = /obj/item/ammo_box/magazine/malone
	cost = PAYCHECK_COMMAND*4