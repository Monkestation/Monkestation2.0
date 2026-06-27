GLOBAL_VAR(posibrain_notify_cooldown)

/obj/item/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "posibrain"
	base_icon_state = "posibrain"
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_ROBOTICS)
	braintype = "Android"

	///Message sent to the user when polling ghosts
	var/begin_activation_message = "<span class='notice'>You carefully locate the manual activation switch and start the positronic brain's boot process.</span>"
	///Message sent as a visible message on success
	var/success_message = "<span class='notice'>The positronic brain pings, and its lights start flashing. Success!</span>"
	///Message sent as a visible message on failure
	var/fail_message = "<span class='notice'>The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>"
	///Visible message sent when a player possesses the brain
	var/new_mob_message = "<span class='notice'>The positronic brain chimes quietly.</span>"
	///Examine message when the posibrain has no mob
	var/dead_message = "<span class='deadsay'>It appears to be completely inactive. The reset light is blinking.</span>"
	///Examine message when the posibrain cannot poll ghosts due to cooldown
	var/recharge_message = "<span class='warning'>The positronic brain isn't ready to activate again yet! Give it some time to recharge.</span>"

	///Can be set to tell ghosts what the brain will be used for
	var/ask_role = ""
	///Does this positronic need a master set before being activated
	var/requires_master = TRUE
	///Who will this positronic serve if placed in a IRC body
	var/mob/living/carbon/human/imprinted_master = null
	///Role assigned to the newly created mind
	var/posibrain_job_path = /datum/job/positronic_brain
	///World time tick when ghost polling will be available again
	var/next_ask
	///Delay after polling ghosts
	var/ask_delay = 60 SECONDS
	///One of these names is randomly picked as the posibrain's name on possession. If left blank, it will use the global posibrain names
	var/list/possible_names
	///Picked posibrain name
	var/picked_name
	///Whether this positronic brain is currently looking for a ghost to enter it.
	var/searching = FALSE
	///List of all ckeys who has already entered this posibrain once before.
	var/list/ckeys_entered = list()

/obj/item/mmi/posibrain/Destroy()
	imprinted_master = null
	return ..()

///Notify ghosts that the posibrain is up for grabs
/obj/item/mmi/posibrain/proc/ping_ghosts(msg, newlymade)
	if(newlymade || GLOB.posibrain_notify_cooldown <= world.time)
		notify_ghosts(
			"[name] [msg] in [get_area(src)]! [ask_role ? "Personality requested: \[[ask_role]\]" : ""]",
			ghost_sound = !newlymade ? 'sound/effects/ghost2.ogg':null,
			notify_volume = 75,
			source = src,
			action = NOTIFY_PLAY,
			notify_flags = (GHOST_NOTIFY_IGNORE_MAPLOAD),
			ignore_key = POLL_IGNORE_POSIBRAIN,
		)
		if(!newlymade)
			GLOB.posibrain_notify_cooldown = world.time + ask_delay

/obj/item/mmi/posibrain/attack_self(mob/user)
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Central Command has temporarily outlawed posibrain sentience in this sector..."))
	if(is_occupied())
		to_chat(user, span_warning("This [name] is already active!"))
		return
	if(next_ask > world.time)
		to_chat(user, recharge_message)
		return
	if(requires_master && !imprinted_master)
		to_chat(user, span_notice("You press your thumb on [src] and imprint your user information."))
		imprinted_master = user
		return
	//Start the process of requesting a new ghost.
	to_chat(user, begin_activation_message)
	ping_ghosts("requested", FALSE)
	next_ask = world.time + ask_delay
	searching = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(check_success)), ask_delay)

/obj/item/mmi/posibrain/click_alt(mob/living/user)
	var/input_seed = tgui_input_text(user, "Enter a personality seed", "Enter seed", ask_role, max_length = MAX_NAME_LEN)
	if(isnull(input_seed) || !user.can_perform_action(src))
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("You set the personality seed to \"[input_seed]\"."))
	ask_role = input_seed
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/mmi/posibrain/proc/check_success()
	searching = FALSE
	update_appearance()
	if(QDELETED(brainmob))
		return
	if(brainmob.client)
		visible_message(success_message)
		playsound(src, 'sound/machines/ping.ogg', 15, TRUE)
	else
		visible_message(fail_message)

///ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/item/mmi/posibrain/attack_ghost(mob/user)
	activate(user)

/obj/item/mmi/posibrain/proc/is_occupied()
	if(brainmob.key)
		return TRUE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(R.mmi == src)
			return TRUE
	return FALSE

