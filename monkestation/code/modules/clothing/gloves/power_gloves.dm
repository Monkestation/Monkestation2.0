/obj/item/clothing/gloves/color/yellow/power_gloves
	name = "Power Gloves"
	desc = "Insulated gloves with onboard machinery that appears to be able to redirect the electrical current towards a creature."
	armor_type = /datum/armor/power_gloves
	var/datum/action/cooldown/spell/pointed/glove_zap/zap = new

/obj/item/clothing/gloves/color/yellow/power_gloves/Destroy()
    QDEL_NULL(zap)
    return ..()

/datum/armor/power_gloves
	acid = 50
	bio = 50
	fire = 80

/datum/action/cooldown/spell/pointed/glove_zap
	name = "Nerd Blast"
	desc = "Blast your foes with the electricity surging beneath your feet!"
	button_icon_state = "lightning"
	cooldown_time = 10 SECONDS
	spell_max_level = 1
	sparks_amt = 4
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	overlay_icon_state = "bg_default_border"

//had to recreate tesla zap into a pointed version
/datum/action/cooldown/spell/pointed/glove_zap/proc/target_tesla_zap(atom/source, atom/target, power, zap_flags = ZAP_DEFAULT_FLAGS, max_damage = INFINITY)
	// damage the shock causes, be wary of fucking with the function without extensive testing.
	var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round( 5*(ROOT (4, (power)))), max_damage) + rand(-5, 5)) : 0
	//24 damage at 10 KW, 75 damage at 1 MW, 132 at 10 MW, 420 at 1 GW (nice)
	var/mob/living/electrocute_victim = target
	var/dust_power = 10000000000
	var/heavy_emp_threshold = 1000000

	source.Beam(target, icon_state="lightning[rand(1,12)]", time = 5) //Creates lightning beam
	var/zapdir = get_dir(source, target)
	if(zapdir)
		. = zapdir

	if(power >= dust_power) //Dusts if there's enough in the grid
		electrocute_victim.dust(TRUE, FALSE, TRUE)

	if (isliving(target))
		electrocute_victim.electrocute_act(shock_damage, source, 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))

	if(issilicon(target)) //sillycons get emp'd
		var/mob/living/silicon/silicon_target = target
		if (power <= 10000)
			silicon_target.emp_act(EMP_LIGHT)
		else if (power <=heavy_emp_threshold)
			silicon_target.emp_act(EMP_HEAVY)

/datum/action/cooldown/spell/pointed/glove_zap/proc/glove_nerd_zap(atom/target, /mob/living/owner, var/zap_range = 6)
	var/turf/owner_turf = get_turf(owner)
	var/obj/structure/cable/cable_target = owner_turf.get_cable_node() //Gets power from underfoot node
	var/heavy_zap = 100000000
	if(!cable_target)
		return FALSE

	var/surplus = cable_target.surplus()
	if (surplus <= 1000)
		owner.balloon_alert (owner,"Not enough power in the grid!")

	if (get_dist(owner, target) >= zap_range)
		owner.balloon_alert (owner, "Unable to lock on! Move closer!")
	else
		playsound(owner, 'monkestation/sound/weapons/powerglovestarget.ogg', 35, TRUE, -1)
		if (do_after(owner, 3 SECONDS, target, IGNORE_TARGET_LOC_CHANGE))
			if (get_dist(owner, target) > zap_range)
				owner.balloon_alert(owner, "Target moved out of range!")
			else
				var/calculated_power = surplus/20 //Calc_power, change division to balance
				target_tesla_zap(owner, target, calculated_power, SHOCK_NOSTUN, max_damage = INFINITY)
				StartCooldown()
				if (surplus <= heavy_zap) //plays a separate sound at 2 MW excess
					playsound(target, 'sound/magic/lightningshock.ogg', 50, TRUE, -1)
				else
					playsound(target, 'sound/magic/lightningbolt.ogg', 50, TRUE, -1)

/obj/item/clothing/gloves/color/yellow/power_gloves/equipped(mob/living/owner, slot)
	. = ..()
	if (slot & ITEM_SLOT_GLOVES)
		zap.Grant(owner)

/obj/item/clothing/gloves/color/yellow/power_gloves/dropped(mob/living/owner, slot)
	. = ..()
	if (owner.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		zap.Remove(owner)

/datum/action/cooldown/spell/pointed/glove_zap/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	if (!isliving(target) && !issilicon(target))
		return FALSE
	else
		glove_nerd_zap(target, caller)

