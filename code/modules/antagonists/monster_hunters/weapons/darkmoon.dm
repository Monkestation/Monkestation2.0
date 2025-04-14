/obj/item/melee/trick_weapon/darkmoon
	name = "Darkmoon Greatsword"
	desc = "Ahh my guiding moonlight, you were by my side all along."
	ui_desc = "A heavy sword hilt that would knock anyone out cold, can transform into the darkmoonlight greatsword."
	icon_state = "darkmoon"
	icon_state_preview = "darkmoon_active"
	base_icon_state = "darkmoon"
	inhand_icon_state = "darkmoon"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	on_force = 20
	force = 17
	light_system = OVERLAY_LIGHT
	light_color = "#59b3c9"
	light_outer_range = 2
	light_power = 2
	light_on = FALSE
	throwforce = 12
	active_thrown_force = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	///ready to launch a beam attack?
	COOLDOWN_DECLARE(moonbeam_fire)

/obj/item/melee/trick_weapon/darkmoon/on_transform(obj/item/source, mob/user, active)
	. = ..()
	balloon_alert(user, active ? "glows with power" : "turns dormant")
	if(active)
		playsound(src, 'monkestation/sound/weapons/moonlightsword.ogg', vol = 50)
	set_light_on(active)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/trick_weapon/darkmoon/attack_secondary(atom/target, mob/living/user, clickparams)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/melee/trick_weapon/darkmoon/afterattack_secondary(atom/target, mob/living/user, clickparams)
	if(!enabled)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, moonbeam_fire))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_moonbeam(target, user, clickparams)
	user.changeNext_move(CLICK_CD_MELEE)
	COOLDOWN_START(src, moonbeam_fire, 4 SECONDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/melee/trick_weapon/darkmoon/proc/fire_moonbeam(atom/target, mob/living/user, clickparams)
	var/modifiers = params2list(clickparams)
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/moonbeam/moon = new(proj_turf)
	moon.preparePixelProjectile(target, user, modifiers)
	moon.firer = user
	playsound(src, 'monkestation/sound/weapons/moonlightbeam.ogg', vol = 50)
	moon.fire()

/obj/projectile/moonbeam
	name = "Moonlight"
	icon = 'icons/effects/effects.dmi'
	icon_state = "plasmasoul"
	damage = 25
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 1
	light_color = "#44acb1"
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
