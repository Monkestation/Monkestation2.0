/datum/robot_model/peacekeeper
	name = "Peacekeeper"
	hud_icon_state = "standard"
	default_skin = /datum/robot_skin/peacekeeper/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/rsf/cookiesynth,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/borg/projectile_dampen
	)
	emagged_modules = list(
		/obj/item/reagent_containers/borghypo/peace/hacked
	)
	clock_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sigil_submission
	)
	traits = list(TRAIT_PUSHIMMUNE)

/datum/robot_model/peacekeeper/do_transform_animation()
	. = ..()
	if(!.)
		return
	to_chat(cyborg_owner, span_userdanger("You are an Enforcer and Upholder of your active lawset. \
		You are not a security member and you are expected to follow orders and prevent harm above all else. Space law means nothing to you."))
