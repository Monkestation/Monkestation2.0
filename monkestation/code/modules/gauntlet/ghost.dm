//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/obj/item/badmin_stone/ghost
	name = "Ghost Stone"
	desc = "Salts your food very well."
	color = "#e429f2"
	ability_text = list(
		"HELP INTENT: Transmutate ghosts into a random simplemob.",
		"DISARM INTENT: Fire a bolt that scales based on how many ghosts orbit you."
	)
	stone_type = GHOST_STONE
	spell_types = list(
		/datum/action/cooldown/spell/pointed/infinity/clown_rise_up,
		/datum/action/cooldown/spell/infinity/scrying_orb,
		/datum/action/cooldown/spell/infinity/fortress,
		/datum/action/cooldown/spell/conjure_item/spellpacket/sandmans_dust
	)
	gauntlet_spell_types = list(
		/datum/action/cooldown/spell/infinity/soulscreech,
		/datum/action/cooldown/spell/pointed/infinity/chariot
	)
	var/summon_cooldown = 0
	var/next_pull = 0
	var/list/mob/dead/observer/spirits = list()

/obj/item/badmin_stone/ghost/help_act(atom/target, mob/user, proximity_flag)
	if(!isobserver(target))
		to_chat(user, span_notice("You can only transmutate ghosts!"))
		return
	var/mob/dead/observer/ghost_target = target
	var/picked_mob = pick(
		/mob/living/basic/carp,
		/mob/living/basic/bear,
		/mob/living/basic/mushroom,
		/mob/living/basic/bat,
		/mob/living/basic/goat,
		/mob/living/basic/parrot,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/crab,
		/mob/living/basic/pet/dog/pug,
		/mob/living/simple_animal/pet/cat,
		/mob/living/basic/mouse,
		/mob/living/basic/chicken,
		/mob/living/basic/cow,
		/mob/living/basic/lizard,
		/mob/living/basic/pet/fox,
		/mob/living/basic/butterfly,
		/mob/living/simple_animal/pet/cat/cak,
		/mob/living/basic/chick)
	var/mob/living/mob = new picked_mob(get_turf(ghost_target))
	ghost_target.visible_message(span_danger("The ghost of [ghost_target] turns into [mob]!"))
	mob.ckey = ghost_target.ckey
	to_chat(mob, span_userdanger("[user] is your master. Protect them at all costs."))
	var/atom/movable/screen/alert/mind_control/mind_alert = mob.throw_alert(ALERT_MIND_CONTROL, /atom/movable/screen/alert/mind_control)
	mind_alert.command = "[user] is your master. Protect them at all costs"
	qdel(ghost_target)

/obj/item/badmin_stone/ghost/disarm_act(atom/target, mob/user, proximity_flag)
	for(var/i in ghost_check())
		fire_projectile(/obj/projectile/spirit_fist, target)
	user.changeNext_move(CLICK_CD_RANGE)

/obj/item/badmin_stone/ghost/give_abilities(mob/living/living_mob, gauntlet)
	. = ..()
	ADD_TRAIT(living_mob, TRAIT_SIXTHSENSE, GHOST_STONE_TRAIT)
	ADD_TRAIT(living_mob, TRAIT_XRAY_VISION, GHOST_STONE_TRAIT)
	living_mob.see_invisible = SEE_INVISIBLE_OBSERVER
	living_mob.update_sight()

/obj/item/badmin_stone/ghost/remove_abilities(mob/living/living_mob)
	. = ..()
	REMOVE_TRAIT(living_mob, TRAIT_SIXTHSENSE, GHOST_STONE_TRAIT)
	REMOVE_TRAIT(living_mob, TRAIT_XRAY_VISION, GHOST_STONE_TRAIT)
	living_mob.see_invisible = initial(living_mob.see_invisible)
	living_mob.update_sight()

/obj/item/badmin_stone/ghost/Initialize()
	. = ..()
	notify_ghosts(
		"The Ghost Stone has been formed!",
		enter_link = "<a href=?src=[REF(src)];orbit=1>(Click to orbit)</a>",
		source = src,
		action = NOTIFY_ORBIT,
		ignore_key = POLL_IGNORE_SPECTRAL_BLADE)

/obj/item/badmin_stone/ghost/Destroy()
	for(var/mob/dead/observer/ghost in spirits)
		ghost.invisibility = GLOB.observer_default_invisibility
	return ..()

/obj/item/badmin_stone/ghost/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")
	notify_ghosts(
		"[user] is clenching [user.p_their()] [src], calling for your help!",
		enter_link = "<a href=?src=[REF(src)];orbit=1>(Click to help)</a>",
		source = user,
		action = NOTIFY_ORBIT,
		ignore_key = POLL_IGNORE_SPECTRAL_BLADE)
	summon_cooldown = world.time + 60 SECONDS

/obj/item/badmin_stone/ghost/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/badmin_stone/ghost/process()
	..()
	ghost_check()

