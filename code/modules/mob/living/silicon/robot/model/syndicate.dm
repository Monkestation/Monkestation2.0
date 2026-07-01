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

/datum/robot_model/syndicate/on_model_removed()
	cyborg_owner.faction |= FACTION_SILICON // AI is your BFF now!

/datum/robot_model/syndicate/on_model_given()
	cyborg_owner.faction -= FACTION_SILICON // AI hates us!
