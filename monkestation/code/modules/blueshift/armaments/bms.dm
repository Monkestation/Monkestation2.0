/datum/armament_entry/company_import/bms
	category = BASSET_MOTOR_SOCIETY_NAME
	company_bitflag = CARGO_COMPANY_BMS



/datum/armament_entry/company_import/sol_defense/light // unrestricted, but very very expensive
	subcategory = "Small Arms"

/datum/armament_entry/company_import/bms/light/argenti
	item_type = /obj/item/gun/ballistic/automatic/argenti
	cost = PAYCHECK_COMMAND * 20

/datum/armament_entry/company_import/bms/light/hangman
	item_type = /obj/item/gun/ballistic/automatic/hangman
	cost = PAYCHECK_COMMAND * 18

/datum/armament_entry/company_import/bms/heavy // restricted, this shits scary
	subcategory = "Support weapons"

/datum/armament_entry/company_import/bms/heavy/ignifist
	item_type = /obj/item/gun/ballistic/automatic/ignifist
	cost = PAYCHECK_COMMAND * 8

/datum/armament_entry/company_import/bms/heavy/malone
	item_type = /obj/item/gun/ballistic/automatic/malone
	cost = PAYCHECK_COMMAND * 32

/datum/armament_entry/company_import/bms/heavy/neville
	item_type = /obj/item/gun/ballistic/automatic/neville
	cost = PAYCHECK_COMMAND * 38

/datum/armament_entry/company_import/bms/tanks // No shit that the tank is restricted
	subcategory = "Armored Vehicles"
	restricted = TRUE

/datum/armament_entry/company_import/bms/tanks/kingspire
	item_type = /obj/vehicle/sealed/mecha/kingspire
	cost = PAYCHECK_COMMAND * 260

/datum/armament_entry/company_import/bms/magazines // feed the war machine
	subcategory = "Magazines"
	cost = PAYCHECK_CREW*3

/datum/armament_entry/company_import/bms/magazines/argenti_mag
	item_type = /obj/item/ammo_box/magazine/argenti

/datum/armament_entry/company_import/sol_defense/magazines/hangman_mag
	item_type = /obj/item/ammo_box/magazine/hangman

/datum/armament_entry/company_import/sol_defense/magazines/neville_mag
	item_type = /obj/item/ammo_box/magazine/neville
	cost = PAYCHECK_COMMAND*4

/datum/armament_entry/company_import/sol_defense/magazines/malone_mag
	item_type = /obj/item/ammo_box/magazine/malone
	cost = PAYCHECK_COMMAND*4
