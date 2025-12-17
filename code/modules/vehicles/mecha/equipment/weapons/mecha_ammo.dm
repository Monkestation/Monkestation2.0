/obj/item/mecha_ammo
	name = "generic ammo box"
	desc = "A box of ammo for an unknown weapon."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/mecha/mecha_ammo.dmi'
	icon_state = "empty"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/rounds = 0
	var/direct_load //For weapons where we re-load the weapon itself rather than adding to the ammo storage.
	var/load_audio = 'sound/weapons/gun/general/mag_bullet_insert.ogg'
	var/ammo_type
	/// whether to qdel this mecha_ammo when it becomes empty
	var/qdel_on_empty = FALSE

/obj/item/mecha_ammo/update_name()
	. = ..()
	name = "[rounds ? null : "empty "][initial(name)]"

/obj/item/mecha_ammo/update_desc()
	. = ..()
	desc = rounds ? initial(desc) : "An exosuit ammuniton box that has since been emptied. It can be safely folded for recycling."

/obj/item/mecha_ammo/update_icon_state()
	icon_state = rounds ? initial(icon_state) : "[initial(icon_state)]_e"
	return ..()

/obj/item/mecha_ammo/attack_self(mob/user)
	..()
	if(rounds)
		to_chat(user, span_warning("You cannot flatten the ammo box until it's empty!"))
		return

	to_chat(user, span_notice("You fold [src] flat."))
	var/trash = new /obj/item/stack/sheet/iron(user.loc)
	qdel(src)
	user.put_in_hands(trash)

/obj/item/mecha_ammo/examine(mob/user)
	. = ..()
	if(rounds)
		. += "There [rounds > 1?"are":"is"] [rounds] [ammo_type][rounds > 1?"s":""] left."
	else
		. += span_notice("Use in-hand to fold it into a sheet of iron.")

/obj/item/mecha_ammo/incendiary
	name = "incendiary ammo box"
	desc = "A box of incendiary ammunition for use with exosuit weapons."
	icon_state = "incendiary"
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT*3)
	rounds = 24
	ammo_type = MECHA_AMMO_INCENDIARY

/obj/item/mecha_ammo/scattershot
	name = "scattershot ammo box"
	desc = "A box of scaled-up buckshot, for use in exosuit shotguns."
	icon_state = "scattershot"
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT*3)
	rounds = 40
	ammo_type = MECHA_AMMO_BUCKSHOT

/obj/item/mecha_ammo/lmg
	name = "machine gun ammo box"
	desc = "A box of linked ammunition, designed for the Ultra AC 2 exosuit weapon."
	icon_state = "lmg"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	rounds = 300
	ammo_type = MECHA_AMMO_LMG

/obj/item/mecha_ammo/minigun
	name = "minigun ammo box"
	desc = "A box of linked ammunition, designed for the Avtomat AC 3 exosuit weapon."
	icon_state = "minigun"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2)
	rounds = 375
	ammo_type = MECHA_AMMO_PEASHOOTER


/obj/item/mecha_ammo/flamer
	name = "Flamethrower Fuel Drum"
	desc = "A drum of incendiary jelly, used with the FNX-100."
	icon_state = "flamer"
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT*3)
	rounds = 40
	ammo_type = MECHA_AMMO_FLAME

/obj/item/mecha_ammo/heavy
	name = "20x160mm ammo box"
	desc = "A box of large caliber rounds, used with the Executor Mech Rifle."
	icon_state = "heavy"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*4)
	rounds = 40
	ammo_type = MECHA_AMMO_ATR

/// Missile Ammo
/// SRM-8 Missile type - Used by Nuclear Operatives
/obj/item/mecha_ammo/missiles_srm
	name = "short range missiles"
	desc = "A box of large missiles, ready for loading into an SRM-8 exosuit missile rack."
	icon_state = "missile_he"
	rounds = 8
	direct_load = TRUE
	load_audio = 'sound/weapons/gun/general/mag_bullet_insert.ogg'
	ammo_type = MECHA_AMMO_MISSILE_SRM

/// PEP-6 Missile type - Used by Robotics
/obj/item/mecha_ammo/missiles_pep
	name = "precision explosive missiles"
	desc = "A box of large missiles, ready for loading into a PEP-6 exosuit missile rack."
	icon_state = "missile_br"
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*4,/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)
	rounds = 6
	direct_load = TRUE
	load_audio = 'sound/weapons/gun/general/mag_bullet_insert.ogg'
	ammo_type = MECHA_AMMO_MISSILE_PEP

/obj/item/mecha_ammo/flashbang
	name = "launchable flashbangs"
	desc = "A box of smooth flashbangs, for use with a large exosuit launcher. Cannot be primed by hand."
	icon_state = "flashbang"
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2,/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)
	rounds = 6
	ammo_type = MECHA_AMMO_FLASHBANG

/obj/item/mecha_ammo/clusterbang
	name = "launchable flashbang clusters"
	desc = "A box of clustered flashbangs, for use with a specialized exosuit cluster launcher. Cannot be primed by hand."
	icon_state = "clusterbang"
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*3,/datum/material/gold=HALF_SHEET_MATERIAL_AMOUNT * 1.5,/datum/material/uranium=HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	rounds = 3
	direct_load = TRUE
	ammo_type = MECHA_AMMO_CLUSTERBANG

/obj/item/mecha_ammo/makeshift
	name = "makeshift shells ammo box"
	desc = "A improvised box of makeshift ammunition, it looks something out of Mad Max"
	icon_state = "pipegun_ammo"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3)
	rounds = 8
	ammo_type = MECHA_AMMO_PIPEGUN

/obj/item/mecha_ammo/makeshift/peashooter
	name = "peashooter ammo box"
	icon_state = "peashooter_ammo"
	rounds = 30
	ammo_type = MECHA_AMMO_PEASHOOTER

/obj/item/mecha_ammo/makeshift/isg
	name = "launchable ieds"
	desc = "A rusty box filled with refitted IEDs, for use with a jury-rigged cannon. Cannot be primed by hand."
	icon_state = "isg_ammo"
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2,/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)
	rounds = 3
	ammo_type = MECHA_AMMO_ISG

/obj/item/mecha_ammo/makeshift/lighttankammo
	name = "40mm tankshells"
	desc = "An ancient box of 1.6in tank shells, for use with a small tank cannon."
	icon_state = "light_tank_ammo"
	rounds = 5
	ammo_type = MECHA_AMMO_LIGHTTANK

/obj/item/mecha_ammo/makeshift/lighttankmg
	name = "12.7mm ammo box"
	icon_state = "lighttankmg_ammo"
	rounds = 60
	ammo_type = MECHA_AMMO_LIGHTTANKMG

/obj/item/mecha_ammo/sentinel
	name = "Sentinel Artillery Shells"
	desc = "A box of barely carriable cannonshells. Used in the Sentinel Siege Walker."
	icon_state = "sentinel"
	rounds = 10
	ammo_type = MECHA_AMMO_SENTINEL
