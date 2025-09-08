/datum/design/beanbag_slug
	name = "Beanbag Slug (Less Lethal)"
	id = "beanbag_slug"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/rubbershot
	name = "Rubber Shot (Less Lethal)"
	id = "rubber_shot"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/shotgun/rubbershot
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c38
	name = "Speed Loader (.38) (Lethal)"
	id = "c38"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*10)
	build_path = /obj/item/ammo_box/c38
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/recorder
	name = "Universal Recorder"
	id = "recorder"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*0.6, /datum/material/glass = SMALL_MATERIAL_AMOUNT*0.3)
	build_path = /obj/item/taperecorder/empty
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/tape
	name = "Universal Recorder Tape"
	id = "tape"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*0.2, /datum/material/glass = SMALL_MATERIAL_AMOUNT*0.2)
	build_path = /obj/item/tape/random
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/foam_dart
	name = "Box of Foam Darts (Harmless)"
	id = "foam_dart"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/ammo_box/foambox
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/flamethrower
	name = "Flamethrower (Lethal/Highly Destructive)"
	id = "flamethrower"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/flamethrower/full
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_RANGED,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/electropack
	name = "Electropack"
	id = "electropack"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*5, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT*2.5)
	build_path = /obj/item/electropack
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/handcuffs
	name = "Handcuffs"
	id = "handcuffs"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/restraints/handcuffs
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/handcuffs/sec
	id = "handcuffs_s"
	build_type = PROTOLATHE | AWAY_LATHE
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	autolathe_exportable = FALSE

/datum/design/receiver
	name = "Modular Receiver"
	id = "receiver"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*7.5)
	build_path = /obj/item/weaponcrafting/receiver
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_PARTS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/shotgun_dart
	name = "Shotgun Dart (Lethal)"
	id = "shotgun_dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/shotgun/dart
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/shotgun_slug
	name = "Shotgun Slug"
	id = "shotgun_slug"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/shotgun
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/incendiary_slug
	name = "Incendiary Slug (Lethal)"
	id = "incendiary_slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/shotgun/incendiary
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/riot_dart
	name = "Foam Riot Dart (Nonlethal)"
	id = "riot_dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =HALF_SHEET_MATERIAL_AMOUNT) //Discount for making individually - no box = less iron!
	build_path = /obj/item/ammo_casing/caseless/foam_dart/riot
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/riot_darts
	name = "Foam Riot Dart Box (Nonlethal)"
	id = "riot_darts"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*25) //Comes with 40 darts
	build_path = /obj/item/ammo_box/foambox/riot
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/a357
	name = ".357 Casing (VERY Lethal)"
	id = "a357"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/a357
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/a762surplus
	name = "7.62 Surplus Bullet Casing (VERY Lethal)"
	id = "a762surplus"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/a762/surplus
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c10mm
	name = "Ammo Box (10mm) (Lethal)"
	id = "c10mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 300)
	build_path = /obj/item/ammo_box/c10mm
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c45
	name = "Ammo Box (.45) (Lethal)"
	id = "c45"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 300)
	build_path = /obj/item/ammo_box/c45
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY


/datum/design/c45/rubber
	name = "Ammo Box (.45) (Rubber)"
	id = "c45rubber"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 300)
	build_path = /obj/item/ammo_box/c45/rubber
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY


/datum/design/g45l
	name = "Ammo Box (.45 Long) (Rubber)"
	id = "g45l"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*15)
	build_path = /obj/item/ammo_box/g45l/rubber
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/g45lethal
	name = "Ammo Box (.45 Long) (Lethal)"
	id = "g45lethal"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*17.5)
	build_path = /obj/item/ammo_box/g45l
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/c9mm
	name = "Ammo Box (9mm) (Lethal)"
	id = "c9mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron =SMALL_MATERIAL_AMOUNT * 300)
	build_path = /obj/item/ammo_box/c9mm
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/a40MM
	name = "Light 40mm HE Grenade"
	id = "a40mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	build_path = /obj/item/ammo_casing/a40mm/weak
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/telescreen_interrogation
	name = "Interrogation Telescreen"
	id = "telescreen_interrogation"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*5,
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5,
	)
	build_path = /obj/item/wallframe/telescreen/interrogation
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/telescreen_prison
	name = "Prison Telescreen"
	id = "telescreen_prison"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT*5,
		/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5,
	)
	build_path = /obj/item/wallframe/telescreen/prison
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY


/datum/design/fss
	name = "FSS-550"
	desc = "FSS-550 autorifle."
	id = "fss"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*10, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/gun/ballistic/automatic/wt550/fss/no_mag
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss //WT-550 ammo but printable in autolathe and you get it from a design disk.
	name = "WT-550 Autorifle Magazine (4.6x30mm) (Lethal)"
	desc = "A 20 round magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_fss"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*6)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/ap_mag
	name = "WT-550 Autorifle Armour Piercing Magazine (4.6x30mm AP) (Lethal)"
	desc = "A 20 round armour piercing magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_ap_fss"
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT*15, /datum/material/silver = SMALL_MATERIAL_AMOUNT*6)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/ic_mag
	name = "WT-550 Autorifle Incendiary Magazine (4.6x30mm IC) (Lethal/Highly Destructive)"
	desc = "A 20 round armour piercing magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_ic_fss"
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT*15, /datum/material/silver = SMALL_MATERIAL_AMOUNT*6, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/rub_mag
	name = "WT-550 Autorifle Rubber Magazine (4.6x30mm R) (Lethal)"
	desc = "A 20 round rubber magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_rub_fss"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtrub
	category = list(RND_CATEGORY_IMPORTED)

/datum/design/mag_autorifle_fss/salt_mag
	name = "WT-550 Autorifle Saltshot Magazine (4.6x30mm SALT) (Non-Lethal)"
	desc = "A 20 round saltshot magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_salt_fss"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3, /datum/material/plasma = SMALL_MATERIAL_AMOUNT*6)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtsalt
	category = list(RND_CATEGORY_IMPORTED)


/datum/design/nifsoft_remover
	name = "Lopland 'Wrangler' NIF-Cutter"
	desc = "A small device that lets the user remove NIFSofts from a NIF user."
	id = "nifsoft_remover"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/nifsoft_remover
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/nifsoft_hud/security
	name = "Security HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Security HUD NIFsoft."
	id = "nifsoft_hud_security"
	build_path = /obj/item/disk/nifsoft_uploader/sec_hud
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

