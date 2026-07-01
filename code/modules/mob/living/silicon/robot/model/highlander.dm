/datum/robot_model/highlander
	name = "Highlander"
	hud_icon_state = "kilt"
	default_skin = /datum/robot_skin/highlander/default
	basic_modules = list(
		/obj/item/claymore/highlander/robot,
		/obj/item/pinpointer/nuke,
	)
	breakable_modules = FALSE
	locked_transform = FALSE
	traits = list(TRAIT_PUSHIMMUNE)

/datum/robot_model/highlander/New(mob/living/silicon/robot/new_cyborg_owner)
	. = ..()
	if(!cyborg_owner)
		return
	cyborg_owner.faction -= FACTION_SILICON
	qdel(cyborg_owner.radio)
	cyborg_owner.radio = new /obj/item/radio/borg/syndicate(cyborg_owner)
	cyborg_owner.scrambledcodes = TRUE
	cyborg_owner.maxHealth = 50 // Die in 3 hits.
	cyborg_owner.put_in_hand(locate(/obj/item/claymore/highlander/robot) in usable_modules, 1)
	var/obj/item/pinpointer/nuke/nukedisk_pinpointer = locate(/obj/item/pinpointer/nuke) in usable_modules
	if(nukedisk_pinpointer)
		cyborg_owner.put_in_hand(nukedisk_pinpointer, 2)
		nukedisk_pinpointer.attack_self(cyborg_owner)
	cyborg_owner.break_cyborg_slot(3)
	cyborg_owner.place_on_head(new /obj/item/clothing/head/beret/highlander(cyborg_owner))
	ADD_TRAIT(cyborg_owner.hat, TRAIT_NODROP, HIGHLANDER_TRAIT)

/datum/robot_model/highlander/Destroy()
	if(cyborg_owner)
		cyborg_owner.faction |= FACTION_SILICON
		qdel(cyborg_owner.radio)
		cyborg_owner.radio = new radio(cyborg_owner)
		cyborg_owner.scrambledcodes = initial(cyborg_owner.scrambledcodes)
		cyborg_owner.maxHealth = initial(cyborg_owner.maxHealth)
	return ..()
