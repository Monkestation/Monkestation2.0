//Blocks an attempt to connect before even creating our client datum thing.

/world/IsBanned(key, address, computer_id, type, real_bans_only=FALSE)
	debug_world_log("isbanned(): '[args.Join("', '")]'")
	if (!key || (!real_bans_only && (!address || !computer_id)))
		if(real_bans_only)
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	if (type == "world")
		return ..() //shunt world topic banchecks to purely to byond's internal ban system

	var/admin = FALSE
	var/mentor = FALSE
	var/ckey = ckey(key)

	var/client/C = GLOB.directory[ckey]
	if (C && ckey == C.ckey && computer_id == C.computer_id && address == C.address)
		return //don't recheck connected clients.

	//IsBanned can get re-called on a user in certain situations, this prevents that leading to repeated messages to admins.
	var/static/list/checkedckeys = list()
	//magic voodo to check for a key in a list while also adding that key to the list without having to do two associated lookups
	var/message = !checkedckeys[ckey]++

	if (GLOB.admin_datums[ckey] || GLOB.deadmins[ckey] || (ckey in GLOB.protected_admins))
		admin = TRUE

	if (GLOB.mentor_datums[ckey] || GLOB.dementors[ckey] || (ckey in GLOB.protected_mentors))
		mentor = TRUE

	if (!real_bans_only)
		log_client_to_db_connection_log_manual(ckey, address, computer_id, "isbanned", type)

	if(!real_bans_only && !admin && CONFIG_GET(flag/panic_bunker) && !CONFIG_GET(flag/panic_bunker_interview))
		var/datum/db_query/query_client_in_db = SSdbcore.NewQuery(
			"SELECT 1 FROM [format_table_name("player")] WHERE ckey = :ckey",
			list("ckey" = ckey)
		)
		if(!query_client_in_db.Execute())
			qdel(query_client_in_db)
			return

		var/client_is_in_db = query_client_in_db.NextRow()
		if(!client_is_in_db)
			var/reject_message = "Failed Login: [ckey] [address]-[computer_id] - New Account attempting to connect during panic bunker, but was rejected due to no prior connections to game servers (no database entry)"
			log_access(reject_message)
			if (message)
				message_admins(span_adminnotice("[reject_message]"))
			qdel(query_client_in_db)
			return list("reason"="panicbunker", "desc" = "Sorry but the server is currently not accepting connections from never before seen players")

		qdel(query_client_in_db)

	//Whitelist
	if(!real_bans_only && !C && CONFIG_GET(flag/usewhitelist))
		if(!check_whitelist(ckey))
			if (admin || mentor)
				log_admin("The admin/mentor [ckey] has been allowed to bypass the whitelist")
				if (message)
					message_admins(span_adminnotice("The admin/mentor [ckey] has been allowed to bypass the whitelist"))
					addclientmessage(ckey,span_adminnotice("You have been allowed to bypass the whitelist"))
			else
				log_access("Failed Login: [ckey] - Not on whitelist")
				return list("reason"="whitelist", "desc" = "\nReason: You are not on the white list for this server")

	//Guest Checking
	if(!real_bans_only && !C && is_guest_key(key))
		if (CONFIG_GET(flag/guest_ban))
			log_access("Failed Login: [ckey] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
		if (CONFIG_GET(flag/panic_bunker) && SSdbcore.Connect())
			log_access("Failed Login: [ckey] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")

	//Population Cap Checking
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(!real_bans_only && !C && extreme_popcap)
		var/popcap_value = GLOB.clients.len
		if(popcap_value >= extreme_popcap && !GLOB.joined_player_list.Find(ckey))
			var/supporter = get_patreon_rank(ckey) > 0
			if (admin || mentor || supporter)
				var/msg = "Popcap Login: [ckey] - Is a(n) [admin ? "admin" : mentor ? "mentor" : supporter ? "patreon supporter" : "???"], therefore allowed passed the popcap of [extreme_popcap] - [popcap_value] clients connected"
				log_access(msg)
				message_admins(msg)
			if(!CONFIG_GET(flag/byond_member_bypass_popcap) || !world.IsSubscribed(ckey, "BYOND"))
				var/msg = "Failed Login: [ckey] - Population cap reached"
				log_access(msg)
				message_admins(msg)
				return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")

	//Discord verification checking. This won't be used under normal circumstances, but was ported just in case
	if (!real_bans_only && !.)
		if (SSplexora.enabled && CONFIG_GET(flag/require_discord_verification))
			var/required_roleid = CONFIG_GET(string/plexora_verification_required_roleid)
			var/list/plexora_poll_result = SSplexora.poll_ckey_for_verification(ckey, required_roleid)
			var/datum/discord_details/discord_details = new /datum/discord_details(
				plexora_poll_result["discord_id"],
				plexora_poll_result["discord_username"],
				plexora_poll_result["discord_displayname"],
				plexora_poll_result["polling_response"],
			)
			var/has_requiredrole = plexora_poll_result["has_requiredrole"]
			if (has_requiredrole)
				discord_details.has_requiredrole = has_requiredrole

			var/log
			switch(plexora_poll_result["polling_response"])
				if (PLEXORA_DOWN)
					log = "Denied entry: Plexora is down. Failed verification for [ckey]"
					message_admins("[log] - Ping @flleeppyy on the Discord if issue persists.")
					log_access(log)
					return list("reason"="internalerror", "desc"="\nInternal server error - Plexora is down. Please try again in a few moments. If issue issue persists, ping @flleeppyy on the Discord.")
				if (PLEXORA_CKEYPOLL_FAILED)
					stack_trace("Ckey polling failed for [ckey]. [json_encode(plexora_poll_result)]")
					log = "Denied entry: Ckey polling failed for [key_name_admin(ckey)]. Check runtimes"
					log_access(log)
					message_admins(log)
					return list("reason"="internalerror", "desc"="\nInternal server error - Plexora failed to poll your ckey. Please try again in a few moments. If issue issue persists, ping @flleeppyy on the Discord.")
				if (PLEXORA_CKEYPOLL_NOTLINKED, PLEXORA_CKEYPOLL_RECORDNOTVALID)
					var/one_time_token = SSplexora.get_or_generate_one_time_token_for_ckey(ckey)
					log_access("Denied entry: [ckey] does not have a valid link record.")
					return list("reason"="linking", "desc"="\nYour Discord account is not linked to BYOND, this is required to join.\nYour verification code is: [one_time_token] - Use this in conjunction with the /verifydiscord command in the Discord server to link your account, then try again.")
				if (PLEXORA_CKEYPOLL_LINKED_ABSENT, PLEXORA_CKEYPOLL_LINKED_DELETED)
					log = "Denied entry: [ckey]'s linked Discord account is either deleted, or not present in the Discord. ([plexora_poll_result["discord_id"]] - [plexora_poll_result["discord_username"]])"
					log_access(log)
					message_admins(log)
					return list("reason"="linkingabsent", "desc"="\nYour current linked Discord account is not present in the Discord server! Please rejoin before you can play.\nIf your previous Discord account has been deleted, or lost, please open a ticket in the Discord.",)
				if (PLEXORA_CKEYPOLL_LINKED_BANNED)
					log = "Denied entry: [ckey] is banned from the Discord. ([plexora_poll_result["discord_id"]] - [plexora_poll_result["discord_username"]])"
					log_access(log)
					message_admins(log)
					return list("reason"="linkingbanned", "desc"="\nYou are banned from the server.")
				if (PLEXORA_CKEYPOLL_LINKED_ALLOWEDWHITELIST)
					log_access("Allowed entry: [ckey] is in allowed_ckeys.txt")

			if (!has_requiredrole)
				log = "Denied entry: [ckey] has a valid Discord link record, but lacks the required role ([plexora_poll_result["requiredrole_name"]] - [required_roleid])"
				log_access(log)
				message_admins(log)
				return list("reason"="linkingrolerror", "desc"="\nYour Discord is properly linked, but you lack the required role ([plexora_poll_result["requiredrole_name"]] - [required_roleid]). Please make a ticket in the Discord.")

			log_access("Allowed entry: [ckey] has a valid link record [has_requiredrole ? "(and has the required role)" : ""] - ID: [plexora_poll_result["discord_id"]] Username: [plexora_poll_result["discord_username"]]")
		else if (CONFIG_GET(flag/require_discord_verification))
			return list("reason"="internalerror", "desc"="\nInternal server error - Discord Verification is required but Plexora is not enabled! This is a config issue, please alert the sysadmins.")

	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckey] not checked"
			log_world(msg)
			if (message)
				message_admins(msg)
		else
			var/list/ban_details = is_banned_from_with_details(ckey, address, computer_id, "Server")
			for(var/i in ban_details)
				if(admin)
					if(text2num(i["applies_to_admins"]))
						var/msg = "Admin [ckey] is admin banned, and has been disallowed access."
						log_admin(msg)
						if (message)
							message_admins(msg)
					else
						var/msg = "Admin [ckey] has been allowed to bypass a matching non-admin ban on [ckey(i["key"])] [i["ip"]]-[i["computerid"]]."
						log_admin(msg)
						if (message)
							message_admins(msg)
							addclientmessage(ckey,span_adminnotice("Admin [ckey] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."))
						continue
				var/expires = "This is a permanent ban."
				if(i["expiration_time"])
					expires = " The ban is for [DisplayTimeText(text2num(i["duration"]) MINUTES)] and expires on [i["expiration_time"]] (server time)."
				var/desc = {"You, or another user of this computer or connection ([i["key"]]) is banned from playing here.
				The ban reason is: [i["reason"]]
				This ban (BanID #[i["id"]]) was applied by [i["admin_key"]] on [i["bantime"]] during round ID [i["round_id"]].
				[expires]"}
				log_suspicious_login("Failed Login: [ckey] [computer_id] [address] - Banned (#[i["id"]])")
				return list("reason"="Banned","desc"="[desc]")

	. = ..() //default pager ban stuff

