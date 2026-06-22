/obj/machinery/computer/ai_resource_distribution
	name = "\improper AI system resource distribution"
	desc = "Used for distributing processing resources across the current artificial intelligences."
	req_one_access = list(ACCESS_RD, ACCESS_NETWORK)
	circuit = /obj/item/circuitboard/computer/ai_resource_distribution
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	authenticated = FALSE
	var/human_only = FALSE

/obj/machinery/computer/ai_resource_distribution/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	authenticated = TRUE
	if(user)
		balloon_alert(user, "access restrictions bypassed")

/obj/machinery/computer/ai_resource_distribution/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiResources", name)
		ui.open()

/obj/machinery/computer/ai_resource_distribution/ui_data(mob/living/carbon/human/user)
	var/list/data = list()
	data["authenticated"] = authenticated

	if(issilicon(user))
		var/mob/living/silicon/borg = user
		data["username"] = borg.name
		data["has_access"] = TRUE

	if(isAdminGhostAI(user))
		data["username"] = user.client.holder.admin_signature
		data["has_access"] = TRUE

	if(obj_flags & EMAGGED)
		data["username"] = "ERROR"
		data["has_access"] = TRUE
	else if(ishuman(user))
		data["has_access"] = allowed(user)
		var/username = user.get_authentification_name("Unknown")
		data["username"] = user.get_authentification_name("Unknown")
		if(username != "Unknown")
			var/datum/data/record/record
			for(var/RP in GLOB.manifest.general)
				var/datum/data/record/R = RP

				if(!istype(R))
					continue
				if(R.fields["name"] == username)
					record = R
					break
			if(record)
				if(istype(record.fields["photo_front"], /obj/item/photo))
					var/obj/item/photo/P1 = record.fields["photo_front"]
					var/icon/picture = icon(P1.picture.picture_image)
					picture.Crop(10, 32, 22, 22)
					var/md5 = md5(fcopy_rsc(picture))

					if(!SSassets.cache["photo_[md5]_cropped.png"])
						SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
					SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))

					data["user_image"] = SSassets.transport.get_asset_url("photo_[md5]_cropped.png")
	else
		data["has_access"] = allowed(user)
		data["username"] = user.name

	if(!authenticated)
		return data


	data["total_cpu"] = GLOB.ai_os.total_cpu
	data["total_ram"] = GLOB.ai_os.total_ram


	data["total_assigned_cpu"] = GLOB.ai_os.total_cpu_assigned()
	data["total_assigned_ram"] = GLOB.ai_os.total_ram_assigned()

	data["human_only"] = human_only


	data["ais"] = list()

	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		data["ais"] += list(list(
			"name" = A.name,
			"ref" = REF(A),
			"assigned_cpu" = GLOB.ai_os.cpu_assigned[A] ? GLOB.ai_os.cpu_assigned[A] : 0,
			"assigned_ram" = GLOB.ai_os.ram_assigned[A] ? GLOB.ai_os.ram_assigned[A] : 0,
		))

	return data

/obj/machinery/computer/ai_resource_distribution/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)

	var/mob/user = ui.user
	if(!authenticated)
		if(action == "log_in")
			if(allowed(user) || (obj_flags & EMAGGED))
				authenticated = TRUE
				return TRUE
		return

	var/is_human = ishuman(user)

	switch(action)
		if("log_out")
			authenticated = FALSE
			. = TRUE

		if("clear_ai_resources")
			if(!authenticated)
				balloon_alert(user, "must be logged in!")
				return ITEM_INTERACT_BLOCKING
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return

			GLOB.ai_os.clear_ai_resources(target_ai)
			. = TRUE

		if("set_cpu")
			if(!authenticated)
				balloon_alert(user, "must be logged in!")
				return ITEM_INTERACT_BLOCKING
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return
			if(human_only && !is_human)
				to_chat(user, span_warning("CAPTCHA check failed. This console is NOT silicon operable. Please call for human assistance."))
				return

			var/amount = params["amount_cpu"]
			if(!isnum(amount) || amount < 0)
				return
			GLOB.ai_os.set_cpu(target_ai, amount)
			. = TRUE

		if("set_ram")
			if(!authenticated)
				balloon_alert(user, "must be logged in!")
				return ITEM_INTERACT_BLOCKING
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"])
			if(!istype(target_ai))
				return
			if(human_only && !is_human)
				to_chat(user, span_warning("CAPTCHA check failed. This console is NOT silicon operable. Please call for human assistance."))
				return

			var/amount = params["amount_ram"]
			if(!isnum(amount) || amount < 0)
				return
			GLOB.ai_os.set_ram(target_ai, amount)
			. = TRUE

		if("toggle_human_status")
			if(!authenticated)
				balloon_alert(user, "must be logged in!")
				return ITEM_INTERACT_BLOCKING
			if(!is_human)
				to_chat(user, span_warning("CAPTCHA check failed. This console is NOT silicon operable. Please call for human assistance."))
				return
			human_only = !human_only
			balloon_alert(user, "now [human_only ? "human only" : "allowing silicon"]")
