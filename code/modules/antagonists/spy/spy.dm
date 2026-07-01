/datum/antagonist/spy
	name = "\improper Spy"
	roundend_category = "spies"
	antagpanel_category = "Spy"
	antag_hud_name = "spy"
	job_rank = ROLE_SPY
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5 // Not really intended to hijack
	ui_name = "AntagInfoSpy"
	preview_outfit = /datum/outfit/spy
	can_assign_self_objectives = TRUE
	default_custom_objective = "Rob the station blind."
	stinger_sound = 'sound/ambience/antag/spy.ogg'
	/// Whether an uplink has been created (successfully or at all)
	var/uplink_created = FALSE
	/// String displayed in the antag panel pointing the spy to where their uplink is.
	var/uplink_location
	/// Whether we give them some random objetives to aim for.
	var/spawn_with_objectives = TRUE
	/// Tracks number of bounties claimed, for roundend
	var/bounties_claimed = 0
	/// Tracks all loot items the spy has claimed, for roundend
	var/list/all_loot = list()
	/// Weakref to our spy uplink
	/// Only exists for the sole purpose of letting admins see it
	var/datum/weakref/uplink_weakref

/datum/antagonist/spy/on_gain()
	if(!uplink_created)
		auto_create_spy_uplink(owner.current)
	if(spawn_with_objectives)
		give_random_objectives()
	return ..()

/datum/antagonist/spy/on_removal()
	. = ..()
	owner.special_role = null

/datum/antagonist/spy/ui_static_data(mob/user)
	var/list/data = ..()
	data["uplink_location"] = uplink_location
	return data

/datum/antagonist/spy/get_admin_commands()
	. = ..()
	// I wanted to put this in check-antagonists but it's less conducive to that
	.["See All Bounties (For all spies)"] = CALLBACK(src, PROC_REF(see_bounties))
	.["Refresh Bounties (For all spies)"] = CALLBACK(src, PROC_REF(refresh_bounties))
	.["Give Spy Uplink"] = CALLBACK(src, PROC_REF(admin_create_spy_uplink))
	.["Bounty Handler VV"] = CALLBACK(src, PROC_REF(bounty_handler_vv))

/datum/antagonist/spy/proc/see_bounties()
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(isnull(uplink))
		tgui_alert(usr, "No spy uplink!", "Mission Failed")
		return

	uplink.ui_interact(usr)

/datum/antagonist/spy/proc/refresh_bounties()
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(isnull(uplink))
		tgui_alert(usr, "No spy uplink!", "Mission Failed")
		return

	uplink.handler.force_refresh()
	tgui_alert(usr, "Bounties refreshed.", "Mission Success")

/datum/antagonist/spy/proc/admin_create_spy_uplink()
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	if(!auto_create_spy_uplink(owner.current))
		tgui_alert(usr, "Failed to give [owner.current] a spy uplink - likely don't have a valid item to host it.", "Mission Failed")

/datum/antagonist/spy/proc/bounty_handler_vv()
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(isnull(uplink))
		tgui_alert(usr, "No spy uplink!", "Mission Failed")
		return

	usr.client?.debug_variables(uplink.handler)

/datum/antagonist/spy/proc/auto_create_spy_uplink(mob/living/carbon/spy)
	if(!iscarbon(spy))
		return FALSE

	var/spy_uplink_loc = spy.client?.prefs?.read_preference(/datum/preference/choiced/uplink_location)
	if(isnull(spy_uplink_loc) || spy_uplink_loc == UPLINK_IMPLANT)
		spy_uplink_loc = pick(UPLINK_PEN, UPLINK_PDA)

	var/obj/item/spy_uplink = spy.get_uplink_location(spy_uplink_loc)
	var/datum/action/backup_uplink/backup = new(src)
	backup.Grant(spy)
	if(isnull(spy_uplink) || !create_spy_uplink(spy, spy_uplink))
		backup.charges = 2
		to_chat(spy, span_boldnotice("You were unable to recieve a uplink, so your ability to create one has been given a additional charge"))
		return FALSE

	return TRUE

