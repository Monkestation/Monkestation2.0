/obj/item/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie. It features a nice round socket at the base of its obsidian blade."
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "cultblade"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	sharpness = SHARP_EDGED
	block_chance = 50 // now it's officially a cult esword
	wound_bonus = -50
	bare_wound_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")

	var/checkcult = 1


/obj/item/melee/cultblade/salt_act()
	new /obj/item/melee/cultblade/nocult(loc)
	qdel(src)

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 4 SECONDS, \
	effectiveness = 100, \
	)

/obj/item/melee/cultblade/narsie_act()
	return

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!checkcult)
		return ..()
	if (IS_CULTIST(user))
		if (!IS_CULTIST(target) && target.stat != DEAD)
			var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
			if (target.mind)
				cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_cultblade", target)
			else
				cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_cultblade_nomind", target)
		if (ishuman(target) && target.resting)
			var/obj/structure/cult/altar/altar = locate() in target.loc
			if (altar)
				altar.attackby(src, user)
				return
			else
				return ..()
		else
			return ..()
	else
		user.Paralyze(0.5 SECONDS)
		user.dropItemToGround(src, TRUE)
		to_chat(user, span_warning("An unexplicable force powerfully repels \the [src] from [target]!") )

/obj/item/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(checkcult && !IS_CULTIST(user))
		to_chat(user, span_warning("An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.") )
		user.set_dizzy(12 SECONDS)


/obj/item/melee/cultblade/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/soulstone/gem))
		var/turf/T = get_turf(user)
		playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
		user.dropItemToGround(src)
		var/obj/item/melee/soulblade/SB = new (T)
		spawn(1)
			user.put_in_active_hand(SB)
			if (IS_CULTIST(user))
				SB.linked_cultist = user
				to_chat(SB.shade, "<spawn class = 'notice'>You have made contact with [user]. As long as you remain within 5 tiles of them, you can move by yourself without losing blood, and regenerate blood passively at a faster rate.</span>")
		var/obj/item/soulstone/gem/sgem = I
		var/mob/living/basic/shade/shadeMob = locate(/mob/living/basic/shade) in sgem.contents
		if (shadeMob)
			shadeMob.forceMove(SB)
			SB.shade = shadeMob
			sgem.contents -= shadeMob
			if (shadeMob.mind)
				shadeMob.give_blade_powers()
			else
				to_chat(user, span_warning("Although the game appears to hold a shade, it somehow doesn't appear to have a mind capable of manipulating the blade.") )
				to_chat(user, span_danger("(that's a bug, call Deity, and tell him exactly how you obtained that shade).") )
				message_admins("[key_name(usr)] somehow placed a soul gem containing a shade with no mind inside a soul blade.")
		SB.update_icon()
		qdel(sgem)
		qdel(src)
		return 1
	if(istype(I, /obj/item/soulstone))
		to_chat(user, span_warning("\The [I] doesn't fit in \the [src]'s socket.") )
		return 1
	..()


/obj/item/melee/cultblade/nocult
	name = "broken cult blade"
	desc = "What remains of an arcane weapon wielded by the followers of Nar-Sie. In this state, it can be held mostly without risks."
	icon_state = "cultblade-broken"
	checkcult = 0
	force = 15

/obj/item/melee/cultblade/nocult/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/talisman) || istype(I, /obj/item/paper))
		return 1
	..()


/obj/item/melee/cultblade/dagger
	name = "ritual dagger"
	desc = "A strange dagger said to be used by sinister groups for \"preparing\" a corpse before sacrificing it to their dark gods."
	icon = 'icons/obj/cult/items_and_weapons.dmi'
	icon_state = "render"
	inhand_icon_state = "cultdagger"
	worn_icon_state = "render"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	block_chance = 25
	wound_bonus = -10
	bare_wound_bonus = 20
	armour_penetration = 35
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/blood.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", silicon_image)

	var/examine_text = {"Allows the scribing of blood runes of the cult of Nar'Sie.
Hitting a cult structure will unanchor or reanchor it. Cult Girders will be destroyed in a single blow.
Can be used to scrape blood runes away, removing any trace of them.
Striking another cultist with it will purge all holy water from them and transform it into unholy water.
Striking a noncultist, however, will tear their flesh."}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text))

/obj/item/melee/cultblade/dagger/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/block_message = "[owner] parries [attack_text] with [src]"
	if(owner.get_active_held_item() != src)
		block_message = "[owner] parries [attack_text] with [src] in their offhand"

	if(IS_CULTIST(owner) && prob(final_block_chance) && attack_type != PROJECTILE_ATTACK)
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		owner.visible_message(span_danger("[block_message]"))
		return TRUE
	else
		return FALSE

/obj/item/melee/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE
	block_chance = 25 //these dweebs don't get full block chance, because they're free cultists
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))

