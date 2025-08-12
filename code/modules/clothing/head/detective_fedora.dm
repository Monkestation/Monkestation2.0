//Detective
/obj/item/clothing/head/fedora/det_hat
	name = "detective's fedora"
	desc = "There's only one man who can sniff out the dirty stench of crime, and he's likely wearing this hat."
	armor_type = /datum/armor/fedora_det_hat
	icon_state = "detective"
	inhand_icon_state = "det_hat"
	var/candy_cooldown = 0
	dog_fashion = /datum/dog_fashion/head/detective
	///Path for the flask that spawns inside their hat roundstart
	var/flask_path = /obj/item/reagent_containers/cup/glass/flask/det

	var/datum/action/item_action/noir_mode/noir_action

/datum/armor/fedora_det_hat
	melee = 25
	bullet = 5
	laser = 25
	energy = 35
	fire = 30
	acid = 50
	wound = 5

/obj/item/clothing/head/fedora/det_hat/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/small/fedora/detective)

	new flask_path(src)
	noir_action = new(src)
	add_item_action(noir_action)

/obj/item/clothing/head/fedora/det_hat/Destroy()
	QDEL_NULL(noir_action)
	return ..()

/obj/item/clothing/head/fedora/det_hat/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to take a candy corn.")

/obj/item/clothing/head/fedora/det_hat/AltClick(mob/user)
	. = ..()
	if(loc != user || !user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	if(candy_cooldown < world.time)
		var/obj/item/food/candy_corn/CC = new /obj/item/food/candy_corn(src)
		user.put_in_hands(CC)
		to_chat(user, span_notice("You slip a candy corn from your hat."))
		candy_cooldown = world.time+1200
	else
		to_chat(user, span_warning("You just took a candy corn! You should wait a couple minutes, lest you burn through your stash."))

/obj/item/clothing/head/fedora/det_hat/minor
	flask_path = /obj/item/reagent_containers/cup/glass/flask/det/minor

/datum/action/item_action/noir_mode
	name = "Investigate"

	var/area/station/security/detectives_office/noir_area
	var/list/datum/weakref/noired_mobs = list()

	var/investigating = FALSE

/datum/action/item_action/noir_mode/Remove(mob/remove_from)
	. = ..()
	stop_investigating(remove_from)

/datum/action/item_action/noir_mode/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	if(!investigating)
		start_investigating(usr)
	else
		stop_investigating(usr)

/datum/action/item_action/noir_mode/proc/start_investigating(mob/living/user)
	investigating = TRUE
	user.apply_status_effect(/datum/status_effect/noir)
	RegisterSignal(user, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))

	on_enter_area(null, get_area(user))

/datum/action/item_action/noir_mode/proc/stop_investigating(mob/living/user)
	investigating = FALSE
	user.remove_status_effect(/datum/status_effect/noir)
	UnregisterSignal(user, COMSIG_ENTER_AREA)

	if(noir_area)
		UnregisterSignal(noir_area, COMSIG_AREA_ENTERED)
		noir_area = null

	free_noired_mobs()

/datum/action/item_action/noir_mode/proc/free_noired_mobs()
	for(var/datum/weakref/weakref as anything in noired_mobs)
		var/mob/living/carbon/human/H = weakref.resolve()
		if(H)
			H.remove_status_effect(/datum/status_effect/grouped/noir_in_area, ref(src))

/datum/action/item_action/noir_mode/proc/on_enter_area(datum/source, area/entered)
	SIGNAL_HANDLER

	if(istype(entered, /area/station/security/detectives_office))
		noir_area = entered
		RegisterSignal(noir_area, COMSIG_AREA_ENTERED, PROC_REF(noir_area_entered))

		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(get_area(H) != noir_area)
				continue

			noir_mob(H)


	else if(noir_area)
		free_noired_mobs()
		UnregisterSignal(noir_area, COMSIG_AREA_ENTERED)
		noir_area = null

/datum/action/item_action/noir_mode/proc/noir_area_entered(datum/source, atom/movable/arrived, area/old_area)
	SIGNAL_HANDLER

	if(!ishuman(arrived) || arrived == owner || astype(arrived, /mob/living/carbon/human)?.mind?.assigned_role?.title == JOB_DETECTIVE)
		return

	noir_mob(arrived)

/datum/action/item_action/noir_mode/proc/noir_mob(mob/living/carbon/human/H)
	if(H == owner)
		return

	if(!H.apply_status_effect(/datum/status_effect/grouped/noir_in_area, ref(src), noir_area))
		return

	noired_mobs |= WEAKREF(H)
