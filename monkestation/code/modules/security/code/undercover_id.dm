/// Copypaste of the chamelon I.D without the code for copying access.

/obj/item/card/id/advanced/undercover
	name = "Undercover I.D"
	desc = "Nanotrasen finest detective's wet dream, an undercover I.D."
	trim = /datum/id_trim/undercover
	wildcard_slots = WILDCARD_LIMIT_CHAMELEON

	/// Have we set a custom name and job assignment, or will we use what we're given when we chameleon change?
	var/forged = FALSE
	/// Anti-metagaming protections. If TRUE, anyone can change the ID card's details. If FALSE, only syndicate agents can.
	var/anyone = TRUE

	var/datum/action/item_action/chameleon/change/id/chameleon_card_action // MONKESTATION ADDITION -- DATUM MOVED FROM INITIALIZE()

// MONKESTATION ADDITION START
/obj/item/card/id/advanced/undercover/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour != TOOL_MULTITOOL)
		return ..()

	if(chameleon_card_action.hidden)
		chameleon_card_action.hidden = FALSE
		actions += chameleon_card_action
		chameleon_card_action.Grant(user)
		log_game("[key_name(user)] has removed the disguise lock on the agent ID ([name]) with [W]")
	else
		chameleon_card_action.hidden = TRUE
		actions -= chameleon_card_action
		chameleon_card_action.Remove(user)
		log_game("[key_name(user)] has locked the disguise of the agent ID ([name]) with [W]")
// MONKESTATION ADDITION END

/obj/item/card/id/advanced/undercover/Initialize(mapload)
	. = ..()

//	var/datum/action/item_action/chameleon/change/id/chameleon_card_action = new(src) MONKESTATION EDIT CHANGE OLD
	chameleon_card_action = new(src) // MONKESTATION EDIT CHANGE NEW -- MOVED THE DATUM TO THE ITEM ITSELF
	chameleon_card_action.chameleon_type = /obj/item/card/id/advanced
	chameleon_card_action.chameleon_name = "ID Card"
	chameleon_card_action.initialize_disguises()
	add_item_action(chameleon_card_action)
	register_item_context()



/obj/item/card/id/advanced/undercover/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChameleonCard", name)
		ui.open()

/obj/item/card/id/advanced/undercover/ui_static_data(mob/user)
	var/list/data = list()
	data["wildcardFlags"] = SSid_access.wildcard_flags_by_wildcard
	data["accessFlagNames"] = SSid_access.access_flag_string_by_flag
	data["accessFlags"] = SSid_access.flags_by_access
	return data

/obj/item/card/id/advanced/undercover/attack_self(mob/user)
	// MONKESTATION ADDITION START
	if(chameleon_card_action.hidden)
		return ..()
	// MONKESTATION ADDITION END
	if(isliving(user) && user.mind)
		var/popup_input = tgui_input_list(user, "Choose Action", "Agent ID", list("Show", "Forge/Reset", "Change Account ID"))
		if(user.incapacitated())
			return
		if(!user.is_holding(src))
			return
		if(popup_input == "Forge/Reset")
			if(!forged)
				var/input_name = tgui_input_text(user, "What name would you like to put on this card? Leave blank to randomise.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
				input_name = sanitize_name(input_name, allow_numbers = TRUE)
				if(!input_name)
					// Invalid/blank names give a randomly generated one.
					if(user.gender == MALE)
						input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
					else if(user.gender == FEMALE)
						input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
					else
						input_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"

				registered_name = input_name

				var/change_trim = tgui_alert(user, "Adjust the appearance of your card's trim?", "Modify Trim", list("Yes", "No"))
				if(change_trim == "Yes")
					var/list/blacklist = typecacheof(list(
						type,
						/obj/item/card/id/advanced/simple_bot,
					))
					var/list/trim_list = list()
					for(var/trim_path in typesof(/datum/id_trim))
						if(blacklist[trim_path])
							continue

						var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]

						if(trim && trim.trim_state && trim.assignment)
							var/fake_trim_name = "[trim.assignment] ([trim.trim_state])"
							trim_list[fake_trim_name] = trim_path

					var/selected_trim_path = tgui_input_list(user, "Select trim to apply to your card.\nNote: This will not grant any trim accesses.", "Forge Trim", sort_list(trim_list, GLOBAL_PROC_REF(cmp_typepaths_asc)))
					if(selected_trim_path)
						SSid_access.apply_trim_to_chameleon_card(src, trim_list[selected_trim_path])

				var/target_occupation = tgui_input_text(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels.", "Undercover card job assignment", assignment ? assignment : "Assistant")
				if(target_occupation)
					assignment = target_occupation

				var/new_age = tgui_input_number(user, "Choose the ID's age", "Undercover card age", AGE_MIN, AGE_MAX, AGE_MIN)
				if(QDELETED(user) || QDELETED(src) || !user.can_perform_action(user, NEED_DEXTERITY| FORBID_TELEKINESIS_REACH))
					return
				if(new_age)
					registered_age = new_age

				if(tgui_alert(user, "Activate wallet ID spoofing, allowing this card to force itself to occupy the visible ID slot in wallets?", "Wallet ID Spoofing", list("Yes", "No")) == "Yes")
					ADD_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)

				update_label()
				update_icon()
				forged = TRUE
				to_chat(user, span_notice("You successfully forge the ID card."))
				user.log_message("forged \the [initial(name)] with name \"[registered_name]\", occupation \"[assignment]\" and trim \"[trim?.assignment]\".", LOG_GAME)

				if(!registered_account)
					if(ishuman(user))
						var/mob/living/carbon/human/accountowner = user

						var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[accountowner.account_id]"]
						if(account)
							account.bank_cards += src
							registered_account = account
							to_chat(user, span_notice("Your account number has been automatically assigned."))
				return
			if(forged)
				registered_name = initial(registered_name)
				assignment = initial(assignment)
				SSid_access.remove_trim_from_chameleon_card(src)
				REMOVE_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)
				user.log_message("reset \the [initial(name)] named \"[src]\" to default.", LOG_GAME)
				update_label()
				update_icon()
				forged = FALSE
				to_chat(user, span_notice("You successfully reset the ID card."))
				return
		if (popup_input == "Change Account ID")
			set_new_account(user)
			return
	return ..()

/datum/id_trim/undercover
	assignment = "Unknown"
	access = list(ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		)
