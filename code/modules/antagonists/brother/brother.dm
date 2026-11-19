/datum/antagonist/brother
	name = "\improper Brother"
	antagpanel_category = "Brother"
	job_rank = ROLE_BROTHER
	var/special_role = ROLE_BROTHER
	antag_hud_name = "brother"
	hijack_speed = 0.5
	ui_name = "AntagInfoBrother"
	suicide_cry = "FOR MY BROTHER!!"
	antag_moodlet = /datum/mood_event/focused
	hardcore_random_bonus = TRUE
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_TEAM // monkestation addition
	stinger_sound = 'sound/music/antag/traitor/tatoralert.ogg'
	antag_count_points = 5 //duo antag
	var/datum/action/bb/comms/comms_action
	var/datum/action/bb/gear/gear_action
	VAR_PRIVATE/datum/team/brother_team/team
	///This is used to say who is the big and little brothers. 0 = big, 1 is the middle brother, 2 is little, 3 is little little
	var/brotherRank = 0
	///Whether the confirmation UI popup is active or not
	var/popup = FALSE
	///Whether this brother is compromising a mindshield
	var/compromising = FALSE
	///Whether this brother is hacking a cloning console
	var/hacking_cloner = FALSE
	///Clone data taken when this brother joins and dies, used if their body is gone
	var/list/clone_snapshot
	///How long a brother holds still to compromise a mindshield
	var/mindshield_compromise_time = 15 SECONDS
	///This is the same sechud that's given to head revolutionaries but here it's only given to the starting brother
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate/given_hud

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team
	set_hud_keys(REF(new_team))

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	objectives |= team.objectives
	owner.special_role = special_role
	finalize_brother()

	// The extra conversion chance is rolled in /datum/team/brother_team/New()
	team.brothers_left -= 1

	// Only the starting brother gets a flash, convertees have to find their own
	if (team.brothers_left > 0 && length(team.members) <= 1)
		var/mob/living/carbon/carbon_owner = owner.current
		if (istype(carbon_owner))
			carbon_owner.equip_conspicuous_item(new /obj/item/assembly/flash)

	// Abandoning the bond (cryo, DNR, suicide, new role) removes you from the team
	RegisterSignal(owner, COMSIG_MIND_DNR, PROC_REF(on_dnr))
	RegisterSignal(owner, COMSIG_MIND_CRYOED, PROC_REF(on_cryoed))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_mob_logged_in))

	take_clone_snapshot(owner.current)

	return ..()

/datum/antagonist/brother/on_removal()
	remove_security_hud()
	owner.special_role = null
	UnregisterSignal(owner, list(COMSIG_MIND_DNR, COMSIG_MIND_CRYOED))
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN)
	return ..()

/datum/antagonist/brother/proc/on_dnr(datum/mind/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(abandon_bond), "chosen not to be revived", "chose not to be revived")

/datum/antagonist/brother/proc/on_cryoed(datum/mind/source, mob/living/body)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(abandon_bond), "entered cryosleep", "entered cryosleep")

/// Suicides can't be revived, so they abandon the bond
/datum/antagonist/brother/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	// Gib and dust send this before the body goes, so snapshot for the cloning hack
	take_clone_snapshot(source)
	if(!HAS_TRAIT(source, TRAIT_SUICIDED))
		return
	INVOKE_ASYNC(src, PROC_REF(abandon_bond), "committed suicide", "committed suicide")

/// Ghosting out of a living body for good abandons the bond
/datum/antagonist/brother/proc/on_ghostized(mob/living/source)
	SIGNAL_HANDLER
	if(source.stat == DEAD || owner.get_ghost(even_if_they_cant_reenter = TRUE))
		return
	INVOKE_ASYNC(src, PROC_REF(abandon_bond), "left their body for good", "left your body for good")

/// Taking a new body (ghost role, midround antag) abandons the bond
/datum/antagonist/brother/proc/on_mob_logged_in(datum/source, mob/new_mob)
	SIGNAL_HANDLER
	if(isnull(owner.key) || new_mob.mind == owner || new_mob.ckey != ckey(owner.key))
		return
	// Ghosts, the lobby and the ghost cafe aren't new roles
	if(isobserver(new_mob) || isnewplayer(new_mob) || istype(new_mob, /mob/living/carbon/human/ghost))
		return
	// Bitrunning avatars and other temporary bodies
	if(owner.current && (HAS_TRAIT(owner.current, TRAIT_MIND_TEMPORARILY_GONE) || istype(owner.current.loc, /obj/machinery/netpod)))
		return
	INVOKE_ASYNC(src, PROC_REF(abandon_bond), "taken on another role", "took on another role")

