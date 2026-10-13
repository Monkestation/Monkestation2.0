/obj/item/robot_model/ninja
	name = "Ninja Assault"
	hud_icon_state = "ninja"
	default_skin = /datum/robot_skin/ninja/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg/ninja,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
	)
	traits = list(TRAIT_PUSHIMMUNE)

/obj/item/robot_model/ninja/Initialize(mapload)
	. = ..()
	if(!cyborg_owner)
		return
	cyborg_owner.faction -= FACTION_SILICON
	cyborg_owner.faction |= ROLE_NINJA

/obj/item/robot_model/ninja/Destroy()
	if(cyborg_owner)
		cyborg_owner.faction |= FACTION_SILICON
		cyborg_owner.faction -= ROLE_NINJA
	return ..()
