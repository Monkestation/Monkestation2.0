/// A field guide to every slime color, its mutations, its extract and its crossbreeds.
/datum/computer_file/program/slimepedia
	filename = "slimepedia"
	filedesc = "Slimepedia"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "research"
	extended_desc = "A xenobiology field guide covering every slime color, what it mutates into, what its extract does, and every crossbreed."
	size = 4
	tgui_id = "NtosSlimepedia"
	program_icon = "flask"

/datum/computer_file/program/slimepedia/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/slimepedia),
		get_asset_datum(/datum/asset/spritesheet_batched/slimepedia),
	)
