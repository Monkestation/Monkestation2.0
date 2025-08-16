//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

GLOBAL_VAR_INIT(gauntlet_snapped, FALSE)
GLOBAL_VAR_INIT(gauntlet_equipped, FALSE)
GLOBAL_LIST_INIT(badmin_stones, list(SYNDIE_STONE, BLUESPACE_STONE, SUPERMATTER_STONE, LAG_STONE, CLOWN_STONE, GHOST_STONE))
GLOBAL_LIST_INIT(badmin_stone_types, list(
		SYNDIE_STONE = /obj/item/badmin_stone/syndie,
		BLUESPACE_STONE = /obj/item/badmin_stone/bluespace,
		SUPERMATTER_STONE = /obj/item/badmin_stone/supermatter,
		LAG_STONE = /obj/item/badmin_stone/lag,
		CLOWN_STONE = /obj/item/badmin_stone/clown,
		GHOST_STONE = /obj/item/badmin_stone/ghost))
GLOBAL_LIST_INIT(badmin_stone_weights, list(
		SYNDIE_STONE = list(
			"Head of Security" = 70,
			"Captain" = 60,
			"Security Officer" = 20,
			"Head of Personnel" = 15
		),
		BLUESPACE_STONE = list(
			"Research Director" = 60,
			"Scientist" = 20,
			"Mime" = 15
		),
		SUPERMATTER_STONE = list(
			"Chief Engineer" = 60,
			"Station Engineer" = 30,
			"Atmospheric Technician" = 30
		),
		LAG_STONE = list(
			"Quartermaster" = 40,
			"Cargo Technician" = 20
		),
		GHOST_STONE = list(
			"Chief Medical Officer" = 50,
			"Chaplain" = 50
		),
		CLOWN_STONE = list(
			"Clown" = 100
		)
	))
GLOBAL_VAR_INIT(telescroll_time, 0)

/obj/item/badmin_gauntlet
	name = "Badmin Gauntlet"
	icon = 'monkestation/icons/obj/infinity.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/righthand.dmi'
	icon_state = "gauntlet"
	force = 25
	armour_penetration = 70
	var/badmin = FALSE
	var/next_flash = 0
	var/flash_index = 1
	var/locked_on = FALSE
	var/stone_mode = null
	var/ert_canceled = FALSE
	var/list/stones = list()
	var/list/spells = list()
	var/datum/martial_art/cqc/martial_art
	var/mutable_appearance/flashy_aura
	var/mob/living/carbon/last_aura_holder


/obj/item/badmin_gauntlet/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	martial_art = new
	flashy_aura = mutable_appearance('monkestation/icons/obj/infinity.dmi', "aura", -MUTATIONS_LAYER)
	update_icon()
	spells += new /datum/action/cooldown/spell/infinity/regenerate_gauntlet
	spells += new /datum/action/cooldown/spell/aoe/shockwave
	spells += new /datum/action/cooldown/spell/infinity/syndie_bullcharge/gauntlet
	spells += new /datum/action/cooldown/spell/infinity/gauntlet_jump

/obj/item/badmin_gauntlet/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/badmin_gauntlet/process()
	if(!fully_assembled())
		return
	if(world.time < next_flash)
		return
	if(!iscarbon(loc))
		return
	var/mob/living/carbon/carbon_loc = loc
	if(last_aura_holder && carbon_loc != last_aura_holder)
		last_aura_holder.cut_overlay(flashy_aura)
	last_aura_holder = carbon_loc
	carbon_loc.cut_overlay(flashy_aura)
	var/static/list/stone_colors = list("#ff0130", "#266ef6", "#ECF332", "#FFC0CB", "#20B2AA", "#e429f2")
	var/index = (flash_index <= 6) ? flash_index : 1
	flashy_aura.color = stone_colors[index]
	carbon_loc.add_overlay(flashy_aura)
	flash_index = index + 1
	next_flash = world.time + 5

/obj/item/badmin_gauntlet/examine(mob/user)
	. = ..()
	for(var/obj/item/badmin_stone/stone in stones)
		to_chat(user, span_boldnotice("[stone.name] mode"))
		. += stone.examine(user)

/obj/item/badmin_gauntlet/ex_act(severity, target)
	return

/obj/item/badmin_gauntlet/proc/get_stone(stone_type)
	for(var/obj/item/badmin_stone/I in stones)
		if(I.stone_type == stone_type)
			return I
	return

