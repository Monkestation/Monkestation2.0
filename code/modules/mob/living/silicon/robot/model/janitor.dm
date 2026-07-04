/datum/robot_model/janitor
	name = "Janitor"
	hud_icon_state = "janitor"
	default_skin = /datum/robot_skin/janitor/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/soap/nanotrasen/cyborg,
		/obj/item/storage/bag/trash,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer,
		/obj/item/holosign_creator,
		/obj/item/reagent_containers/spray/cyborg_drying,
		/obj/item/wirebrush,
		/obj/item/pushbroom/cyborg
	)
	emagged_modules = list(
		/obj/item/reagent_containers/spray/cyborg_lube
	)
	clockwork_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/vanguard,
		/obj/item/clockwork/weapon/brass_spear
	)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	/// The weakref to the wash toggle action we own.
	var/datum/weakref/wash_toggle_ref

/datum/robot_model/janitor/New(mob/living/silicon/robot/new_cyborg_owner)
	. = ..()
	if(!cyborg_owner)
		return
	var/datum/action/wash_toggle = new /datum/action/toggle_buffer(cyborg_owner)
	wash_toggle.Grant(cyborg_owner)
	wash_toggle_ref = WEAKREF(wash_toggle)

/datum/robot_model/janitor/Destroy()
	if(cyborg_owner)
		QDEL_NULL(wash_toggle_ref)
	return ..()

/datum/robot_model/janitor/on_cyborg_recharge(coeff)
	. = ..()
	for(var/obj/item/usable_module in usable_modules)
		if(istype(usable_module, /obj/item/reagent_containers/spray/cyborg_drying))
			var/obj/item/reagent_containers/spray/cyborg_drying/drying_spray
			drying_spray.reagents.add_reagent(/datum/reagent/drying_agent, 5 * coeff)
			continue
		if(istype(usable_module, /obj/item/reagent_containers/spray/cyborg_lube))
			var/obj/item/reagent_containers/spray/cyborg_drying/lube_spray
			lube_spray.reagents.add_reagent(/datum/reagent/lube, 2 * coeff)
			continue

/obj/item/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list(/datum/reagent/lube = 250)
