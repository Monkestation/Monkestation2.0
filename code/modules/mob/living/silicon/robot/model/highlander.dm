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

/datum/robot_model/highlander/on_model_removed()
	cyborg_owner.faction |= FACTION_SILICON

/datum/robot_model/highlander/on_model_given()
	cyborg_owner.faction -= FACTION_SILICON
	qdel(cyborg_owner.radio)
	cyborg_owner.radio = new /obj/item/radio/borg/syndicate(cyborg_owner)
	cyborg_owner.scrambledcodes = TRUE
	cyborg_owner.maxHealth = 50 // Die in 3 hits.
	cyborg_owner.break_cyborg_slot(3)
	var/obj/item/pinpointer/nuke/nukedisk_pinpointer = locate(/obj/item/pinpointer/nuke) in basic_modules
	nukedisk_pinpointer.attack_self(cyborg_owner)

/datum/robot_model/highlander/do_transform_delay()
	. = ..()
	cyborg_owner.put_in_hand(locate(/obj/item/claymore/highlander/robot) in basic_modules, 1)
	cyborg_owner.put_in_hand(locate(/obj/item/pinpointer/nuke) in basic_modules, 2)
	cyborg_owner.place_on_head(new /obj/item/clothing/head/beret/highlander(cyborg_owner))
	ADD_TRAIT(cyborg_owner.hat, TRAIT_NODROP, HIGHLANDER_TRAIT)