/obj/item/badmin_gauntlet/proc/do_snap(mob/living/snapee)
	var/dust_time = rand(5 SECONDS, 10 SECONDS)
	var/dust_sound = pick(
		'monkestation/sound/effects/snap/snap1.wav',
		'monkestation/sound/effects/snap/snap2.wav',
		'monkestation/sound/effects/snap/snap3.wav',
		'monkestation/sound/effects/snap/snap4.wav',
		'monkestation/sound/effects/snap/snap5.wav',
		'monkestation/sound/effects/snap/snap6.wav')
	if(prob(25))
		addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(to_chat), snapee, span_danger("You don't feel so good...")), dust_time - 3 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(playsound), snapee, dust_sound, 100, TRUE), dust_time-2.5)
	addtimer(CALLBACK(snapee, TYPE_PROC_REF(/mob/living, dust), TRUE), dust_time)

/obj/item/badmin_gauntlet/proc/do_the_snap()
	var/mob/living/snapper = usr
	var/list/players = GLOB.player_list.Copy()
	shuffle_inplace(players)
	var/players_to_wipe = FLOOR((players.len-1)/2, 1)
	var/players_wiped = 0
	to_chat(world, span_userdanger("You feel as if something big has happened."))
	for(var/mob/living/living_player in players)
		if(players_wiped >= players_to_wipe)
			break
		if(snapper == living_player || !living_player.ckey)
			continue
		do_snap(living_player)
		players_wiped++
	log_game("[key_name(snapper)] snapped, wiping out [players_wiped] players.")
	message_admins("[key_name(snapper)] snapped, wiping out [players_wiped] players.")

/obj/item/badmin_gauntlet/proc/get_weighted_chances(list/job_list, list/blacklist)
	var/list/jobs = list()
	var/list/weighted_list = list()
	for(var/A in job_list)
		jobs += A
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && !considered_afk(M) && considered_alive(M, TRUE) && is_station_level(M.current.z) && !(M.current in blacklist) && (M.assigned_role in jobs))
			weighted_list[M.current] = job_list[M.assigned_role]
	return weighted_list

/obj/item/badmin_gauntlet/proc/make_stonekeepers(mob/living/current_user)
	var/list/has_a_stone = list(current_user)
	for(var/stone in GLOB.badmin_stones)
		var/list/to_get_stones = get_weighted_chances(GLOB.badmin_stone_weights[stone], has_a_stone)
		var/mob/living/L
		if(LAZYLEN(to_get_stones))
			L = pick_weight(to_get_stones)
		else
			var/list/minds = list()
			for(var/datum/mind/M in SSticker.minds)
				if(M.current && !considered_afk(M) && considered_alive(M, TRUE) && is_station_level(M.current.z) && !(M.current in has_a_stone))
					minds += M
			if(LAZYLEN(minds))
				var/datum/mind/M = pick(minds)
				L = M.current
		var/stone_type = GLOB.badmin_stone_types[stone]
		var/obj/item/badmin_stone/IS = new stone_type(L ? get_turf(L) : null)
		if(L && istype(L))
			has_a_stone += L
			var/datum/antagonist/stonekeeper/SK = L.mind.add_antag_datum(/datum/antagonist/stonekeeper)
			SK = L.mind.has_antag_datum(/datum/antagonist/stonekeeper)
			var/datum/objective/stonekeeper/SKO = new
			SKO.stone = IS
			SKO.owner = L.mind
			SKO.update_explanation_text()
			SK.objectives += SKO
			L.mind.announce_objectives()
			L.put_in_hands(IS)
			L.equip_to_slot(IS, ITEM_SLOT_BACKPACK)


/obj/item/badmin_gauntlet/proc/fully_assembled()
	for(var/stone in GLOB.badmin_stones)
		if(!get_stone(stone))
			return FALSE
	return TRUE

/obj/item/badmin_gauntlet/proc/get_stone_color(stone_type)
	var/obj/item/badmin_stone/IS = get_stone(stone_type)
	if(IS && istype(IS))
		return IS.color
	return "#DC143C"

/obj/item/badmin_gauntlet/proc/OnEquip(mob/living/user)
	for(var/datum/action/cooldown/spell/spell in spells)
		spell.Grant(user)
	user.AddComponent(/datum/component/stationloving)
	var/datum/antagonist/wizard/wizard = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(wizard && istype(wizard))
		for(var/datum/objective/objective in wizard.objectives)
			wizard.objectives -= objective
			qdel(objective)
		wizard.objectives += new /datum/objective/snap
		user.mind.announce_objectives()
	user.move_resist = INFINITY

/obj/item/badmin_gauntlet/proc/OnUnquip(mob/living/user)
	user.cut_overlay(flashy_aura)
	var/datum/component/stationloving/stationloving = user.GetComponent(/datum/component/stationloving)
	if(stationloving)
		user.TakeComponent(stationloving)
	for(var/datum/action/cooldown/spell/spell in spells)
		spell.Remove(user)
	user.move_resist = initial(user.move_resist)
	take_abilities(user)

