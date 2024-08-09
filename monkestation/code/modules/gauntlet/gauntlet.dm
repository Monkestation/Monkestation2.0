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
	AddComponent(/datum/component/spell_catalyst)
	martial_art = new
	flashy_aura = mutable_appearance('monkestation/icons/obj/infinity.dmi', "aura", -MUTATIONS_LAYER)
	update_icon()
	spells += new /datum/action/cooldown/spell/infinity/regenerate_gauntlet
	spells += new /datum/action/cooldown/spell/infinity/shockwave
	spells += new /datum/action/cooldown/spell/infinity/gauntlet_bullcharge
	spells += new /datum/action/cooldown/spell/infinity/gauntlet_jump

/obj/item/badmin_gauntlet/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/badmin_gauntlet/process()
	if(!FullyAssembled())
		return
	if(world.time < next_flash)
		return
	if(!iscarbon(loc))
		return
	var/mob/living/carbon/C = loc
	if(last_aura_holder && C != last_aura_holder)
		last_aura_holder.cut_overlay(flashy_aura)
	last_aura_holder = C
	C.cut_overlay(flashy_aura)
	var/static/list/stone_colors = list("#ff0130", "#266ef6", "#ECF332", "#FFC0CB", "#20B2AA", "#e429f2")
	var/index = (flash_index <= 6) ? flash_index : 1
	flashy_aura.color = stone_colors[index]
	C.add_overlay(flashy_aura)
	flash_index = index + 1
	next_flash = world.time + 5

/obj/item/badmin_gauntlet/examine(mob/user)
	. = ..()
	for(var/obj/item/badmin_stone/IS in stones)
		to_chat(user, "<span class='bold notice'>[IS.name] mode</span>")
		IS.ShowExamine(user)

/obj/item/badmin_gauntlet/ex_act(severity, target)
	return

/obj/item/badmin_gauntlet/proc/GetStone(stone_type)
	for(var/obj/item/badmin_stone/I in stones)
		if(I.stone_type == stone_type)
			return I
	return

/obj/item/badmin_gauntlet/proc/DoSnap(mob/living/snapee)
	var/dust_time = rand(5 SECONDS, 10 SECONDS)
	var/dust_sound = pick(
		'monkestation/sound/effects/snap/snap1.wav',
		'monkestation/sound/effects/snap/snap2.wav',
		'monkestation/sound/effects/snap/snap3.wav',
		'monkestation/sound/effects/snap/snap4.wav',
		'monkestation/sound/effects/snap/snap5.wav',
		'monkestation/sound/effects/snap/snap6.wav')
	if(prob(25))
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, snapee, "<span class='danger'>You don't feel so good...</span>"), dust_time - 3 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, snapee, dust_sound, 100, TRUE), dust_time-2.5)
	addtimer(CALLBACK(snapee, /mob/living.proc/dust, TRUE), dust_time)

/obj/item/badmin_gauntlet/proc/DoTheSnap()
	var/mob/living/snapper = usr
	var/list/players = GLOB.player_list.Copy()
	shuffle_inplace(players)
	var/players_to_wipe = FLOOR((players.len-1)/2, 1)
	var/players_wiped = 0
	to_chat(world, "<span class='userdanger italics'>You feel as if something big has happened.</span>")
	for(var/mob/living/L in players)
		if(players_wiped >= players_to_wipe)
			break
		if(snapper == L || !L.ckey)
			continue
		DoSnap(L)
		players_wiped++
	log_game("[key_name(snapper)] snapped, wiping out [players_wiped] players.")
	message_admins("[key_name(snapper)] snapped, wiping out [players_wiped] players.")

/obj/item/badmin_gauntlet/proc/GetWeightedChances(list/job_list, list/blacklist)
	var/list/jobs = list()
	var/list/weighted_list = list()
	for(var/A in job_list)
		jobs += A
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && !considered_afk(M) && considered_alive(M, TRUE) && is_station_level(M.current.z) && !(M.current in blacklist) && (M.assigned_role in jobs))
			weighted_list[M.current] = job_list[M.assigned_role]
	return weighted_list

