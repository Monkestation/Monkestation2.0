/datum/job_milestone
	/// The job title these milestones are for
	var/key_id = JOB_CAPTAIN
	/// Assoc list of "level" : reward you keep forever, like a loadout item
	var/list/milestones
	/// Assoc list of "level" : item you can claim once every round
	var/list/in_round_milestones

/// Gives the rewards for reaching the level. force skips the "already claimed" check for loadout items.
/datum/job_milestone/proc/check_milestones(level, client/user, force = FALSE)
	if(!user?.prefs)
		return
	var/level_text = num2text(level)
	var/milestone_type = LAZYACCESS(milestones, level_text)
	var/round_reward = LAZYACCESS(in_round_milestones, level_text)
	if(!milestone_type && !round_reward)
		return

	if(milestone_type)
		var/list/claimed = user.prefs.job_rewards_claimed[key_id]
		var/already_claimed = islist(claimed) && (milestone_type in claimed)
		var/given = TRUE
		//handles adding loadout items
		if(ispath(milestone_type, /datum/loadout_item) && (force || !already_claimed))
			var/datum/loadout_item/listed_loadout = milestone_type
			given = give_loadout_reward(initial(listed_loadout.item_path), user)
		if(given)
			if(!islist(user.prefs.job_rewards_claimed[key_id]))
				user.prefs.job_rewards_claimed[key_id] = list()
			user.prefs.job_rewards_claimed[key_id] |= milestone_type

	if(round_reward)
		if(!islist(user.prefs.job_rewards_per_round[key_id]))
			user.prefs.job_rewards_per_round[key_id] = list()
		user.prefs.job_rewards_per_round[key_id] |= "[round_reward]" //Path2String

	user.prefs.save_preferences()

/// Adds the item to the metacoin inventory of the user, returns FALSE if the database didn't take it
/datum/job_milestone/proc/give_loadout_reward(item_path, client/user)
	if(item_path in user.prefs.inventory)
		return TRUE
	var/datum/db_query/query_add_gear_purchase = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("metacoin_item_purchases")] (`ckey`, `item_id`, `amount`) VALUES (:ckey, :item_id, :amount)"},
		list("ckey" = user.ckey, "item_id" = item_path, "amount" = 1))
	if(!query_add_gear_purchase.Execute())
		to_chat(user, span_warning("Failed to add level up reward to the database, contact coders. Use Reload Job Rewards to try again."))
		qdel(query_add_gear_purchase)
		return FALSE
	qdel(query_add_gear_purchase)
	user.prefs.inventory += item_path
	return TRUE

/datum/preferences
	/// Per round rewards already claimed this round. Lives on the prefs and not the client so reconnecting doesn't let you claim them again.
	var/list/job_rewards_redeemed = list()

GAME_VERB_DESC(/client, open_xp_menu, "Open XP Menu", "List job xp.", "IC")

	xp_menu = new(src)
	xp_menu.ui_interact(usr)

GAME_VERB_DESC(/client, claim_job_reward, "Claim Job Rewards", "List job rewards you have for the current job and can spawn.", "IC")

	if(!isliving(mob) || !mob.mind?.assigned_role)
		to_chat(src, "For this to work you need to be living.")
		return

	var/job_string = mob.mind.assigned_role.title
	var/list/saved_rewards = prefs.job_rewards_per_round[job_string]
	if(!length(saved_rewards))
		to_chat(src, span_notice("You currently don't have any job rewards to claim!"))
		return
	// copy it, so we don't eat the saved rewards when taking out the ones already redeemed
	var/list/viable_rewards = saved_rewards.Copy()
	for(var/path in prefs.job_rewards_redeemed)
		viable_rewards -= "[path]"
	if(!length(viable_rewards))
		to_chat(src, span_notice("You have redeemed all the rewards you have for this job."))
		return

	var/list/name_and_path = list()
	for(var/path in viable_rewards)
		var/obj/item/true_path = text2path(path)
		if(!ispath(true_path, /obj/item))
			continue
		name_and_path[initial(true_path.name)] = true_path

	var/choice = tgui_input_list(mob, "Choose a reward to redeem.", "Job Reward Claim.", name_and_path)
	if(!choice || !isliving(mob))
		return

	var/path = name_and_path[choice]
	if(path in prefs.job_rewards_redeemed)
		return
	prefs.job_rewards_redeemed += path
	var/obj/item/new_item = new path(get_turf(mob))
	mob.put_in_hands(new_item)

GAME_VERB_DESC(/client, reload_job_rewards, "Reload Job Rewards", "Refresh job rewards you have for the current job (Use this if you suspect something is missing or broken).", "IC")

	if(!isliving(mob) || !mob.mind?.assigned_role)
		to_chat(src, "For this to work you need to be living.")
		return

	var/job_string = mob.mind.assigned_role.title
	if(!prefs.job_level_list[job_string])
		return

	for(var/datum/job_milestone/subtype as anything in subtypesof(/datum/job_milestone))
		if(initial(subtype.key_id) != job_string)
			continue
		var/datum/job_milestone/subtype_created = new subtype
		for(var/level in 1 to prefs.job_level_list[job_string])
			subtype_created.check_milestones(level, src, force = TRUE)
	to_chat(src, span_notice("Your job rewards have been reloaded."))