/obj/item/badmin_gauntlet/pickup(mob/user)
	. = ..()
	if(locked_on && isliving(user))
		OnEquip(user)
		visible_message(span_danger("The Badmin Gauntlet attaches to [user]'s hand!."))

/obj/item/badmin_gauntlet/dropped(mob/user)
	. = ..()
	if(locked_on && isliving(user))
		OnUnquip(user)
		visible_message(span_danger("The Badmin Gauntlet falls off of [user]."))

/obj/item/badmin_gauntlet/proc/take_abilities(mob/living/user)
	for(var/obj/item/badmin_stone/stone in stones)
		stone.remove_abilities(user, TRUE)
		stone.take_visual_effects(user)
		stone.take_status_effect(user)
	for(var/datum/action/cooldown/spell/spell in spells)
		spell.Remove(user)
	if(ishuman(user))
		martial_art.remove(user)

/obj/item/badmin_gauntlet/proc/give_abilities(mob/living/user)
	var/obj/item/badmin_stone/syndie = get_stone(SYNDIE_STONE)
	if(!syndie)
		for(var/datum/action/cooldown/spell/spell in spells)
			spell.Grant(user)
	if(ishuman(user))
		if(stone_mode != SYNDIE_STONE && (!get_stone(stone_mode) || !stone_mode))
			martial_art.teach(user)
	if(syndie)
		syndie.give_abilities(user, TRUE)
	if(fully_assembled())
		for(var/obj/item/badmin_stone/stone in stones)
			if(stone && istype(stone) && stone.stone_type != SYNDIE_STONE)
				stone.give_abilities(user, TRUE)
	else
		var/obj/item/badmin_stone/stone = get_stone(stone_mode)
		if(stone && istype(stone))
			stone.give_visual_effects(user)
			if(stone_mode != SYNDIE_STONE)
				stone.give_abilities(user, TRUE)

/obj/item/badmin_gauntlet/proc/UpdateAbilities(mob/living/user)
	take_abilities(user)
	give_abilities(user)

/obj/item/badmin_gauntlet/update_icon()
	. = ..()
	cut_overlays()
	var/index = 1
	var/image/veins = image(icon = 'monkestation/icons/obj/infinity.dmi', icon_state = "glow-overlay")
	veins.color = get_stone_color(stone_mode)
	add_overlay(veins)
	for(var/obj/item/badmin_stone/stone in stones)
		var/I = index
		if(stone.stone_type == stone_mode)
			I = 0
		var/image/O = image(icon = 'monkestation/icons/obj/infinity.dmi', icon_state = "[I]-stone")
		O.color = stone.color
		add_overlay(O)
		index++

/obj/item/badmin_gauntlet/proc/AttackThing(mob/user, atom/target)
	. = FALSE
	if(istype(target, /obj/vehicle/sealed/mecha))
		. = TRUE
		var/obj/vehicle/sealed/mecha/mech = target
		mech.take_damage(17.5)
	else if(istype(target, /obj/structure/safe))
		. = TRUE
		var/obj/structure/safe/safe = target
		user.visible_message(span_danger("[user] begins to pry open [safe]!"), span_notice("We begin to pry open [safe]..."))
		if(do_after(user, 35, target = safe))
			user.visible_message(span_danger("[user] pries open [safe]!"), span_notice("We pry open [safe]!"))
			safe.open = TRUE
			safe.locked = FALSE
			safe.update_icon()
			safe.updateUsrDialog()
	else if(isclosedturf(target))
		var/turf/closed/target_turf = target
		if(istype(get_area(target_turf), /area/centcom/wizard_station))
			to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to start smashing down walls."))
			return FALSE
		if(!get_stone(SYNDIE_STONE))
			. = TRUE
			user.visible_message(span_danger("[user] begins to charge up a punch..."), span_notice("We begin to charge a punch..."))
			if(do_after(user, 15, target = target_turf))
				playsound(target_turf, 'sound/effects/bang.ogg', 50, 1)
				user.visible_message(span_danger("[user] punches down [target_turf]!"))
				target_turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		else
			playsound(target_turf, 'sound/effects/bang.ogg', 50, 1)
			user.visible_message(span_danger("[user] punches down [target_turf]!"))
			target_turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/target_closet = target
		. = TRUE
		target_closet.broken = TRUE
		target_closet.locked = FALSE
		target_closet.open()
		target_closet.update_icon()
		playsound(target_closet, 'sound/effects/bang.ogg', 50, 1)
		user.visible_message(span_danger("[user] smashes open [target_closet]!"))
	else if(istype(target, /obj/structure/table) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
		var/obj/structure/target_structure = target
		if(istype(get_area(target_structure), /area/centcom/wizard_station))
			to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to start smashing down stuff."))
			return FALSE
		. = TRUE
		playsound(target_structure, 'sound/effects/bang.ogg', 50, 1)
		user.visible_message(span_danger("[user] smashes [target_structure]!"))
		target_structure.take_damage(INFINITY)

/obj/item/badmin_gauntlet/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!locked_on)
		return ..()
	if(!isliving(user))
		return ..()
	var/obj/item/badmin_stone/stone = get_stone(stone_mode)
	if(!stone || !istype(stone))
		switch(user.istate)
			if(ISTATE_SECONDARY)
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.disarm_act(user, target)
			if(ISTATE_HARM)
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.harm_act(user, target)
				if(proximity_flag)
					AttackThing(user, target)
			else
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.help_act(user, target)
		return
	switch(user.istate)
		if(ISTATE_SECONDARY)
			stone.disarm_act(target, user, proximity_flag)
		if(ISTATE_HARM)
			stone.harm_act(target, user, proximity_flag)
		else
			stone.help_act(target, user, proximity_flag)