/obj/item/badmin_gauntlet/proc/MakeStonekeepers(mob/living/current_user)
	var/list/has_a_stone = list(current_user)
	for(var/stone in GLOB.badmin_stones)
		var/list/to_get_stones = GetWeightedChances(GLOB.badmin_stone_weights[stone], has_a_stone)
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


/obj/item/badmin_gauntlet/proc/FullyAssembled()
	for(var/stone in GLOB.badmin_stones)
		if(!GetStone(stone))
			return FALSE
	return TRUE

/obj/item/badmin_gauntlet/proc/GetStoneColor(stone_type)
	var/obj/item/badmin_stone/IS = GetStone(stone_type)
	if(IS && istype(IS))
		return IS.color
	return "#DC143C" //crimson by default

/obj/item/badmin_gauntlet/proc/OnEquip(mob/living/user)
	for(var/datum/action/cooldown/spell/A in spells)
		user.mob_spell_list += A
		A.Grant(user)
	user.AddComponent(/datum/component/stationloving)
	var/datum/antagonist/wizard/W = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(W && istype(W))
		for(var/datum/objective/O in W.objectives)
			W.objectives -= O
			qdel(O)
		W.objectives += new /datum/objective/snap
		W.can_hijack = HIJACK_NEUTRAL
		user.mind.announce_objectives()
	user.move_resist = INFINITY

/obj/item/badmin_gauntlet/proc/OnUnquip(mob/living/user)
	user.cut_overlay(flashy_aura)
	GET_COMPONENT_FROM(stationloving, /datum/component/stationloving, user)
	if(stationloving)
		user.TakeComponent(stationloving)
	for(var/datum/action/cooldown/spell/A in spells)
		user.mob_spell_list -= A
		A.action.Remove(user)
	user.move_resist = initial(user.move_resist)
	TakeAbilities(user)

/obj/item/badmin_gauntlet/pickup(mob/user)
	. = ..()
	if(locked_on && isliving(user))
		OnEquip(user)
		visible_message("<span class='danger'>The Badmin Gauntlet attaches to [user]'s hand!.</span>")

/obj/item/badmin_gauntlet/dropped(mob/user)
	. = ..()
	if(locked_on && isliving(user))
		OnUnquip(user)
		visible_message("<span class='danger'>The Badmin Gauntlet falls off of [user].</span>")

/obj/item/badmin_gauntlet/proc/TakeAbilities(mob/living/user)
	for(var/obj/item/badmin_stone/IS in stones)
		IS.RemoveAbilities(user, TRUE)
		IS.TakeVisualEffects(user)
		IS.TakeStatusEffect(user)
	for(var/datum/action/cooldown/spell/A in spells)
		user.mob_spell_list -= A
		A.action.Remove(user)
	if(ishuman(user))
		martial_art.remove(user)

// warning: contains snowflake code for syndie stone
/obj/item/badmin_gauntlet/proc/GiveAbilities(mob/living/user)
	var/obj/item/badmin_stone/syndie = GetStone(SYNDIE_STONE)
	if(!syndie)
		for(var/datum/action/cooldown/spell/A in spells)
			user.mob_spell_list += A
			A.action.Grant(user)
	if(ishuman(user))
		if(stone_mode != SYNDIE_STONE && (!GetStone(stone_mode) || !stone_mode))
			martial_art.teach(user)
	if(syndie)
		syndie.GiveAbilities(user, TRUE)
	if(FullyAssembled())
		for(var/obj/item/badmin_stone/IS in stones)
			if(IS && istype(IS) && IS.stone_type != SYNDIE_STONE)
				IS.GiveAbilities(user, TRUE)
	else
		var/obj/item/badmin_stone/IS = GetStone(stone_mode)
		if(IS && istype(IS))
			IS.GiveVisualEffects(user)
			if(stone_mode != SYNDIE_STONE)
				IS.GiveAbilities(user, TRUE)

/obj/item/badmin_gauntlet/proc/UpdateAbilities(mob/living/user)
	TakeAbilities(user)
	GiveAbilities(user)

