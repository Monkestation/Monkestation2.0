/datum/robot_model/highlander
	name = "Highlander"
	hud_icon_state = "kilt"
	default_skin = /datum/robot_skin/highlander/default
	basic_modules = list(
		/obj/item/claymore/highlander/robot,
		/obj/item/pinpointer/nuke,
	)
	traits = list(TRAIT_PUSHIMMUNE)
	// breakable_modules = FALSE
	// locked_transform = FALSE //GO GO QUICKLY AND SLAUGHTER THEM ALL

/*
/datum/robot_model/highlander/rebuild_modules()
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction -= FACTION_SILICON //ai turrets

/datum/robot_model/highlander/remove_module(obj/item/removed_module)
	..()
	var/mob/living/silicon/robot/cyborg = loc
	cyborg.faction |= FACTION_SILICON //ai is your bff now!

/datum/robot_model/highlander/be_transformed_to(obj/item/robot_model/old_model)
	. = ..()
	qdel(robot.radio)
	robot.radio = new /obj/item/radio/borg/syndicate(robot)
	robot.scrambledcodes = TRUE
	robot.maxHealth = 50 //DIE IN THREE HITS, LIKE A REAL SCOT
	robot.break_cyborg_slot(3) //YOU ONLY HAVE TWO ITEMS ANYWAY
	var/obj/item/pinpointer/nuke/diskyfinder = locate(/obj/item/pinpointer/nuke) in basic_modules
	diskyfinder.attack_self(robot)

/datum/robot_model/highlander/do_transform_delay() //AUTO-EQUIPPING THESE TOOLS ANY EARLIER CAUSES RUNTIMES OH YEAH
	. = ..()
	robot.put_in_hand(locate(/obj/item/claymore/highlander/robot) in basic_modules, 1)
	robot.put_in_hand(locate(/obj/item/pinpointer/nuke) in basic_modules, 2)
	robot.place_on_head(new /obj/item/clothing/head/beret/highlander(robot)) //THE ONLY PART MORE IMPORTANT THAN THE SWORD IS THE HAT
	ADD_TRAIT(robot.hat, TRAIT_NODROP, HIGHLANDER_TRAIT)
*/
