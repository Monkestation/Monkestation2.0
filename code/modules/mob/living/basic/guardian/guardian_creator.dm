GLOBAL_LIST_INIT(guardian_radial_images, setup_guardian_radial())

/proc/setup_guardian_radial()
	. = list()
	for(var/mob/living/basic/guardian/guardian_path as anything in subtypesof(/mob/living/basic/guardian))
		var/datum/radial_menu_choice/option = new()
		option.name = initial(guardian_path.creator_name)
		option.image = image(icon = 'icons/hud/guardian.dmi', icon_state = initial(guardian_path.creator_icon))
		option.info = span_boldnotice(initial(guardian_path.creator_desc))
		.[guardian_path] = option

/// An item which grants you your very own soul buddy
/obj/item/guardian_creator
	name = "enchanted deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power."
	icon = 'icons/obj/toys/playing_cards.dmi'
	icon_state = "deck_tarot_full"
	/// Are we used or in the process of being used? If yes, then we can't be used.
	var/used = FALSE
	/// The visuals we give to the guardian we spawn.
	var/theme = GUARDIAN_THEME_MAGIC
	/// The name of the guardian, for UI/message stuff.
	var/mob_name = "Guardian Spirit"
	/// Message sent when you use it.
	var/use_message = span_holoparasite("You shuffle the deck...")
	/// Message sent when it's already used.
	var/used_message = span_holoparasite("All the cards seem to be blank now.")
	/// Failure message if no ghost picks the holopara.
	var/failure_message = span_boldholoparasite("..And draw a card! It's... blank? Maybe you should try again later.")
	/// Failure message if we don't allow lings.
	var/ling_failure = span_boldholoparasite("The deck refuses to respond to a souless creature such as you.")
	/// Message sent if we successfully get a guardian.
	var/success_message = span_holoparasite("<b>%GUARDIAN</b> has been summoned!")
	/// If true, you are given a random guardian rather than picking from a selection.
	var/random = FALSE
	/// If true, you can have multiple guardians at the same time.
	var/allow_multiple = FALSE
	/// If true, lings can get guardians from this.
	var/allow_changeling = TRUE
	/// If true, a dextrous guardian can get their own guardian, infinite chain!
	var/allow_guardian = FALSE
	/// List of all the guardians this type can spawn.
	var/list/possible_guardians = list( //default, has everything but dextrous
		/mob/living/basic/guardian/assassin,
		/mob/living/basic/guardian/charger,
		/mob/living/basic/guardian/explosive,
		/mob/living/basic/guardian/gaseous,
		/mob/living/basic/guardian/gravitokinetic,
		/mob/living/basic/guardian/lightning,
		/mob/living/basic/guardian/protector,
		/mob/living/basic/guardian/ranged,
		/mob/living/basic/guardian/standard,
		/mob/living/basic/guardian/support,
	)

/obj/item/guardian_creator/Initialize(mapload)
	. = ..()
	var/datum/guardian_fluff/using_theme = GLOB.guardian_themes[theme]
	mob_name = using_theme.name

/obj/item/guardian_creator/attack_self(mob/living/user)
	if(isguardian(user) && !allow_guardian)
		balloon_alert(user, "can't do that!")
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allow_multiple)
		balloon_alert(user, "already have one!")
		return
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling) && !allow_changeling)
		to_chat(user, ling_failure)
		return
	if(used)
		to_chat(user, used_message)
		return
	var/list/radial_options = GLOB.guardian_radial_images.Copy()
	for(var/possible_guardian in radial_options)
		if(possible_guardian in possible_guardians)
			continue
		radial_options -= possible_guardian
	var/mob/living/basic/guardian/guardian_path
	if(random)
		guardian_path = pick(possible_guardians)
	else
		guardian_path = show_radial_menu(user, src, radial_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 42, require_near = TRUE)
		if(isnull(guardian_path))
			return
	used = TRUE
	to_chat(user, use_message)
	var/guardian_type_name = random ? "Random" : capitalize(initial(guardian_path.creator_name))
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as [user.real_name]'s [guardian_type_name] [mob_name]?",
		check_jobban = ROLE_PAI,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_HOLOPARASITE,
		alert_pic = guardian_path,
		role_name_text = "guardian spirit"
	)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/candidate = pick(candidates)
		spawn_guardian(user, candidate, guardian_path)
		SEND_SIGNAL(src, COMSIG_TRAITOR_ITEM_USED(type))
	else
		to_chat(user, failure_message)
		used = FALSE

