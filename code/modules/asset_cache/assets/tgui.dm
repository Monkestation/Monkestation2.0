/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
		// monaco editor
		"editor.worker.js" = file("tgui/public/editor.worker.js"),
	)
	var/ready = FALSE

/datum/asset/simple/tgui/New()
	var/file_list = flist("tgui/public/")
	for(var/_file in file_list)
		if(endswith(_file, ".ttf"))
			assets[_file] = file("tgui/public/[_file]")
	. = ..()

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = file("tgui/public/tgui-panel.bundle.js"),
		"tgui-panel.bundle.css" = file("tgui/public/tgui-panel.bundle.css"),
	)