/obj/item/badmin_gauntlet/attack_self(mob/living/user)
	if(!istype(user))
		return
	if(!locked_on)
		var/prompt = alert("Would you like to truly wear the Badmin Gauntlet? You will be unable to remove it!", "Confirm", "Yes", "No")
		if(prompt == "Yes")
			if(locked_on)
				return
			user.dropItemToGround(src)
			if(user.put_in_hands(src))
				locked_on = TRUE
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					H.set_species(/datum/species/ganymede)
					H.dropItemToGround(H.wear_suit)
					H.dropItemToGround(H.w_uniform)
					H.dropItemToGround(H.head)
					H.dropItemToGround(H.back)
					H.dropItemToGround(H.shoes)
					var/obj/item/clothing/head/ganymedian/ganymedian_helmet = new(get_turf(user))
					var/obj/item/clothing/suit/ganymedian/ganymedian_armor = new(get_turf(user))
					var/obj/item/clothing/under/ganymedian/ganymedian_jumpsuit = new(get_turf(user))
					var/obj/item/clothing/shoes/ganymedian/ganymedian_shoes = new(get_turf(user))
					var/obj/item/tank/jetpack/ganypack/ganymedian_jetpack = new(get_turf(user))
					var/obj/item/teleportation_scroll/scroll = new(get_turf(user))
					H.equip_to_appropriate_slot(ganymedian_helmet)
					H.equip_to_appropriate_slot(ganymedian_armor)
					H.equip_to_appropriate_slot(ganymedian_jumpsuit)
					H.equip_to_appropriate_slot(ganymedian_shoes)
					H.equip_to_appropriate_slot(scroll)
					H.equip_to_slot(ganymedian_jetpack, ITEM_SLOT_BACK)
				GLOB.gauntlet_equipped = TRUE
				for(var/obj/item/spellbook/SB in world)
					if(SB.owner == user)
						qdel(SB)
				user.apply_status_effect(/datum/status_effect/agent_pinpointer/gauntlet)
				if(!badmin)
					if(LAZYLEN(GLOB.wizardstart))
						user.forceMove(pick(GLOB.wizardstart))
					priority_announce(
						"A Wizard has declared that he will wipe out half the universe with the Badmin Gauntlet!\n\
						Stones have been scattered across the station. Protect anyone who holds one!\n\
						We've allocated a large amount of resources to you, for protecting the Stones:\n\
						Cargo has been given $50k to spend\n\
						Science has been given 50k techpoints, and a large amount of minerals.\n\
						In addition, we've moved your Artifical Intelligence unit to your Bridge, and reinforced your telecommunications machinery.",
						title = "Declaration of War",
						sound = 'monkestation/sound/misc/wizard_wardec.ogg'
					)
					var/datum/bank_account/cargo_moneys = SSeconomy.get_dep_account(ACCOUNT_CAR)
					var/datum/bank_account/sci_moneys = SSeconomy.get_dep_account(ACCOUNT_SCI)
					if(cargo_moneys)
						cargo_moneys.adjust_money(50000)
					if(sci_moneys)
						sci_moneys.adjust_money(50000)
						SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_GENERIC, 50000)
					var/obj/structure/closet/supplypod/bluespacepod/sci_pod = new()
					sci_pod.explosionSize = list(0,0,0,0)
					var/list/materials_to_give_science = list(
						/obj/item/stack/sheet/iron,
						/obj/item/stack/sheet/plasteel,
						/obj/item/stack/sheet/mineral/diamond,
						/obj/item/stack/sheet/mineral/uranium,
						/obj/item/stack/sheet/mineral/plasma,
						/obj/item/stack/sheet/mineral/gold,
						/obj/item/stack/sheet/mineral/silver,
						/obj/item/stack/sheet/glass,
						/obj/item/stack/ore/bluespace_crystal/artificial
					)
					for(var/mat in materials_to_give_science)
						var/obj/item/stack/sheet/sheet = new mat(sci_pod)
						sheet.amount = 50
						sheet.update_icon()
					var/list/sci_tiles = list()
					for(var/turf/turf_lab in get_area_turfs(/area/station/science/lab))
						if(!turf_lab.density)
							var/clear = TRUE
							for(var/obj/lab_obj in turf_lab)
								if(lab_obj.density)
									clear = FALSE
									break
							if(clear)
								sci_tiles += turf_lab
					if(LAZYLEN(sci_tiles))
						new /obj/effect/dumpeet_fall(get_turf(pick(sci_tiles)), sci_pod)
					for(var/obj/machinery/telecomms/telecomms in world)
						if(istype(get_area(telecomms), /area/station/tcommsat))
							telecomms.resistance_flags |= INDESTRUCTIBLE
					for(var/obj/machinery/power/apc/apc in world)
						if(istype(get_area(apc), /area/station/tcommsat))
							apc.resistance_flags |= INDESTRUCTIBLE
					var/list/bridge_tiles = list()
					for(var/turf/turf_bridge in get_area_turfs(/area/station/command/bridge))
						if(!turf_bridge.density)
							var/clear = TRUE
							for(var/obj/obj_bridge in turf_bridge)
								if(obj_bridge.density)
									clear = FALSE
									break
							if(clear)
								bridge_tiles += turf_bridge
					if(LAZYLEN(bridge_tiles))
						for(var/mob/living/silicon/ai/ai in GLOB.ai_list)
							var/obj/structure/closet/supplypod/bluespacepod/ai_pod = new
							ai.forceMove(ai_pod)
							ai.move_resist = MOVE_FORCE_NORMAL
							new /obj/effect/dumpeet_fall(get_turf(pick(bridge_tiles)), ai_pod)
					GLOB.telescroll_time = world.time + 10 MINUTES
					addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(to_chat), user, span_boldnotice("You can now teleport to the station.")), 10 MINUTES)
					addtimer(CALLBACK(src, PROC_REF(_call_revengers)), 25 MINUTES)
					to_chat(user, span_boldnotice("You need to wait 10 minutes before teleporting to the station."))
				to_chat(user, span_boldnotice("You can click on the pinpointer at the top right to track a stone."))
				to_chat(user, span_boldnotice("Examine a stone/the gauntlet to see what each intent does."))
				to_chat(user, span_boldnotice("You can smash walls, tables, grilles, windows, and safes on HARM intent."))
				to_chat(user, span_boldnotice("Be warned -- you may be mocked if you kill innocents, that does not bring balance!"))
				ADD_TRAIT(src, TRAIT_NODROP, GAUNTLET_TRAIT)
				visible_message(span_bolddanger("The badmin gauntlet clamps to [user]'s hand!"))
				for(var/datum/action/cooldown/spell/spell in spells)
					spell.Remove(user)
				UpdateAbilities(user)
				OnEquip(user)
				if(!badmin)
					make_stonekeepers(user)
			else
				to_chat(user, span_danger("You do not have an empty hand for the Badmin Gauntlet."))
		return
	if(!LAZYLEN(stones))
		to_chat(user, span_danger("You have no stones yet."))
		return
	var/list/gauntlet_radial = list()
	for(var/obj/item/badmin_stone/I in stones)
		var/image/IM = image(icon = I.icon, icon_state = I.icon_state)
		IM.color = I.color
		gauntlet_radial[I.stone_type] = IM
	if(!get_stone(SYNDIE_STONE))
		gauntlet_radial["none"] = image(icon = 'monkestation/icons/obj/infinity.dmi', icon_state = "none")
	var/chosen = show_radial_menu(user, src, gauntlet_radial, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	if(chosen)
		if(chosen == "none")
			stone_mode = null
		else
			stone_mode = chosen
		UpdateAbilities(user)
		update_icon()

/obj/item/badmin_gauntlet/Topic(href, list/href_list)
	. = ..()
	if(href_list["cancel"])
		if(!check_rights(R_ADMIN) || ert_canceled) // no href exploits for you, karma!
			return
		message_admins("[key_name_admin(usr)] cancelled the automatic Revengers ERT.")
		log_admin_private("[key_name(usr)] cancelled the automatic Revengers ERT.")
		ert_canceled = TRUE

/obj/item/badmin_gauntlet/proc/_call_revengers()
	message_admins("Revengers ERT being auto-called in 15 seconds (<a href='?src=[REF(src)];cancel=1'>CANCEL</a>)")
	addtimer(CALLBACK(src, PROC_REF(call_revengers)), 15 SECONDS)

/obj/item/badmin_gauntlet/proc/call_revengers()
	if(ert_canceled)
		return
	message_admins("The Revengers ERT has been auto-called.")
	log_game("The Revengers ERT has been auto-called.")

	var/datum/ert/revengers/ertemplate = new
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates("Do you wish to be an Revenger?", "deathsquad", null)
	var/teamSpawned = FALSE

	if(candidates.len > 0)
		//Pick the (un)lucky players
		var/numagents = min(ertemplate.teamsize,candidates.len)

		//Create team
		var/datum/team/ert/ert_team = new ertemplate.team
		if(ertemplate.rename_team)
			ert_team.name = ertemplate.rename_team

		//Asign team objective
		var/datum/objective/missionobj = new
		missionobj.team = ert_team
		missionobj.explanation_text = ertemplate.mission
		missionobj.completed = TRUE
		ert_team.objectives += missionobj
		ert_team.mission = missionobj

		var/list/spawnpoints = GLOB.emergencyresponseteamspawn
		while(numagents && candidates.len)
			if (numagents > spawnpoints.len)
				numagents--
				continue // This guy's unlucky, not enough spawn points, we skip him.
			var/spawnloc = spawnpoints[numagents]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/ERTOperative = new ertemplate.mobtype(spawnloc)
			ERTOperative.key = chosen_candidate.key

			ERTOperative.set_species(/datum/species/human)

			//Give antag datum
			var/datum/antagonist/ert/ert_antag

			if(numagents == 1)
				ert_antag = new ertemplate.leader_role
			else
				ert_antag = ertemplate.roles[WRAP(numagents,1,length(ertemplate.roles) + 1)]
				ert_antag = new ert_antag

			ERTOperative.mind.add_antag_datum(ert_antag,ert_team)
			ERTOperative.mind.assigned_role = ert_antag.name

			//Logging and cleanup
			log_game("[key_name(ERTOperative)] has been selected as an [ert_antag.name]")
			numagents--
			teamSpawned++

		if (teamSpawned)
			message_admins("Revengers ERT has auto-spawned with the mission: [ertemplate.mission]")

		//Open the Armory doors
		if(ertemplate.opendoors)
			for(var/obj/machinery/door/poddoor/ert/door in GLOB.airlocks)
				door.open()
				CHECK_TICK

/obj/item/badmin_gauntlet/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/badmin_stone))
		if(!locked_on)
			to_chat(user, span_notice("You need to wear the gauntlet first."))
			return
		var/obj/item/badmin_stone/stone = attacking_item
		if(!get_stone(stone.stone_type))
			user.visible_message(span_bolddanger("[user] drops the [stone] into the Badmin Gauntlet."))
			if(stone.stone_type == SYNDIE_STONE)
				force = 27.5
			stone.forceMove(src)
			stones += stone
			var/datum/component/stationloving/stationloving = stone.GetComponent(/datum/component/stationloving)
			if(stationloving)
				stationloving.RemoveComponentSource()
			UpdateAbilities(user)
			update_icon()
			if(fully_assembled() && !GLOB.gauntlet_snapped)
				var/datum/action/cooldown/spell/infinity/snap/snap = new
				snap.Grant(user)
				user.visible_message(
					span_userdanger("A massive surge of power courses through [user]. You feel as though your very existence is in danger!"),
					span_bolddanger("You have fully assembled the Badmin Gauntlet. You can use all stone abilities no matter the mode, and can SNAP using the ability.")
				)
			return
	return ..()

