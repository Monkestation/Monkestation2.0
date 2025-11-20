///Prevents spam-printing badges.
#define PRINT_DELAY (3 MINUTES)

/datum/computer_file/program/cargo_union
	filename = "unionemployees"
	filedesc = "Union Employees"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	extended_desc = "The official Supply Employees Union (SEU) employee tracker and badge printer/recycler."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	run_access = list(ACCESS_QM)
	size = 6
	tgui_id = "NtosCargoUnion"
	program_icon = "id-badge"

	///The time between printing new badges, to prevent spamming them.
	COOLDOWN_DECLARE(time_between_printing)

/datum/computer_file/program/cargo_union/ui_data(mob/user)
	var/list/data = list()
	data["union_members"] = GLOB.cargo_union_employees
	return data

/datum/computer_file/program/cargo_union/ui_act(action, params, datum/tgui/ui)
	var/mob/user = ui.user
	switch(action)
		if("add_member")
			var/member_name = tgui_input_text(user, "What is the new member's name?", "New Union Personnel", max_length = MAX_NAME_LEN)
			if(isnull(member_name) || !istext(member_name))
				return TRUE
			GLOB.cargo_union_employees += member_name
			print_new_badge(user, member_name, cooldown_affected = FALSE)
			return TRUE
		if("remove_member")
			var/removed_member = params["member_name"]
			if(!(removed_member in GLOB.cargo_union_employees))
				return TRUE
			GLOB.cargo_union_employees -= removed_member
			return TRUE
		if("print_badge")
			var/lost_badge_member = params["member_name"]
			if(!(lost_badge_member in GLOB.cargo_union_employees))
				return TRUE
			print_new_badge(user, lost_badge_member)
			return TRUE

/datum/computer_file/program/cargo_union/application_attackby(obj/item/attacking_item, mob/living/user)
	if(!computer)
		return FALSE
	if(!istype(attacking_item, /obj/item/clothing/accessory/badge/cargo))
		return FALSE

	to_chat(user, span_notice("You insert \the [attacking_item] into \the [computer.name]."))
	qdel(attacking_item)
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
	var/obj/item/clothing/accessory/badge/cargo/new_cargo_badge = new(computer.drop_location())
	new_cargo_badge.set_identity(member_name)
	if(cooldown_affected)
		COOLDOWN_START(src, time_between_printing, PRINT_DELAY)

#undef PRINT_DELAY