/// Actually create our guy
/obj/item/guardian_creator/proc/spawn_guardian(mob/living/user, mob/dead/candidate, guardian_path)
	if(QDELETED(user) || user.stat == DEAD)
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allow_multiple)
		balloon_alert(user, "already got one!")
		used = FALSE
		return
	var/datum/guardian_fluff/guardian_theme = GLOB.guardian_themes[theme]
	var/mob/living/basic/guardian/summoned_guardian = new guardian_path(user, guardian_theme)
	summoned_guardian.set_summoner(user, different_person = TRUE)
	summoned_guardian.PossessByPlayer(candidate.key)
	user.log_message("has summoned [key_name(summoned_guardian)], a [summoned_guardian.creator_name] holoparasite.", LOG_GAME)
	summoned_guardian.log_message("was summoned as a [summoned_guardian.creator_name] holoparasite.", LOG_GAME)
	to_chat(user, guardian_theme.get_fluff_string(summoned_guardian.guardian_type))
	to_chat(user, replacetext(success_message, "%GUARDIAN", mob_name))
	summoned_guardian.client?.init_verbs()
	summoned_guardian.updatehealth() // Set the initial health hud
	return summoned_guardian

/// Checks to ensure we're still capable of using the radial selector
/obj/item/guardian_creator/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.is_holding(src) || used)
		return FALSE
	return TRUE

/// Guardian creator available in the wizard spellbook. All but support are available.
/obj/item/guardian_creator/wizard
	allow_multiple = TRUE
	possible_guardians = list(
		/mob/living/basic/guardian/assassin,
		/mob/living/basic/guardian/charger,
		/mob/living/basic/guardian/dextrous,
		/mob/living/basic/guardian/explosive,
		/mob/living/basic/guardian/gaseous,
		/mob/living/basic/guardian/gravitokinetic,
		/mob/living/basic/guardian/lightning,
		/mob/living/basic/guardian/protector,
		/mob/living/basic/guardian/ranged,
		/mob/living/basic/guardian/standard,
	)

/obj/item/guardian_creator/wizard/spawn_guardian(mob/living/user, mob/dead/candidate)
	var/mob/guardian = ..()
	if(isnull(guardian))
		return null
	// Add the wizard team datum
	var/datum/antagonist/wizard/antag_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(isnull(antag_datum))
		return guardian
	if(!antag_datum.wiz_team)
		antag_datum.create_wiz_team()
	guardian.mind.add_antag_datum(/datum/antagonist/wizard_minion, antag_datum.wiz_team)
	return guardian

/// Guardian creator available in the traitor uplink. All but dextrous are available, you can pick which you want, and changelings cannot use it.
/obj/item/guardian_creator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "hypo_qmc"
	theme = GUARDIAN_THEME_TECH
	allow_multiple = TRUE
	allow_changeling = FALSE
	use_message = span_holoparasite("You start to power on the injector...")
	used_message = span_holoparasite("The injector has already been used.")
	failure_message = span_boldholoparasite("...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.")
	ling_failure = span_boldholoparasite("The holoparasites recoil in horror. They want nothing to do with a creature like you.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> is now online!")

/// Guardian creator only spawned by admins, which creates a holographic fish. You can have several of them.
/obj/item/guardian_creator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfingers"
	theme = GUARDIAN_THEME_CARP
	use_message = span_holoparasite("You put the fishsticks in your mouth...")
	used_message = span_holoparasite("Someone's already taken a bite out of these fishsticks! Ew.")
	failure_message = span_boldholoparasite("You couldn't catch any carp spirits from the seas of Lake Carp. Maybe there are none, maybe you fucked up.")
	ling_failure = span_boldholoparasite("Carp'sie seems to not have taken you as the chosen one. Maybe it's because of your horrifying origin.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> has been caught!")
	allow_multiple = TRUE