/obj/item/badmin_gauntlet/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE


/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/aoe/shockwave
	name = "Badmin Gauntlet: Shockwave"
	desc = "Stomp down and send out a slow-moving shockwave that is capable of knocking people down."
	background_icon_state = "bg_default"
	sound = 'sound/effects/bang.ogg'
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
	aoe_radius = 5
	cooldown_time = 25 SECONDS

/datum/action/cooldown/spell/aoe/shockwave/get_things_to_cast_on(atom/center)
	. = ..()
	var/list/things = list()
	for(var/mob/living/carbon/human/human in range(aoe_radius, center))
		if(human == owner)
			continue
		things += human

	return things

/datum/action/cooldown/spell/aoe/shockwave/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!ishuman(victim))
		return
	var/mob/living/carbon/human/human_victim = victim
	var/turf/victim_turf = get_turf(human_victim)
	new /obj/effect/temp_visual/gravpush(victim_turf)
	if(istype(human_victim.get_item_by_slot(ITEM_SLOT_FEET), /obj/item/clothing/shoes/magboots))
		var/obj/item/clothing/shoes/magboots/magboots = human_victim.shoes
		if(magboots.magpulse)
			return
	human_victim.visible_message(span_danger("[human_victim] is knocked down by a shockwave!"), span_bolddanger("A shockwave knocks you off your feet!"))
	human_victim.Paralyze(17.5)

