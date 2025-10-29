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

/obj/item/borg/upgrade/surgery
	name = "Surgical Toolset Upgrade"
	desc = "An upgrade to the Medical model cyborg's surgical tools, streamlining \
		the surgical process."
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL
	var/list/adv_surgical_tools = list( /obj/item/circular_saw/augment, /obj/item/scalpel/borg, /obj/item/cautery/augment, /obj/item/retractor/augment, /obj/item/hemostat/augment)
	var/list/surgical_tools = list( /obj/item/circular_saw, /obj/item/scalpel, /obj/item/cautery, /obj/item/retractor, /obj/item/hemostat)
/obj/item/borg/upgrade/surgery/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/module in R.model.modules)
			if(module.type in surgical_tools)
				R.model.remove_module(module, TRUE)

		var/obj/item/circular_saw/augment/saw = new /obj/item/circular_saw/augment(R.model)
		R.model.basic_modules += saw
		R.model.add_module(saw, FALSE, TRUE)

		var/obj/item/scalpel/borg/scalpel = new /obj/item/scalpel/borg(R.model)
		R.model.basic_modules += scalpel
		R.model.add_module(scalpel, FALSE, TRUE)

		var/obj/item/cautery/augment/cautery = new /obj/item/cautery/augment(R.model)
		R.model.basic_modules += cautery
		R.model.add_module(cautery, FALSE, TRUE)

		var/obj/item/retractor/augment/retractor = new /obj/item/retractor/augment(R.model)
		R.model.basic_modules += retractor
		R.model.add_module(retractor, FALSE, TRUE)

		var/obj/item/hemostat/augment/hemostat = new /obj/item/hemostat/augment(R.model)
		R.model.basic_modules += hemostat
		R.model.add_module(hemostat, FALSE, TRUE)

/obj/item/borg/upgrade/surgery/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/advsurgtool in adv_surgical_tools) //For some reason only this is the only list that worked.
			for(advsurgtool in R.model.modules)
				R.model.remove_module(advsurgtool, TRUE)

		var/obj/item/retractor/retractor = new (R.model)
		R.model.basic_modules += retractor
		R.model.add_module(retractor, FALSE, TRUE)

		var/obj/item/scalpel/scalpel = new (R.model)
		R.model.basic_modules += scalpel
		R.model.add_module(scalpel, FALSE, TRUE)

		var/obj/item/circular_saw/saw = new (R.model)
		R.model.basic_modules += saw
		R.model.add_module(saw, FALSE, TRUE)

		var/obj/item/hemostat/hemo = new (R.model)
		R.model.basic_modules += hemo
		R.model.add_module(hemo, FALSE, TRUE)

		var/obj/item/cautery/cautery = new (R.model)
		R.model.basic_modules += cautery
		R.model.add_module(cautery, FALSE, TRUE)
