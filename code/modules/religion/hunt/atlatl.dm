/obj/item/gun/ballistic/atlatl
	icon = 'icons/obj/weapons/guns/atlatl/atlatl.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/bows_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bows_righthand.dmi'
	icon_state = "atlatl"
	inhand_icon_state = "bow"
	base_icon_state = "bow"
	load_sound = null
	fire_sound = null
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/atlatl
	force = 25
	attack_verb_continuous = list("strikes", "cracks", "beats")
	attack_verb_simple = list("strike", "crack", "beat")
	weapon_weight = WEAPON_NORMAL
	w_class = WEIGHT_CLASS_BULKY
	internal_magazine = TRUE
	cartridge_wording = "spear"
	bolt_type = BOLT_TYPE_NO_BOLT
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK

/obj/item/gun/ballistic/atlatl/proc/drop_spear()
	if(chambered)
		chambered.forceMove(drop_location())
		magazine.get_round(keep = FALSE)
		chambered = null
	update_appearance()

/obj/item/gun/ballistic/atlatl/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_BACK | ITEM_SLOT_BELT && chambered)
		balloon_alert(user, "the spear falls off!")
		drop_spear()
		drawn = FALSE
		update_appearance()

/obj/item/gun/ballistic/bow/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!chambered)
		return
	. = ..() //fires, removing the arrow
	update_appearance()

/obj/item/gun/ballistic/atlatl/shoot_with_empty_chamber(mob/living/user)
	return //no clicking sounds please


/obj/item/ammo_box/magazine/internal/atlatl
	name = "notch"
	ammo_type = /obj/item/ammo_casing/caseless/thrownspear
	max_ammo = 1
	start_empty = TRUE
	caliber = CALIBER_SPEAR



/obj/item/ammo_casing/caseless/thrownspear
	name = "throwing spear"
	desc = "A light spear made for throwing from an atlatl"
	icon = 'icons/obj/weapons/guns/bows/thrownspear.dmi'
	icon_state = "thrownspear"
	inhand_icon_state = "thrownspear"
	projectile_type = /obj/projectile/bullet/reusable/thrownspear
	flags_1 = NONE
	throwforce = 25
	w_class = WEIGHT_CLASS_NORMAL
	firing_effect_type = null
	caliber = CALIBER_SPEAR
	heavy_metal = FALSE

/obj/item/ammo_casing/caseless/thrownspear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/element/envenomable_casing)


	/obj/projectile/bullet/reusable/thrownspear
	name = "throwing spear"
	desc = "Beasts be felled!"
	icon = 'icons/obj/weapons/guns/bows/thrownspear.dmi'
	icon_state = "spear_projectile"
	ammo_type = /obj/item/ammo_casing/caseless/thrownspear
	damage = 75
	speed = 1.5
	range = 20
	/// How much the damage is multiplied by when we hit a mob with the correct biotype
	var/biotype_damage_multiplier = 5
	/// What biotype we look for
	var/biotype_we_look_for = MOB_BEAST



/obj/item/storage/bag/spearquiver
	name = "large quiver"
	desc = "A large quiver to hold a few spears for your atlatl"
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/weapons/guns/bows/quivers.dmi'
	icon_state = "holyquiver"
	inhand_icon_state = null
	worn_icon_state = "harpoon_quiver"
	/// type of arrow the quiver should hold
	var/arrow_path = /obj/item/ammo_casing/caseless/thrownspear

/obj/item/storage/bag/spearquiver/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 10
	atom_storage.max_total_storage = 100
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/caseless/thrownspear,
	))

/obj/item/storage/bag/spearquiver/PopulateContents()
	. = ..()
	for(var/i in 3)
		new arrow_path(src)