/datum/antagonist/spy/proc/create_spy_uplink(mob/living/carbon/spy, obj/item/spy_uplink)
	var/datum/component/spy_uplink/uplink = spy_uplink.AddComponent(/datum/component/spy_uplink, src)
	if(!uplink)
		return FALSE

	uplink_weakref = WEAKREF(uplink)
	uplink_created = TRUE

	if(istype(spy_uplink, /obj/item/modular_computer/pda))
		uplink_location = "your PDA"

	else if(istype(spy_uplink, /obj/item/pen))
		if(istype(spy_uplink.loc, /obj/item/modular_computer/pda))
			uplink_location = "your PDA's pen"
		else
			uplink_location = "a pen"

	else if(istype(spy_uplink, /obj/item/radio))
		uplink_location = "your radio headset"

	return TRUE

/datum/antagonist/spy/proc/give_random_objectives()
	var/list/given_objectives = list()
	for(var/i in 1 to rand(1, 3))
		var/datum/objective/custom/your_mission = new()
		your_mission.owner = owner
		your_mission.explanation_text = pick_list_replacements(SPY_OBJECTIVE_FILE, "objective_body")
		if(your_mission.explanation_text in given_objectives)
			continue
		objectives += your_mission
		given_objectives += your_mission.explanation_text

	if((length(objectives) < 3) && prob(25))
		switch(rand(1, 2))
			if(1)
				var/datum/objective/jailbreak/save_the_jailbird = new()
				save_the_jailbird.owner = owner
				save_the_jailbird.find_target()
				objectives += save_the_jailbird
			if(2)
				var/datum/objective/jailbreak/detain/cage_the_jailbird = new()
				cage_the_jailbird.owner = owner
				cage_the_jailbird.find_target()
				objectives += cage_the_jailbird

	if(prob(10))
		var/datum/objective/martyr/leave_no_trace = new()
		leave_no_trace.owner = owner
		objectives += leave_no_trace

	else if(prob(10)) //10% chance on 87.3% chance
		var/datum/objective/exile/hit_the_bricks = new()
		hit_the_bricks.owner = owner
		objectives += hit_the_bricks

	else
		var/datum/objective/escape/gtfo = new()
		gtfo.owner = owner
		objectives += gtfo

/datum/antagonist/spy/antag_panel_data()
	return "Bounties Claimed: [bounties_claimed]"

/datum/antagonist/spy/roundend_report()
	var/list/report = list()
	report += printplayer(owner)
	report += " - They completed <b>[bounties_claimed]</b> bounties."
	if(bounties_claimed > 0)
		report += " - They received the following rewards: [english_list(all_loot)]"
	report += printobjectives(objectives)
	return report.Join("<br>")

/datum/antagonist/spy/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/dummy = new()
	dummy.set_haircolor(COLOR_SILVER, update = FALSE)
	dummy.set_hairstyle("CIA", update = FALSE)
	var/datum/universal_icon/dummy_icon = render_preview_outfit(preview_outfit, dummy)
	qdel(dummy)
	return finish_preview_icon(dummy_icon)

/datum/outfit/spy
	name = "Spy (Preview only)"
	// Balaclava sprite is ass, otherwise I would use it for this
	uniform = /obj/item/clothing/under/suit/black
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/fedora
	suit = /obj/item/clothing/suit/jacket/trenchcoat
	glasses = /obj/item/clothing/glasses/osi
	ears = /obj/item/radio/headset

/datum/action/backup_uplink
	name = "Create Uplink"
	desc = "Fashion a PDA, Pen or Radio Headset into a swanky Spy Uplink."
	var/charges = 1
	var/list/valid_types = list(
		/obj/item/modular_computer/pda,
		/obj/item/pen,
		/obj/item/radio,
	)

/datum/action/backup_uplink/New(Target)
	. = ..()
	if(!istype(Target, /datum/antagonist/spy))
		stack_trace("[type] created on invalid target [Target || "null"]")
		qdel(src)

/datum/action/backup_uplink/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/spy = clicker
	var/obj/item/held_thing = spy.get_active_held_item()
	if(isnull(held_thing))
		spy.balloon_alert(spy, "you need to hold something!")
		return

	if(!is_type_in_list(held_thing, valid_types))
		held_thing.balloon_alert(spy, "invalid item!")
		return

	var/datum/antagonist/spy/spy_datum = target
	spy_datum.create_spy_uplink(spy, held_thing)
	held_thing.balloon_alert(spy, "uplink created")
	charges--
	if(charges <= 0)
		qdel(src)