/obj/item/badmin_stone/ghost/proc/ghost_check()
	var/ghost_counter = 0
	var/mob/dead/observer/current_spirits = list()

	if(aura_holder && world.time >= next_pull)
		aura_holder.transfer_observers_to(src)
		next_pull = world.time + 25

	if(!orbiters)
		orbiters = GetComponent(/datum/component/orbiter)
	for(var/orbiter in orbiters?.orbiter_list)
		if(!isobserver(orbiter))
			continue
		var/mob/dead/observer/ghost = orbiter
		ghost_counter++
		ghost.invisibility = 0
		current_spirits |= ghost

	for(var/mob/dead/observer/ghost in spirits - current_spirits)
		ghost.invisibility = GLOB.observer_default_invisibility

	spirits = current_spirits

	return ghost_counter

/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/pointed/infinity/chariot
	name = "Ghost Stone: The Chariot"
	desc = "Open up an unconscious soul to ghosts, ripe for the stealing!"
	button_icon_state = "chariot"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "ghost"
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/pointed/infinity/chariot/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!user.Adjacent(target))
		to_chat(user, span_notice("You need to be next to the target!"))
		return FALSE
	if(!isliving(target))
		to_chat(user, span_notice("That doesn't even have a soul."))
		return FALSE
	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		to_chat(user, span_notice("That's dead, stupid."))
		return FALSE
	if(living_target.stat != UNCONSCIOUS)
		to_chat(user, span_notice("That's not unconscious."))
		return FALSE
	if(locate(/obj/item/badmin_stone) in living_target.get_all_contents())
		to_chat(user, span_notice("Something stops you from using The Chariot on that..."))
		return FALSE
	log_game("[living_target] was kicked out of their body by The Chariot (user: [user])")
	to_chat(living_target, span_bolddanger("You feel your very soul detach from your body..."))
	to_chat(user, span_boldnotice("You weave [living_target]'s soul in a way that it's open for the spirits to take..."))
	offer_control(living_target, FALSE)
	return TRUE

/obj/effect/forcefield/heaven
	name = "heaven's wall"
	desc = "You'd need a powerful bluespace artifact to get through."
	var/mob/summoner

/obj/effect/forcefield/heaven/Initialize(mapload, mob/user)
	. = ..()
	summoner = user
	QDEL_IN(src, 450)

/obj/effect/forcefield/heaven/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(mover == summoner)
		return TRUE
	if(locate(/obj/item/badmin_stone/bluespace) in mover)
		return TRUE
	return FALSE

/datum/action/cooldown/spell/infinity/fortress
	name = "Ghost Stone: Heaven's Fortress"
	desc = "Summon a massive fortress to keep people in, and keep them out."
	button_icon_state = "fortress"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "ghost"
	cooldown_time = 120 SECONDS

/datum/action/cooldown/spell/infinity/fortress/cast(atom/cast_on)
	. = ..()
	var/fortress = range(5, cast_on) - range(4, cast_on)
	cast_on.visible_message(span_bolddanger("[cast_on] summons Heaven's Fortress!"))
	for(var/turf/fortress_turf in fortress)
		new /obj/effect/forcefield/heaven(get_turf(fortress_turf), cast_on)

/datum/action/cooldown/spell/infinity/soulscreech
	name = "Ghost Stone: Soulscreech"
	desc = "A loud screech that interacts with people's souls in varying ways."
	button_icon_state = "reeeeee"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "ghost"
	sound = 'sound/hallucinations/far_noise.ogg'
	cooldown_time = 90 SECONDS

/datum/action/cooldown/spell/infinity/soulscreech/cast(atom/cast_on)
	. = ..()
	cast_on.visible_message(span_bolddanger("[cast_on] lets out a horrifying screech!"))
	for(var/mob/living/living_in_range in get_hearers_in_view(6, cast_on))
		if(living_in_range == cast_on)
			continue
		var/list/effects = list(1, 2, 3, 4, 6)
		var/list/ni_effects = list(5)
		if(!(locate(/obj/item/badmin_stone) in living_in_range.get_all_contents()) && !(living_in_range.mind && living_in_range.mind.has_antag_datum(/datum/antagonist/ert/revenger)))
			effects += ni_effects
		var/effect = pick(effects)
		switch(effect)
			if(1)
				to_chat(living_in_range, span_danger("You feel horrid..."))
				living_in_range.adjustOxyLoss(30)
				living_in_range.apply_status_effect(/datum/status_effect/speech/slurring/cult)
				living_in_range.apply_status_effect(/datum/status_effect/dizziness)
			if(2)
				living_in_range.throw_at(get_edge_target_turf(living_in_range, get_dir(cast_on, living_in_range)), 7, 5)
			if(3)
				var/turf/potential_turf = find_safe_turf(extended_safety_checks = TRUE)
				if(potential_turf)
					do_teleport(living_in_range, potential_turf, channel = TELEPORT_CHANNEL_BLUESPACE)
			if(4)
				if(living_in_range.can_block_magic(antimagic_flags))
					continue
				if(HAS_TRAIT(living_in_range, TRAIT_REVENANT_BLIGHT_PROTECTION))
					continue
				if(!ishuman(living_in_range))
					continue
				living_in_range.apply_status_effect(/datum/status_effect/revenant_blight)
			if(5)
				living_in_range.Stun(40)
				living_in_range.petrify(3 MINUTES)
			if(6)
				living_in_range.Unconscious(100)

