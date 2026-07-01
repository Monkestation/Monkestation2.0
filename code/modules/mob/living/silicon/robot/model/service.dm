/datum/robot_model/service
	name = "Service"
	hud_icon_state = "service"
	default_skin = /datum/robot_skin/service/default
	available_skins = list(
		/datum/robot_skin/service/default,
		/datum/robot_skin/service/bro,
		/datum/robot_skin/service/kent,
		/datum/robot_skin/service/tophat,
		/datum/robot_skin/service/waitress,
		/datum/robot_skin/service/kerfus
	)
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
	clockwork_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clockwork/replica_fabricator
	)

	radio_channels = list(RADIO_CHANNEL_SERVICE)

/datum/robot_model/service/on_model_removed()
	qdel(cyborg_owner.GetComponent(/datum/component/personal_crafting/borg))
	for(var/atom/movable/screen/craft/button in cyborg_owner.hud_used.static_inventory)
		qdel(button)

/datum/robot_model/service/on_model_given()
	cyborg_owner.AddComponent(/datum/component/personal_crafting/borg)
	var/datum/component/personal_crafting/borg/crafting = cyborg_owner.GetComponent(/datum/component/personal_crafting/borg)
	crafting.forced_mode = TRUE
	crafting.mode = TRUE
	if(cyborg_owner.client)
		crafting.create_mob_button(cyborg_owner, cyborg_owner.client)