/obj/item/badmin_gauntlet/update_icon()
	cut_overlays()
	var/index = 1
	var/image/veins = image(icon = 'monkestation/icons/obj/infinity.dmi', icon_state = "glow-overlay")
	veins.color = GetStoneColor(stone_mode)
	add_overlay(veins)
	for(var/obj/item/badmin_stone/IS in stones)
		var/I = index
		if(IS.stone_type == stone_mode)
			I = 0
		var/image/O = image(icon = 'monkestation/icons/obj/infinity.dmi', icon_state = "[I]-stone")
		O.color = IS.color
		add_overlay(O)
		index++

/obj/item/badmin_gauntlet/melee_attack_chain(mob/user, atom/target, params)
	if(!tool_attack_chain(user, target) && pre_attack(target, user, params))
		if(user == target)
			if(target && !QDELETED(src))
				afterattack(target, user, 1, params)
		else
			var/resolved = target.attackby(src, user, params)
			if(!resolved && target && !QDELETED(src))
				afterattack(target, user, 1, params)

/obj/item/badmin_gauntlet/proc/AttackThing(mob/user, atom/target)
	. = FALSE
	if(istype(target, /obj/mecha))
		. = TRUE
		var/obj/mecha/mech = target
		mech.take_damage(17.5) // 17.5 extra damage against mechs, because this calls AFTER hitting something
	else if(istype(target, /obj/structure/safe))
		. = TRUE
		var/obj/structure/safe/S = target
		user.visible_message("<span class='danger'>[user] begins to pry open [S]!<span>", "<span class='notice'>We begin to pry open [S]...</span>")
		if(do_after(user, 35, target = S))
			user.visible_message("<span class='danger'>[user] pries open [S]!<span>", "<span class='notice'>We pry open [S]!</span>")
			S.tumbler_1_pos = S.tumbler_1_open
			S.tumbler_2_pos = S.tumbler_2_open
			S.open = TRUE
			S.update_icon()
			S.updateUsrDialog()
	else if(isclosedturf(target))
		var/turf/closed/T = target
		if(istype(get_area(T), /area/wizard_station))
			to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to start smashing down walls.</span>")
			return FALSE
		if(!GetStone(SYNDIE_STONE))
			. = TRUE
			user.visible_message("<span class='danger'>[user] begins to charge up a punch...</span>", "<span class='notice'>We begin to charge a punch...</span>")
			if(do_after(user, 15, target = T))
				playsound(T, 'sound/effects/bang.ogg', 50, 1)
				user.visible_message("<span class='danger'>[user] punches down [T]!</span>")
				T.ScrapeAway()
		else
			playsound(T, 'sound/effects/bang.ogg', 50, 1)
			user.visible_message("<span class='danger'>[user] punches down [T]!</span>")
			T.ScrapeAway()
	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/C = target
		. = TRUE
		C.broken = TRUE
		C.locked = FALSE
		C.open()
		C.update_icon()
		playsound(C, 'sound/effects/bang.ogg', 50, 1)
		user.visible_message("<span class='danger'>[user] smashes open [C]!<span>")
	else if(istype(target, /obj/structure/table) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
		var/obj/structure/T = target
		if(istype(get_area(T), /area/wizard_station))
			to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to start smashing down stuff.</span>")
			return FALSE
		. = TRUE
		playsound(T, 'sound/effects/bang.ogg', 50, 1)
		user.visible_message("<span class='danger'>[user] smashes [T]!<span>")
		T.take_damage(INFINITY)

/obj/item/badmin_gauntlet/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!locked_on)
		return ..()
	if(!isliving(user))
		return ..()
	var/obj/item/badmin_stone/IS = GetStone(stone_mode)
	if(!IS || !istype(IS))
		switch(user.a_intent)
			if(INTENT_DISARM)
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.disarm_act(user, target)
			if(INTENT_HARM)
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.harm_act(user, target)
				if(proximity_flag)
					AttackThing(user, target)
			if(INTENT_GRAB)
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.grab_act(user, target)
			if(INTENT_HELP)
				if(ishuman(target) && ishuman(user) && proximity_flag)
					martial_art.help_act(user, target)
		return
	switch(user.a_intent)
		if(INTENT_DISARM)
			IS.disarm_act(target, user, proximity_flag)
		if(INTENT_HARM) // there's no harm intent on the stones anyways
			if(proximity_flag && !AttackThing(user, target))
				IS.harm_act(target, user, proximity_flag)
		if(INTENT_GRAB)
			IS.grab_act(target, user, proximity_flag)
		if(INTENT_HELP)
			IS.help_act(target, user, proximity_flag)

