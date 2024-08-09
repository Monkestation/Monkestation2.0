/obj/item/storage/bag/garment
	name = "garment bag"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "garment_bag"
	desc = "A bag for storing extra clothes and shoes."
	slot_flags = NONE
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/garment/captain
	name = "captain's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the captain."

/obj/item/storage/bag/garment/hos
	name = "head of security's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of security."

/obj/item/storage/bag/garment/hop
	name = "head of personnel's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the head of personnel."

/obj/item/storage/bag/garment/research_director
	name = "research director's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the research director."

/obj/item/storage/bag/garment/chief_medical
	name = "chief medical officer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief medical officer."

/obj/item/storage/bag/garment/engineering_chief
	name = "chief engineer's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the chief engineer."

/obj/item/storage/bag/garment/quartermaster
	name = "quartermasters's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the quartermaster."

/obj/item/storage/bag/garment/warden
	name = "warden's garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to the warden."

/obj/item/storage/bag/garment/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = FALSE
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 15
	atom_storage.insert_preposition = "in"
	atom_storage.set_holdable(list(
		/obj/item/clothing,
	))

/obj/item/storage/bag/garment/captain/PopulateContents()
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/captains_formal(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/clothing/suit/jacket/capjacket(src)
	new /obj/item/clothing/glasses/sunglasses/gar/giga(src)
	new /obj/item/clothing/gloves/captain(src)
	new /obj/item/clothing/head/costume/crown/fancy(src)
	new /obj/item/clothing/head/hats/caphat(src)
	new /obj/item/clothing/head/hats/caphat/parade(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/head/nanner_crown(src)
	new /obj/item/clothing/head/hats/caphat/bunnyears_captain(src)
	new /obj/item/clothing/neck/tie/bunnytie/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/tailcoat_captain(src)
	new /obj/item/clothing/under/rank/captain/bunnysuit(src)
	new /obj/item/clothing/shoes/heels/blue(src)

/obj/item/storage/bag/garment/hop/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/skirt(src)
	new /obj/item/clothing/suit/armor/vest/hop(src)
	new /obj/item/clothing/suit/hooded/wintercoat/hop(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/head/hats/hopcap(src)
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/head/playbunnyears/hop(src)
	new /obj/item/clothing/neck/tie/bunnytie/hop(src)
	new /obj/item/clothing/suit/armor/hop_tailcoat(src)
	new /obj/item/clothing/under/rank/civilian/hop_bunnysuit(src)
	new /obj/item/clothing/shoes/heels/lightblue(src)

/obj/item/storage/bag/garment/hos/PopulateContents()
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/grey(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade/female(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/hos_formal(src)
	new /obj/item/clothing/suit/armor/hos/trenchcoat/winter(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/giga(src)
	new /obj/item/clothing/head/hats/hos/cap(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/clothing/head/playbunnyears/hos(src)
	new /obj/item/clothing/neck/tie/bunnytie/security(src)
	new /obj/item/clothing/suit/armor/hos_tailcoat(src)
	new /obj/item/clothing/under/rank/security/head_of_security/bunnysuit(src)
	new /obj/item/clothing/shoes/jackboots/gogo_boots(src)

/obj/item/storage/bag/garment/research_director/PopulateContents()
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/under/rank/rnd/research_director/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/science/rd(src)
	new /obj/item/clothing/head/beret/science/rd(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/neck/cloak/rd(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/head/playbunnyears/rd(src)
	new /obj/item/clothing/neck/tie/bunnytie/rd(src)
	new /obj/item/clothing/suit/jacket/research_director/tailcoat(src)
	new /obj/item/clothing/under/rank/rnd/research_director/bunnysuit(src)
	new /obj/item/clothing/shoes/heels/purple(src)

/obj/item/storage/bag/garment/chief_medical/PopulateContents()
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/scrubs(src)
	new /obj/item/clothing/suit/hooded/wintercoat/medical/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/clothing/head/beret/medical/cmo(src)
	new /obj/item/clothing/head/utility/surgerycap/cmo(src)
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/clothing/shoes/sneakers/blue (src)
	new /obj/item/clothing/head/playbunnyears/cmo(src)
	new /obj/item/clothing/neck/tie/bunnytie/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo_tailcoat(src)
	new /obj/item/clothing/under/rank/medical/cmo_bunnysuit(src)
	new /obj/item/clothing/shoes/heels/white(src)

/obj/item/storage/bag/garment/engineering_chief/PopulateContents()
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/engineering/ce(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/clothing/gloves/chief_engineer(src)
	new /obj/item/clothing/head/utility/hardhat/white(src)
	new /obj/item/clothing/head/utility/hardhat/welding/white(src)
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/head/playbunnyears/ce(src)
	new /obj/item/clothing/neck/tie/bunnytie/ce(src)
	new /obj/item/clothing/suit/utility/fire/ce_tailcoat(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/bunnysuit(src)
	new /obj/item/clothing/shoes/workboots/heeled(src)

/obj/item/storage/bag/garment/quartermaster/PopulateContents()
	new /obj/item/clothing/under/rank/cargo/qm(src)
	new /obj/item/clothing/under/rank/cargo/qm/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/cargo/qm(src)
	new /obj/item/clothing/suit/utility/fire/firefighter(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/neck/cloak/qm(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/head/playbunnyears/quartermaster(src)
	new /obj/item/clothing/neck/tie/bunnytie/cargo(src)
	new /obj/item/clothing/suit/jacket/tailcoat/quartermaster(src)
	new /obj/item/clothing/under/rank/cargo/quartermaster_bunnysuit(src)
	new /obj/item/clothing/shoes/heels/lightgrey(src)


/obj/item/storage/bag/garment/warden/PopulateContents()
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/hats/warden(src)
	new /obj/item/clothing/head/hats/warden/drill(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/under/rank/security/warden/skirt(src)
	new /obj/item/clothing/head/playbunnyears/warden(src)
	new /obj/item/clothing/neck/tie/bunnytie/security(src)
	new /obj/item/clothing/suit/armor/warden_tailcoat(src)
	new /obj/item/clothing/under/rank/security/warden_bunnysuit(src)
	new /obj/item/clothing/shoes/heels/red(src)
