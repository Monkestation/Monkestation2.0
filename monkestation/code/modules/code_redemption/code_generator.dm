#define CODE_STORAGE_PATH "data/generated_codes.json"
#define CODE_METADATA_PATH "data/code_metadata.json"

GLOBAL_LIST_INIT(stored_codes, list())
GLOBAL_LIST_INIT(code_metadata, list()) // Stores expiry times, use counts, and redeemer tracking

/proc/generate_custom_redemption_code()
	if(!check_rights(R_FUN))
		return

	var/custom_code = tgui_input_text(usr, "Enter your custom code (e.g., 2025MONKE)", "Custom Code", max_length = 50)
	if(!custom_code)
		return

	custom_code = uppertext(trim(custom_code))

	if(length(custom_code) < 3 || length(custom_code) > 50)
		to_chat(usr, span_warning("Code must be between 3 and 50 characters long."))
		return

	reload_global_stored_codes()
	if(GLOB.stored_codes["[custom_code]"])
		to_chat(usr, span_warning("This code already exists!"))
		return

	var/choice = tgui_input_list(usr, "Please choose a code type", "Code generation", list("Coins", "Loadout Items", "Antag Tokens", "Unusual"))

	if(!choice)
		return

	var/restrictions = tgui_input_list(usr, "Add restrictions to this code?", "Code Restrictions", list("None", "Time Limited", "Use Limited", "Both"))

	var/expiry_time = null
	var/max_uses = null

	if(restrictions == "Time Limited" || restrictions == "Both")
		var/hours = tgui_input_number(usr, "How many hours should this code be valid for?", "Expiry Time", 24, 8760, 1) // Max 1 year
		if(hours)
			expiry_time = world.time + (hours * 36000)

	if(restrictions == "Use Limited" || restrictions == "Both")
		max_uses = tgui_input_number(usr, "Maximum number of redemptions allowed?", "Use Limit", 10, 10000, 1)

	switch(choice)
		if("Coins")
			generate_custom_coin_code(custom_code, expiry_time, max_uses)
		if("Loadout Items")
			generate_custom_loadout_code(custom_code, expiry_time, max_uses)
		if("Antag Tokens")
			generate_custom_antag_token_code(custom_code, expiry_time, max_uses)
		if("Unusual")
			generate_custom_unusual_code(custom_code, expiry_time, max_uses)

/proc/generate_custom_coin_code(custom_code, expiry_time = null, max_uses = null)
	var/amount = tgui_input_number(usr, "Please enter an amount of coins to give", "Coin Amount", 0, 10000, 0)
	if(!amount)
		return

	var/json_file = file(CODE_STORAGE_PATH)
	var/list/collated_data = list()

	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[custom_code]"] = amount

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(custom_code, expiry_time, max_uses)
	reload_global_stored_codes()

	var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
	log_game("[key_name(usr)] generated a custom redemption code '[custom_code]' worth [amount] of coins[restrictions_text].")
	message_admins("[ADMIN_LOOKUP(usr)] generated a custom redemption code '[custom_code]' worth [amount] of coins[restrictions_text].")
	to_chat(usr, span_big("Your custom code has been created: [custom_code]"), confidential = TRUE)
	return custom_code

