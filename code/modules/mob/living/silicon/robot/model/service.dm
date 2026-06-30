GENERATE_ROBOT_MODEL(service)

/datum/robot_model/service
	name = "Service"
	default_skin = /datum/robot_skin/service/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/knife/kitchen/silicon,
		/obj/item/borg/apparatus/cooking,
		/obj/item/reagent_containers/cup/beaker/large, // While the shaker is more appropriate, this is for ease of identification.
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/pen,
		/obj/item/reagent_containers/cup/rag,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/scissors,
		/obj/item/hairbrush/comb,
		/obj/item/dyespray,
		/obj/item/rsf,
		/obj/item/instrument/guitar,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/storage/bag/tray,
		/obj/item/reagent_containers/borghypo/borgshaker,
		/obj/item/borg/lollipop,
		/obj/item/stack/pipe_cleaner_coil/cyborg,
		/obj/item/borg/apparatus/beaker/service,
		/obj/item/chisel,
		/obj/item/storage/bag/plants,
		/obj/item/plant_analyzer,
		/obj/item/shovel/spade,
		/obj/item/cultivator
	)
	emagged_modules = list(
		/obj/item/reagent_containers/borghypo/borgshaker/hacked
	)
	radio_channels = list(RADIO_CHANNEL_SERVICE)

/*
/datum/robot_model/service/be_transformed_to(obj/item/robot_model/old_model)
	. = ..()
	var/mob/living/silicon/robot/cyborg = loc

	cyborg.AddComponent(/datum/component/personal_crafting/borg)
	var/datum/component/personal_crafting/borg/crafting = cyborg.GetComponent(/datum/component/personal_crafting/borg)
	crafting.forced_mode = TRUE
	crafting.mode = TRUE
	if(cyborg.client)
		crafting.create_mob_button(cyborg, cyborg.client)

/datum/robot_model/service/Destroy()
	var/mob/living/silicon/robot/cyborg = loc
	if(istype(cyborg, /mob/living/silicon/robot))
		qdel(cyborg.GetComponent(/datum/component/personal_crafting/borg))
		for(var/atom/movable/screen/craft/button in cyborg.hud_used.static_inventory)
			qdel(button)
	return ..()
*/
