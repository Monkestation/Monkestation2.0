/obj/item/robot_model/syndicate
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
		/obj/item/pinpointer/syndicate_cyborg,
	)
	traits = list(TRAIT_PUSHIMMUNE)
	/// Icon state of the blip this cyborg shows as on the nuclear operative tactical map.
	var/minimap_blip_state = "combatborg"
	/// The tactical map action given to the cyborg while it has this model.
	var/datum/weakref/tacmap_action_ref

/obj/item/robot_model/syndicate/Initialize(mapload)
	. = ..()
	if(!cyborg_owner)
		return
	cyborg_owner.faction -= FACTION_SILICON
	add_minimap_blip(cyborg_owner, MINIMAP_NUKEOP_BORG_BLIP, minimap_blip_state)
	var/datum/action/minimap/nuclear/tacmap_action = new
	tacmap_action.Grant(cyborg_owner)
	tacmap_action_ref = WEAKREF(tacmap_action)

/obj/item/robot_model/syndicate/Destroy()
	if(cyborg_owner)
		cyborg_owner.faction |= FACTION_SILICON
		remove_minimap_blip(MINIMAP_NUKEOP_BORG_BLIP, cyborg_owner)
	var/datum/action/minimap/nuclear/tacmap_action = tacmap_action_ref?.resolve()
	if(tacmap_action)
		qdel(tacmap_action)
	tacmap_action_ref = null
	return ..()
