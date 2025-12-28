///Prevents spam-printing badges.
#define PRINT_DELAY (3 MINUTES)
#define UNION_LEADER "Union Leader"
#define UNION_MEMBER "Union Member"

/datum/computer_file/program/cargo_union
	filename = "unionemployees"
	filedesc = "Union Employees"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	extended_desc = "The official Supply Employees Union (SEU) employee tracker and badge printer/recycler. Uses a Union badge as access."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	download_access = list(ACCESS_UNION_LEADER, ACCESS_QM) //you can't put the badge into the PC until it's downloaded but just in-case.
	run_access = list(ACCESS_UNION, ACCESS_CARGO)
	size = 6
	tgui_id = "NtosCargoUnion"
	program_icon = "id-badge"

	///The badge we have inserted into the console as authorization.
	var/obj/item/clothing/accessory/badge/cargo/inserted_badge
	///The time between printing new badges, to prevent spamming them.
	COOLDOWN_DECLARE(time_between_printing)

/datum/computer_file/program/cargo_union/Destroy(force)
	if(inserted_badge)
		inserted_badge.forceMove(computer.drop_location())
		inserted_badge = null
	return ..()

/datum/computer_file/program/cargo_union/ui_data(mob/user)
	var/list/data = list()
	if(inserted_badge)
		data["badge_name"] = inserted_badge.name
		data["badge_icon"] = inserted_badge.icon
		data["badge_icon_state"] = inserted_badge.icon_state
		data["badge_leader"] = !!(ACCESS_UNION_LEADER in inserted_badge.access)
	else
		data["badge_name"] = null
		data["badge_icon"] = null
		data["badge_icon_state"] = null
		data["badge_leader"] = FALSE
	data["union_members"] = GLOB.cargo_union_employees
	return data

/datum/computer_file/program/cargo_union/ui_act(action, params, datum/tgui/ui)
	var/mob/user = ui.user
	switch(action)
		//Adds a new member to the Union, limited to Union Leader.
		if("add_member")
			if(isnull(inserted_badge) || !(ACCESS_UNION_LEADER in inserted_badge.access))
				computer.balloon_alert(user, "access not found!")
				return TRUE
			var/member_name = tgui_input_text(user, "What is the new member's name?", "New Union Personnel", max_length = MAX_NAME_LEN)
			if(isnull(member_name) || !istext(member_name))
				return TRUE
			var/union_leader = tgui_input_list(user, "What is the new member's rank?", "New Union Personnel", list(UNION_LEADER, UNION_MEMBER))
			if(isnull(union_leader) || union_leader == UNION_MEMBER)
				union_leader = FALSE
			else
				union_leader = TRUE

			if(!user.Adjacent(computer))
				return TRUE

			for(var/member in GLOB.cargo_union_employees)
				if(member[CARGO_UNION_NAME] == member_name)
					computer.balloon_alert(user, "already a member!")
					return TRUE

			GLOB.cargo_union_employees += list(list(
				CARGO_UNION_LEADER = union_leader,
				CARGO_UNION_NAME = member_name,
			))
			print_new_badge(user, member_name, cooldown_affected = FALSE)
			return TRUE
		//Removes the member from the Union entirely, limited to Union Leader.
		if("remove_member")
			if(isnull(inserted_badge) || !(ACCESS_UNION_LEADER in inserted_badge.access))
				computer.balloon_alert(user, "access not found!")
				return TRUE
			var/removed_member = params["member_name"]
			for(var/member in GLOB.cargo_union_employees)
				if(member[CARGO_UNION_NAME] != removed_member)
					continue
				GLOB.cargo_union_employees -= removed_member
				break
			return TRUE

		//prints a replacement badge. Regular badges requires any Union badge, Leader badges requires any Union badge + Leader Badge OR QM Access.
		//AKA, QM needs another Union member to replace their own badge, important to ensure the QM is vetted as the real leader.
		if("print_badge")
			if(isnull(inserted_badge) || !(ACCESS_UNION in inserted_badge.access))
				computer.balloon_alert(user, "access not found!")
				return TRUE

			var/lost_badge_member = params["member_name"]
			for(var/member in GLOB.cargo_union_employees)
				if(member[CARGO_UNION_NAME] != lost_badge_member)
					continue
				if(member[CARGO_UNION_LEADER]) //printing a golden badge requires access (aka QM level, ID or Badge)
					if(!can_run(user, downloading = TRUE))
						computer.balloon_alert(user, "elevated access necessary!")
						return TRUE
				print_new_badge(user, lost_badge_member)
				break
			return TRUE

		if("recycle_badge")
			if(isnull(inserted_badge))
				return TRUE
			QDEL_NULL(inserted_badge)
			return TRUE

		if("eject_badge")
			if(isnull(inserted_badge))
				return TRUE
			try_eject(user)
			return TRUE

/datum/computer_file/program/cargo_union/get_access()
	if(inserted_badge)
		return inserted_badge.access

/datum/computer_file/program/cargo_union/application_attackby(obj/item/attacking_item, mob/living/user)
	if(!computer)
		return FALSE
	if(!istype(attacking_item, /obj/item/clothing/accessory/badge/cargo))
		return FALSE

	if(inserted_badge)
		computer.balloon_alert(user, "swapped badges")
		try_eject(user)
	else
		computer.balloon_alert(user, "badge inserted")
	attacking_item.forceMove(computer)
	inserted_badge = attacking_item
	return TRUE

/datum/computer_file/program/cargo_union/try_eject(mob/living/user, forced = FALSE)
	if(!inserted_badge)
		return FALSE

	if(user && computer.Adjacent(user))
		computer.balloon_alert(user, "badge removed")
		user.put_in_hands(inserted_badge)
	else
		inserted_badge.forceMove(computer.drop_location())
	inserted_badge = null
	return TRUE

/**
 * print_new_badge
 *
 * Prints a new union badge to use.
 * Args:
 * user - The person printing the badge, for any feedback necessary.
 * member_name - The name of the person getting a badge printed of, which we'll directly apply to the badge.
 * cooldown_affected - Whether we care for cooldown delays & will trigger a new one afterwards.
 */
/datum/computer_file/program/cargo_union/proc/print_new_badge(mob/user, member_name, cooldown_affected = TRUE)
	if(cooldown_affected && !COOLDOWN_FINISHED(src, time_between_printing))
		user.balloon_alert(user, "on cooldown!")
		return TRUE
	var/obj/item/clothing/accessory/badge/new_cargo_badge
	for(var/member in GLOB.cargo_union_employees)
		if(member[CARGO_UNION_NAME] != member_name)
			continue
		if(member[CARGO_UNION_LEADER])
			new_cargo_badge = new /obj/item/clothing/accessory/badge/cargo/quartermaster(computer.drop_location())
		else
			new_cargo_badge = new /obj/item/clothing/accessory/badge/cargo(computer.drop_location())
	new_cargo_badge.set_identity(member_name)
	if(cooldown_affected)
		COOLDOWN_START(src, time_between_printing, PRINT_DELAY)

#undef PRINT_DELAY
#undef UNION_LEADER
#undef UNION_MEMBER