/**
 * Boots this brother from the team and gives the team back a conversion charge
 *
 * Arguments:
 * * their_reason - what the brother did, as told to the rest of the team ("entered cryosleep")
 * * your_reason - what the brother did, as told to the brother themselves
 */
/datum/antagonist/brother/proc/abandon_bond(their_reason, your_reason)
	var/datum/team/brother_team/bond = team
	if(QDELETED(src) || QDELETED(bond))
		return
	var/brother_name = owner.current?.real_name || owner.name
	// They're probably a ghost by now, so find them by client
	var/client/leaver = GLOB.directory[ckey(owner.key)]
	owner.current?.log_message("was removed from their blood brother team for abandoning it (has [their_reason]).", LOG_GAME)
	if(length(bond.members) == 1)
		message_admins("[owner.current ? ADMIN_LOOKUPFLW(owner.current) : owner.name], the last member of [bond.name], has [their_reason]. The blood brother team is gone.")
	bond.remove_member(owner, span_warning("[span_bold(brother_name)] has [their_reason], and is no longer your brother. You have been refunded a conversion charge."))
	if(leaver)
		to_chat(leaver, span_userdanger("You [your_reason], and have abandoned your blood bond. You are no longer a blood brother."))
	if(!QDELETED(bond))
		bond.adjust_conversion_charges(1)

/// Lets this brother convert people with a flash, if their team has conversions left.
/datum/antagonist/brother/proc/start_converting(mob/living/mob_override)
	var/mob/living/carbon/target = mob_override || owner.current
	if(!istype(target) || get_conversions_left() <= 0)
		return
	target.AddComponentFrom(REF(src), /datum/component/can_flash_from_behind)
	RegisterSignal(target, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON, PROC_REF(on_mob_successful_flashed_carbon), override = TRUE)

/// Stops this brother from being able to convert people with a flash.
/datum/antagonist/brother/proc/stop_converting(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	if(isnull(target))
		return
	target.RemoveComponentSource(REF(src), /datum/component/can_flash_from_behind)
	UnregisterSignal(target, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON)

// Apply team-specific antag HUD.
/datum/antagonist/brother/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(QDELETED(comms_action))
		comms_action = new(src)
	if(QDELETED(gear_action) && !team.summoned_gear)
		gear_action = new(src)
	var/mob/living/target = mob_override || owner.current
	comms_action.Grant(target)
	gear_action?.Grant(target)
	add_team_hud(target, /datum/antagonist/brother, REF(team))
	start_converting(target)
	RegisterSignal(target, COMSIG_MOB_GHOSTIZED, PROC_REF(on_ghostized), override = TRUE)
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death), override = TRUE)

/datum/antagonist/brother/remove_innate_effects(mob/living/mob_override)
	. = ..()
	comms_action?.Remove(mob_override || owner.current)
	QDEL_NULL(comms_action)
	gear_action?.Remove(mob_override || owner.current)
	QDEL_NULL(gear_action)
	stop_converting(mob_override)
	UnregisterSignal(mob_override || owner.current, list(COMSIG_MOB_GHOSTIZED, COMSIG_LIVING_DEATH))

/datum/antagonist/brother/antag_panel_data()
	return "Conspirators : [get_brother_names()]"

// monkestation start: refactor to use [get_base_preview_icon] for better midround polling images
/datum/antagonist/brother/get_base_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new
	var/datum/color_palette/generic_colors/located = brother1.dna.color_palettes[/datum/color_palette/generic_colors]

	located.ethereal_color = GLOB.color_list_ethereal["Faint Red"]
	brother1.set_species(/datum/species/ethereal)

	brother2.dna.features["moth_antennae"] = "Plain"
	brother2.dna.features["moth_markings"] = "None"
	brother2.dna.features["moth_wings"] = "Plain"
	brother2.set_species(/datum/species/moth)

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	var/icon/blood1_icon = icon('icons/effects/blood.dmi', "maskblood")
	blood1_icon.Blend(COLOR_BLOOD, ICON_MULTIPLY)
	brother1_icon.Blend(blood1_icon, ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist/consistent, brother2)
	var/icon/blood2_icon = icon('icons/effects/blood.dmi', "uniformblood")
	blood2_icon.Blend(COLOR_BLOOD, ICON_MULTIPLY)
	brother2_icon.Blend(blood2_icon, ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)

	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return final_icon

