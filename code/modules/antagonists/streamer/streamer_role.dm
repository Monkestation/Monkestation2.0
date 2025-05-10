///this isn't a real antag but I can't find any non antag special roles
/datum/antagonist/streamer
	name = "Streamer"

	var/list/followers = list()
	var/list/subscribers = list()
	var/team = "Cult"
	var/conversions = 0
	var/hits = 0
	var/obj/machinery/camera/spesstv/camera

/datum/antagonist/streamer/on_gain()
	. = ..()
	owner.current.hud_used.streamer_hud()

	update_streamer_hud()

/datum/antagonist/streamer/forge_objectives()
	objectives += new /datum/objective/reach_followers
	objectives += new /datum/objective/reach_subscribers


/datum/antagonist/streamer/proc/update_streamer_hud()
	var/mob/M = owner.current
	if(!M || QDELETED(M) || !M.client || !M.hud_used)
		return
	var/atom/movable/screen/streamer_display = M.hud_used.streamer_display
	if(!streamer_display)
		M.hud_used.streamer_hud()
		streamer_display = M.hud_used.streamer_display
	streamer_display.maptext_width = 84
	streamer_display.maptext_height = 64
	var/list/text = list("<div align = 'left' valign = 'top' style = 'position:relative; top:0px; left:6px'>")
	switch(team)
		if("Cult")
			text += "Conversions: <font color = '#FF1133'>[conversions]</font>"
		if("Security")
			text += "Hits: <font color = '#FF1133'>[hits]</font>"
	text += "<br>Followers: <font color = '#33FF33'>[length(followers)]</font>"
	text += "<br>Subscribers:<font color = '#FFFF00'>[length(subscribers)]</font></div>"
	streamer_display.maptext = jointext(text, null)

/datum/antagonist/streamer/proc/try_add_follower(datum/mind/new_follower)
	if(new_follower == owner)
		to_chat(new_follower.current, span_warning("Following yourself is against Spess.TV's End User License Agreement.") )
		return
	if(followers.Find(new_follower))
		to_chat(new_follower.current, span_warning("You are already following [owner.name].") )
		return
	followers += new_follower
	new_follower.current.visible_message("<span class = 'big notice'>[new_follower.current] is now following [owner.name]!</span>")

/datum/antagonist/streamer/proc/try_add_subscription(datum/mind/new_subscriber, obj/machinery/computer/security/spesstv/tv)
	if(new_subscriber == owner)
		to_chat(new_subscriber.current, span_warning("Subscribing to yourself is against Spess.TV's End User License Agreement.") )
		return
	if(subscribers.Find(new_subscriber))
		to_chat(new_subscriber.current, span_warning("You're already subscribed to [owner.name]!") )
		return
	var/mob/living/current = new_subscriber.current
	var/obj/item/card/id/auth = current.get_idcard(TRUE)
	var/datum/bank_account/account = auth.registered_account
	if(account.adjust_money(-250, "Spess.TV subscription to [owner.name]"))
		tv.visible_message("<span class = 'big notice'>[new_subscriber.current] just subscribed to [name]!</span>")
		playsound(tv, pick('monkestation/code/modules/bloody_cult/sound/noisemaker1.ogg', 'monkestation/code/modules/bloody_cult/sound/noisemaker2.ogg', 'monkestation/code/modules/bloody_cult/sound/noisemaker3.ogg'), 100, TRUE)
		playsound(owner.current, pick('monkestation/code/modules/bloody_cult/sound/noisemaker1.ogg', 'monkestation/code/modules/bloody_cult/sound/noisemaker2.ogg', 'monkestation/code/modules/bloody_cult/sound/noisemaker3.ogg'), 100, TRUE)
	else
		tv.visible_message(span_warning("Something went wrong processing [new_subscriber.current]'s payment.") )
		return
	subscribers += new_subscriber
	/*
	switch(team)
		if("Cult")
			new /obj/item/weapon/storage/cult/sponsored(get_turf(antag.current))
			for(var/i in 1 to 3)
				new /obj/item/weapon/reagent_containers/food/drinks/soda_cans/geometer(get_turf(new_subscriber.current))
		if("Security")
			new /obj/item/weapon/storage/lockbox/security_sponsored(get_turf(antag.current))
			for(var/i in 1 to 4)
				new /obj/item/weapon/reagent_containers/food/snacks/donitos(get_turf(new_subscriber.current))
	*/

/datum/antagonist/streamer/proc/toggle_streaming()
	camera.toggle_cam()
	owner.current.visible_message("<span class = 'big notice'>[owner.current] is now [camera.status ? "streaming!" : "offline."]</span>")

/datum/antagonist/streamer/proc/set_camera(obj/machinery/camera/spesstv/new_camera)
	ASSERT(istype(new_camera))
	camera = new_camera
	camera.streamer = src
	camera.setup_streamer()
	camera.name_camera()


/datum/objective/reach_followers
	var/followers_jectie = 15
	explanation_text = "Reach 15 followers."
	name = "(streamer) Reach followers"

/datum/objective/reach_followers/New()
	. = ..()
	followers_jectie = round(rand(10, 20))
	explanation_text = "Reach [followers_jectie] followers."

/datum/objective/reach_followers/check_completion()
	var/datum/antagonist/streamer/S = owner.has_antag_datum(/datum/antagonist/streamer)
	if (!S)
		message_admins("BUG: [owner.current] was given a streamer objective but is not affiliated with Spess.TV!")
		return FALSE
	return length(S.followers) >= followers_jectie

/datum/objective/reach_subscribers
	var/subscribers_jectie = 7
	explanation_text = "Reach 7 subscribers."
	name = "(streamer) Reach subscribers"

/datum/objective/reach_subscribers/New()
	. = ..()
	subscribers_jectie = round(rand(5, 10))
	explanation_text = "Reach [subscribers_jectie] subscribers."

/datum/objective/reach_subscribers/check_completion()
	var/datum/antagonist/streamer/S = owner.has_antag_datum(/datum/antagonist/streamer)
	if (!S)
		message_admins("BUG: [owner.current] was given a streamer objective but is not affiliated with Spess.TV!")
		return FALSE
	return length(S.subscribers) >= subscribers_jectie
