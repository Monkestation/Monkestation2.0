/datum/robot_model/engineering
	name = "Engineering"
	hud_icon_state = "engineer"
	default_skin = /datum/robot_skin/engineering/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/borg/cyborg_omnitool/engineering,
		/obj/item/borg/cyborg_omnitool/engineering,
		/obj/item/storage/part_replacer/cyborg,
		/obj/item/lightreplacer,
		/obj/item/borg/apparatus/circuit,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/borg/apparatus/sheet_manipulator,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/stack/cable_coil,
		/obj/item/holosign_creator/atmos
	)
	emagged_modules = list(
		/obj/item/borg/stun,
	)
	clockwork_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/tinkerers_cache,
		/obj/item/clock_module/stargazer,
		/obj/item/clockwork/replica_fabricator,
		/obj/item/clock_module/sigil_transmission
	)
	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	traits = list(TRAIT_NEGATES_GRAVITY, TRAIT_KNOW_ENGI_WIRES, TRAIT_KNOW_ROBO_WIRES)

/datum/robot_model/engineering/New(mob/living/silicon/robot/new_cyborg_owner)
	. = ..()
	if(!cyborg_owner)
		return
	var/datum/action/cooldown/borg_sight_vision/sight_vision_meson = new(cyborg_owner)
	sight_vision_meson.Grant(cyborg_owner)
	sight_vision_ref = WEAKREF(sight_vision_meson)