/datum/action/cooldown/spell/infinity/regenerate_gauntlet
	name = "Badmin Gauntlet: Regenerate"
	desc = "Regenerate 2 health per second. Requires you to stand still."
	button_icon_state = "regenerate"
	background_icon_state = "bg_default"

/datum/action/cooldown/spell/infinity/regenerate_gauntlet/cast(atom/cast_on)
	. = ..()
	if(isliving(cast_on))
		var/mob/living/living_caster = cast_on
		if(living_caster.on_fire)
			to_chat(living_caster, span_notice("The fire interferes with your regeneration!"))
			reset_spell_cooldown()
			return
		if(living_caster.stat == DEAD)
			to_chat(living_caster, span_notice("You can't regenerate out of death."))
			reset_spell_cooldown()
			return
		while(do_after(living_caster, 10, living_caster))
			living_caster.visible_message(span_notice("[living_caster]'s wounds heal!"))
			living_caster.heal_overall_damage(2, 2, 2, null, TRUE)
			living_caster.adjustToxLoss(-2)
			living_caster.adjustOxyLoss(-2)
			if(living_caster.getBruteLoss() + living_caster.getFireLoss() < 1)
				to_chat(cast_on, span_notice("You are fully healed."))
				return

/datum/action/cooldown/spell/infinity/syndie_bullcharge/gauntlet
	name = "Badmin Gauntlet: Bull Charge"
	desc = "Imbue yourself with power, and charge forward, smashing through anyone in your way!"
	background_icon_state = "bg_default"
	sound = 'sound/magic/repulse.ogg'
	cooldown_time = 25 SECONDS
	charge_strong = FALSE

