/atom/movable/screen/mapvote_hud
	name = "map vote"
	icon = 'icons/hud/screen_vote.dmi'
	icon_state = "Glass_top"
	maptext_width = 96
	maptext_height = 160
	screen_loc = ui_votehud
	plane = SPLASHSCREEN_PLANE
	invisibility = INVISIBILITY_ABSTRACT
	var/user_preference = "Glass"
	var/list/atom/movable/screen/mapvote_button/buttons = list()
	var/atom/movable/screen/mapvote_button/last_choice
	var/latest_vote_count
	var/latest_vote_length

/atom/movable/screen/mapvote_hud/Initialize(mapload, datum/hud/hud_owner, datum/preferences/preferences)
	. = ..()
/* I am not making good looking hud's for every type of a hud, framework's here though
	if(preferences)
		user_preference = preferences.read_preference(/datum/preference/choiced/ui_style)
		if(icon_exists(icon, "[user_preference]_top"))
			icon_state = "[user_preference]_top"
		else
			user_preference = initial(user_preference)
*/

	// position this to the left if you're in the lobby, else it overlaps with the server buttons
	if(isnewplayer(hud_owner?.mymob))
		screen_loc = ui_votehud_left

	RegisterSignal(SSvote, COMSIG_VOTE_STARTED, PROC_REF(show))
	RegisterSignal(SSvote, COMSIG_VOTE_ENDED, PROC_REF(hide))

/atom/movable/screen/mapvote_hud/Destroy()
	UnregisterSignal(SSvote, list(COMSIG_VOTE_STARTED, COMSIG_VOTE_ENDED))
	hide()
	return ..()

/atom/movable/screen/mapvote_hud/update_overlays()
	cut_overlays()
	. = ..()
	var/valid_maptext_dimensions = ICON_SIZE_Y * length(latest_vote_length)
	maptext_height = valid_maptext_dimensions
	maptext_y = -valid_maptext_dimensions
	var/obj/effect/abstract/overlay_holder = new()
	overlay_holder.icon = icon
	overlay_holder.layer = layer
	overlay_holder.plane = plane
	for(var/index in 1 to latest_vote_length)
		overlay_holder.pixel_y = index * -ICON_SIZE_Y
		overlay_holder.icon_state = "[user_preference]_middle"
		if(index == latest_vote_length)
			overlay_holder.icon_state = "[user_preference]_bottom"
		add_overlay(overlay_holder)
	QDEL_NULL(overlay_holder)

/atom/movable/screen/mapvote_hud/proc/show()
	SIGNAL_HANDLER

	invisibility = INVISIBILITY_NONE
	var/datum/vote/vote = SSvote.current_vote
	latest_vote_count = vote.count_method
	var/choices = vote.choices
	latest_vote_length = length(choices)

	var/text = "[vote.override_question ? vote.override_question : vote.name]"
	text = "[text]\n[latest_vote_count == VOTE_COUNT_METHOD_SINGLE ? "Single" : "Multiple"] choice"

	maptext = MAPTEXT("<div align='center' valign='top' style='position:relative;'><font color='cyan'>[text]</font></div>")
	update_overlays(latest_vote_length)
	for(var/index in 1 to latest_vote_length)
		var/choice = choices[index]
		var/atom/movable/screen/mapvote_button/button = new(src, hud, choice)
		if(vote.has_desc)
			button.desc = vote.return_desc(choice)
		button.pixel_y = index * -ICON_SIZE_Y
		RegisterSignal(button, COMSIG_VOTE_CHOICE_SELECTED, PROC_REF(handle_vote_click))
		buttons += button
		button.icon_state = "[user_preference]_button"
		vis_contents += button

	var/atom/movable/screen/mapvote_button/exit/button = new(src, hud)
	button.pixel_y = (latest_vote_length + 1) * -ICON_SIZE_Y
	RegisterSignal(button, COMSIG_VOTE_CHOICE_SELECTED, PROC_REF(handle_vote_click))
	buttons += button
	button.icon_state = "[user_preference]_exit"
	vis_contents += button

/atom/movable/screen/mapvote_hud/proc/hide()
	SIGNAL_HANDLER

	invisibility = INVISIBILITY_ABSTRACT
	last_choice = null
	for(var/atom/movable/screen/mapvote_button/button as anything in buttons)
		vis_contents -= button
		UnregisterSignal(button, COMSIG_VOTE_CHOICE_SELECTED)
		qdel(button)

	buttons.Cut()

/atom/movable/screen/mapvote_hud/proc/handle_vote_click(datum/source, mob/user, atom/movable/screen/mapvote_button/button, choice)
	SIGNAL_HANDLER

	if(isnull(choice))
		hide()
		return

	button.color = COLOR_VERY_PALE_LIME_GREEN
	if(latest_vote_count == VOTE_COUNT_METHOD_SINGLE)
		if(last_choice && last_choice != button)
			last_choice.color = null

		SSvote.submit_single_vote(user, choice)

		if(user.client?.prefs?.read_preference(/datum/preference/toggle/mapvote_autoclose))
			hide()
			return
	else
		if(SSvote.current_vote.choices_by_ckey[user.ckey + choice] == 1)
			button.color = null

		SSvote.submit_multi_vote(user, choice)

	last_choice = button

/atom/movable/screen/mapvote_button
	name = "voting button"
	icon = 'icons/hud/screen_vote.dmi'
	icon_state = "Glass_button"
	plane = SPLASHSCREEN_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER
	maptext_height = 38
	maptext_width = 86
	maptext_x = 6
	var/choice

/atom/movable/screen/mapvote_button/Initialize(mapload, datum/hud/hud_owner, wanted_choice = null)
	. = ..()
	if(isnull(wanted_choice))
		return

	choice = wanted_choice
	maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative;'><font color='cyan'>[choice]</font></div>")

/atom/movable/screen/mapvote_button/Click(location, control, params)
	SEND_SIGNAL(src, COMSIG_VOTE_CHOICE_SELECTED, usr, src, choice)

/atom/movable/screen/mapvote_button/MouseEntered(location, control, params)
	. = ..()
	if(desc)
		openToolTip(usr, src, params, content = desc)

/atom/movable/screen/mapvote_button/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/mapvote_button/exit
	name = "voting button"
	icon = 'icons/hud/screen_vote.dmi'
	icon_state = "Glass_exit"
	plane = SPLASHSCREEN_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER
