/////////////////////////////
//                          //
//    SELF TELEKINESIS      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////Not a real spell, but informs the player that moving consums blood.

/datum/action/cooldown/spell/pointed/soulblade
	panel = "Cult"
	button_icon = 'monkestation/code/modules/bloody_cult/icons/spells.dmi'
	background_icon = 'monkestation/code/modules/bloody_cult/icons/spells.dmi'
	background_icon_state = "const_spell_base"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/blood_cost = 0

/datum/action/cooldown/spell/pointed/soulblade/soulblade/PreActivate(atom/target)
	var/obj/item/weapon/melee/soulblade/SB = owner.loc
	if (SB.blood < blood_cost)
		to_chat(owner, span_danger("You don't have enough blood left for this move.") )
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/soulblade/after_cast(atom/cast_on)
	..()
	var/obj/item/weapon/melee/soulblade/SB = owner.loc
	SB.blood = max(0, SB.blood-blood_cost)
	var/mob/shade = owner
	shade.DisplayUI("Soulblade")


/datum/action/cooldown/spell/pointed/soulblade/blade_kinesis
	name = "Self Telekinesis"
	desc = "(1 BLOOD) Move yourself without the need of being held."
	button_icon_state = "souldblade_move"



//////////////////////////////Basic attack
//                          //Can be used by clicking anywhere on the screen for convenience
//        SPIN SLASH        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Attackes EVERY (almost) atoms on your turf, and the one in the direction you're facing.
//////////////////////////////That means unexpected behaviours are likely, for instance you can open doors, harvest meat off dead animals, or break important stuff

/datum/action/cooldown/spell/pointed/soulblade/blade_spin
	name = "Spin Slash"
	desc = "(5 BLOOD) Stop your momentum and cut in front of you."
	button_icon_state = "soulblade_spin"

	blood_cost = 5
	COOLDOWN_DECLARE(spin_cooldown) //gotta use that to get a more strict cooldown at such a small value

/datum/action/cooldown/spell/pointed/soulblade/blade_spin/PreActivate(atom/target)
	. = ..()
	if(!COOLDOWN_FINISHED(src, spin_cooldown))
		return

/datum/action/cooldown/spell/pointed/soulblade/blade_spin/cast(atom/cast_on)
	..()
	if(!COOLDOWN_FINISHED(src, spin_cooldown))
		return
	COOLDOWN_START(src, spin_cooldown, 1 SECONDS)
	var/obj/item/weapon/melee/soulblade/SB = owner.loc
	var/turf/source_turf = SB.loc
	SB.reflector = TRUE

	addtimer(VARSET_CALLBACK(SB, reflector, FALSE), 0.4 SECONDS)
	SB.throwing = FALSE

	if (istype(SB.loc, /obj/projectile))
		var/obj/projectile/P = SB.loc
		qdel(P)
	var/obj/structure/cult/altar/altar = cast_on
	var/turf/step_turf = get_step(source_turf, SB.dir)
	if (istype(altar))
		altar.attackby(SB, owner)
		return//gotta make sure we're not gonna bug ourselves out of the altar if there's one by hitting a table or something.
	flick("soulblade-spin", SB)
	for(var/atom/listed in source_turf.contents)
		if(listed == SB)
			continue

		listed.attackby(SB, owner)
	for(var/atom/listed in step_turf.contents)
		if(listed == SB)
			continue
		listed.attackby(SB, owner)

//////////////////////////////Puts the blade inside a bullet that shoots forward.
//                          //Can be used by drag n dropping from turf A to turf B. Will cause the bullet to fire first toward A then change direction toward B
//        PERFORATE         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //You need to hit at least two living mobs to make up for the cost of using this spell
//////////////////////////////The blade moves much faster from A to B than from starting to A

/datum/action/cooldown/spell/pointed/soulblade/blade_perforate
	name = "Perforate"
	desc = "(20 BLOOD) Hurl yourself through the air. You can cast this spell by doing a Drag n Drop with your mouse for more interesting trajectories. If you hit a cultist, they'll automatically grab you."
	button_icon_state = "soulblade_perforate"

	blood_cost = 20

