/obj/item/pinpointer/revhead
	name = "provocatuer pinpointer"
	desc = "A device capable of tracking any leaders of an uprising, for security reasons, only members of command can use it."
	minimum_range = 10

/obj/item/pinpointer/revhead/attack_self(mob/living/user)
	if (!(user?.mind in SSjob.get_all_heads()))
		user.dropItemToGround(src)
		to_chat(user, span_warning("The pinpointer shocks you and you drop it! It only works for members of command."))
		return
	. = ..()

/obj/item/pinpointer/revhead/dropped(mob/user)
	. = ..()
	active = FALSE
	target = null
	STOP_PROCESSING(SSfastprocess, src)
	update_appearance()

/obj/item/pinpointer/revhead/scan_for_target()
	target = null
	var/dist = 1000
	var/mob/living/body
	var/mob/living/possible_target
	var/list/heads_list = get_antag_minds(/datum/antagonist/rev/head)
	for(var/datum/mind/revhead_mind as anything in heads_list)
		body = revhead_mind.current
		if(get_dist(src, body) < dist && considered_alive(revhead_mind))
			dist = get_dist(src, body)
			possible_target = body
	if(QDELETED(body))
		return
	target = possible_target
