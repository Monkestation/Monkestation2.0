/obj/item/melee/trick_weapon
	icon = 'monkestation/icons/obj/weapons/trick_weapons.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/trick_weapon_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/trick_weapon_righthand.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	damtype = BURN
	/// Upgrade level of the weapon.
	var/upgrade_level = 0
	/// Base force when transformed.
	var/on_force
	/// Is the weapon in its transformed state?
	var/enabled = FALSE
	///force we apply when thrown while active
	var/active_thrown_force
	/// The description that appears in the monster hunter UI for choosing one.
	var/ui_desc

/obj/item/melee/trick_weapon/Initialize(mapload)
	. = ..()
	apply_transform_component()

/obj/item/melee/trick_weapon/proc/apply_transform_component()
	AddComponent(/datum/component/transforming, \
		force_on = on_force , \
		throwforce_on = active_thrown_force, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_BULKY, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/trick_weapon/update_name(updates)
	. = ..()
	name = "[initial(name)] +[upgrade_level]"

/obj/item/melee/trick_weapon/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	enabled = active
	force = UPGRADED_VAL(force, upgrade_level)
	update_appearance(UPDATE_ICON_STATE)
	return NONE

/obj/item/melee/trick_weapon/proc/upgrade_weapon()
	upgrade_level++
	var/current_base_force = enabled ? on_force : initial(force)
	force = UPGRADED_VAL(current_base_force, upgrade_level)
	update_name()

/obj/item/melee/trick_weapon/attack(mob/target, mob/living/user, params) //our weapon does 25% less damage on non monsters
	var/old_force = force
	if(!is_monster_hunter_prey(target))
		force = round(force * 0.75)
	. = ..()
	force = old_force

/obj/item/melee/trick_weapon/update_icon_state()
	icon_state = "[base_icon_state][enabled ? "_active" : ""]"
	inhand_icon_state = "[base_icon_state][enabled ? "_active" : ""]"
	return ..()
