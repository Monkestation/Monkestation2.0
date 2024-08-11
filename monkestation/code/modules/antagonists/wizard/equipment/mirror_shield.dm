#define PROJECTILE_HIT_EFFECT_CHANCE 80
#define NORMAL_BLOCK_CHANCE 30
#define REACTION_MODE_ABSORB 0
#define REACTION_MODE_REFLECT 1

//a "shield" that can absorb projectiles and then shoot them back at attackers
/obj/item/gun/magic/mirror_shield
	name = "mirror shield"
	desc = "A strange mirror adorned with various gemstones. If you look close enough it almost seems as if the surface is... rippling?"
	icon = 'monkestation/icons/obj/weapons/shields.dmi'
	icon_state = "wizard_mirror_shield"
	inhand_icon_state = "wizard_mirror_shield"
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 16
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bumps", "prods")
	attack_verb_simple = list("bump", "prod")
	hitsound = 'sound/weapons/smash.ogg'
	fire_sound = 'sound/magic/cosmic_expansion.ogg'
	ammo_type = /obj/item/ammo_casing/mirror_shield_dummy
	can_charge = TRUE
	///Up to how many projectiles can we "have stored"
	var/max_stored_projectiles = 10
	///Do we absorb or reflect projectiles when hit
	var/reaction_mode = REACTION_MODE_ABSORB
	///The list of projectiles we have stored ready to fire
	var/list/stored_projectiles = list()
	///Cannot absorb projectile types in here
	var/static/list/blacklisted_projectile_types = list()

/obj/item/gun/magic/mirror_shield/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src) //we want can_charge set to TRUE but dont actually use the processing it gives so just disable it

/obj/item/gun/magic/mirror_shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(attack_type == PROJECTILE_ATTACK)
		if(!prob(PROJECTILE_HIT_EFFECT_CHANCE))
			return FALSE

		if(reaction_mode == REACTION_MODE_ABSORB && length(stored_projectiles) <= max_stored_projectiles && !(hitby.type in blacklisted_projectile_types))
			absorb_projectile(hitby)
		else
			var/obj/projectile/reflected = hitby
			reflected.set_angle_centered(get_angle(owner, reflected.firer))
			reflected.parried = TRUE
			reflected.firer = owner
			reflected.speed *= 0.8
			reflected.damage *= 1.15
		return TRUE

	else if(prob(NORMAL_BLOCK_CHANCE))
		return TRUE

/obj/item/gun/magic/mirror_shield/attack_self(mob/user, modifiers)
	. = ..()
	reaction_mode = !reaction_mode
	balloon_alert(user, "you hold \the [src] in such a way as to [reaction_mode == REACTION_MODE_ABSORB ? "absorb" : "reflect"] projectiles.")

/obj/item/gun/magic/mirror_shield/examine(mob/user)
	. = ..()
	if(HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		. += "<br>It currently contains: [english_list(stored_projectiles, comma_text = ", <br>")]."

/obj/item/gun/magic/mirror_shield/recharge_newshot()
	if(!chambered.loaded_projectile && length(stored_projectiles))
		var/obj/projectile/loaded = stored_projectiles[1]
		loaded.forceMove(chambered)
		chambered.loaded_projectile = loaded
		stored_projectiles -= loaded

/obj/item/gun/magic/mirror_shield/can_shoot()
	return chambered.loaded_projectile

/obj/item/gun/magic/mirror_shield/handle_chamber(mob/living/user, empty_chamber, from_firing, chamber_next_round)
	recharge_newshot()

/obj/item/gun/magic/mirror_shield/proc/absorb_projectile(obj/projectile/absorbed)
	STOP_PROCESSING(SSprojectiles, absorbed)
	absorbed.projectile_phasing |= PASSMOB //JANK, MIGHT NOT WORK, ALSO NEED TO REMOVE THIS FLAG AFTER IF NEEDED
	absorbed.fired = FALSE
	if(!chambered.loaded_projectile)
		chambered.loaded_projectile = absorbed
		absorbed.forceMove(chambered)
	else
		absorbed.forceMove(src)
		stored_projectiles += absorbed
	visible_message(span_notice("\The [src] absorbs [absorbed]!"))
	playsound(src, 'sound/magic/cosmic_expansion.ogg', vol = 120, channel = CHANNEL_SOUND_EFFECTS)

//a dummy casing type to get filled with absorbed projectiles
/obj/item/ammo_casing/mirror_shield_dummy
	loaded_projectile = null
	firing_effect_type = null

/obj/item/ammo_casing/mirror_shield_dummy/newshot()
	return

/obj/projectile/Destroy()
	if(ismob(firer) && firer:client)
		stack_trace("funny") //LOOK AT THIS
	. = ..()

#undef PROJECTILE_HIT_EFFECT_CHANCE
#undef NORMAL_BLOCK_CHANCE
#undef REACTION_MODE_ABSORB
#undef REACTION_MODE_REFLECT
