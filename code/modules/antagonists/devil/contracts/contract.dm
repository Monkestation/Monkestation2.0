/obj/item/paper/devil_contract
	name = "Sinister contract"
	desc = "A scroll that holds a contract with unethical clauses, this can't be legal."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	show_written_words = FALSE
	default_raw_text = {"# <center> Infernal Soul Contract </center>
### 1. Identification of parties
This binding agreement made this day is made between: The Infernal Party (Contractor) and The Mortal Party (Signer)
### 2. Applied Conditions
The following conditions (clauses) will be respected and take effect upon the Signers and Contractors parties both signing the contract
<i>The clauses may not be broken and must be followed even if the Signer's form changes or is otherwise altered.</i>
<br>The signer will have the following taken or given to them:"}

	// Note: if the contract has clauses, is not signed by the devil and the clause gets deleted the clause will hard-del.
	// ↑ This probably is fine to leave in, since antag datums basically never delete
	/// The list of clauses this contract has
	var/list/clauses = null
	/// The total amount of points this contract has (keep always negative or 0)
	var/points = 0
	/// The person who signed this contract, null if absent, reference if signed by victim, string after signed by devil
	var/mob/living/signer = null
	/// If this contract is completed (signed by both a normal person and a devil)
	var/completed = FALSE

/obj/item/paper/devil_contract/Initialize(mapload, list/default_clauses = list())
	. = ..()
	clauses = list()
	for(var/datum/devil_clause/clause as anything in default_clauses)
		add_clause(clause)

/obj/item/paper/devil_contract/Destroy(force)
	clauses = null
	if(signer)
		UnregisterSignal(signer, COMSIG_QDELETING)
		signer = null
	return ..()

/obj/item/paper/devil_contract/examine(mob/user)
	. = ..()
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	if(completed)
		. += span_warning("Whats done cannot be undone.")
		return

	if(isnull(signer))
		if(devil)
			. += span_notice("You can use the contract in your hand to edit the conditions")
			. += span_notice("Ready to give out to an unfortunate fool.")
		else
			. += span_notice("You could sign on the dotted line if you use a pen on it...")
		return

	if(devil)
		. += span_notice("Sign it to complete the contract.")
	else if(user == signer)
		. += span_notice("Now to hand this contract over to them, could still back out.")

/obj/item/paper/devil_contract/tool_act(mob/living/user, obj/item/pen/pen, list/modifiers)
	if(!istype(pen))
		return ..()

	. = ITEM_INTERACT_BLOCKING
	if(completed)
		to_chat(user, span_notice("This contract already concluded."))
		return

	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	if(isnull(signer))
		if(devil)
			devil.contract_ui.assign_contract(src)
			devil.contract_ui.ui_interact(user)
			return ITEM_INTERACT_SUCCESS

		if(HAS_TRAIT(user, TRAIT_NO_SOUL))
			to_chat(user, span_notice("You remember, you don't actually have a soul to sell. Damn."))
			return

		if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
			var/mindshield_message = "!Soul ownership change attempt identified! NT would like to remind you we own your soul."
			to_chat(user, span_boldwarning("You hear a voice in your head... \"[mindshield_message]\""))
			return

		var/confirm = tgui_alert(user, "Sign [src], agreeing to all its clauses?", "The deal", list("Yes", "No"))
		if(confirm == "Yes" && in_range(user, src) && isnull(signer))
			RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_victim_deleted))
			signer = user
			user.visible_message(span_notice("[user] signs their name on [src]"))
			add_raw_text("I <i>[signer.name]</i> as a Signer agree to the clauses listed above.")
			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
			return ITEM_INTERACT_SUCCESS
	else if(devil) // Ya like if() checks?
		if(isnull(signer.mind))
			to_chat(user, span_notice("Whoever signed this contract looks to already not possess a soul for us to take"))
			return
		if(HAS_TRAIT(signer, TRAIT_NO_SOUL) && locate(/datum/devil_clause/trait_giver/soul) in clauses) // Yeah.
			to_chat(user, span_notice("Whoever signed this contract looks to already not possess a soul for us to take"))
			return
		if(devil.contracted[signer.mind])
			to_chat(user, span_notice("We already made one contract with them, no point of making another."))
			return
		devil.sign_contract(signer.mind, clauses)
		completed = TRUE
		icon_state = "scroll2"
		user.visible_message(span_notice("[user] signs their name on [src]"))
		add_raw_text("I <i>[devil.true_name]</i> as a Contractor agree to fulfill the clauses listed above.")
		playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
		if(!QDELETED(signer)) // No point of holding onto a signal (do check if they still exist tho, clauses are funky)
			on_victim_deleted(signer)
		return ITEM_INTERACT_SUCCESS

/obj/item/paper/devil_contract/ui_static_data(mob/user)
	var/list/static_data = ..() // You see this? What is this?? In ui_data???
	static_data["paper_color"] = "#b94030"
	return static_data

/obj/item/paper/devil_contract/ui_data(mob/user)
	var/list/data = list()
	data["held_item_details"] = null // No writing here silly
	return data

/obj/item/paper/devil_contract/proc/add_clause(datum/devil_clause/clause)
	clauses += clause
	points += clause.cost
	add_raw_text({"- [clause.prefix] [clause.name]
<br>[clause.desc]"})
	playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
	update_static_data_for_all_viewers()

/obj/item/paper/devil_contract/proc/remove_clause(datum/devil_clause/clause)
	for(var/index in 1 to length(clauses))
		if(clause != clauses[index])
			continue
		clauses -= clause
		points -= clause.cost
		var/list/datum/paper_input/clause_text = raw_text_inputs[index + 1]
		raw_text_inputs -= clause_text
		qdel(clause_text) // Fun fact: clear_paper() actually leaves these to be collected by the GC instead of qdeleting.
		playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
		update_static_data_for_all_viewers()
		break

/obj/item/paper/devil_contract/proc/on_victim_deleted(mob/living/victim)
	SIGNAL_HANDLER
	UnregisterSignal(victim, COMSIG_QDELETING)
	signer = null
	completed = TRUE