/// Guardian creator available to miners from chests, very limited selection and randomly assigned.
/obj/item/guardian_creator/miner
	name = "dusty shard"
	desc = "Seems to be a very old rock, may have originated from a strange meteor."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "dustyshard"
	theme = GUARDIAN_THEME_MINER
	allow_multiple = FALSE
	use_message = span_holoparasite("You pierce your skin with the shard...")
	used_message = span_holoparasite("This shard seems to have lost all its power...")
	failure_message = span_boldholoparasite("The shard hasn't reacted at all. Maybe try again later...")
	ling_failure = span_boldholoparasite("The power of the shard seems to not react with your horrifying, mutated body.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> has appeared!")
	random = TRUE
	//limited to ones which are plausibly useful on lavaland
	possible_guardians = list(
		/mob/living/basic/guardian/charger, // A flying mount which can cross chasms
		/mob/living/basic/guardian/protector, // Bodyblocks projectiles for you
		/mob/living/basic/guardian/ranged, // Shoots the bad guys
		/mob/living/basic/guardian/standard, // Can mine walls
		/mob/living/basic/guardian/support, // Heals and teleports you
	)

/// Holoparasite injector printed by science. Needs a hallucination core and an MMI/posibrain, whose occupant picks the guardian type and then pilots it.
/obj/item/guardian_creator/tech/phantasmal
	name = "phantasmal holoparasite injector"
	desc = "A holoparasite injector with no nanoswarm of its own. A hallucination core powers the hardlight projector inside, allowing a living mind to control a body of light. Holoparasite type is determined by the occupant."
	use_message = span_holoparasite("You start to power on the injector...")
	used_message = span_holoparasite("The injector has already been used.")
	failure_message = span_boldholoparasite("...ERROR. PROJECTION ABORTED. PILOT FAILED TO CONNECT. PLEASE TRY AGAIN LATER.")
	success_message = span_holoparasite("<b>%GUARDIAN</b> is now online!")
	ling_failure = span_boldholoparasite("The injector scans you and shuts down in a burst of static. It wants nothing to do with a creature like you.")
	icon = 'icons/obj/medical/holo_injector.dmi'
	icon_state = "holo_injector"
	var/obj/item/assembly/signaler/anomaly/hallucination/loaded_core
	/// The MMI or posibrain we are loaded with, its occupant becomes the guardian.
	var/obj/item/mmi/loaded_mmi
	/// True while the occupant is picking a type, so it can't be activated twice.
	var/choosing = FALSE
	var/choice_time = 30 SECONDS

/obj/item/guardian_creator/tech/phantasmal/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/guardian_creator/tech/phantasmal/Destroy()
	QDEL_NULL(loaded_core)
	QDEL_NULL(loaded_mmi)
	return ..()

/obj/item/guardian_creator/tech/phantasmal/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == loaded_core)
		loaded_core = null
		update_appearance()
	else if(gone == loaded_mmi)
		loaded_mmi = null
		update_appearance()

/obj/item/guardian_creator/tech/phantasmal/examine(mob/user)
	. = ..()
	if(used)
		return
	. += span_notice("The core socket is [loaded_core ? "loaded" : "empty, it needs a hallucination core"].")
	. += span_notice("The brain slot is [loaded_mmi ? "loaded with [loaded_mmi]" : "empty, it needs an MMI or positronic brain"].")
	. += span_notice("<b>Alt-click</b> to remove whatever is loaded.")

/obj/item/guardian_creator/tech/phantasmal/update_overlays()
	. = ..()
	if(used)
		. += "holo_injector_spent"
		return
	if(loaded_mmi)
		. += "holo_injector_brain"
	if(loaded_core)
		. += "holo_injector_core"
	if(loaded_core && loaded_mmi)
		. += "holo_injector_ready"

