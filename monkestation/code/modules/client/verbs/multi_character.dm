/*
 * # Multi-character verbs
 *
 * Verbs that can be used by a client to switch instantaneously between different mobs that they've
 * been assigned by admins.
 *
 * This multi-character system is meant as an alternative to the "Assume Direct Control" and "Give
 * Control" actions that admins have, when the mobs that a player will be using are known ahead of
 * time. This makes them very useful for storytelling purposes.
 *
**/

/client
	/// A list of `/mob` which has been assigned to this client. No list should exist here unless an
	/// admin has been here.
	var/list/mobs_assigned = null

/mob
	/// List of ckeys denoting the clients that have previously been assigned to this mob.
	var/list/client_assignment_history = null

/mob/Destroy()
	. = ..()
	if(src.client_assignment_history)
		for(var/client/a_client as anything in GLOB.clients)
			LAZYREMOVE(a_client.mobs_assigned, src)

/// Adds the option to assign a mob to a client, via the View-Variables window
/mob/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_ASSIGN_MOB_TO_CLIENT, "Assign Mob to Client")

/// Handles assigning mobs to a client.
/mob/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ASSIGN_MOB_TO_CLIENT])
		if(!check_rights(NONE))
			return
		usr.client.cmd_assign_mob_to_client(src)

/client/proc/cmd_assign_mob_to_client(mob/mob_to_assign in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Assign Mob to Client"

	// Just in case someone convinces the server to somehow call this...
	if(!check_rights(NONE))
		return

	if(!mob_to_assign)
		// How did you even get here...?
		CRASH("Assign Mob to Client verb called without a client.")

	// Ask which client to assign this mob to
	var/client/assign_to = input(src, "Assign this mob to which admin client?", "Assigning mob...") as null|anything in sort_list(GLOB.admins)
	if(!assign_to)
		return

	// If the client we're assigning this mob to isn't an admin (somehow), alert the admin of this
	// and refuse to continue.
	if(!assign_to.holder)
		tgui_alert(
			src,
			title = "Not an Admin",
			message = "The client you selected is (somehow) not an admin."
		)
		return

	// If the client is already assigned this mob, alert the admin of this and refuse to continue.
	if(LAZYFIND(assign_to.mobs_assigned, mob_to_assign))
		tgui_alert(
			src,
			title = "Mob Already Assigned",
			message = "This mob is already assigned to the client you selected.",
		)
		return

	// If the mob is already being controlled by a different client than we selected, ensure the
	// admin is aware that they will not be immediately able to take control.
	if(mob_to_assign.ckey && !mob_to_assign.is_controlled_by_client(assign_to))
		var/understands = tgui_alert(
			src,
			title = "This Mob Is Already Under Control",
			message = "This mob is already being controlled by [mob_to_assign.ckey]. If you assign this mob to [assign_to], they will not be able to switch to this mob until the previous controller relinquishes control. Do you wish to continue?",
			buttons = list("Yes", "No"),
		)
		if(understands != "Yes")
			return

	// Send an admin message...
	message_admins(span_adminnotice("[key_name_admin(src)] assigned a mob ([ADMIN_LOOKUPFLW(mob_to_assign)]) to [key_name_admin(src)]."))
	// Notify the acting admin of how to undo this action...
	to_chat(src, span_notice("You have granted [assign_to] control of a mob. To undo this action, var-edit the 'mobs_assigned' list contained here: [ADMIN_VV(assign_to)]."))

	// Add the mob to the client's assigned mob list...
	LAZYOR(assign_to.mobs_assigned, mob_to_assign)
	// and to the mob's history of clients it's been assigned to
	LAZYOR(mob_to_assign.client_assignment_history, assign_to.ckey)

	// ...and notify the user that they've been granted control.
	to_chat(assign_to, span_notice("You have been granted control of a mob. Use the Switch Character verb in the OOC tab to switch to the mob."))

/// Verb given to clients which allows them to instantly swap between any characters assigned to
/// them.
// TODO: Probably add an `assigned_to` var to mobs, and use that to check if the mob is already assigned
/client/verb/switch_character()
	set category = "OOC"
	set name = "Switch Character"

	// Does the player have any assigned mobs at all?
	if(!src.mobs_assigned)
		to_chat(src, span_notice("You have no mobs assigned to you by an admin."))
		return

	// Does the player have any assigned mobs, aside from their current one?
	// Side note: Why does `(src.mobs_assigned == list(src.mob))` not work?
	if(src.mob && !length(src.mobs_assigned - src.mob))
		to_chat(src, span_notice("You have no other mobs assigned to you by an admin."))
		return

	var/mob/switch_to = tgui_input_list(
		src,
		title = "Character Selection",
		message = "Select a character to swap to",
		items = sort_list(src.mobs_assigned),
	)
	if(!switch_to)
		return

	// Is this mob the same mob as they're already controlling?
	if(switch_to == src.mob)
		return

	// Is the selected mob not being controlled by someone else?
	if(!switch_to.is_controlled_by_client(src))
		var/force_switch = tgui_alert(
			src,
			title = "Character In Use",
			message = "The mob you selected is being controlled by [switch_to.key]. You can switch to this mob, but this will ghost the current controller. Switch anyways?",
			buttons = list("Yes", "No")
		)
		if(force_switch != "Yes")
			return

	// Final check: Is this mob still within the mobs assigned to them?
	// This check is placed last since tgui alerts pause the current proc - and we want to check
	// this at as close a point to switching as possible, to prevent abuse.
	if(!LAZYFIND(src.mobs_assigned, switch_to))
		tgui_alert(
			src,
			title = "Switching Canceled",
			message = "The mob you selected is no longer in your assigned mobs list.",
		)
		return

	// Ensure the client is part of this mob's assignment history.
	LAZYOR(switch_to.client_assignment_history, src.ckey)

	// And finally, switch this client's control to the mob.
	src.switch_control_to_mob(switch_to)

/mob/proc/is_controlled_by_client(client/who)
	if(!who)
		CRASH("who parameter not specified")
	if(!src.ckey)
		return FALSE
	// We check for "@ckey" because that's the format used by aghost.
	return (src.ckey == who.ckey || src.ckey == "@[who.ckey]")

/client/proc/switch_control_to_mob(mob/switch_to)
	// Perform the switch
	if(!switch_to.is_controlled_by_client(src))
		// If they're within this block, the user already knows someone was controlling it, and has
		// decided to take over.
		to_chat(switch_to.client, span_notice("Another player has forcefully taken over this mob."))
		switch_to.ghostize(FALSE)

	var/mob/old_mob = src.mob
	switch_to.ckey = src.ckey
	switch_to.client?.init_verbs()
	// If the client's previous mob was an observer, we have no more work to do but to delete the ghost.
	if(isobserver(old_mob))
		qdel(old_mob)
		return

	// I'm not sure if there's a need for this, but the aghost verb does this as a hack for
	// something, so...
	old_mob.ckey = "@[src.ckey]"
	// Prevents the mob from showing the usual "Zz" icon when someone is disconnected.
	if(isliving(old_mob))
		var/mob/living/old_mob_living = old_mob
		old_mob_living.set_ssd_indicator(FALSE)
