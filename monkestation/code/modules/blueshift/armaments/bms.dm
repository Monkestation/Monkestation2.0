/datum/armament_entry/company_import/bms
	category = BASSETT_MOTOR_SOCIETY_NAME
	company_bitflag = CARGO_COMPANY_BMS

/datum/armament_entry/company_import/bms/clothing // unrestricted, pricier then normal larp, the armor is expensive to others
	subcategory = "Clothing"
	cost = PAYCHECK_COMMAND * 2

/datum/armament_entry/company_import/bms/clothing/battledress
	item_type = /obj/item/clothing/under/costume/warden

/datum/armament_entry/company_import/bms/clothing/legionfatigues
	item_type = /obj/item/clothing/under/costume/colonial

/datum/armament_entry/company_import/bms/clothing/Whelmet
	item_type =/obj/item/clothing/head/helmet/warden

/datum/armament_entry/company_import/bms/clothing/Chelmet
	item_type =/obj/item/clothing/head/helmet/colonial

/datum/armament_entry/company_import/bms/clothing/gunnerplate
	item_type = /obj/item/clothing/suit/armor/foxhole_warden
	cost = PAYCHECK_COMMAND * 4
/datum/armament_entry/company_import/bms/clothing/gunnerplatehelmet
	item_type = /obj/item/clothing/head/helmet/warden_heavy
	cost = PAYCHECK_COMMAND * 2.5

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
	contraband = TRUE

/datum/armament_entry/company_import/bms/heavy/neville
	item_type = /obj/item/gun/ballistic/automatic/neville
	cost = PAYCHECK_COMMAND * 44
	contraband = TRUE

/datum/armament_entry/company_import/bms/heavy/lamentum
	item_type = /obj/item/deployable_lamentum_folded
	cost = PAYCHECK_COMMAND * 48
	contraband = TRUE

/datum/armament_entry/company_import/bms/vehicles // No shit that the vics are restricted
	subcategory = "Vehicles"
	restricted = TRUE

/datum/armament_entry/company_import/bms/vehicles/argonaut
	item_type = /obj/vehicle/ridden/argonaut
	cost = PAYCHECK_COMMAND * 150

/datum/armament_entry/company_import/bms/vehicles/odyssey
	item_type = /obj/vehicle/ridden/odyssey
	cost = PAYCHECK_COMMAND * 185

/datum/armament_entry/company_import/bms/vehicles/kingspire
	item_type = /obj/item/mecha_parts/chassis/kingspire
	cost = PAYCHECK_COMMAND * 200
	contraband = TRUE

/datum/armament_entry/company_import/bms/vehicles/ratcatcherbelt
	item_type = /obj/item/mecha_ammo/makeshift/lighttankmg
	cost = PAYCHECK_COMMAND * 2
	contraband = TRUE

/datum/armament_entry/company_import/bms/vehicles/percutio
	item_type = /obj/item/mecha_parts/chassis/percutio
	cost = PAYCHECK_COMMAND * 220
	contraband = TRUE

/datum/armament_entry/company_import/bms/vehicles/typhonmag
	item_type = /obj/item/mecha_ammo/antitankammo
	cost = PAYCHECK_COMMAND * 3
	contraband = TRUE

/datum/armament_entry/company_import/bms/vehicles/callahanmeme
	item_type = /obj/vehicle/sealed/mecha/callahan
	cost = PAYCHECK_COMMAND * 1000000
	contraband = TRUE

/datum/armament_entry/company_import/bms/vehicles/nakkinmeme
	item_type = /obj/vehicle/sealed/mecha/nakki
	cost = PAYCHECK_COMMAND * 1000000
	contraband = TRUE

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
	contraband = TRUE

/datum/armament_entry/company_import/bms/magazines/malone
	item_type = /obj/item/ammo_box/magazine/malone
	cost = PAYCHECK_COMMAND*4
	contraband = TRUE
