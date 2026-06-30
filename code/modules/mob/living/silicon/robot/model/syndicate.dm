/datum/robot_model/syndicate
	name = "Syndicate Assault"
	hud_icon_state = "malf"
	default_skin = /datum/robot_skin/syndicate/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg
	)
	traits = list(TRAIT_PUSHIMMUNE)

/*
/datum/robot_model/syndicate/rebuild_modules()
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction -= FACTION_SILICON //ai turrets

/datum/robot_model/syndicate/remove_module(obj/item/removed_module)
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction |= FACTION_SILICON //ai is your bff now!
*/
