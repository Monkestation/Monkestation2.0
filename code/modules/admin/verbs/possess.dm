ADMIN_VERB(possess, R_POSSESS, FALSE, "Possess Obj", "Possess an object.", ADMIN_CATEGORY_OBJECT, obj/target in world)
	if((target.obj_flags & DANGEROUS_POSSESSION) && CONFIG_GET(flag/forbid_singulo_possession))
		to_chat(user, "[target] is too powerful for you to possess.", confidential = TRUE)
		return

	var/turf/target_turf = get_turf(target)

	if(target)
		log_admin("[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]")
		message_admins("[key_name(user)] has possessed [target] ([target.type]) at [AREACOORD(target_turf)]")
	else
		log_admin("[key_name(user)] has possessed [target] ([target.type]) at an unknown location")
		message_admins("[key_name(user)] has possessed [target] ([target.type]) at an unknown location")

	if(!user.mob.control_object) //If you're not already possessing something...
		user.mob.name_archive = user.mob.real_name

	user.mob.forceMove(target)
	user.mob.real_name = target.name
	user.mob.name = target.name
	user.mob.reset_perspective(target)
	user.mob.control_object = target
	target.AddElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	BLACKBOX_LOG_ADMIN_VERB("Possess Object")

ADMIN_VERB(release, R_POSSESS, FALSE, "Release Object", "Stop possessing an object.", ADMIN_CATEGORY_OBJECT)
	if(!user.mob.control_object) //lest we are banished to the nullspace realm.
		return

	if(user.mob.name_archive) //if you have a name archived
		user.mob.real_name = user.mob.name_archive
		user.mob.name_archive = ""
		user.mob.name = user.mob.real_name
		if(ishuman(user.mob))
			var/mob/living/carbon/human/Human = user.mob
			Human.name = Human.get_visible_name()

	user.mob.control_object.RemoveElement(/datum/element/weather_listener, /datum/weather/ash_storm, ZTRAIT_ASHSTORM, GLOB.ash_storm_sounds)
	user.mob.forceMove(get_turf(user.mob.control_object))
	user.mob.reset_perspective()
	user.mob.control_object = null
	BLACKBOX_LOG_ADMIN_VERB("Release Object")