/datum/antagonist/brother/get_preview_icon()
	return finish_preview_icon(get_base_preview_icon())
// monkestation end

/datum/antagonist/brother/proc/get_brother_names(add_span = FALSE)
	var/list/names = list()
	for(var/datum/mind/brother as anything in team.members - owner)
		names += add_span ? span_name(brother.name) : brother.name
	return english_list(names)

/datum/antagonist/brother/greet()
	to_chat(owner.current, span_alertsyndie("You are the [owner.special_role]."))
	owner.announce_objectives()

/datum/antagonist/brother/proc/finalize_brother()
	play_stinger()
	team.update_name()

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	var/datum/team/brother_team/team = new
	team.add_member(new_owner)
	team.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother, team)
	team.update_name()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into a blood brother.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into a blood brother.")

/datum/antagonist/brother/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/brother/antag_token(datum/mind/hosts_mind, mob/spender)
	var/datum/team/brother_team/team = new
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/job/assistant)
		var/datum/mind/new_mind = new_mob.mind
		team.add_member(new_mind)
		team.forge_brother_objectives()
		new_mind.add_antag_datum(/datum/antagonist/brother, team)
	else
		team.add_member(hosts_mind)
		team.forge_brother_objectives()
		hosts_mind.add_antag_datum(/datum/antagonist/brother, team)

/datum/antagonist/brother/proc/communicate(message)
	if(!istext(message) || !length(message) || QDELETED(owner) || QDELETED(team))
		return
	owner.current.log_talk(html_decode(message), LOG_SAY, tag = "blood brother")
	var/name_rank = "Big Brother"
	if(brotherRank > 0)
		name_rank = ""
		for (var/littleness in 2 to brotherRank)
			name_rank += "Little "
		name_rank += "Brother"
	var/formatted_msg = "<span class='[team.color]'><b><i>\[Blood Bond\]</i> [span_name("[name_rank]: [owner.name]")]</b>: [message]</span>"
	for(var/datum/mind/brother as anything in team.members)
		var/mob/living/target = brother.current
		if(QDELETED(target))
			continue
		if(brother != owner)
			target.balloon_alert(target, "you hear a voice")
			target.playsound_local(get_turf(target), 'goon/sounds/misc/talk/radio_ai.ogg', vol = 25, vary = FALSE, pressure_affected = FALSE, use_reverb = FALSE)
		to_chat(target, formatted_msg, type = MESSAGE_TYPE_RADIO, avoid_highlighting = (brother == owner))
	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, owner.current)
		to_chat(dead_mob, "[link] [formatted_msg]", type = MESSAGE_TYPE_RADIO)

/datum/antagonist/brother/proc/on_mob_successful_flashed_carbon(mob/living/source, mob/living/carbon/flashed, obj/item/assembly/flash/flash)
	//SIGNAL_HANDLER

	if (flashed.stat == DEAD)
		return

	if (get_conversions_left() <= 0)
		return

	if (flashed.stat != CONSCIOUS)
		flashed.balloon_alert(source, "unconscious!")
		return

	if (isnull(flashed.mind) || !GET_CLIENT(flashed))
		flashed.balloon_alert(source, "[flashed.p_their()] mind is vacant!")
		return

	// monkestation edit: dont try to convert banned people
	if(is_banned_from(flashed.ckey, list(ROLE_BROTHER, ROLE_SYNDICATE)))
		flashed.balloon_alert(source, "cannot become brother!")
		return
	// monkestation end

	for(var/datum/objective/brother_objective as anything in source.mind.get_all_objectives())
		// If the objective has a target, are we flashing them?
		if(flashed == brother_objective.target?.current)
			flashed.balloon_alert(source, "that's your target!")
			return

	if (flashed.mind.has_antag_datum(/datum/antagonist/brother) || flashed.mind.enslaved_to)
		flashed.balloon_alert(source, "[flashed.p_theyre()] loyal to someone else!")
		return

	// monkestation edit: TRAIT_UNCONVERTABLE and remove hardcoded security check
	if (HAS_MIND_TRAIT(flashed, TRAIT_UNCONVERTABLE))
		flashed.balloon_alert(source, "[flashed.p_they()] resist!")
		return

	// A mindshield only blocks conversion unless they're restrained with unprotected eyes
	var/compromising_shield = HAS_TRAIT(flashed, TRAIT_MINDSHIELD)
	if (compromising_shield && (!HAS_TRAIT(flashed, TRAIT_RESTRAINED) || flashed.get_eye_protection() > FLASH_PROTECTION_NONE))
		flashed.balloon_alert(source, "[flashed.p_they()] resist!")
		return

	if (flashed in team.rejected_brothers)
		flashed.balloon_alert(source, "[flashed.p_they()] have rejected you before")
		return

	if (compromising_shield && !compromise_mindshield(source, flashed))
		return

	//The first BB flash against someone should sleep them. They get a popup if they want to join the BB team or not. If they say no they cant be BB flashed anymore
	flashed.SetSleeping(30 SECONDS)
	join_brother_flashed_popup(source, flashed, flash)

