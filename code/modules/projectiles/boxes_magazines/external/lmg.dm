///SAW belts

/obj/item/ammo_box/magazine/mm712x82
	name = "box magazine (7.12x82mm)"
	icon_state = "a762-50"
	ammo_type = /obj/item/ammo_casing/mm712x82
	caliber = CALIBER_712X82MM
	max_ammo = 50

/obj/item/ammo_box/magazine/mm712x82/hollow
	name = "box magazine (Hollow-Point 7.12x82mm)"
	ammo_type = /obj/item/ammo_casing/mm712x82/hollow

/obj/item/ammo_box/magazine/mm712x82/ap
	name = "box magazine (Armor Penetrating 7.12x82mm)"
	ammo_type = /obj/item/ammo_casing/mm712x82/ap

/obj/item/ammo_box/magazine/mm712x82/incen
	name = "box magazine (Incendiary 7.12x82mm)"
	ammo_type = /obj/item/ammo_casing/mm712x82/incen

/obj/item/ammo_box/magazine/mm712x82/match
	name = "box magazine (Match 7.12x82mm)"
	ammo_type = /obj/item/ammo_casing/mm712x82/match

/obj/item/ammo_box/magazine/mm712x82/bouncy
	name = "box magazine (Rubber 7.12x82mm)"
	ammo_type = /obj/item/ammo_casing/mm712x82/bouncy

/obj/item/ammo_box/magazine/mm712x82/bouncy/hicap
	name = "hi-cap box magazine (Rubber 7.12x82mm)"
	max_ammo = 150

/obj/item/ammo_box/magazine/mm712x82/update_icon_state()
	. = ..()
	icon_state = "a762-[min(round(ammo_count(), 10), 50)]" //Min is used to prevent high capacity magazines from attempting to get sprites with larger capacities


///Minigun Drum

/obj/item/ammo_box/magazine/minigun22
	name = "Minigun drum (.22 LR)"
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "22minigun_drum"
	ammo_type = /obj/item/ammo_casing/minigun22
	w_class = WEIGHT_CLASS_NORMAL
	caliber = CALIBER_22LR
	max_ammo = 300


///Quarad Drums

/obj/item/ammo_box/magazine/c65xeno_drum
	name = "\improper 6.5mm drum magazine"
	desc = "A hefty 120 round drum of 6.5mm frangible rounds, designed for minimal damage to company property."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drum"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	ammo_type = /obj/item/ammo_casing/c65xeno
	caliber = CALIBER_C65XENO
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/pierce
	name = "\improper 6.5mm AP drum magazine"
	desc = "A hefty 120 round drum of 6.5mm saboted tungsten penetrators, designed to punch through multiple targets. Warning: Liable to break windows."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumP"

	ammo_type = /obj/item/ammo_casing/c65xeno/pierce
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/incendiary
	name = "\improper 6.5mm incendiary drum magazine"
	desc = "A hefty 120 round drum of 6.5mm rounds tipped with an incendiary compound."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumI"

	ammo_type = /obj/item/ammo_casing/c65xeno/incendiary
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/evil
	name = "\improper 6.5mm FMJ drum magazine"
	desc = "A hefty 120 round drum of 6.5mm FMJ rounds."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumevil"

	ammo_type = /obj/item/ammo_casing/c65xeno/evil
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/pierce/evil
	name = "\improper 6.5mm UDS drum magazine"
	desc = "A hefty 120 round drum of 6.5mm Uranium Discarding Sabot rounds. No, NOT depleted uranium. Prepare for your enemies to be irradiated."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumPevil"

	ammo_type = /obj/item/ammo_casing/c65xeno/pierce/evil
	max_ammo = 120

/obj/item/ammo_box/magazine/c65xeno_drum/incendiary/evil
	name = "\improper 6.5mm Inferno drum magazine"
	desc = "A hefty 120 round drum of 6.5mm inferno rounds. They leave a trail of fire as they fly."

	icon = 'monkestation/icons/obj/weapons/guns/ammo.dmi'
	icon_state = "c65xeno_drumIevil"

	ammo_type = /obj/item/ammo_casing/c65xeno/incendiary/evil
	max_ammo = 120