/obj/item/guardian_creator/tech/phantasmal/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(used || choosing)
		return NONE
	if(istype(tool, /obj/item/assembly/signaler/anomaly/hallucination))
		if(loaded_core)
			balloon_alert(user, "already has a core!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		loaded_core = tool
		balloon_alert(user, "core loaded")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/mmi))
		var/obj/item/mmi/new_mmi = tool
		if(loaded_mmi)
			balloon_alert(user, "already has a brain!")
			return ITEM_INTERACT_BLOCKING
		if(!new_mmi.brainmob?.key)
			balloon_alert(user, "nobody inside!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		loaded_mmi = new_mmi
		balloon_alert(user, "brain loaded")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_appearance()
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/guardian_creator/tech/phantasmal/click_alt(mob/user)
	if(used || choosing)
		return CLICK_ACTION_BLOCKING
	if(!loaded_core && !loaded_mmi)
		return CLICK_ACTION_BLOCKING
	if(loaded_core)
		user.put_in_hands(loaded_core)
	if(loaded_mmi)
		user.put_in_hands(loaded_mmi)
	balloon_alert(user, "unloaded")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	return CLICK_ACTION_SUCCESS

/obj/item/guardian_creator/tech/phantasmal/attack_self(mob/living/user)
	if(used)
		to_chat(user, used_message)
		return
	if(choosing)
		balloon_alert(user, "already in use!")
		return
	if(isguardian(user))
		balloon_alert(user, "can't do that!")
		return
	if(user.mind?.has_antag_datum(/datum/antagonist/changeling) && !allow_changeling)
		to_chat(user, ling_failure)
		return
	if(!loaded_core)
		balloon_alert(user, "needs a hallucination core!")
		return
	if(!loaded_mmi)
		balloon_alert(user, "needs an MMI or posibrain!")
		return
	var/mob/living/brain/pilot = loaded_mmi.brainmob
	if(QDELETED(pilot) || !pilot.client || pilot.stat == DEAD)
		balloon_alert(user, "the brain doesn't respond!")
		return

	choosing = TRUE
	to_chat(user, use_message)
	to_chat(pilot, span_boldholoparasite("[user.real_name] is trying to use a phantasmal holoparasite injector with you as the pilot. Pick a type, or refuse and nothing will happen."))

	var/list/options = list()
	for(var/mob/living/basic/guardian/possible_path as anything in subtypesof(/mob/living/basic/guardian))
		var/guardian_name = initial(possible_path.creator_name)
		if(!guardian_name)
			continue
		options["[capitalize(guardian_name)]: [initial(possible_path.creator_desc)]"] = possible_path
	var/refuse_option = "Refuse"
	var/choice = tgui_input_list(pilot, "Pick the type of holoparasite you will pilot, or refuse and nothing will happen.", "Phantasmal Holoparasite", list(refuse_option) + assoc_to_keys(options), refuse_option, choice_time)
	choosing = FALSE

	if(isnull(choice) || choice == refuse_option)
		if(!QDELETED(user))
			to_chat(user, span_warning("...ERROR. PILOT REFUSED THE CONNECTION. The injector has not been used."))
		return
	// Everything could have changed while they were choosing
	if(QDELETED(user) || user.stat == DEAD || !user.is_holding(src) || QDELETED(loaded_core) || QDELETED(loaded_mmi) || loaded_mmi.brainmob != pilot || !pilot.client)
		if(!QDELETED(user))
			to_chat(user, span_warning("...ERROR. CONNECTION LOST. The injector has not been used."))
		if(!QDELETED(pilot))
			to_chat(pilot, span_warning("The connection to the injector was lost."))
		return
	var/mob/living/basic/guardian/guardian_path = options[choice]
	used = TRUE
	var/key_name_pilot = key_name(pilot)
	var/mob/living/basic/guardian/summoned_guardian = spawn_guardian(user, pilot, guardian_path)
	if(isnull(summoned_guardian))
		used = FALSE
		to_chat(user, failure_message)
		return
	summoned_guardian.log_message("was piloted by the brain of [key_name_pilot] through a phantasmal injector.", LOG_GAME)
	pilot.mind?.transfer_to(summoned_guardian)
	// The core and the brain are used up, the occupant now lives in the guardian
	QDEL_NULL(loaded_core)
	QDEL_NULL(loaded_mmi)
	update_appearance()