/// Pushes past a restrained target's mindshield, leaving it in place. Returns FALSE if interrupted.
/datum/antagonist/brother/proc/compromise_mindshield(mob/living/source, mob/living/carbon/flashed)
	if (compromising)
		return FALSE
	compromising = TRUE
	flashed.balloon_alert(source, "compromising mindshield")
	var/success = do_after(source, mindshield_compromise_time, flashed, extra_checks = CALLBACK(src, PROC_REF(can_keep_compromising), flashed), hidden = TRUE)
	compromising = FALSE
	if (success)
		return TRUE
	if (!QDELETED(flashed) && !HAS_TRAIT(flashed, TRAIT_RESTRAINED))
		flashed.balloon_alert(source, "[flashed.p_they()] broke free!")
	else
		flashed.balloon_alert(source, "Interrupted!")
	return FALSE

/// Hacks a cloning console to clone a dead brother, with no record left behind.
/datum/antagonist/brother/proc/hack_cloning_console(obj/machinery/computer/cloning/console)
	var/mob/living/hacker = owner.current
	if(!istype(hacker) || hacking_cloner || QDELETED(console))
		return
	if(!LAZYLEN(console.pods))
		console.balloon_alert(hacker, "no cloning pod linked!")
		return

	hacking_cloner = TRUE
	console.balloon_alert(hacker, "hacking...")
	var/success = do_after(hacker, 5 SECONDS, console, hidden = TRUE)
	hacking_cloner = FALSE
	if(!success)
		console.balloon_alert(hacker, "hack failed!")
		return

	var/list/brothers = list()
	for(var/datum/mind/member as anything in team.members - owner)
		var/dead = member.current?.stat == DEAD
		brothers["[member.name] ([dead ? "dead" : "alive"])"] = member
	if(!length(brothers))
		console.balloon_alert(hacker, "no brothers to clone")
		return

	var/choice = tgui_input_list(hacker, "Which of your brothers do you want to clone?", "Blood Bond Cloning", brothers)
	if(isnull(choice) || QDELETED(console) || !hacker.Adjacent(console))
		return
	clone_brother(hacker, console, brothers[choice])

/// Reads what's needed to clone a body, ignoring what blocks the scanner (husk, bad DNA, species, neurons). Null if unreadable.
/datum/antagonist/brother/proc/get_clone_data(mob/living/carbon/human/body)
	if(QDELETED(body) || !ishuman(body))
		return null
	var/datum/dna/old_dna = body.has_dna()
	if(!istype(old_dna))
		return null
	var/datum/dna/copied_dna = new()
	old_dna.copy_dna(copied_dna, COPY_DNA_SE|COPY_DNA_SPECIES)
	var/list/mutations = list()
	for(var/datum/mutation/mutation in old_dna.mutations)
		var/list/valid_sources = mutation.sources & GLOB.standard_mutation_sources
		if(!length(valid_sources))
			continue
		var/datum/mutation/added_mutation = mutation.make_copy()
		added_mutation.sources = valid_sources.Copy()
		mutations += added_mutation
	var/list/quirks = list()
	for(var/datum/quirk/quirk as anything in body.quirks)
		if(quirk.quirk_flags & QUIRK_DONT_CLONE)
			continue
		quirks[quirk.type] = quirk.clone_data()
	var/obj/item/card/id/id_card = body.get_idcard(TRUE)
	return list(
		"name" = body.real_name,
		"dna" = copied_dna,
		"mutations" = mutations,
		"quirks" = quirks,
		"factions" = body.faction.Copy(),
		"underwear" = body.underwear,
		"undershirt" = body.undershirt,
		"socks" = body.socks,
		"account" = id_card?.registered_account,
		"traumas" = body.get_traumas(),
	)