/datum/action/cooldown/spell/infinity/scrying_orb
	name = "Ghost Stone: Scrying Detachment"
	desc = "Detach your soul from your body, going into the realm of the ghosts."
	button_icon_state = "scrying"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "ghost"

/datum/action/cooldown/spell/infinity/scrying_orb/cast(atom/cast_on)
	. = ..()
	if(isliving(cast_on))
		var/mob/living/living_caster = cast_on
		living_caster.visible_message(span_notice("[living_caster] stares into the Ghost Stone, and the Ghost Stone stares back."))
		living_caster.ghostize(TRUE)

/datum/action/cooldown/spell/pointed/infinity/clown_rise_up
	name = "Ghost Stone: Clown Rise"
	desc = "Rise a corpse as a subservient, magical cluwne. You may only have 1 magical cluwne alive."
	button_icon_state = "clownrise"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "ghost"
	cooldown_time = 90 SECONDS
	var/list/clowns = list()

/datum/action/cooldown/spell/pointed/infinity/clown_rise_up/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/clown = clowns[user]
		if(istype(clown) && clown && !clown.stat >= HARD_CRIT)
			to_chat(user, span_danger("You still have a magical cluwne alive."))
			return FALSE
		var/mob/living/carbon/human/human_target = target
		if(human_target.stat != DEAD && human_target.stat == HARD_CRIT)
			to_chat(user, span_danger("They aren't dead enough yet."))
			return FALSE
		human_target.revive(TRUE, TRUE)
		clowns[user] = human_target
		human_target.mind.add_memory("[user] is your master. Follow their orders at all costs.")
		var/datum/action/cooldown/spell/jaunt/bloodcrawl/clown_bloodcrawl = new
		var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/infinity_clown/clown_jaunt = new
		var/datum/action/cooldown/spell/blink/infinity_clown/clown_blink = new
		clown_bloodcrawl.Grant(human_target)
		clown_jaunt.Grant(human_target)
		clown_blink.Grant(human_target)
		ADD_TRAIT(human_target, TRAIT_BLOODCRAWL_WITH_ITEMS, "ghost_stone_clown")
		var/obj/item/knife/butcher/butcher_knife = new(get_turf(human_target))
		ADD_TRAIT(butcher_knife, TRAIT_NODROP, "ghost_stone_clown")
		butcher_knife.name = "clown's cursed knife"
		human_target.put_in_hands(butcher_knife, TRUE)
		var/human_target_mask = human_target.get_item_by_slot(ITEM_SLOT_MASK)
		if(human_target.dropItemToGround(human_target_mask))
			human_target.equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat, ITEM_SLOT_MASK)
		human_target.visible_message(span_danger("[human_target] struggles back up, now a clown!"))
		to_chat(human_target, span_userdanger("You are risen from the dead as a clown. [user] is your master. Follow their orders at all costs."))

/datum/action/cooldown/spell/conjure_item/spellpacket/sandmans_dust
	name = "Ghost Stone: Sandman's Dust"
	desc = "Gives you dust capable of knocking out most people."
	button_icon = 'monkestation/icons/obj/infinity.dmi'
	button_icon_state = "sandman"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "ghost"
	invocation = "POCKET SAND"
	invocation_type = "shout"
	item_type = /obj/item/spellpacket/sandman
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
	sound = 'monkestation/sound/effects/pocketsand.ogg'
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/blink/infinity_clown
	name = "Cluwne Blink"
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/infinity_clown
	name = "Cluwne Jaunt"
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
	jaunt_duration = 100

/////////////////////////////////////////////
///////////////// OTHER CRAP ////////////////
/////////////////////////////////////////////

/obj/item/spellpacket/sandman
	name = "\improper Sandman's dust"
	desc = "Some weird sand wrapped in cloth."
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY

/obj/item/spellpacket/sandman/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		if(isliving(hit_atom))
			var/mob/living/hit_living = hit_atom
			if(locate(/obj/item/badmin_gauntlet) in hit_living)
				to_chat(span_danger("[src] hits you, and you feel dizzy..."))
				hit_living.apply_status_effect(/datum/status_effect/dizziness)
				for(var/datum/action/cooldown/spell/spell in hit_living.actions)
					spell.StartCooldown()
					spell.update_button_status()
			else
				to_chat(span_danger("You're knocked out cold by [src]!"))
				hit_living.Unconscious(600)
		qdel(src)

/obj/projectile/spirit_fist
	name = "spiritual fist"
	icon_state = "bounty"
	damage = 3
	damage_type = BRUTE
