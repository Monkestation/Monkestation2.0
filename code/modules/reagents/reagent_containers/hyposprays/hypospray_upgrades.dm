/obj/item/hypospray_upgrade
	name = "hypospray modification kit"
	desc = "An upgrade for hyposprays."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	var/upgrade_flag

/obj/item/hypospray_upgrade/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/hypospray))
		install(attacking_item, user)
	else
		..()

/obj/item/hypospray_upgrade/proc/install(obj/item/hypospray/hypo, mob/user)
	if(!upgrade_flag)
		to_chat(user, span_notice("The modkit you are trying to install should not exist."))
		return FALSE
	if(hypo.upgrade_flags & upgrade_flag)
		user.balloon_alert(user, "Already installed!")
		return
	hypo.upgrade_flags |= upgrade_flag
	playsound(src, 'sound/items/screwdriver.ogg', 50, 1)
	qdel(src)
	return TRUE

/obj/item/hypospray_upgrade/piercing
	name = "Hypospray Piercing Upgrade"
	desc = "Allows a hypospray to pierce through thick clothing."
	upgrade_flag = HYPO_UPGRADE_PIERCING

/obj/item/hypospray_upgrade/speed
	name = "Hypospray Speed Upgrade"
	desc = "Allows a hypospray to work slightly faster."
	upgrade_flag = HYPO_UPGRADE_SPEED

/obj/item/hypospray_upgrade/speed/install(obj/item/hypospray/hypo, mob/user)
	if(..())
		hypo.inject_other = max(0, hypo.inject_other - 0.5 SECONDS)
		hypo.spray_other = max(0, hypo.spray_other - 0.5 SECONDS)
		hypo.draw_other = max(0, hypo.draw_other - 0.5 SECONDS)

/obj/item/hypospray_upgrade/nozzle
	name = "Hypospray Nozzle Upgrade"
	desc = "Allows a hypospray to inject or apply more units a time."
	upgrade_flag = HYPO_UPGRADE_NOZZLE
