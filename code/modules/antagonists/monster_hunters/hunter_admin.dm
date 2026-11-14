/datum/antagonist/monsterhunter/antag_panel_data()
	var/list/lines = list("Rifts opened: [rabbits_spotted]/5")
	for(var/obj/effect/bnnuy/rift as anything in rabbits)
		lines += "Rift: [ADMIN_VERBOSEJMP(rift)]"
	for(var/datum/objective/hunter/goal in objectives)
		var/mob/prey_body = goal.target.current
		lines += "Prey: [goal.target.name] ([goal.discovered ? "named" : "hidden"], [considered_alive(goal.target) ? "alive" : "dead"]) [ADMIN_VERBOSEJMP(prey_body)]"
	return lines.Join("<br>")

/datum/antagonist/monsterhunter/get_admin_commands()
	. = ..()
	.["Add Prey"] = CALLBACK(src, PROC_REF(admin_add_prey))
	var/has_prey = FALSE
	var/has_hidden_prey = FALSE
	for(var/datum/objective/hunter/goal in objectives)
		has_prey = TRUE
		if(!goal.discovered)
			has_hidden_prey = TRUE
			break
	if(has_prey)
		.["Remove Prey"] = CALLBACK(src, PROC_REF(admin_remove_prey))
	if(has_hidden_prey)
		.["Reveal Prey"] = CALLBACK(src, PROC_REF(admin_reveal_prey))
	if(rabbits_spotted + length(rabbits) < 5)
		.["Respawn Missing Rifts"] = CALLBACK(src, PROC_REF(admin_respawn_rifts))

/datum/antagonist/monsterhunter/proc/admin_add_prey(mob/admin)
	var/list/current_prey = list()
	for(var/datum/objective/hunter/goal in objectives)
		current_prey += goal.target

	var/list/candidates = list()
	var/list/used_keys = list()
	var/default
	for(var/datum/mind/candidate as anything in SSticker.minds)
		if(candidate == owner || (candidate in current_prey) || QDELETED(candidate.current) || candidate.current.stat == DEAD)
			continue
		var/key = avoid_assoc_duplicate_keys("[candidate.name] ([candidate.assigned_role?.title])[is_monster_hunter_prey(candidate) ? " - monster" : ""]", used_keys)
		candidates[key] = candidate
		if(candidate.current == admin.client?.holder.marked_datum)
			default = key

	var/choice = tgui_input_list(admin, "Choose a new prey", "Add Prey", candidates, default)
	if(QDELETED(src) || !admin.client?.holder || isnull(choice))
		return
	var/datum/mind/target = candidates[choice]
	var/reveal = tgui_alert(admin, "Reveal them to the hunter now?", "Add Prey", list("Yes", "No"))
	if(QDELETED(src) || !admin.client?.holder || isnull(reveal))
		return

	var/datum/objective/hunter/new_goal = new
	new_goal.owner = owner
	new_goal.target = target
	add_objective(new_goal)
	to_chat(owner.current, span_userdanger("A new monster has been added to your prey. Your objective list has been updated!"))
	if(reveal == "Yes")
		reveal_prey(new_goal)
	message_admins("[key_name_admin(admin)] added [key_name_admin(target)] as prey for [key_name_admin(owner)] ([reveal == "Yes" ? "revealed" : "hidden"]).")
	log_admin("[key_name(admin)] added [key_name(target)] as prey for [key_name(owner)] ([reveal == "Yes" ? "revealed" : "hidden"]).")

/datum/antagonist/monsterhunter/proc/admin_remove_prey(mob/admin)
	var/list/removable = list()
	var/list/used_keys = list()
	for(var/datum/objective/hunter/goal in objectives)
		removable[avoid_assoc_duplicate_keys(goal.target.name, used_keys)] = goal

	var/choice = tgui_input_list(admin, "Choose prey to remove", "Remove Prey", removable)
	if(QDELETED(src) || !admin.client?.holder || isnull(choice))
		return
	var/datum/objective/hunter/goal = removable[choice]
	var/datum/mind/target = goal.target
	objectives -= goal
	qdel(goal)
	for(var/list/entry as anything in journal)
		if(entry["ref"] == REF(target))
			journal -= list(entry)
			break
	update_static_data_for_all_viewers()
	to_chat(owner.current, span_userdanger("A target has been removed from your prey. Your objective list has been updated!"))
	message_admins("[key_name_admin(admin)] removed [key_name_admin(target)] from [key_name_admin(owner)]'s prey.")
	log_admin("[key_name(admin)] removed [key_name(target)] from [key_name(owner)]'s prey.")

/datum/antagonist/monsterhunter/proc/admin_reveal_prey(mob/admin)
	var/list/hidden = list()
	var/list/used_keys = list()
	for(var/datum/objective/hunter/goal in objectives)
		if(!goal.discovered)
			hidden[avoid_assoc_duplicate_keys(goal.target.name, used_keys)] = goal

	var/choice = tgui_input_list(admin, "Choose prey to reveal", "Reveal Prey", list("(All)") + assoc_to_keys(hidden))
	if(QDELETED(src) || !admin.client?.holder || isnull(choice))
		return
	var/list/revealing = choice == "(All)" ? assoc_to_values(hidden) : list(hidden[choice])
	for(var/datum/objective/hunter/goal as anything in revealing)
		reveal_prey(goal)
		message_admins("[key_name_admin(admin)] revealed [key_name_admin(goal.target)] to [key_name_admin(owner)].")
		log_admin("[key_name(admin)] revealed [key_name(goal.target)] to [key_name(owner)].")

/datum/antagonist/monsterhunter/proc/admin_respawn_rifts(mob/admin)
	spawn_rabbits(5 - rabbits_spotted)
	message_admins("[key_name_admin(admin)] respawned [key_name_admin(owner)]'s missing rifts.")
	log_admin("[key_name(admin)] respawned [key_name(owner)]'s missing rifts.")
