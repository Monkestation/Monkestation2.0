//////////////////////////////////////////////////////////////////////////
//---------------------Upgradeable warlock staff------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/item/gun/magic/darkspawn
	name = "channeling staff"
	desc = "A staff made from pure darkness."
	icon = 'icons/obj/darkspawn_items.dmi'
	icon_state = "shadow_staff0"
	inhand_icon_state = "shadow_staff0"
	base_icon_state = "shadow_staff"
	lefthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_righthand.dmi'
	block_chance = 5
	fire_sound = 'sound/weapons/emitter2.ogg'
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	slot_flags = NONE
	flags_1 = NONE

	antimagic_flags = MAGIC_RESISTANCE_MIND
	ammo_type = /obj/item/ammo_casing/magic/darkspawn
	///the psi cost to shoot the staff
	var/psi_cost = 40
	/// Flags used for different effects that apply when a projectile hits something
	var/effect_flags

/obj/item/gun/magic/darkspawn/examine(mob/user)
	. = ..()
	if(isobserver(user) || IS_DARKSPAWN(user))
		. += span_velvet("<b>Functions:</b>")
		if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
			. += span_velvet("The staff will devour any lights hit.")
		. += span_velvet("Consumes [psi_cost] psi to fire a projectile.")
		. += span_velvet("Projectiles do 65 stamina damage.")

		. += span_velvet("Also functions to pry open depowered airlocks using right click.")
		if(effect_flags)
			. += span_velvet("The projectile will also:")
			if(effect_flags & STAFF_UPGRADE_HEAL)
				. += span_velvet("Heal any ally hit for 30 health.")
			if(effect_flags & STAFF_UPGRADE_EXTINGUISH)
				. += span_velvet("Extinguish the fire on any ally.")
			if(effect_flags & STAFF_UPGRADE_EXTINGUISH)
				. += span_velvet("Confuse any enemy struck for 4 seconds.")
			if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
				. += span_velvet("Consume the light of anything struck.")

/obj/item/gun/magic/darkspawn/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	RegisterSignal(src, COMSIG_PROJECTILE_ON_HIT, PROC_REF(on_projectile_hit))
	AddComponent(/datum/component/two_handed, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
		icon_wielded ="[base_icon_state]1")

/obj/item/gun/magic/darkspawn/worn_overlays(mutable_appearance/standing, isinhands, icon_file) //this doesn't work and i have no clue why
	. = ..()
	if(isinhands)
		. += emissive_appearance(icon_file, "[inhand_icon_state]_emissive", src)

///////////////////FANCY PROJECTILE EFFECTS//////////////////////////
/obj/item/gun/magic/darkspawn/proc/on_projectile_hit(datum/source, atom/movable/firer, mob/living/target, angle)
	if(!isliving(target))
		return
	if(IS_TEAM_DARKSPAWN(target))
		if(effect_flags & STAFF_UPGRADE_HEAL)
			target.heal_ordered_damage(30, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		if(effect_flags & STAFF_UPGRADE_EXTINGUISH)
			target.extinguish_mob()
	else
		if(isanimal_or_basicmob(target) || !target.uses_stamina) // just deal brute damage if they don't use stamina
			target.apply_damage(20, BRUTE, spread_damage = TRUE, wound_bonus = CANT_WOUND)
		else
			var/datum/stamina_container/stamina = target.stamina
			stamina.adjust(-30)
		if(effect_flags & STAFF_UPGRADE_CONFUSION)
			target.adjust_confusion(4 SECONDS)

////////////////////////TWO-HANDED BLOCKING//////////////////////////
/obj/item/gun/magic/darkspawn/proc/on_wield() //guns do weird things to some of the icon procs probably, and i can't find which ones, so i need to do this all again
	inhand_icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"
	block_chance = 35

/obj/item/gun/magic/darkspawn/proc/on_unwield()
	inhand_icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"
	block_chance = 10

/obj/item/gun/magic/darkspawn/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()
////////////////////////INFINITE AMMO////////////////////////// (some psi required)
/obj/item/gun/magic/darkspawn/can_shoot()
	psi_cost = initial(psi_cost)
	if(effect_flags & STAFF_UPGRADE_EFFICIENCY)
		psi_cost *= 0.5
	if(isliving(src.loc))
		var/mob/living/dude = src.loc
		if(!(dude.mind && SEND_SIGNAL(dude.mind, COMSIG_MIND_CHECK_ANTAG_RESOURCE, ANTAG_RESOURCE_DARKSPAWN, psi_cost)))
			return FALSE
	return ..()

/obj/item/gun/magic/darkspawn/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	if(. && user.mind)
		SEND_SIGNAL(user.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, list(ANTAG_RESOURCE_DARKSPAWN = psi_cost))

/obj/item/gun/magic/darkspawn/process_chamber(user, empty_chamber, from_firing, chamber_next_round)
	. = ..()
	charges = max_charges //infinite charges

////////////////////////OTHER STUFF//////////////////////////
/obj/item/ammo_casing/magic/darkspawn
	projectile_type = /obj/projectile/magic/darkspawn
	firing_effect_type = null
	harmful = FALSE

/obj/projectile/magic/darkspawn
	name = "bolt of nothingness"
	icon = 'icons/obj/darkspawn_projectiles.dmi'
	icon_state = "staff_blast"
	damage = 0
	pass_flags = PASSTABLE | PASSMACHINE
	damage_type = STAMINA
	antimagic_flags = MAGIC_RESISTANCE_MIND
	speed = 2 //watch out, it fucks you up

/obj/projectile/magic/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)
	update_appearance(UPDATE_OVERLAYS)

/obj/projectile/magic/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src)
