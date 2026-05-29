/datum/computer_file/program/ai_restorer
	filename = "ai_restore"
	filedesc = "AI Manager & Restorer"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "generic"
	extended_desc = "Firmware Restoration Kit. AI systems have been decommissioned."
	size = 12
	can_run_on_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	download_access = list(ACCESS_RD)
	tgui_id = "NtosAiRestorer"
	program_icon = "laptop-code"

/datum/computer_file/program/ai_restorer/ui_data(mob/user)
	var/list/data = list()
	data["error"] = "AI systems have been decommissioned."
	return data