/obj/item/badmin_gauntlet/attack_self(mob/living/user)
	if(!istype(user))
		return
	if(!locked_on)
		var/prompt = alert("Would you like to truly wear the Badmin Gauntlet? You will be unable to remove it!", "Confirm", "Yes", "No")
		if (prompt == "Yes")
			user.dropItemToGround(src)
			if(user.put_in_hands(src))
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					H.set_species(/datum/species/ganymede)
					H.doUnEquip(H.wear_suit)
					H.doUnEquip(H.w_uniform)
					H.doUnEquip(H.head)
					H.doUnEquip(H.back)
					H.doUnEquip(H.shoes)
					var/obj/item/clothing/head/hippie/ganymedian/GH = new(get_turf(user))
					var/obj/item/clothing/suit/hippie/ganymedian/GS = new(get_turf(user))
					var/obj/item/clothing/under/hippie/ganymedian/GJ = new(get_turf(user))
					var/obj/item/clothing/shoes/ganymedian/Gs = new(get_turf(user))
					var/obj/item/tank/jetpack/ganypack/GP = new(get_turf(user))
					var/obj/item/teleportation_scroll/TS = new(get_turf(user))
					H.equip_to_appropriate_slot(GJ)
					H.equip_to_appropriate_slot(GH)
					H.equip_to_appropriate_slot(GS)
					H.equip_to_appropriate_slot(Gs)
					H.equip_to_appropriate_slot(TS)
					H.equip_to_slot(GP, SLOT_BACK)
				GLOB.gauntlet_equipped = TRUE
				for(var/obj/item/spellbook/SB in world)
					if(SB.owner == user)
						qdel(SB)
				user.apply_status_effect(/datum/status_effect/agent_pinpointer/gauntlet)
				if(!badmin)
					if(LAZYLEN(GLOB.wizardstart))
						user.forceMove(pick(GLOB.wizardstart))
					priority_announce("A Wizard has declared that he will wipe out half the universe with the Badmin Gauntlet!\n\
						Stones have been scattered across the station. Protect anyone who holds one!\n\
						We've allocated a large amount of resources to you, for protecting the Stones:\n\
						Cargo has been given $50k to spend\n\
						Science has been given 50k techpoints, and a large amount of minerals.\n\
						In addition, we've moved your Artifical Intelligence unit to your Bridge, and reinforced your telecommunications machinery.", title = "Declaration of War", sound = 'monkestation/sound/misc/wizard_wardec.ogg')
					// give cargo/sci money
					var/datum/bank_account/cargo_moneys = SSeconomy.get_dep_account(ACCOUNT_CAR)
					var/datum/bank_account/sci_moneys = SSeconomy.get_dep_account(ACCOUNT_SCI)
					if(cargo_moneys)
						cargo_moneys.adjust_money(50000)
					if(sci_moneys)
						sci_moneys.adjust_money(50000)
						SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, 50000)
					// give sci materials
					var/obj/structure/closet/supplypod/bluespacepod/sci_pod = new()
					sci_pod.explosionSize = list(0,0,0,0)
					var/list/materials_to_give_science = list(/obj/item/stack/sheet/metal,
						/obj/item/stack/sheet/plasteel,
						/obj/item/stack/sheet/mineral/diamond,
						/obj/item/stack/sheet/mineral/uranium,
						/obj/item/stack/sheet/mineral/plasma,
						/obj/item/stack/sheet/mineral/gold,
						/obj/item/stack/sheet/mineral/silver,
						/obj/item/stack/sheet/glass,
						/obj/item/stack/ore/bluespace_crystal/artificial)
					for(var/mat in materials_to_give_science)
						var/obj/item/stack/sheet/S = new mat(sci_pod)
						S.amount = 50
						S.update_icon()
					var/list/sci_tiles = list()
					for(var/turf/T in get_area_turfs(/area/science/lab))
						if(!T.density)
							var/clear = TRUE
							for(var/obj/O in T)
								if(O.density)
									clear = FALSE
									break
							if(clear)
								sci_tiles += T
					if(LAZYLEN(sci_tiles))
						new /obj/effect/DPtarget(get_turf(pick(sci_tiles)), sci_pod)
					// make telecomms machinery invincible
					for(var/obj/machinery/telecomms/TC in world)
						if(istype(get_area(TC), /area/tcommsat))
							TC.resistance_flags |= INDESTRUCTIBLE
					for(var/obj/machinery/power/apc/APC in world)
						if(istype(get_area(APC), /area/tcommsat))
							APC.resistance_flags |= INDESTRUCTIBLE
					// move ai(s) to bridge
					var/list/bridge_tiles = list()
					for(var/turf/T in get_area_turfs(/area/bridge))
						if(!T.density)
							var/clear = TRUE
							for(var/obj/O in T)
								if(O.density)
									clear = FALSE
									break
							if(clear)
								bridge_tiles += T
					if(LAZYLEN(bridge_tiles))
						for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
							var/obj/structure/closet/supplypod/bluespacepod/ai_pod = new
							AI.forceMove(ai_pod)
							AI.move_resist = MOVE_FORCE_NORMAL
							new /obj/effect/DPtarget(get_turf(pick(bridge_tiles)), ai_pod)
					GLOB.telescroll_time = world.time + 10 MINUTES
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, user, "<span class='notice bold'>You can now teleport to the station.</span>"), 10 MINUTES)
					addtimer(CALLBACK(src, .proc/_CallRevengers), 25 MINUTES)
					to_chat(user, "<span class='notice bold'>You need to wait 10 minutes before teleporting to the station.</span>")
				to_chat(user, "<span class='notice bold'>You can click on the pinpointer at the top right to track a stone.</span>")
				to_chat(user, "<span class='notice bold'>Examine a stone/the gauntlet to see what each intent does.</span>")
				to_chat(user, "<span class='notice bold'>You can smash walls, tables, grilles, windows, and safes on HARM intent.</span>")
				to_chat(user, "<span class='notice bold'>Be warned -- you may be mocked if you kill innocents, that does not bring balance!</span>")
				ADD_TRAIT(src, TRAIT_NODROP, GAUNTLET_TRAIT)
				locked_on = TRUE
				visible_message("<span class='danger bold'>The badmin gauntlet clamps to [user]'s hand!</span>")
				user.mind.RemoveAllSpells()
				UpdateAbilities(user)
				OnEquip(user)
				if(!badmin)
					MakeStonekeepers(user)
			else
				to_chat(user, "<span class='danger'>You do not have an empty hand for the Badmin Gauntlet.</span>")
		return
	if(!LAZYLEN(stones))
		to_chat(user, "<span class='danger'>You have no stones yet.</span>")
		return
	var/list/gauntlet_radial = list()
	for(var/obj/item/badmin_stone/I in stones)
		var/image/IM = image(icon = I.icon, icon_state = I.icon_state)
		IM.color = I.color
		gauntlet_radial[I.stone_type] = IM
	if(!GetStone(SYNDIE_STONE))
		gauntlet_radial["none"] = image(icon = 'monkestation/icons/obj/infinity.dmi', icon_state = "none")
	var/chosen = show_radial_menu(user, src, gauntlet_radial, custom_check = CALLBACK(src, .proc/check_menu, user))
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