/datum/action/cooldown/spell/pointed/soulblade/blade_perforate/cast(atom/cast_on, atom/second_cast)
	..()
	var/obj/item/weapon/melee/soulblade/blade = owner.loc
	if (istype(blade.loc, /obj/projectile))
		var/obj/projectile/P = blade.loc
		qdel(P)
	var/turf/starting = get_turf(blade)
	var/turf/target = cast_on
	var/obj/projectile/soulbullet/soul_bullet = new (starting)
	soul_bullet.preparePixelProjectile(target, starting)
	soul_bullet.secondary_target = second_cast
	soul_bullet.shade = owner
	soul_bullet.blade = blade
	blade.forceMove(soul_bullet)
	soul_bullet.fire()
	soul_bullet.process()


/client/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!mob || !isshade(mob) || !istype(mob.loc, /obj/item/weapon/melee/soulblade))
		return ..()
	var/obj/item/weapon/melee/soulblade/SB = mob.loc
	if(!isturf(src_location) || !isturf(over_location))
		return ..()
	if(src_location == over_location)
		return ..()
	var/datum/action/cooldown/spell/pointed/soulblade/blade_perforate/BP = locate() in mob.actions
	if (BP && isturf(SB.loc))
		BP.cast(src_location, over_location)


//////////////////////////////
//                          //Spend 10 blood -> Heal 10 brute damage on your wielder and clamp their bleeding wounds. Good trade, yes?
//        MEND              ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////

/datum/action/cooldown/spell/pointed/soulblade/blade_mend
	name = "Mend"
	desc = "(10 BLOOD) Heal some of your wielder's brute damage using your blood."
	button_icon_state = "soulblade_mend"

	blood_cost = 10

/datum/action/cooldown/spell/pointed/soulblade/blade_mend/cast(atom/cast_on)
	..()
	var/obj/item/weapon/melee/soulblade/SB = owner.loc
	var/mob/living/wielder = SB.loc
	if(istype(wielder, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = wielder
		for(var/datum/wound/wound as anything in H.all_wounds)
			wound.adjust_blood_flow(-20)

	//playsound(wielder.loc, 'sound/effects/mend.ogg', 50, 0, -2)
	wielder.adjustBruteLoss(-10)
	to_chat(owner, "You heal some of your wielder's wounds.")
	to_chat(wielder, "\The [owner] heals some of your wounds.")


//////////////////////////////
//                          //
//    TOGGLE BLADE HARM     ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////

/datum/action/cooldown/spell/pointed/soulblade/blade_harm
	name = "Toggle Harm to Non-Masters"
	desc = "(FREE) Change whether you allow people who aren't either cultists or the person that soulstone'd you to wield you."
	button_icon_state = "soulblade_harm"

/datum/action/cooldown/spell/pointed/soulblade/blade_harm/cast(atom/cast_on)
	. = ..()
	var/mob/living/basic/shade/user = owner
	if (istype(user))
		if (user.blade_harm)
			user.blade_harm = FALSE
			button_icon_state = "soulblade_calm"
			to_chat(user, span_notice("You now allow anyone to wield you.") )
		else
			user.blade_harm = TRUE
			button_icon_state = "soulblade_harm"
			to_chat(user, span_notice("You now harm and make dizzy miscreants trying to wield you.") )

		var/obj/item/weapon/melee/soulblade/SB = user.loc
		if (istype(SB))
			var/mob/living/M = SB.loc//bloke holding the blade
			if (istype(M) && !IS_CULTIST(M) && (user.master != M))
				if (user.blade_harm)
					M.adjust_dizzy(120)
					to_chat(M, span_warning("You feel a chill as \the [SB]'s murderous intents suddenly turn against you.") )
				else
					M.adjust_dizzy(-120)
					to_chat(M, span_notice("\The energies emanated by the [SB] subside a little, allowing you to wield it.") )
