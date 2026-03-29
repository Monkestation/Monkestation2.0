/obj/item/citationinator
	name = "Citationinator"
	desc = "A cheaply made plastic handheld doohickey, capable of issuing fines to ner-do-wells, and printing out a slip of paper with the details of the fine."
	icon = 'monkestation/icons/obj/items/secass.dmi'
	icon_state = "doohickey_closed"
	inhand_icon_state = "doohickey"
	worn_icon_state = "electronic"
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/secass_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/secass_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON | NO_MAT_REDEMPTION
	slot_flags = ITEM_SLOT_BELT
	req_access = list(ACCESS_SECURITY)
	custom_price = PAYCHECK_COMMAND * 2.5 //Comes out to 50 with the security dept discount on the vendor

/obj/item/citationinator/attack_self(mob/living/user, modifiers)
	if(!isliving(user))
		return
	add_fingerprint(user)
	icon_state = "doohickey_open"
	issue_fine(user)
	icon_state = initial(icon_state)

/obj/item/citationinator/proc/issue_fine(mob/living/user)
	var/obj/item/card/id/using_id = user.get_idcard()
	if(!istype(using_id) || QDELING(using_id))
		return
	if(!check_access(using_id))
		to_chat(user, span_warning("Insufficient access to issue citations!"))
		return
	var/list/choices = list()
	for(var/datum/record/crew/person in GLOB.manifest.general)
		if(!person.name)
			continue
		choices[person.name] = person
	var/victim_name = tgui_input_list(user, "Select crew member to fine", "Do you got a loicense for that, mate?", choices, timeout = 1 MINUTES)
	if(!victim_name)
		return
	var/datum/record/crew/victim = choices[victim_name]
	if(!victim)
		return
	var/fine = tgui_input_number(user, "How many credits to fine?", "Civil Asset Forfeiture", default = 50, max_value = CONFIG_GET(number/maxfine), timeout = 1 MINUTES, round_value = 1)
	if(!fine)
		return
	var/citation_name = trim(tgui_input_text(user, "What crime are they being fined for?", "Handling a fish in suspicious circumstances", max_length = MAX_NAME_LEN, encode = FALSE, timeout = 1 MINUTES))
	if(!citation_name)
		return
	var/reason = trim(tgui_input_text(user, "Provide details about the citation.", "Handling a fish in suspicious circumstances", multiline = TRUE, encode = FALSE, timeout = 1 MINUTES))
	var/issuer_name = using_id.assignment + " " + using_id.registered_name
	var/datum/crime/citation/new_citation = new(name = citation_name, details = reason, author = issuer_name, fine = fine)
	new_citation.alert_owner(user, src, victim.name, "You have been issued a [fine]cr citation for [citation_name] by [issuer_name]. Fines are payable at Security.")
	victim.citations += new_citation
	investigate_log("New Citation: <strong>[citation_name]</strong> Fine: [fine] | Added to [victim.name] by [key_name(user)]", INVESTIGATE_RECORDS)
	SSblackbox.ReportCitation(REF(new_citation), user.ckey, user.real_name, victim.name, citation_name, fine)

	var/final_paper_text = "# <u>SECURITY CITATION</u>\n"
	final_paper_text += "You have been issued a citation by the on-board station security department for the following offense:<br>"
	final_paper_text += {"<table style="text-align:left;" border="1" cellspacing="0" width="100%">"}
	final_paper_text += "<tr><th>Details: </th><td>[length(new_citation.details) > 0 ? sanitize(new_citation.details) : "None provided."]</td></tr>"
	final_paper_text += "<tr><th>Cited By: </th><td>[sanitize(new_citation.author)]</td></tr>"
	final_paper_text += "<tr><th>Time: </th><td>[new_citation.time]</td></tr>"
	final_paper_text += "<tr><th>Fine Amount: </th><td>[new_citation.fine]</td></tr>"
	final_paper_text += "<center><b>[sanitize(new_citation.name)]</b></center><br>"
	final_paper_text += "</table><br>"
	final_paper_text += "Citations are payable at the Security Warrant Console at the front of the station brig.<br><br>"
	final_paper_text += "<i>Accepting this ticket does not indicate an admission of guilt. If you wish to dispute this citation, please contact the Captain, Head of Security, or the onboard legal counsel.</i><br><br>"
	final_paper_text += "<i>Refusing to accept this ticket, or failure to pay/dispute this citation within a reasonable timeframe, may result in you being charged with Fine Evasion (code 111) and serving time in the station brig.</i><br>"

	var/obj/item/paper/slip = new(drop_location())
	slip.name = "Citation - [victim.name] for [sanitize(new_citation.name)]"
	slip.color = COLOR_FADED_PINK

	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
	slip.add_stamp(sheet.icon_class_name("stamp-law"), 284, 0, 0, "stamp-law")
	slip.cut_overlays()

	slip.add_raw_text(final_paper_text)
	slip.update_appearance()
	user.put_in_hands(slip)

	user.visible_message(span_warning("[src] whirrs and clicks, before spitting out a slip of paper!"))
	playsound(src, 'sound/machines/printer.ogg', vol = 40, vary = TRUE)
