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
	innate_ionpulse = TRUE
	traits = list(TRAIT_PUSHIMMUNE)

/datum/robot_model/syndicate/New(mob/living/silicon/robot/new_cyborg_owner)
	. = ..()
	if(!cyborg_owner)
		return
	cyborg_owner.faction -= FACTION_SILICON

/datum/robot_model/syndicate/Destroy()
	if(cyborg_owner)
		cyborg_owner.faction |= FACTION_SILICON
	return ..()
