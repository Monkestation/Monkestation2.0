// Deadchat copied from ./looc.dm which was ported from Bee, which was in turn ported from Citadel
GLOBAL_VAR_INIT(deadchat_allowed, TRUE)

//admin tool
/proc/toggle_deadchat(toggle = null)
	if(!isnull(toggle)) //if we're specifically en/disabling deadchat
		GLOB.deadchat_allowed = toggle
	else //otherwise just toggle it
		GLOB.deadchat_allowed = !GLOB.deadchat_allowed
	deadchat_broadcast("<span class='bold'>Deadchat channel has been globally [GLOB.deadchat_allowed ? "enabled" : "disabled"].</span>")

ADMIN_VERB(toggledeadchat, R_ADMIN, FALSE, "Toggle Deadchat", "Shows the range of cameras on the station.", ADMIN_CATEGORY_SERVER)
	toggle_deadchat()
	log_admin("[key_name(user)] toggled Deadchat.")
	message_admins("[key_name_admin(user)] toggled Deadchat.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Deadchat", "[GLOB.deadchat_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