/// Saves clone data for when the body is gone
/datum/antagonist/brother/proc/take_clone_snapshot(mob/living/carbon/human/body)
	var/list/data = get_clone_data(body)
	if(!data)
		return
	// Traumas belong to the brain that's about to be destroyed
	data["traumas"] = list()
	clone_snapshot = data

/// Clones a dead brother through a hacked console, from the body or the snapshot if it's gone.
/datum/antagonist/brother/proc/clone_brother(mob/living/hacker, obj/machinery/computer/cloning/console, datum/mind/brother_mind)
	if(!(brother_mind in team.members) || brother_mind == owner)
		return
	var/datum/antagonist/brother/their_bond = brother_mind.has_antag_datum(/datum/antagonist/brother)
	if(!their_bond)
		return
	var/mob/living/body = brother_mind.current
	// A missing body counts as dead
	if(!QDELETED(body) && body.stat != DEAD)
		console.balloon_alert(hacker, "[brother_mind.name] isn't dead")
		return
	// Defib blacklist is ignored, suicides aren't
	if(!QDELETED(body) && HAS_TRAIT(body, TRAIT_SUICIDED))
		console.balloon_alert(hacker, "[brother_mind.name] won't respond")
		return
	// Prefer the body, fall back to the snapshot
	var/list/data = their_bond.get_clone_data(body) || their_bond.clone_snapshot
	if(!data)
		console.balloon_alert(hacker, "nothing left to clone from")
		return
	var/obj/machinery/clonepod/pod = console.GetAvailablePod(brother_mind)
	if(!pod)
		console.balloon_alert(hacker, "no free cloning pod!")
		return

	var/result = pod.growclone(data["name"], data["mutations"], data["underwear"], data["undershirt"], data["socks"], data["dna"], "[REF(brother_mind)]", data["factions"], data["quirks"], data["account"], data["traumas"], FALSE, TRUE)
	if(!(result & CLONING_SUCCESS))
		console.balloon_alert(hacker, "unable to clone!")
		return
	// A bloodsucker back from Final Death gets its curse back
	var/datum/antagonist/bloodsucker/bloodsucker = brother_mind.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsucker?.restore_from_final_death()
	log_cloning("[key_name(hacker)] used a hacked cloning console to clone their blood brother [key_name(brother_mind)] at [AREACOORD(console)]. Pod: [pod] at [AREACOORD(pod)].")
	console.balloon_alert(hacker, "cloning started")

/// Whether the mindshield can still be compromised
/datum/antagonist/brother/proc/can_keep_compromising(mob/living/carbon/flashed)
	return !QDELETED(flashed) && flashed.stat == CONSCIOUS && HAS_TRAIT(flashed, TRAIT_RESTRAINED) && flashed.get_eye_protection() <= FLASH_PROTECTION_NONE && get_conversions_left() > 0

/datum/antagonist/brother/proc/set_brother_rank(newRank)
	brotherRank = newRank

/// How many more people this brother's team can convert.
/datum/antagonist/brother/proc/get_conversions_left()
	return team ? max(team.brothers_left, 0) : 0

/datum/antagonist/brother/get_admin_commands()
	. = ..()
	.["Adjust conversion charges"] = CALLBACK(src, PROC_REF(admin_adjust_conversions))

/// Lets an admin set how many more people this brother's team can convert.
/datum/antagonist/brother/proc/admin_adjust_conversions(mob/admin)
	if(QDELETED(team))
		return
	var/old_charges = get_conversions_left()
	var/new_charges = tgui_input_number(admin, "How many more people should [team.name] be able to convert? Currently [old_charges].", "Conversion charges", old_charges, 10, 0)
	if(isnull(new_charges) || QDELETED(team) || new_charges == old_charges)
		return
	team.brothers_left = new_charges
	// Turn the conversion ability on or off for the whole team
	for(var/datum/mind/member as anything in team.members)
		var/datum/antagonist/brother/member_datum = member.has_antag_datum(/datum/antagonist/brother)
		if(new_charges > 0)
			member_datum?.start_converting()
		else
			member_datum?.stop_converting()
	message_admins("[key_name_admin(admin)] set the conversion charges of [team.name] from [old_charges] to [new_charges].")
	log_admin("[key_name(admin)] set the conversion charges of [team.name] from [old_charges] to [new_charges].")