/datum/action/cooldown/spell/infinity/gauntlet_jump
	name = "Badmin Gauntlet: Super Jump"
	desc = "With a bit of startup time, leap across the station to wherever you'd like!"
	background_icon_state = "bg_default"
	button_icon_state = "jump"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/infinity/gauntlet_jump/cast(atom/cast_on)
	. = ..()
	if(istype(get_area(cast_on), /area/centcom/wizard_station) || istype(get_area(cast_on), /area/centcom/thanos_farm))
		to_chat(cast_on, span_warning("You can't jump here!"))
		return
	INVOKE_ASYNC(src, PROC_REF(do_jaunt), cast_on)

/datum/action/cooldown/spell/infinity/gauntlet_jump/proc/do_jaunt(mob/living/target)
	ADD_TRAIT(target, TRAIT_NO_TRANSFORM, type)
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/phased_mob/spell_jaunt/infinity/holder = new(mobloc)

	var/mob/living/passenger
	if(isliving(target.pulling) && target.grab_state >= GRAB_AGGRESSIVE)
		passenger = target.pulling
		holder.passenger = passenger
		ADD_TRAIT(passenger, TRAIT_NO_TRANSFORM, type)

	target.visible_message(span_bolddanger("[target] LEAPS[passenger ? ", bringing [passenger] up with them" : ""]!"))
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		ADD_TRAIT(carbon_target, TRAIT_BOMBIMMUNE, type)
	if(passenger)
		animate(passenger, pixel_y = 128, alpha = 0, time = 4.5, easing = LINEAR_EASING)
	animate(target, pixel_y = 128, alpha = 0, time = 4.5, easing = LINEAR_EASING)
	sleep(4.5)

	if(passenger)
		passenger.forceMove(holder)
		passenger.reset_perspective(holder)
		REMOVE_TRAIT(passenger, TRAIT_NO_TRANSFORM, type)
	target.forceMove(holder)
	target.reset_perspective(holder)
	REMOVE_TRAIT(target, TRAIT_NO_TRANSFORM, type)

	sleep(7.5 SECONDS)
	if(target.loc != holder && (passenger && passenger.loc != holder))
		qdel(holder)
		return
	mobloc = get_turf(target.loc)
	target.mobility_flags &= ~MOBILITY_MOVE
	if(passenger)
		passenger.mobility_flags &= ~MOBILITY_MOVE
	holder.reappearing = TRUE

	if(passenger)
		passenger.forceMove(mobloc)
		passenger.Paralyze(50)
		passenger.take_overall_damage(17.5)
	target.visible_message(span_bolddanger("[target] slams down from above[passenger ? ", slamming [passenger] down to the floor" : ""]!"))
	playsound(target, 'sound/effects/bang.ogg', 50, 1)
	explosion(mobloc, 0, 0, 2, 3)
	target.forceMove(mobloc)
	target.setDir(holder.dir)
	animate(target, pixel_y = 0, alpha = 255, time = 4.5, easing = LINEAR_EASING)
	if(passenger)
		passenger.setDir(holder.dir)
		animate(passenger, pixel_y = 0, alpha = 255, time = 4.5, easing = LINEAR_EASING)
	sleep(4.5)
	target.opacity = initial(target.opacity)
	target.mouse_opacity = initial(target.mouse_opacity)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		REMOVE_TRAIT(carbon_target, TRAIT_BOMBIMMUNE, type)
	qdel(holder)
	if(!QDELETED(target))
		if(mobloc.density)
			for(var/direction in GLOB.alldirs)
				var/turf/turf = get_step(mobloc, direction)
				if(turf)
					if(target.Move(turf))
						break
		target.mobility_flags |= MOBILITY_MOVE
	if(!QDELETED(passenger))
		passenger.mobility_flags |= MOBILITY_MOVE