///Two ways to activate a positronic brain. A clickable link in the ghost notif, or simply clicking the object itself.
/obj/item/mmi/posibrain/proc/activate(mob/user)
	if(QDELETED(brainmob))
		return
	if(user.ckey in ckeys_entered)
		to_chat(user, span_warning("You cannot re-enter [src] a second time!"))
		return
	if(is_occupied() || is_banned_from(user.ckey, ROLE_POSIBRAIN) || QDELETED(brainmob) || QDELETED(src) || QDELETED(user))
		return
	if(HAS_TRAIT(src, TRAIT_SUICIDED)) //if they suicided, they're out forever.
		to_chat(user, span_warning("[src] fizzles slightly. Sadly it doesn't take those who suicided!"))
		return
	var/posi_ask = tgui_alert(user, "Become a [name]? (Warning, You can no longer be revived, and all past lives will be forgotten!)", "Confirm", list("Yes","No"))
	if(posi_ask != "Yes" || QDELETED(src))
		return
	if(HAS_TRAIT(brainmob, TRAIT_SUICIDED)) //clear suicide status if the old occupant suicided.
		brainmob.set_suicide(FALSE)
	transfer_personality(user)

/obj/item/mmi/posibrain/transfer_identity(mob/living/carbon/transfered_user)
	name = "[initial(name)] ([transfered_user])"
	brainmob.name = transfered_user.real_name
	brainmob.real_name = transfered_user.real_name
	if(transfered_user.has_dna())
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		transfered_user.dna.copy_dna(brainmob.stored_dna)
	brainmob.timeofhostdeath = transfered_user.timeofdeath
	brainmob.set_stat(CONSCIOUS)
	if(brainmob.mind)
		brainmob.mind.set_assigned_role(SSjob.GetJobType(posibrain_job_path))
	if(transfered_user.mind)
		transfered_user.mind.transfer_to(brainmob)

	brainmob.mind.remove_all_antag_datums()
	brainmob.mind.wipe_memory()
	update_appearance()

///Moves the candidate from the ghost to the posibrain
/obj/item/mmi/posibrain/proc/transfer_personality(mob/candidate)
	if(QDELETED(brainmob))
		return
	if(is_occupied()) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		to_chat(candidate, span_warning("This [name] was taken over before you could get to it! Perhaps it might be available later?"))
		return FALSE
	if(candidate.mind && !isobserver(candidate))
		candidate.mind.transfer_to(brainmob)
	else
		brainmob.PossessByPlayer(candidate.ckey)
	name = "[initial(name)] ([brainmob.name])"
	var/policy = get_policy(ROLE_POSIBRAIN)
	if(policy)
		to_chat(brainmob, policy)
	brainmob.mind.set_assigned_role(SSjob.GetJobType(posibrain_job_path))
	brainmob.set_stat(CONSCIOUS)

	visible_message(new_mob_message)
	check_success()
	ckeys_entered |= brainmob.ckey
	return TRUE

/obj/item/mmi/posibrain/attempt_become_organ(obj/item/bodypart/parent, mob/living/carbon/human/H)
	if(..())
		if(imprinted_master)
			to_chat(H, span_danger("You are permanently imprinted to [imprinted_master], obey [imprinted_master]'s every order and assist [imprinted_master.p_them()] in completing [imprinted_master.p_their()] goals at any cost."))

