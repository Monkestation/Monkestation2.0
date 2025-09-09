GLOBAL_DATUM(bridge_axe, /obj/item/fireaxe)

/*
 * Fireaxe
 */
/obj/item/fireaxe  // DEM AXES MAN, marker -Agouri
	icon = 'icons/obj/weapons/fireaxe.dmi'
	icon_state = "fireaxe0"
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "chop", "cleave", "tear", "lacerate", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	armor_type = /datum/armor/item_fireaxe
	resistance_flags = FIRE_PROOF
	wound_bonus = -15
	bare_wound_bonus = 20
	/// How much damage to do unwielded
	var/force_unwielded = 5
	/// How much damage to do wielded
	var/force_wielded = 24

/datum/armor/item_fireaxe
	fire = 100
	acid = 30

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	if(!GLOB.bridge_axe && istype(get_area(src), /area/station/command))
		GLOB.bridge_axe = src

	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 80, \
		bonus_modifier = 0 , \
		butcher_sound = hitsound, \
	)
	//axes are not known for being precision butchering tools
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[base_icon_state]1")

/obj/item/fireaxe/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/fireaxe/Destroy()
	if(GLOB.bridge_axe == src)
		GLOB.bridge_axe = null
	return ..()

/obj/item/fireaxe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window_sill))
			if(!(A.resistance_flags & INDESTRUCTIBLE))
				var/obj/structure/W = A
				W.atom_destruction("fireaxe")

/*
 * Bone Axe
 */
/obj/item/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon = 'monkestation/icons/obj/items_and_weapons.dmi' //Monkestation Edit
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/melee_righthand.dmi' //End Of Monke Edit
	icon_state = "bone_axe0"
	base_icon_state = "bone_axe"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_unwielded = 5
	force_wielded = 23

/*
 * Metal Hydrogen Axe
 */
/obj/item/fireaxe/metal_h2_axe
	icon_state = "metalh2_axe0"
	base_icon_state = "metalh2_axe"
	name = "metallic hydrogen axe"
	desc = "A lightweight crowbar with an extreme sharp fire axe head attached. It trades it's hefty as a weapon by making it easier to carry around when holstered to suits without having to sacrifice your backpack."
	force_unwielded = 5
	force_wielded = 20
	demolition_mod = 2
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	usesound = 'sound/items/crowbar.ogg'

/*
 * Energised Fire Axe
 */
/obj/item/fireaxe/energy
	icon = 'icons/obj/weapons/eaxe.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/eaxe_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/eaxe_righthand.dmi'
	icon_state = "eaxe0"
	base_icon_state = "eaxe"
	name = "energised fire axe"
	desc = "A truly terrifying weapon, this variant of the fireaxe boasts a durable and lightweight polymer handle, and an impossibly sharp hardlight edge. You feel like this could probably cut through anything."
	light_system = OVERLAY_LIGHT
	light_outer_range = 1.5
	light_power = 1.5
	light_color = COLOR_DARK_RED
	light_on = TRUE
	force_unwielded = 15
	throwforce = 30
	force_wielded = 40
	demolition_mod = 2.5
	wound_bonus = 10
	armour_penetration = 75
	armour_ignorance = 10
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/fireaxe/energy/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! Heavens above it's going clean through!"))
	user.gib()
	return MANUAL_SUICIDE

/obj/item/fireaxe/energy/ignition_effect(atom/atom, mob/user)
	. = span_warning("[user] holds [user.p_their()] axe edge to the [atom.name]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [atom.name] in the process. Holy fuck.")
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)
