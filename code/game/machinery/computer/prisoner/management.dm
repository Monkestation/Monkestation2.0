/obj/machinery/computer/prisoner/management
	name = "prisoner management console"
	desc = "Used to manage tracking implants placed inside criminals."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	light_color = COLOR_SOFT_RED
	var/id = 0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed
	circuit = /obj/item/circuitboard/computer/prisoner


/obj/machinery/computer/prisoner/management/ui_interact(mob/user)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrisonerManagement")
		ui.open()

/obj/machinery/computer/prisoner/management/ui_data(mob/user)
	var/list/data = list()

	data["authorized"] = (authenticated && isliving(user)) || HAS_SILICON_ACCESS(user)
	data["inserted_id"] = null
	if(!isnull(contained_id))
		data["inserted_id"] = list(
			"name" = contained_id.name,
			"points" = contained_id.points,
			"goal" = contained_id.goal,
		)

	var/list/implants = list()
	for(var/obj/item/implant/implant as anything in GLOB.tracked_implants)
		if(!implant.is_shown_on_console(src))
			continue
		var/list/implant_data = list()
		implant_data["info"] = implant.get_management_console_data()
		implant_data["buttons"] = implant.get_management_console_buttons()
		implant_data["category"] = initial(implant.name)
		implant_data["ref"] = REF(implant)
		UNTYPED_LIST_ADD(implants, implant_data)
	data["implants"] = implants

	return data

/obj/machinery/computer/prisoner/management/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!authenticated && action != "login")
		CRASH("[usr] potentially spoofed ui action [action] on prisoner console without the console being logged in.")

	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	var/dat = ""
	if(screen == 0)
		dat += "<HR><A href='byond://?src=[REF(src)];lock=1'>{Log In}</A>"
	else if(screen == 1)
		dat += "<H3>Prisoner ID Management</H3>"
		if(contained_id)
			dat += text("<A href='byond://?src=[REF(src)];id=eject'>[contained_id]</A><br>")
			dat += text("Collected Points: [contained_id.points]. <A href='byond://?src=[REF(src)];id=reset'>Reset.</A><br>")
			dat += text("Card goal: [contained_id.goal].  <A href='byond://?src=[REF(src)];id=setgoal'>Set </A><br>")
			dat += text("Space Law recommends quotas of 100 points per minute they would normally serve in the brig.<BR>")
		else
			dat += text("<A href='byond://?src=[REF(src)];id=insert'>Insert Prisoner ID.</A><br>")
		dat += "<H3>Prisoner Implant Management</H3>"
		dat += "<HR>Chemical Implants<BR>"
		var/turf/current_turf = get_turf(src)
		for(var/obj/item/implant/chem/C in GLOB.tracked_chem_implants)
			var/turf/implant_turf = get_turf(C)
			if(!is_valid_z_level(current_turf, implant_turf))
				continue//Out of range
			if(!C.imp_in)
				continue
			dat += "ID: [C.imp_in.name] | Remaining Units: [C.reagents.total_volume] <BR>"
			dat += "| Inject: "
			dat += "<A href='byond://?src=[REF(src)];inject1=[REF(C)]'>(<font class='bad'>(1)</font>)</A>"
			dat += "<A href='byond://?src=[REF(src)];inject5=[REF(C)]'>(<font class='bad'>(5)</font>)</A>"
			dat += "<A href='byond://?src=[REF(src)];inject10=[REF(C)]'>(<font class='bad'>(10)</font>)</A><BR>"
			dat += "********************************<BR>"
		dat += "<HR>Tracking Implants<BR>"
		for(var/obj/item/implant/tracking/T in GLOB.tracked_implants)
			if(!isliving(T.imp_in))
				continue
			var/turf/implant_turf = get_turf(T)
			if(!is_valid_z_level(current_turf, implant_turf))
				continue//Out of range

			var/loc_display = "Unknown"
			var/mob/living/M = T.imp_in
			if(is_station_level(implant_turf.z) && !isspaceturf(M.loc))
				var/turf/mob_loc = get_turf(M)
				loc_display = mob_loc.loc

			dat += "ID: [T.imp_in.name] | Location: [loc_display]<BR>"
			dat += "<A href='byond://?src=[REF(src)];warn=[REF(T)]'>(<font class='bad'><i>Message Holder</i></font>)</A> |<BR>"
			dat += "********************************<BR>"
		dat += "<HR><A href='byond://?src=[REF(src)];lock=1'>{Log Out}</A>"
	var/datum/browser/popup = new(user, "computer", "Prisoner Management Console", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/prisoner/management/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(isidcard(attacking_item))
		if(screen)
			id_insert(user)
		else
			to_chat(user, span_danger("Unauthorized access."))
	else
		return ..()

/obj/machinery/computer/prisoner/management/process()
	if(!..())
		src.updateDialog()
	return

/obj/machinery/computer/prisoner/management/Topic(href, href_list)
	if(..())
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		usr.set_machine(src)

		if(href_list["id"])
			if(href_list["id"] == "insert" && !contained_id)
				id_insert(usr)
			else if(contained_id)
				switch(href_list["id"])
					if("eject")
						id_eject(usr)
					if("reset")
						contained_id.points = 0
					if("setgoal")
						var/num = tgui_input_text(usr, "Enter the prisoner's goal", "Prisoner Management", 1, 1000, 1)
						if(isnull(num))
							return
						contained_id.goal = round(num)
		else if(href_list["inject1"])
			var/obj/item/implant/I = locate(href_list["inject1"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(1)
		else if(href_list["inject5"])
			var/obj/item/implant/I = locate(href_list["inject5"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(5)
		else if(href_list["inject10"])
			var/obj/item/implant/I = locate(href_list["inject10"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(10)

		else if(href_list["lock"])
			if(allowed(usr))
				screen = !screen
				playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
			else
				to_chat(usr, span_danger("Unauthorized access."))

		else if(href_list["warn"])
			var/warning = tgui_input_text(usr, "Enter your message here", "Messaging")
			if(!warning)
				return
			var/obj/item/implant/I = locate(href_list["warn"]) in GLOB.tracked_implants
			if(I && istype(I) && I.imp_in)
				var/mob/living/R = I.imp_in
				to_chat(R, span_hear("You hear a voice in your head saying: '[warning]'"))
				log_directed_talk(usr, R, warning, LOG_SAY, "implant message")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return