/datum/action/innate/dash/cult
	name = "Rend the Veil"
	desc = "Use the sword to shear open the flimsy fabric of this reality and teleport to your target."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/IsAvailable(feedback = FALSE)
	if(IS_CULTIST(owner) && current_charges)
		return TRUE
	else
		return FALSE


/obj/item/melee/cultblade/halberd
	name = "bloody halberd"
	desc = "A halberd with a volatile axehead made from crystallized blood. It seems linked to its creator. And, admittedly, more of a poleaxe than a halberd."
	icon = 'icons/obj/cult/items_and_weapons.dmi'
	icon_state = "occultpoleaxe0"
	base_icon_state = "occultpoleaxe"
	inhand_icon_state = "occultpoleaxe0"
	w_class = WEIGHT_CLASS_HUGE
	force = 17
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	slot_flags = null
	attack_verb_continuous = list("attacks", "slices", "shreds", "sunders", "lacerates", "cleaves")
	attack_verb_simple = list("attack", "slice", "shred", "sunder", "lacerate", "cleave")
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	var/datum/action/innate/cult/halberd/halberd_act

/obj/item/melee/cultblade/halberd/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 90, \
	)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 17, \
		force_wielded = 24, \
	)

/obj/item/melee/cultblade/halberd/update_icon_state()
	icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "[base_icon_state]1" : "[base_icon_state]0"
	inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "[base_icon_state]1" : "[base_icon_state]0"
	return ..()

/obj/item/melee/cultblade/halberd/Destroy()
	if(halberd_act)
		QDEL_NULL(halberd_act)
	return ..()

/obj/item/melee/cultblade/halberd/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom

		if(IS_CULTIST(target) && target.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			target.visible_message(span_warning("[target] catches [src] out of the air!"))
			return
		if(target.can_block_magic() || IS_CULTIST(target))
			target.visible_message(span_warning("[src] bounces off of [target], as if repelled by an unseen force!"))
			return
		if(!..())
			target.Paralyze(50)
			break_halberd(T)
	else
		..()

/obj/item/melee/cultblade/halberd/proc/break_halberd(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message(span_warning("[src] shatters and melts back into blood!"))
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/melee/cultblade/halberd/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		final_block_chance *= 2
	if(IS_CULTIST(owner) && prob(final_block_chance))
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/halberd
	name = "Bloody Bond"
	desc = "Call the bloody halberd back to your hand!"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon_state = "bloodspear"
	default_button_position = "6:157,4:-2"
	var/obj/item/melee/cultblade/halberd/halberd
	var/cooldown = 0

/datum/action/innate/cult/halberd/Grant(mob/user, obj/blood_halberd)
	. = ..()
	halberd = blood_halberd

/datum/action/innate/cult/halberd/Activate()
	if(owner == halberd.loc || cooldown > world.time)
		return
	var/halberd_location = get_turf(halberd)
	var/owner_location = get_turf(owner)
	if(get_dist(owner_location, halberd_location) > 10)
		to_chat(owner,span_cult("The halberd is too far away!"))
	else
		cooldown = world.time + 20
		if(isliving(halberd.loc))
			var/mob/living/current_owner = halberd.loc
			current_owner.dropItemToGround(halberd)
			current_owner.visible_message(span_warning("An unseen force pulls the bloody halberd from [current_owner]'s hands!"))
		halberd.throw_at(owner, 10, 2, owner)
