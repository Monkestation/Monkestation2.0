/mob/living/basic/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	mob_biotypes = MOB_SPIRIT
	maxHealth = 40
	health = 40
	speak_emote = list("hisses")
	response_help_continuous = "puts their hand through"
	response_help_simple = "put your hand through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	melee_damage_lower = 5
	melee_damage_upper = 12
	attack_verb_continuous = "metaphysically strikes"
	attack_verb_simple = "metaphysically strike"
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	speed = -1
	faction = list(FACTION_CULT)
	basic_mob_flags = DEL_ON_DEATH
	initial_language_holder = /datum/language_holder/construct
	/// Theme controls color. THEME_CULT is red THEME_WIZARD is purple and THEME_HOLY is blue
	var/theme = THEME_CULT
	/// The different flavors of goop shades can drop, depending on theme.
	var/static/list/remains_by_theme = list(
		THEME_CULT = list(/obj/item/ectoplasm/construct),
		THEME_HOLY = list(/obj/item/ectoplasm/angelic),
		THEME_WIZARD = list(/obj/item/ectoplasm/mystic),
	)
	var/soulblade_ritual = FALSE
	var/blade_harm = TRUE
	var/mob/master = null
	var/mob/living/carbon/human/body

/mob/living/basic/shade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	add_traits(list(TRAIT_HEALS_FROM_CULT_PYLONS, TRAIT_SPACEWALK, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)
	if(isnull(theme))
		return
	if(theme != THEME_CULT)
		icon = 'icons/mob/nonhuman-player/cult.dmi'
		icon_state = "shade_[theme]"
	var/list/remains = string_list(remains_by_theme[theme])
	if(length(remains))
		AddElement(/datum/element/death_drops, remains)

/mob/living/basic/shade/update_icon_state()
	. = ..()
	if(theme == THEME_CULT)
		return

	if(!isnull(theme))
		icon = 'icons/mob/nonhuman-player/cult.dmi'
		icon_state = "shade_[theme]"
	icon_living = icon_state

/mob/living/basic/shade/death()
	if(death_message == initial(death_message))
		death_message = "lets out a contented sigh as [p_their()] form unwinds."
	if(body)
		body.forceMove(get_turf(src))
		mind?.transfer_to(body)
	..()

/mob/living/basic/shade/can_suicide()
	if(istype(loc, /obj/item/soulstone)) //do not suicide inside the soulstone
		return FALSE
	return ..()

/mob/living/basic/shade/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/soulstone))
		var/obj/item/soulstone/stone = item
		stone.capture_shade(src, user)
	else if (istype(item, /obj/item/melee/soulblade))
		var/obj/item/melee/soulblade/blade = item
		blade.capture_shade(src, user)
	else
		. = ..()

/mob/living/basic/shade/Life()
	if (istype(loc, /obj/item/melee/soulblade))
		var/obj/item/melee/soulblade/SB = loc
		if (istype(SB.loc, /obj/structure/cult/altar))
			if (SB.blood < SB.maxblood)
				SB.blood = min(SB.maxblood, SB.blood+10)//fastest blood regen when planted on an altar
			if (SB.get_integrity() < SB.max_integrity)
				SB.update_integrity(min(SB.max_integrity, SB.get_integrity()+10))//and health regen on top
		else if (istype(SB.loc, /mob/living))
			var/mob/living/L = SB.loc
			if (IS_CULTIST(L) && SB.blood < SB.maxblood)
				SB.blood = min(SB.maxblood, SB.blood+3)//fast blood regen when held by a cultist (stacks with the one below for an effective +5)
		if (SB.linked_cultist && (get_dist(get_turf(SB.linked_cultist), get_turf(src)) <= 5))
			SB.blood = min(SB.maxblood, SB.blood+2)//slow blood regen when near your linked cultist
		if (SB.passivebloodregen < (SB.blood/3))
			SB.passivebloodregen++
		if ((SB.passivebloodregen >= (SB.blood/3)) && (SB.blood < SB.maxblood))
			SB.passivebloodregen = 0
			SB.blood++//very slow passive blood regen that goes slower and slower the more blood you currently have.
		SB.update_icon()

/mob/living/basic/shade/ClickOn(atom/A, params)
	. = ..()
	if (istype(loc, /obj/item/melee/soulblade))
		var/obj/item/melee/soulblade/SB = loc
		SB.dir = get_dir(get_turf(SB), A)
		var/datum/action/cooldown/spell/pointed/soulblade/blade_spin/BS = locate() in actions
		if (BS)
			BS.Activate(src)
			return

//Giving the spells
/mob/living/basic/shade/proc/give_blade_powers()
	if (!istype(loc, /obj/item/melee/soulblade))
		return
	DisplayUI("Soulblade")

	var/obj/item/melee/soulblade/SB = loc
	var/datum/control/new_control = new /datum/control/soulblade(src, SB)
	control_object = new_control
	new_control.take_control()

	grant_actions_by_list(list(
		/datum/action/cooldown/spell/pointed/soulblade/blade_kinesis,
		/datum/action/cooldown/spell/pointed/soulblade/blade_spin,
		/datum/action/cooldown/spell/pointed/soulblade/blade_perforate,
		/datum/action/cooldown/spell/pointed/soulblade/blade_mend,
		/datum/action/cooldown/spell/pointed/soulblade/blade_harm,
	))

//Removing the spells, this should always fire when the shade gets removed from the blade, such as when it gets destroyed
/mob/living/basic/shade/proc/remove_blade_powers()
	HideUI("Soulblade")
	for(var/datum/action/cooldown/spell/pointed/soulblade/spell_to_remove in actions)
		qdel(spell_to_remove)

/mob/living/basic/shade/proc/add_HUD(var/mob/user)
	DisplayUI("Soulblade")
