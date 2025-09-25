/obj/item/kinetic_crusher/knives
	name = "set of proto kinetic knives"
	desc = "With a touch of bluespace, the crusher has been made into a more practical form for throwing. \
	This set of throwing knives allows you to utilize the features of a crusher while maintaining more than a safe \
	distance from whatever fauna stands between you and your ore. \
	at least it can still utilize trophies."
	force = 10
	force_wielded = 20
	throwforce = 10
	throw_speed = 5
	wound_bonus = 2
	bare_wound_bonus = 10
	armour_penetration = 0
	block_chance = 0
	charged = TRUE
	charge_time = 10
	detonation_damage = 60
	backstab_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon = 'icons/obj/mining.dmi'
	attack_verb_continuous = list("slashes", "stabs", "cuts")
	attack_verb_simple = list("slash", "stab", )
	icon_state = "crusherknife"
	inhand_icon_state = "switchblade_on"
	worn_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	override_examine = TRUE
	overrides_main = TRUE
	overrides_twohandrequired = TRUE
	override_twohandedsprite = TRUE
	override_light_overlay_sprite = TRUE
	crusher_destabilizer = /obj/projectile/destabilizer/longrange
	/// Max amount of charges we can have
	var/max_knife_charges = 5
	/// How many charges we currently have
	var/current_knife_charges = 5
	///Knife recharge rate
	var/knife_charge_rate = 5
	/// Reload timer
	var/knife_charge_timer = 0

/obj/item/kinetic_crusher/knives/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/kinetic_crusher/knives/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/kinetic_crusher/knives/examine(mob/living/user)
	. = ..()
	. += span_notice("Mark a large creature with a destabilizing force with right-click, then click them fire projectile, dealing <b>[force + detonation_damage]</b> damage.")
	. += span_notice("Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.")
	. += span_notice("Currently has [current_knife_charges] amount of knives")
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += span_notice("It has \a [T] attached, which causes [T.effect_desc()].")

/obj/item/kinetic_crusher/knives/process(seconds_per_tick)
	if (current_knife_charges >= max_knife_charges)
		knife_charge_timer = 0
		return FALSE
	update_appearance()
	knife_charge_timer += seconds_per_tick
	if(knife_charge_timer < knife_charge_rate)
		return FALSE
	knife_charge_timer = 0
	playsound(src, 'sound/items/unsheath.ogg', 100, TRUE)
	current_knife_charges++
	return TRUE

/obj/item/kinetic_crusher/knives/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!current_knife_charges)
		return ITEM_INTERACT_BLOCKING
	fire_knife(interacting_with, user, modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	current_knife_charges--
	return ITEM_INTERACT_SUCCESS

/obj/item/kinetic_crusher/knives/proc/fire_knife(atom/target, mob/living/user, list/modifiers)
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/knives/knife = new(proj_turf)
	knife.preparePixelProjectile(target, user, modifiers)
	knife.firer = user
	knife.hammer_synced = src
	playsound(user, 'sound/weapons/fwoosh.ogg', 100, TRUE)
	knife.fire()

/obj/projectile/destabilizer/longrange //This does not get all its procs copy pasted because its actually a subtype of destabilizer
	name = "destabilizing shot"
	range = 15 //its an actual knife you throw
	log_override = TRUE

/obj/projectile/knives
	name = "thrown proto-kinetic knife"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusherknife_thrown"
	damage = 10 //if people start abusing the FUCK out of this for station combat, drop it to five, thatll fucking teach them
	damage_type = BRUTE
	armour_penetration = 0
	armor_flag = MELEE
	wound_bonus = 5
	bare_wound_bonus = 10
	hitsound = 'sound/weapons/guillotine.ogg'
	hitsound_wall = 'sound/weapons/guillotine.ogg'
	var/obj/item/kinetic_crusher/knives/hammer_synced

//we have more copy pasted crusher code here because the damage from a projectile is different from a melee strike
/obj/projectile/knives/on_hit(atom/target, Firer, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		var/datum/status_effect/crusher_mark/crusher_mark = living_target.has_status_effect(/datum/status_effect/crusher_mark)
		if(!crusher_mark || !living_target.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/mark_damage = living_target.has_status_effect(/datum/status_effect/crusher_damage)
		if(!mark_damage)
			mark_damage = living_target.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = living_target.health
		for(var/thing in hammer_synced.trophies)
			var/obj/item/crusher_trophy/trophy = thing
			trophy.on_mark_detonation(target, firer)
		if(!QDELETED(living_target))
			if(!QDELETED(mark_damage))
				mark_damage.total_damage += target_health - living_target.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(living_target))
			var/backstabbed = FALSE
			var/combined_damage = hammer_synced.detonation_damage
			var/backstab_dir = get_dir(firer, living_target)
			var/def_check = living_target.getarmor(type = BOMB)
			if((firer.dir & backstab_dir) && (living_target.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += hammer_synced.backstab_bonus
				playsound(firer, 'sound/weapons/kenetic_accel.ogg', 50, TRUE)

			if(!QDELETED(mark_damage))
				mark_damage.total_damage += combined_damage


			SEND_SIGNAL(firer, COMSIG_LIVING_CRUSHER_DETONATE, living_target, src, backstabbed)
			living_target.apply_damage(combined_damage, BRUTE, blocked = def_check)
	. = ..()