/obj/effect/dummy/phased_mob/spell_jaunt/infinity
	name = "shadow"
	icon = 'monkestation/icons/obj/infinity.dmi'
	icon_state = "shadow"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	invisibility = 0
	var/mob/living/passenger

/datum/action/cooldown/spell/infinity/snap
	name = "SNAP"
	desc = "Snap the Badmin Gauntlet, erasing half the life in the universe."
	button_icon_state = "gauntlet"

/datum/action/cooldown/spell/infinity/snap/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/living_caster = cast_on
	var/obj/item/badmin_gauntlet/gauntlet = locate() in living_caster
	if(!gauntlet || !istype(gauntlet))
		return
	var/prompt = alert("Are you REALLY sure you'd like to erase half the life in the universe?", "SNAP?", "YES!", "No")
	if(prompt == "YES!" && !QDELETED(src))
		if(living_caster.stat <= SOFT_CRIT)
			living_caster.say("You should've gone for the head...")
		living_caster.visible_message(span_userdanger("[living_caster] raises their Badmin Gauntlet into the air, and... <i>snap.</i>"))
		for(var/mob/mob in GLOB.mob_list)
			SEND_SOUND(mob, 'monkestation/sound/effects/snap/snap1.wav')
			if(isliving(mob))
				var/mob/living/living = mob
				living.flash_act()
		GLOB.gauntlet_snapped = TRUE
		gauntlet.spells -= src
		gauntlet.do_the_snap()
		src.Remove(living_caster)
		SSshuttle.emergency_no_recall = TRUE
		SSshuttle.emergency.request(null, set_coefficient = 0.3)
		var/list/shuttle_turfs = list()
		for(var/turf/turf in get_area_turfs(/area/shuttle/escape))
			if(!turf.density)
				var/clear = TRUE
				for(var/obj/O in turf)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					shuttle_turfs += turf
		for(var/i = 1 to 3)
			var/turf/turf = pick_n_take(shuttle_turfs)
			new /obj/effect/thanos_portal(turf)
		if(LAZYLEN(GLOB.thanos_start))
			living_caster.forceMove(pick(GLOB.thanos_start))

/////////////////////////////////////////////
/////////////////// OTHER ///////////////////
/////////////////////////////////////////////

/atom/movable/screen/alert/status_effect/agent_pinpointer/gauntlet
	name = "Badmin Stone Pinpointer"

/atom/movable/screen/alert/status_effect/agent_pinpointer/gauntlet/Click()
	. = ..()
	var/mob/living/living_user = usr
	if(!living_user || !istype(living_user))
		return
	var/datum/status_effect/agent_pinpointer/gauntlet/gauntlet_effect = attached_effect
	if(gauntlet_effect && istype(gauntlet_effect))
		var/prompt = input(living_user, "Choose the Badmin Stone to track.", "Track Stone") as null|anything in GLOB.badmin_stones
		if(prompt)
			gauntlet_effect.stone_target = prompt
			gauntlet_effect.scan_for_target()
			gauntlet_effect.point_to_target()

/datum/status_effect/agent_pinpointer/gauntlet
	id = "badmin_stone_pinpointer"
	minimum_range = 1
	range_fuzz_factor = 0
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/gauntlet
	var/stone_target = SYNDIE_STONE

/datum/status_effect/agent_pinpointer/gauntlet/scan_for_target()
	scan_target = null
	for(var/obj/item/badmin_stone/IS in world)
		if(IS.stone_type == stone_target)
			scan_target = IS
			return

/datum/objective/snap
	name = "snap"
	explanation_text = "Bring balance to the universe, by snapping out half the life with the Badmin Gauntlet"

/datum/objective/snap/check_completion()
	return GLOB.gauntlet_snapped

/obj/item/badmin_gauntlet/for_badmins
	badmin = TRUE

/obj/item/badmin_gauntlet/for_badmins/assembled/Initialize()
	. = ..()
	for(var/stone in subtypesof(/obj/item/badmin_stone))
		var/obj/item/badmin_stone/badminstone = new stone(src)
		stones += badminstone
		var/datum/component/stationloving/stationloving = badminstone.GetComponent(/datum/component/stationloving)
		if(stationloving)
			qdel(stationloving)
	spells += new /datum/action/cooldown/spell/infinity/snap
	update_icon()