/obj/item/badmin_gauntlet/proc/_CallRevengers()
	message_admins("Revengers ERT being auto-called in 15 seconds (<a href='?src=[REF(src)];cancel=1'>CANCEL</a>)")
	addtimer(CALLBACK(src, .proc/CallRevengers), 15 SECONDS)

/obj/item/badmin_gauntlet/proc/CallRevengers()
	if(ert_canceled)
		return
	message_admins("The Revengers ERT has been auto-called.")
	log_game("The Revengers ERT has been auto-called.")

	var/datum/ert/revengers/ertemplate = new
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be an Revenger?", "deathsquad", null)
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
			chosen_candidate.client.prefs.copy_to(ERTOperative)
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

/obj/item/badmin_gauntlet/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/badmin_stone))
		if(!locked_on)
			to_chat(user, "<span class='notice'>You need to wear the gauntlet first.</span>")
			return
		var/obj/item/badmin_stone/IS = I
		if(!GetStone(IS.stone_type))
			user.visible_message("<span class='danger bold'>[user] drops the [IS] into the Badmin Gauntlet.</span>")
			if(IS.stone_type == SYNDIE_STONE)
				force = 27.5
			IS.forceMove(src)
			stones += IS
			var/datum/component/stationloving/stationloving = IS.GetComponent(/datum/component/stationloving)
			if(stationloving)
				stationloving.RemoveComponent()
			UpdateAbilities(user)
			update_icon()
			if(FullyAssembled() && !GLOB.gauntlet_snapped)
				user.AddSpell(new /datum/action/cooldown/spell/infinity/snap)
				user.visible_message("<span class='userdanger'>A massive surge of power courses through [user]. You feel as though your very existence is in danger!</span>",
					"<span class='danger bold'>You have fully assembled the Badmin Gauntlet. You can use all stone abilities no matter the mode, and can SNAP using the ability.</span>")
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
//Weaker versions of Syndie Stone spells

