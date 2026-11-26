SUBSYSTEM_DEF(achievements)
	name = "Achievements"
	flags = SS_NO_FIRE
	var/achievements_enabled = FALSE

	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///The achievement with the highest amount of players that have unlocked it.
	var/datum/award/achievement/most_unlocked_achievement
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

/datum/controller/subsystem/achievements/Initialize()
	if(!SSdbcore.Connect())
		return SS_INIT_NO_NEED
	achievements_enabled = TRUE

	var/list/achievements_by_db_id = list()
	for(var/datum/award/achievement/achievement as anything in subtypesof(/datum/award/achievement))
		if(!initial(achievement.database_id)) // abstract type
			continue
		var/datum/award/achievement/instance = new achievement
		achievements[achievement] = instance
		awards[achievement] = instance
		achievements_by_db_id[instance.database_id] = instance

	for(var/datum/award/score/score as anything in subtypesof(/datum/award/score))
		if(!initial(score.database_id)) // abstract type
			continue
		var/instance = new score
		scores[score] = instance
		awards[score] = instance

	update_metadata()
	load_high_scores()

	/**
	 * Count how many (unlocked) achievements are in the achievements database
	 * then store that amount in the times_achieved variable for each achievement.
	 *
	 * Thanks to Jordie for the query.
	 */
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT a.achievement_key, COUNT(a.achievement_key) AS count FROM [format_table_name("achievements")] a \
		JOIN [format_table_name("achievement_metadata")] m ON a.achievement_key = m.achievement_key AND m.achievement_type = 'achievement' \
		GROUP BY a.achievement_key ORDER BY count DESC"
	)
	if(query.Execute(async = TRUE))
		while(query.NextRow())
			var/id = query.item[1]
			var/datum/award/achievement/instance = id ? achievements_by_db_id[id] : null
			if(isnull(instance)) // removed achievement
				continue
			instance.times_achieved = query.item[2]
			// the results are ordered in descending orders, so the first in the list should be the most unlocked one.
			if(!most_unlocked_achievement)
				most_unlocked_achievement = instance
	qdel(query)

	for(var/client/player as anything in GLOB.clients)
		if(player?.persistent_client?.achievements && !player.persistent_client.achievements.initialized)
			player.persistent_client.achievements.InitializeData()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/achievements/Shutdown()
	save_achievements_to_db()

/datum/controller/subsystem/achievements/proc/save_achievements_to_db()
	var/list/cheevos_to_save = list()
	for(var/ckey in GLOB.persistent_clients_by_ckey)
		var/datum/persistent_client/PD = GLOB.persistent_clients_by_ckey[ckey]
		if(!PD || !PD.achievements)
			continue
		cheevos_to_save += PD.achievements.get_changed_data()
	if(!length(cheevos_to_save))
		return
	SSdbcore.MassInsert(format_table_name("achievements"), cheevos_to_save, duplicate_key = TRUE)
	SEND_SIGNAL(src, COMSIG_ACHIEVEMENTS_SAVED_TO_DB)

/// Fills the leaderboards of every score with one query instead of one per score.
/datum/controller/subsystem/achievements/proc/load_high_scores()
	var/list/scores_by_db_id = list()
	var/list/query_args = list()
	var/list/query_arg_keys = list()
	for(var/score_type in scores)
		var/datum/award/score/score = scores[score_type]
		if(!score.track_high_scores || istype(score, /datum/award/score/achievements_score))
			continue
		scores_by_db_id[score.database_id] = score
		query_args["key[length(query_arg_keys)]"] = score.database_id
		query_arg_keys += ":key[length(query_arg_keys)]"

	if(length(query_arg_keys))
		var/datum/db_query/query = SSdbcore.NewQuery({"
			SELECT achievement_key, ckey, value FROM (
				SELECT achievement_key, ckey, value,
					ROW_NUMBER() OVER (PARTITION BY achievement_key ORDER BY value DESC) AS rank_in_key
				FROM [format_table_name("achievements")]
				WHERE achievement_key IN ([query_arg_keys.Join(",")])
			) ranked
			WHERE rank_in_key <= 50
			ORDER BY achievement_key, rank_in_key
		"}, query_args)
		if(query.Execute(async = TRUE))
			while(query.NextRow())
				var/datum/award/score/score = scores_by_db_id[query.item[1]]
				score?.high_scores += list(list("ckey" = query.item[2], "value" = text2num(query.item[3])))
		qdel(query)

	var/datum/award/score/achievements_score/achievements_score = scores[/datum/award/score/achievements_score]
	achievements_score?.LoadHighScores()

//Update the metadata if any are behind
/datum/controller/subsystem/achievements/proc/update_metadata()
	var/list/current_metadata = list()
	//select metadata here
	var/datum/db_query/Q = SSdbcore.NewQuery("SELECT achievement_key,achievement_version FROM [format_table_name("achievement_metadata")]")
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return
	else
		while(Q.NextRow())
			current_metadata[Q.item[1]] = text2num(Q.item[2])
		qdel(Q)

	var/list/to_update = list()
	for(var/T in awards)
		var/datum/award/A = awards[T]
		if(!current_metadata[A.database_id] || current_metadata[A.database_id] < A.achievement_version)
			to_update += list(A.get_metadata_row())

	if(to_update.len)
		SSdbcore.MassInsert(format_table_name("achievement_metadata"),to_update,duplicate_key = TRUE)
