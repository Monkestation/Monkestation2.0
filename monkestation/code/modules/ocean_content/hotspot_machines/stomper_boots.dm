/obj/item/clothing/shoes/stomper
	name = "stomper boots"
	icon_state = "stompers0"
	base_icon_state = "stompers"
	armor_type = /datum/armor/shoes_magboots
	actions_types = list(/datum/action/item_action/stomp)
	strip_delay = 7 SECONDS
	equip_delay_other = 7 SECONDS
	resistance_flags = FIRE_PROOF
	alternate_worn_layer = ABOVE_SUIT_LAYER
	clothing_flags = THICKMATERIAL

	/// Are we currently stomping?
	/// Basically used for the cooldown + changing the sprite back.
	var/stomping = FALSE
	/// The cooldown between stomping.
	var/stomp_cooldown = 1 SECONDS

/obj/item/clothing/shoes/stomper/ui_action_click(mob/user, action)
	if(!istype(action, /datum/action/item_action/stomp))
		return ..()
	if(stomping)
		user.balloon_alert(user, "wait a moment!")
		return
	var/turf/user_turf = get_turf(user)
	if(!user_turf || !SSmapping.level_trait(user_turf.z, ZTRAIT_OSHAN))
		user.balloon_alert(user, "must be in ocean!")
		return
	stomping = TRUE
	icon_state = "[base_icon_state]1"
	user.update_worn_shoes()
	user.balloon_alert(user, "stomped")
	user.visible_message(span_notice("[user] stomps down on \the [user_turf] with \the [src]!"))
	SShotspots.stomp(user_turf)
	addtimer(CALLBACK(src, PROC_REF(finish_stomp)), stomp_cooldown)
	// animate them jumping
	animate(user, pixel_z = user.pixel_z + 4, time = 0.1 SECONDS)
	animate(pixel_z = user.pixel_z - 4, time = 0.1 SECONDS)

/obj/item/clothing/shoes/stomper/proc/finish_stomp()
	stomping = FALSE
	icon_state = "[base_icon_state]0"
	if(isliving(loc))
		var/mob/living/living_loc = loc
		living_loc.update_worn_shoes()