/proc/generate_custom_loadout_code(custom_code, expiry_time = null, max_uses = null)
	var/static/list/possible_items
	if(!possible_items)
		possible_items = subtypesof(/datum/store_item) - typesof(/datum/store_item/roundstart)
	var/choice = tgui_input_list(usr, "Please choose a loadout item to award", "Loadout Choice", possible_items)
	if(!choice)
		return

	var/json_file = file(CODE_STORAGE_PATH)
	var/list/collated_data = list()

	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[custom_code]"] = "[choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(custom_code, expiry_time, max_uses)
	reload_global_stored_codes()

	var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
	log_game("[key_name(usr)] generated a custom redemption code '[custom_code]' giving a [choice][restrictions_text].")
	message_admins("[ADMIN_LOOKUP(usr)] generated a custom redemption code '[custom_code]' giving a [choice][restrictions_text].")
	to_chat(usr, span_big("Your custom code has been created: [custom_code]"), confidential = TRUE)
	return custom_code

/proc/generate_custom_antag_token_code(custom_code, expiry_time = null, max_uses = null)
	var/choice = tgui_input_list(usr, "Please choose an antag token level to award", "Token Choice", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!choice)
		return

	var/json_file = file(CODE_STORAGE_PATH)
	var/list/collated_data = list()

	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[custom_code]"] = "[choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(custom_code, expiry_time, max_uses)
	reload_global_stored_codes()

	var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
	log_game("[key_name(usr)] generated a custom redemption code '[custom_code]' giving a [choice] Antag Token[restrictions_text].")
	message_admins("[ADMIN_LOOKUP(usr)] generated a custom redemption code '[custom_code]' giving a [choice] Antag Token[restrictions_text].")
	to_chat(usr, span_big("Your custom code has been created: [custom_code]"), confidential = TRUE)
	return custom_code

/proc/generate_custom_unusual_code(custom_code, expiry_time = null, max_uses = null)
	var/free_pick_item = tgui_alert(usr, "Should this be any item?", "Item Choice Type", list("Yes", "No"))
	var/item_choice
	if(free_pick_item == "No")
		item_choice = tgui_alert(usr, "Should it be a random item?", "Loadout Choice", list("Yes", "No"))
		switch(item_choice)
			if("Yes")
				item_choice = pick(GLOB.possible_lootbox_clothing)
			if("No")
				item_choice = tgui_input_list(usr, "Please choose a loadout item to award", "Loadout Choice", GLOB.possible_lootbox_clothing)
	else
		item_choice = tgui_input_list(usr, "Choose an Item", "Item Choice", typesof(/obj/item))

	if(!ispath(item_choice))
		return

	var/static/list/possible_effects
	if(!possible_effects)
		possible_effects = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement

	var/effect_choice = tgui_alert(usr, "Should it be a random effect?", "Loadout Choice", list("Yes", "No"))
	switch(effect_choice)
		if("Yes")
			effect_choice = pick(possible_effects)
		if("No")
			effect_choice = tgui_input_list(usr, "Please choose an effect to give the item.", "Loadout Choice", possible_effects)
	if(!ispath(effect_choice))
		return

	var/json_file = file(CODE_STORAGE_PATH)
	var/list/collated_data = list()

	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[custom_code]"] = "unusual_path=[item_choice]&effect_path=[effect_choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(custom_code, expiry_time, max_uses)
	reload_global_stored_codes()

	var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
	log_game("[key_name(usr)] generated a custom redemption code '[custom_code]' giving a [item_choice] with the unusual effect [effect_choice][restrictions_text].")
	message_admins("[ADMIN_LOOKUP(usr)] generated a custom redemption code '[custom_code]' giving a [item_choice] with the unusual effect [effect_choice][restrictions_text].")
	to_chat(usr, span_big("Your custom code has been created: [custom_code]"), confidential = TRUE)
	return custom_code

/proc/generate_redemption_code()
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose a code type", "Code generation", list("Coins", "Loadout Items", "Antag Tokens", "Unusual"))

	if(!choice)
		return

	var/restrictions = tgui_input_list(usr, "Add restrictions to this code?", "Code Restrictions", list("None", "Time Limited", "Use Limited", "Both"))

	var/expiry_time = null
	var/max_uses = null

	if(restrictions == "Time Limited" || restrictions == "Both")
		var/hours = tgui_input_number(usr, "How many hours should this code be valid for?", "Expiry Time", 24, 8760, 1) // Max 1 year
		if(hours)
			expiry_time = world.time + (hours * 36000)

	if(restrictions == "Use Limited" || restrictions == "Both")
		max_uses = tgui_input_number(usr, "Maximum number of redemptions allowed?", "Use Limit", 10, 10000, 1)

	switch(choice)
		if("Coins")
			generate_coin_code_tgui(FALSE, expiry_time, max_uses)
		if("Loadout Items")
			generate_loadout_code_tgui(FALSE, expiry_time, max_uses)
		if("Antag Tokens")
			generate_antag_token_code_tgui(FALSE, expiry_time, max_uses)
		if("Unusual")
			generate_unusual_code_tgui(FALSE, expiry_time, max_uses)

/proc/generate_coin_code_tgui(no_logs = FALSE, expiry_time = null, max_uses = null)
	if(!check_rights(R_FUN))
		return
	var/amount = tgui_input_number(usr, "Please enter an amount of coins to give", "Coin Amount", 0, 10000, 0)
	if(!amount)
		return
	return generate_coin_code(amount, no_logs, expiry_time, max_uses)

/proc/generate_loadout_code_tgui(no_logs = FALSE, expiry_time = null, max_uses = null)
	if(!check_rights(R_FUN))
		return
	var/static/list/possible_items
	if(!possible_items)
		possible_items = subtypesof(/datum/store_item) - typesof(/datum/store_item/roundstart)
	var/choice = tgui_input_list(usr, "Please choose a loadout item to award", "Loadout Choice", possible_items)
	if(!choice)
		return
	return generate_loadout_code(choice, no_logs, expiry_time, max_uses)

/proc/generate_antag_token_code_tgui(no_logs = FALSE, expiry_time = null, max_uses = null)
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose an antag token level to award", "Token Choice", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!choice)
		return
	return generate_antag_token_code(choice, no_logs, expiry_time, max_uses)

/proc/generate_unusual_code_tgui(no_logs = FALSE, expiry_time = null, max_uses = null)
	if(!check_rights(R_FUN))
		return
	var/free_pick_item = tgui_alert(usr, "Should this be any item?", "Item Choice Type", list("Yes", "No"))
	var/item_choice
	if(free_pick_item == "No")
		item_choice = tgui_alert(usr, "Should it be a random item?", "Loadout Choice", list("Yes", "No"))
		switch(item_choice)
			if("Yes")
				item_choice = pick(GLOB.possible_lootbox_clothing)
			if("No")
				item_choice = tgui_input_list(usr, "Please choose a loadout item to award", "Loadout Choice", GLOB.possible_lootbox_clothing)
	else
		item_choice = tgui_input_list(usr, "Choose an Item", "Item Choice", typesof(/obj/item))

	if(!ispath(item_choice))
		return

	var/static/list/possible_effects
	if(!possible_effects)
		possible_effects = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement

	var/effect_choice = tgui_alert(usr, "Should it be a random effect?", "Loadout Choice", list("Yes", "No"))
	switch(effect_choice)
		if("Yes")
			effect_choice = pick(possible_effects)
		if("No")
			effect_choice = tgui_input_list(usr, "Please choose an effect to give the item.", "Loadout Choice", possible_effects)
	if(!ispath(effect_choice))
		return
	return generate_unusual_code(item_choice, effect_choice, no_logs, expiry_time, max_uses)

/proc/save_code_metadata(code, expiry_time = null, max_uses = null)
	if(!expiry_time && !max_uses)
		return

	var/json_file = file(CODE_METADATA_PATH)
	var/list/collated_data = list()

	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	var/list/metadata = list()
	if(expiry_time)
		metadata["expiry"] = expiry_time
	if(max_uses)
		metadata["max_uses"] = max_uses
		metadata["current_uses"] = 0

	metadata["redeemed_by"] = list()

	collated_data["[code]"] = metadata

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)
	reload_code_metadata()

/proc/reload_code_metadata()
	GLOB.code_metadata = list()
	var/json_file = file(CODE_METADATA_PATH)

	if(!fexists(json_file))
		return
	GLOB.code_metadata = json_decode(file2text(json_file))

/proc/generate_coin_code(amount, no_logs = FALSE, expiry_time = null, max_uses = null)
	if(!amount)
		return
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = amount

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(string, expiry_time, max_uses)
	reload_global_stored_codes()

	if(!no_logs)
		var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
		log_game("[key_name(usr)] generated a new redemption code worth [amount] of coins[restrictions_text].")
		message_admins("[ADMIN_LOOKUP(usr)] generated a new redemption code worth [amount] of coins[restrictions_text].")
		to_chat(usr, span_big("Your generated code is: [string]"), confidential = TRUE)
	return string

/proc/generate_loadout_code(choice, no_logs = FALSE, expiry_time = null, max_uses = null)
	if(!choice)
		return
	reload_global_stored_codes()
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = "[choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(string, expiry_time, max_uses)
	reload_global_stored_codes()

	if(!no_logs)
		var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
		log_game("[key_name(usr)] generated a new redemption code giving a [choice][restrictions_text].")
		message_admins("[ADMIN_LOOKUP(usr)] generated a new redemption code giving a [choice][restrictions_text].")
		to_chat(usr, span_big("Your generated code is: [string]"), confidential = TRUE)
	return string

/proc/generate_antag_token_code(choice, no_logs = FALSE, expiry_time = null, max_uses = null)
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = "[choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(string, expiry_time, max_uses)
	reload_global_stored_codes()

	if(!no_logs)
		var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
		log_game("[key_name(usr)] generated a new redemption code giving a [choice] Antag Token[restrictions_text].")
		message_admins("[ADMIN_LOOKUP(usr)] generated a new redemption code giving a [choice] Antag Token[restrictions_text].")
		to_chat(usr, span_big("Your generated code is: [string]"), confidential = TRUE)
	return string

/proc/generate_unusual_code(item_choice, effect_choice, no_logs = FALSE, expiry_time = null, max_uses = null)
	reload_global_stored_codes()
	var/string = generate_code_string()

	var/json_file = file(CODE_STORAGE_PATH)

	var/list/collated_data = list()
	if(fexists(json_file))
		var/list/old_data = json_decode(file2text(json_file))
		collated_data += old_data

	collated_data["[string]"] = "unusual_path=[item_choice]&effect_path=[effect_choice]"

	var/payload = json_encode(collated_data)
	fdel(json_file)
	WRITE_FILE(json_file, payload)

	save_code_metadata(string, expiry_time, max_uses)
	reload_global_stored_codes()

	if(!no_logs)
		var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
		log_game("[key_name(usr)] generated a new redemption code giving a [item_choice] with the unusual effect [effect_choice][restrictions_text].")
		message_admins("[ADMIN_LOOKUP(usr)] generated a new redemption code giving a [item_choice] with the unusual effect [effect_choice][restrictions_text].")
		to_chat(usr, span_big("Your generated code is: [string]"), confidential = TRUE)
	return string

/proc/get_restrictions_text(expiry_time, max_uses)
	var/text = ""
	if(expiry_time)
		var/hours_remaining = round((expiry_time - world.time) / 36000, 0.1)
		text += " (expires in [hours_remaining] hours)"
	if(max_uses)
		text += " (max [max_uses] uses)"
	return text

/proc/generate_code_string()
	var/list/sections = list()
	for(var/num in 1 to 5)
		sections += random_string(5, GLOB.hex_characters)

	var/string = sections.Join("-")
	return string

/proc/reload_global_stored_codes()
	GLOB.stored_codes = list()
	var/json_file = file(CODE_STORAGE_PATH)

	if(!fexists(json_file))
		return
	GLOB.stored_codes = json_decode(file2text(json_file))

	reload_code_metadata()

/proc/generate_bulk_redemption_code()
	if(!check_rights(R_FUN))
		return
	var/choice = tgui_input_list(usr, "Please choose a code type", "Code generation", list("Coins", "Loadout Items", "Antag Tokens"))

	if(!choice)
		return
	var/amount = tgui_input_number(usr, "Choose a number", "Number", 1, 20, 0)
	if(!amount)
		return

	var/restrictions = tgui_input_list(usr, "Add restrictions to these codes?", "Code Restrictions", list("None", "Time Limited", "Use Limited", "Both"))

	var/expiry_time = null
	var/max_uses = null

	if(restrictions == "Time Limited" || restrictions == "Both")
		var/hours = tgui_input_number(usr, "How many hours should these codes be valid for?", "Expiry Time", 24, 8760, 1)
		if(hours)
			expiry_time = world.time + (hours * 36000)

	if(restrictions == "Use Limited" || restrictions == "Both")
		max_uses = tgui_input_number(usr, "Maximum number of redemptions per code?", "Use Limit", 10, 10000, 1)

	reload_global_stored_codes()
	var/list/generated_codes = list()
	for(var/num in 1 to amount)
		if(choice == "Coins")
			generated_codes += generate_coin_code_tgui(TRUE, expiry_time, max_uses)
		else if(choice == "Loadout Items")
			generated_codes += generate_loadout_code_tgui(TRUE, expiry_time, max_uses)
		else
			generated_codes += generate_antag_token_code_tgui(TRUE, expiry_time, max_uses)

	var/restrictions_text = get_restrictions_text(expiry_time, max_uses)
	log_game("[key_name(usr)] generated [amount] new redemption codes[restrictions_text].")
	message_admins("[ADMIN_LOOKUP(usr)] generated [amount] new redemption codes[restrictions_text].")
	var/connected_keys = generated_codes.Join(" ,")
	to_chat(usr, span_big("Your generated codes are: [connected_keys]"), confidential = TRUE)