/datum/action/cooldown/spell/infinity/shockwave
	name = "Badmin Gauntlet: Shockwave"
	desc = "Stomp down and send out a slow-moving shockwave that is capable of knocking people down."
	charge_max = 250
	clothes_req = FALSE
	human_req = FALSE
	staff_req = FALSE
	background_icon_state = "bg_default"
	range = 5
	sound = 'sound/effects/bang.ogg'

/datum/action/cooldown/spell/infinity/shockwave/cast(list/targets, mob/user)
	user.visible_message("<span class='danger'>[user] stomps down!</span>")
	INVOKE_ASYNC(src, .proc/shockwave, user, get_turf(user))

/datum/action/cooldown/spell/infinity/shockwave/proc/shockwave(mob/user, turf/center)
	for(var/i = 1 to range)
		var/to_hit = range(center, i) - range(center, i-1)
		for(var/turf/T in to_hit)
			new /obj/effect/temp_visual/gravpush(T)
		for(var/mob/living/L in to_hit)
			if(L == user)
				continue
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(istype(H.shoes, /obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						continue
			L.visible_message("<span class='danger'>[L] is knocked down by a shockwave!</span>", "<span class='danger bold'>A shockwave knocks you off your feet!</span>")
			L.Paralyze(17.5)
		sleep(2)

/datum/action/cooldown/spell/infinity/regenerate_gauntlet
	name = "Badmin Gauntlet: Regenerate"
	desc = "Regenerate 2 health per second. Requires you to stand still."
	button_icon_state = "regenerate"
	background_icon_state = "bg_default"
	stat_allowed = TRUE

/datum/action/cooldown/spell/infinity/regenerate_gauntlet/cast(list/targets, mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.on_fire)
			to_chat(L, "<span class='notice'>The fire interferes with your regeneration!</span>")
			revert_cast(L)
			return
		if(L.stat == DEAD)
			to_chat(L, "<span class='notice'>You can't regenerate out of death.</span>")
			revert_cast(L)
			return
		while(do_after(L, 10, FALSE, L))
			L.visible_message("<span class='notice'>[L]'s wounds heal!</span>")
			L.heal_overall_damage(2, 2, 2, null, TRUE)
			L.adjustToxLoss(-2)
			L.adjustOxyLoss(-2)
			if(L.getBruteLoss() + L.getFireLoss() + L.getStaminaLoss() < 1)
				to_chat(user, "<span class='notice'>You are fully healed.</span>")
				return

/datum/action/cooldown/spell/infinity/gauntlet_bullcharge
	name = "Badmin Gauntlet: Bull Charge"
	desc = "Imbue yourself with power, and charge forward, smashing through anyone in your way!"
	background_icon_state = "bg_default"
	charge_max = 250
	sound = 'sound/magic/repulse.ogg'

/datum/action/cooldown/spell/infinity/gauntlet_bullcharge/cast(list/targets, mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.mario_star = TRUE
		C.super_mario_star = FALSE
		ADD_TRAIT(user, TRAIT_IGNORESLOWDOWN, YEET_TRAIT)
		user.visible_message("<span class='danger'>[user] charges!</span>")
		addtimer(CALLBACK(src, .proc/done, C), 50)

/datum/action/cooldown/spell/infinity/gauntlet_bullcharge/proc/done(mob/living/carbon/user)
	user.mario_star = FALSE
	user.super_mario_star = FALSE
	REMOVE_TRAIT(user, TRAIT_IGNORESLOWDOWN, YEET_TRAIT)
	user.visible_message("<span class='danger'>[user] relaxes...</span>")

/datum/action/cooldown/spell/infinity/gauntlet_jump
	name = "Badmin Gauntlet: Super Jump"
	desc = "With a bit of startup time, leap across the station to wherever you'd like!"
	background_icon_state = "bg_default"
	button_icon_state = "jump"
	charge_max = 300

/datum/action/cooldown/spell/infinity/gauntlet_jump/revert_cast(mob/user)
	. = ..()
	user.opacity = initial(user.opacity)
	user.mouse_opacity = initial(user.mouse_opacity)
	user.pixel_y = 0
	user.alpha = 255

// i really hope this never runtimes
/datum/action/cooldown/spell/infinity/gauntlet_jump/cast(list/targets, mob/user)
	if(istype(get_area(user), /area/wizard_station) || istype(get_area(user), /area/hippie/thanos_farm))
		to_chat(user, "<span class='warning'>You can't jump here!</span>")
		revert_cast(user)
		return
	INVOKE_ASYNC(src, .proc/do_jaunt, user)

/datum/action/cooldown/spell/infinity/gauntlet_jump/proc/do_jaunt(mob/living/target)
	target.notransform = TRUE
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/phased_mob/spell_jaunt/infinity/holder = new(mobloc)

	var/mob/living/passenger
	if(isliving(target.pulling) && target.grab_state >= GRAB_AGGRESSIVE)
		passenger = target.pulling
		holder.passenger = passenger

	target.visible_message("<span class='danger bold'>[target] LEAPS[passenger ? ", bringing [passenger] up with them" : ""]!</span>")
	target.opacity = FALSE
	target.mouse_opacity = FALSE
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.super_leaping = TRUE
	if(passenger)
		passenger.opacity = FALSE
		passenger.mouse_opacity = FALSE
		animate(passenger, pixel_y = 128, alpha = 0, time = 4.5, easing = LINEAR_EASING)
	animate(target, pixel_y = 128, alpha = 0, time = 4.5, easing = LINEAR_EASING)
	sleep(4.5)

	if(passenger)
		passenger.forceMove(holder)
		passenger.reset_perspective(holder)
		passenger.notransform = FALSE
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.notransform = FALSE //mob is safely inside holder now, no need for protection.

	sleep(7.5 SECONDS)

	if(target.loc != holder && (passenger && passenger.loc != holder)) //mob warped out of the warp
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
	playsound(target, 'sound/effects/bang.ogg', 50, 1)
	target.forceMove(mobloc)
	target.visible_message("<span class='danger bold'>[target] slams down from above[passenger ? ", slamming [passenger] down to the floor" : ""]!</span>")

	target.setDir(holder.dir)
	animate(target, pixel_y = 0, alpha = 255, time = 4.5, easing = LINEAR_EASING)
	if(passenger)
		passenger.setDir(holder.dir)
		animate(passenger, pixel_y = 0, alpha = 255, time = 4.5, easing = LINEAR_EASING)
	sleep(4.5)
	target.opacity = initial(target.opacity)
	target.mouse_opacity = initial(target.mouse_opacity)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.super_leaping = FALSE
	if(passenger)
		passenger.opacity = initial(passenger.opacity)
		passenger.mouse_opacity = initial(passenger.mouse_opacity)
	qdel(holder)
	if(!QDELETED(target))
		if(mobloc.density)
			for(var/direction in GLOB.alldirs)
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(target.Move(T))
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

/obj/effect/dummy/phased_mob/spell_jaunt/infinity/relaymove(var/mob/user, direction)
	if ((movedelay > world.time) || reappearing || !direction)
		return
	var/turf/newLoc = get_step(src,direction)
	setDir(direction)

	movedelay = world.time + movespeed

	if(newLoc.flags_1 & NOJAUNT_1)
		to_chat(user, "<span class='warning'>Some strange aura is blocking the way.</span>")
		return

	forceMove(newLoc)

/obj/effect/dummy/phased_mob/spell_jaunt/infinity/relaymove(mob/user, direction)
	if(user == passenger)
		return
	return ..()

/datum/action/cooldown/spell/infinity/snap
	name = "SNAP"
	desc = "Snap the Badmin Gauntlet, erasing half the life in the universe."
	button_icon_state = "gauntlet"
	stat_allowed = TRUE

/datum/action/cooldown/spell/infinity/snap/cast(list/targets, mob/living/user)
	var/obj/item/badmin_gauntlet/IG = locate() in user
	if(!IG || !istype(IG))
		return
	var/prompt = alert("Are you REALLY sure you'd like to erase half the life in the universe?", "SNAP?", "YES!", "No")
	if(prompt == "YES!")
		if(user.InCritical())
			user.say("You should've gone for the head...")
		user.visible_message("<span class='userdanger'>[user] raises their Badmin Gauntlet into the air, and... <i>snap.</i></span>")
		for(var/mob/M in GLOB.mob_list)
			SEND_SOUND(M, 'monkestation/sound/voice/snap.ogg')
			if(isliving(M))
				var/mob/living/L = M
				L.flash_act()
		GLOB.gauntlet_snapped = TRUE
		IG.DoTheSnap()
		user.RemoveSpell(src)
		SSshuttle.emergencyNoRecall = TRUE
		SSshuttle.emergency.request(null, set_coefficient = 0.3)
		var/list/shuttle_turfs = list()
		for(var/turf/T in get_area_turfs(/area/shuttle/escape))
			if(!T.density)
				var/clear = TRUE
				for(var/obj/O in T)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					shuttle_turfs+=T
		for(var/i = 1 to 3)
			var/turf/T = pick_n_take(shuttle_turfs)
			new /obj/effect/thanos_portal(T)
		if(LAZYLEN(GLOB.thanos_start))
			user.forceMove(pick(GLOB.thanos_start))

/////////////////////////////////////////////
/////////////////// OTHER ///////////////////
/////////////////////////////////////////////

/obj/screen/alert/status_effect/agent_pinpointer/gauntlet
	name = "Badmin Stone Pinpointer"

/obj/screen/alert/status_effect/agent_pinpointer/gauntlet/Click()
	var/mob/living/L = usr
	if(!L || !istype(L))
		return
	var/datum/status_effect/agent_pinpointer/gauntlet/G = attached_effect
	if(G && istype(G))
		var/prompt = input(L, "Choose the Badmin Stone to track.", "Track Stone") as null|anything in GLOB.badmin_stones
		if(prompt)
			G.stone_target = prompt
			G.scan_for_target()
			G.point_to_target()

/datum/status_effect/agent_pinpointer/gauntlet
	id = "badmin_stone_pinpointer"
	minimum_range = 1
	range_fuzz_factor = 0
	tick_interval = 10
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/gauntlet
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
