//Weapon beacon
/obj/item/choice_beacon/blueshield
	name = "armament beacon"
	desc = "A single use beacon to deliver a gunset of your choice. Please only call this in your office"
	company_source = "Sol Defense Contracting"
	company_message = span_bold("Supply Pod incoming, please stand by.")

/obj/item/choice_beacon/blueshield/generate_display_names()
	var/static/list/selectable_gun_types = list(
		"Unmarked Takbok Revolver Gunset" = /obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok/blueshield,
		"Custom Hellfire Laser Rifle" = /obj/item/gun/energy/laser/hellgun/blueshield,
		"Bogseo Submachinegun Gunset" = /obj/item/storage/toolbox/guncase/skyrat/xhihao_large_case/bogseo,
		"Tech-9" = /obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9,
		"S.A.Y.A. Arm Defense System Cyberset" = /obj/item/storage/box/shield_blades,
	)

	return selectable_gun_types

// Gunset for the custom Takbok Revolver
/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok/blueshield
	name = "Unmarked 'Takbok' gunset"

	weapon_to_spawn = /obj/item/gun/ballistic/revolver/takbok/blueshield

/obj/item/storage/toolbox/guncase/skyrat/pistol/trappiste_small_case/takbok/blueshield/PopulateContents()
	new weapon_to_spawn (src)

	generate_items_inside(list(
		/obj/item/ammo_box/c585trappiste/incapacitator = 1,
		/obj/item/ammo_box/c585trappiste = 1,
		/obj/item/ammo_box/c585trappiste/hollowpoint = 1,
	), src)

/obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9
	name = "Tech-9 Gunset"
	desc = "A thick yellow gun case with foam inserts laid out to fit a weapon, magazines, and gear securely. The five square grid of Tech-9 is displayed prominently on the top."

	icon = 'monkestation/code/modules/blueshift/icons/obj/gunsets.dmi'
	icon_state = "case_trappiste"

	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/cases_righthand.dmi'
	inhand_icon_state = "yellowcase"

	weapon_to_spawn = /obj/item/gun/ballistic/automatic/pistol/tech_9/no_mag
	extra_to_spawn = /obj/item/ammo_box/magazine/m35/rubber

/obj/item/storage/toolbox/guncase/skyrat/pistol/tech_9/PopulateContents()
	new weapon_to_spawn (src)

	generate_items_inside(list(
		/obj/item/ammo_box/magazine/m35/rubber = 2,
		/obj/item/ammo_box/magazine/m35 = 1,
	), src)

/obj/item/storage/box/shield_blades
	name = "S.A.Y.A. Arm Defense System Cyberset"
	desc = "A box with essentials for S.A.Y.A. Arm Defense System. Blades that serve protection purposes, while being harder to swing and dealing less wounds to the target."
	icon_state = "cyber_implants"

/obj/item/storage/box/shield_blades/PopulateContents()
	new /obj/item/autosurgeon/organ/shield_blade(src)
	new /obj/item/autosurgeon/organ/shield_blade/l(src)
