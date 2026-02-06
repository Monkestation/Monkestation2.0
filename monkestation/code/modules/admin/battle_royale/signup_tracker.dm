/obj/effect/battle_royale_signup
	name = "Battle Royale Signup Machine"
	desc = "Click to sign up for battle royale."
	icon = 'icons/effects/128x128.dmi'
	icon_state = "meatball_man"
	pixel_x = -32
	pixel_y = -32
	plane = GAME_PLANE_UPPER
	///List of people currently signed up
	var/list/signed_up = list()

/obj/effect/battle_royale_signup/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)
	notify_ghosts(
		"SIGN UP FOR BATTLE ROYALE HERE!",
		source = src,
		header = "BATTLE ROYALE",
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_DEFAULT,
	)

/obj/effect/battle_royale_signup/Destroy(force)
	signed_up = null
	SSpoints_of_interest.remove_point_of_interest(src)
	return ..()

/obj/effect/battle_royale_signup/attack_ghost(mob/user)
	. = ..()
	if(user in signed_up) //this should never be around for very long so just make sure to check for deletion before accessing things in here
		if(tgui_alert(user, "CANCEL battle royale signup?", "Battle Royale", list("Yes", "No"), FALSE) == "Yes")
			if(!QDELETED(src))
				signed_up -= user
	else if(tgui_alert(user, "Sign up for battle royale?", "Battle Royale", list("Yes", "No"), FALSE) == "Yes")
		if(!QDELETED(src))
			signed_up += user