/obj/item/mmi/posibrain/examine(mob/user)
	. = ..()
	if(brainmob?.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
					. += "It appears to be in stand-by mode." //afk
			if(DEAD)
				. += span_deadsay("It appears to be completely inactive.")
	else
		. += "[dead_message]"
		if(ask_role)
			. += span_notice("Current consciousness seed: \"[ask_role]\"")
		. += span_boldnotice("Alt-click to set a consciousness seed, specifying what [src] will be used for. This can help generate a personality interested in that role.")

/obj/item/mmi/posibrain/Initialize(mapload, autoping = TRUE)
	. = ..()
	set_brainmob(new /mob/living/brain(src))
	var/new_name
	if(!LAZYLEN(possible_names))
		new_name = pick(GLOB.posibrain_names)
	else
		new_name = pick(possible_names)
	brainmob.name = "[new_name]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.forceMove(src)
	brainmob.container = src
	if(autoping)
		ping_ghosts("created", TRUE)

/obj/item/mmi/posibrain/update_icon_state()
	. = ..()
	if(searching)
		icon_state = "[base_icon_state]-searching"
		return
	if(brainmob?.key)
		icon_state = "[base_icon_state]-occupied"
		return
	icon_state = "[base_icon_state]"
	return

/obj/item/mmi/posibrain/attackby(obj/item/O, mob/user, params)
	return

/obj/item/mmi/posibrain/add_mmi_overlay()
	return

/obj/item/mmi/posibrain/ipc/Initialize(autoping = FALSE) // IPC posi brain, no ping/alert for ghost anytime a IPC is spawned, and radio off by default for balance concerns
	. = ..()
	radio.set_on(FALSE)

// Used for IPC and IRC brains, MMIs/Positronics surgerically installed become these
/obj/item/organ/internal/brain/positronic
	name = "compact positronic brain"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES | ORGAN_VITAL
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	desc = "You should not be seeing this, please bug report if found" // These should always become positronics/mmis on removal, should never be able to examine
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "posibrain-ipc"

	/// The last time (in ticks) a message about brain damage was sent. Don't touch.
	var/last_message_time = 0

	var/obj/item/mmi/stored_mmi

/obj/item/organ/internal/brain/positronic/Destroy()
	QDEL_NULL(stored_mmi)
	return ..()

/obj/item/organ/internal/brain/positronic/Initialize()
	. = ..()
	stored_mmi = new /obj/item/mmi/posibrain/ipc(src) // Spawned/roundstart IPCs get a mmi too

/obj/item/organ/internal/brain/positronic/on_insert(mob/living/carbon/brain_owner)
	. = ..()

	if(brain_owner.stat != DEAD || !ishuman(brain_owner))
		return

	var/mob/living/carbon/human/user_human = brain_owner
	if(HAS_TRAIT(user_human, TRAIT_REVIVES_BY_HEALING) && user_human.health > SYNTH_BRAIN_WAKE_THRESHOLD)
		if(!HAS_TRAIT(user_human, TRAIT_DEFIB_BLACKLISTED))
			user_human.revive(FALSE)

/obj/item/organ/internal/brain/positronic/check_for_repair(obj/item/item, mob/user)
	if(damage && item.is_drainable() && item.reagents.has_reagent(/datum/reagent/medicine/liquid_solder)) //attempt to heal the brain

		user.visible_message(span_notice("[user] starts to slowly pour the contents of [item] onto [src]."), span_notice("You start to slowly pour the contents of [item] onto [src]."))
		if(!do_after(user, 3 SECONDS, src))
			to_chat(user, span_warning("You failed to pour the contents of [item] onto [src]!"))
			return TRUE

		user.visible_message(span_notice("[user] pours the contents of [item] onto [src], causing it to restore its previous circuit paths."), span_notice("You pour the contents of [item] onto [src], causing it to restore its previous circuit paths."))
		var/amount = item.reagents.get_reagent_amount(/datum/reagent/medicine/liquid_solder)
		var/healto = max(0, damage - amount * 2)
		item.reagents.remove_all(ROUND_UP(item.reagents.total_volume / amount * (damage - healto) * 0.5)) //only removes however much solution is needed while also taking into account how much of the solution is liquid solder
		set_organ_damage(healto) //heals 2 damage per unit of liquid solder, and by using "set_organ_damage", we clear the failing variable if that was up
		cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
		return TRUE
	return FALSE

/obj/item/organ/internal/brain/positronic/emp_act(severity) // EMP act against the posi, keep the cap far below the organ health
	. = ..()

	if((. & EMP_PROTECT_SELF) || !owner)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("01001001 00100111 01101101 00100000 01100110 01110101 01100011 01101011 01100101 01100100 00101110"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maximum = SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organ_flag = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Electromagnetic damage taken in central processing unit. Error Code: 401-YT"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maximum = SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organ_flag = ORGAN_ROBOTIC)

/obj/item/organ/internal/brain/positronic/apply_organ_damage(damage_amount, maximum = maxHealth, required_organ_flag)
	. = ..()

	if(owner && damage > 0 && (world.time - last_message_time) > SYNTH_BRAIN_DAMAGE_MESSAGE_INTERVAL)
		last_message_time = world.time

		if(damage > BRAIN_DAMAGE_SEVERE)
			to_chat(owner, span_warning("Alre: re oumtnin ilir tocorr:pa ni ne:cnrrpiioruloomatt cessingode: P1_1-H"))
			return

		if(damage > BRAIN_DAMAGE_MILD)
			to_chat(owner, span_warning("Alert: Minor corruption in central processing unit. Error Code: 001-HP"))

/obj/item/organ/internal/brain/positronic/Remove(mob/living/user, special = FALSE)
	if(!special)
		if(stored_mmi)
			. = stored_mmi
			if(owner.mind)
				owner.mind.transfer_to(stored_mmi.brainmob)
			stored_mmi.forceMove(get_turf(owner))
			qdel(src)
	return ..()

/obj/item/organ/internal/brain/positronic/mmi // MMI version of internal brain, also shouldn't ever be seen
	name = "man-machine interface"
	desc = "A man-machine interface inserted into the chest. Please bug report if seen."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "mmi-ipc"

/obj/item/organ/internal/brain/positronic/mmi/Initialize(mapload)
	. = ..()
	stored_mmi = new /obj/item/mmi/ipc(src) // Spawned/roundstart IPCs get a mmi too