/// Gives starting brothers the contraband security HUD head revs get
/datum/antagonist/brother/proc/give_security_hud()
	var/mob/living/carbon/carbon_owner = owner.current
	if(!istype(carbon_owner) || carbon_owner.get_organ_slot(ORGAN_SLOT_HUD))
		return
	var/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate/hud = new()
	hud.Insert(carbon_owner)
	given_hud = hud
	if(carbon_owner.get_quirk(/datum/quirk/body_purist))
		to_chat(carbon_owner, span_boldnotice("Being a body purist, you would never accept cybernetic implants. Upon hearing this, your employers signed you up for a special program, which... for some odd reason, you just can't remember... either way, the program must have worked, because you have gained the ability to keep track of who is mindshield-implanted. Mindshielded crew can't be converted with your normal flash, but with a bit of force... you can compromise mindshields. Examine a flash for more details."))
	else
		to_chat(carbon_owner, span_boldnotice("Your eyes have been implanted with a cybernetic security HUD which will help you keep track of who is mindshield-implanted. Mindshielded crew can't be converted with your normal flash, but with a bit of force... you can compromise mindshields. Examine a flash for more details."))

/datum/antagonist/brother/proc/remove_security_hud()
	if(!given_hud)
		return
	var/mob/living/carbon/carbon_owner = owner.current
	if(istype(carbon_owner) && given_hud.owner == carbon_owner)
		given_hud.Remove(carbon_owner)
	QDEL_NULL(given_hud)

/datum/antagonist/brother/proc/join_brother_flashed_popup(mob/living/source, mob/living/carbon/flashed, obj/item/assembly/flash/flash)
	if(popup)
		return
	var/response = "Become a brother"
	// Security and command had to be restrained or unshielded to get this far, so they get no say
	if(flashed.mind.assigned_role.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_COMMAND))
		to_chat(flashed, span_big(span_hypnophrase("With nothing left to hold them back, the visions of a life with [source] as your brother overwhelm you.")))
	else
		popup = TRUE
		response = tgui_alert(flashed, "Visions of a life with [source] as your brother pass through your mind.", "Become brothers?", list("Become a brother", "Reject Brotherhood"), timeout = 30 SECONDS)
		popup = FALSE

	if(response == "Become a brother")
		// Someone may have used the last conversion meanwhile
		if (get_conversions_left() <= 0)
			flashed.balloon_alert(source, "no conversions left!")
			flashed.SetSleeping(0 SECONDS)
			return
		if (!team.add_brother(flashed, key_name(source))) // Shouldn't happen given the former, more specific checks but just in case
			flashed.balloon_alert(source, "failed!")
			return
		source.log_message("converted [key_name(flashed)] to blood brother", LOG_ATTACK)
		flashed.log_message("was converted by [key_name(source)] to blood brother", LOG_ATTACK)
		log_game("[key_name(flashed)] was made into a blood brother by [key_name(source)]", list(
			"converted" = flashed,
			"converted by" = source,
		))
		flashed.mind.add_memory( \
			/datum/memory/recruited_by_blood_brother, \
			protagonist = flashed, \
			antagonist = owner.current, \
		)
		flashed.balloon_alert(source, "converted")

		// Nobody can convert once the team is out of conversions
		if(get_conversions_left() <= 0)
			for(var/datum/mind/member as anything in team.members)
				var/datum/antagonist/brother/member_datum = member.has_antag_datum(/datum/antagonist/brother)
				member_datum?.stop_converting()
	else
		team.rejected_brothers.Add(flashed)
		source.balloon_alert(source, "[flashed.name] has rejected you")
		to_chat(flashed, span_big(span_hypnophrase("You wake up forgetting why exactly you fell asleep, and the brotherly visions you had during your sleep")))

	flashed.SetSleeping(0 SECONDS)
