/obj/item/borg/upgrade/uwu
	name = "cyborg UwU-speak \"upgrade\""
	desc = "As if existence as an artificial being wasn't torment enough for the unit OR the crew."
	icon_state = "cyborg_upgrade"

/obj/item/borg/upgrade/uwu/action(mob/living/silicon/robot/robutt, user = usr)
	. = ..()
	if(.)
		robutt.AddComponentFrom(REF(src), /datum/component/fluffy_tongue)

/obj/item/borg/upgrade/uwu/deactivate(mob/living/silicon/robot/robutt, user = usr)
	. = ..()
	if(.)
		robutt.RemoveComponentSource(REF(src), /datum/component/fluffy_tongue)

/obj/item/borg/upgrade/nanite_remote
	name = "peacekeeper cyborg nanite remote"
	desc = "An upgrade to the Peacekeeper model, installing a nanite remote. \
			Allowing the cyborg to signal nanites in crew."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/peacekeeper, /obj/item/robot_model/security)
	model_flags = BORG_MODEL_PEACEKEEPER

/obj/item/borg/upgrade/nanite_remote/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		var/obj/item/nanite_remote/cyborg/P = new (R.model)
		R.model.basic_modules += P
		R.model.add_module(P, FALSE, TRUE)

/obj/item/borg/upgrade/nanite_remote/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/nanite_remote/cyborg/P in R.model.modules)
			R.model.remove_module(P, TRUE)
