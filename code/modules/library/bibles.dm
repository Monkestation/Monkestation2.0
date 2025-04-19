GLOBAL_LIST_INIT(biblenames, list(
	"Bible",
	"Quran",
	"Scrapbook",
	"Burning Bible",
	"Clown Bible",
	"Banana Bible",
	"Creeper Bible",
	"White Bible",
	"Holy Light",
	"The God Delusion",
	"Tome",
	"The King in Yellow",
	"Ithaqua",
	"Scientology",
	"Melted Bible",
	"Necronomicon",
	"Insulationism",
	"Guru Granth Sahib",
	"Kojiki",
))
//If you get these two lists not matching in size, there will be runtimes and I will hurt you in ways you couldn't even begin to imagine
// if your bible has no custom itemstate, use one of the existing ones
GLOBAL_LIST_INIT(biblestates, list(
	"bible",
	"koran",
	"scrapbook",
	"burning",
	"honk1",
	"honk2",
	"creeper",
	"white",
	"holylight",
	"atheist",
	"tome",
	"kingyellow",
	"ithaqua",
	"scientology",
	"melted",
	"necronomicon",
	"insuls",
	"gurugranthsahib",
	"kojiki",
))
GLOBAL_LIST_INIT(bibleitemstates, list(
	"bible",
	"koran",
	"scrapbook",
	"burning",
	"honk1",
	"honk2",
	"creeper",
	"white",
	"holylight",
	"atheist",
	"tome",
	"kingyellow",
	"ithaqua",
	"scientology",
	"melted",
	"necronomicon",
	"kingyellow",
	"gurugranthsahib",
	"kojiki",
))

/obj/item/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage/book.dmi'
	icon_state = "bible"
	worn_icon_state = "bible"
	inhand_icon_state = "bible"
	lefthand_file = 'icons/mob/inhands/items/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/books_righthand.dmi'
	force_string = "holy"
	unique = TRUE
	/// Deity this bible is related to
	var/deity_name = "Space Jesus"

/obj/item/book/bible/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE_HOLY)
	carve_out()

/obj/item/book/bible/examine(mob/user)
	. = ..()
	if(deity_name)
		. += span_notice("This bible has been approved by [deity_name].")
	if(user.mind?.holy_role)
		if(GLOB.chaplain_altars.len)
			. += span_notice("[src] has an expansion pack to replace any broken Altar.")
		else
			. += span_notice("[src] can be unpacked by hitting the floor of a holy area with it.")

/obj/item/book/bible/burn_paper_product_attackby_check(obj/item/attacking_item, mob/living/user, bypass_clumsy)
	. = ..()
	// no deity to cast a curse upon thee
	if(!deity_name)
		return
	if(. && (resistance_flags & ON_FIRE))
		var/datum/component/omen/existing_omen = user.GetComponent(/datum/component/omen)
		//DOUBLE CURSED?! Just straight up gib the guy.
		if(existing_omen)
			to_chat(user, span_userdanger("[deity_name] <b>SMITE</b> thee!"))
			add_memory_in_range(user, 7, /datum/memory/witnessed_gods_wrath, protagonist = user, deuteragonist = src, antagonist = deity_name)
			user.client?.give_award(/datum/award/achievement/misc/gods_wrath, user)
			user.gib()
		else
			to_chat(user, span_userdanger("[deity_name] cast a curse upon thee!"))
			user.AddComponent(/datum/component/omen/bible)

/obj/item/book/bible/carve_out(obj/item/carving_item, mob/living/user)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/book/bible/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is offering [user.p_them()]self to [deity_name]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/book/bible/attack_self(mob/living/carbon/human/user)
	if(GLOB.bible_icon_state)
		return FALSE
	if(user?.mind?.holy_role != HOLY_ROLE_HIGHPRIEST)
		return FALSE

	var/list/skins = list()
	for(var/i in 1 to GLOB.biblestates.len)
		var/image/bible_image = image(icon = 'icons/obj/storage/book.dmi', icon_state = GLOB.biblestates[i])
		skins += list("[GLOB.biblenames[i]]" = bible_image)

	var/choice = show_radial_menu(user, src, skins, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 40, require_near = TRUE)
	if(!choice)
		return FALSE
	var/bible_index = GLOB.biblenames.Find(choice)
	if(!bible_index)
		return FALSE
	icon_state = GLOB.biblestates[bible_index]
	inhand_icon_state = GLOB.bibleitemstates[bible_index]

	switch(icon_state)
		if("honk1")
			user.dna.add_mutation(/datum/mutation/human/clumsy)
			user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(user), ITEM_SLOT_MASK)
			AddComponent(/datum/component/slippery, 40) //Same as a synthesized banana peel.
		if("honk2")
			user.dna.add_mutation(/datum/mutation/human/clumsy)
			user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(user), ITEM_SLOT_MASK)
			AddComponent(/datum/component/slippery, 40) //Same as a synthesized banana peel.
		if("insuls")
			var/obj/item/clothing/gloves/color/fyellow/insuls = new
			insuls.name = "insuls"
			insuls.desc = "A mere copy of the true insuls."
			insuls.siemens_coefficient = 0.99999
			user.equip_to_slot(insuls, ITEM_SLOT_GLOVES)
	GLOB.bible_icon_state = icon_state
	GLOB.bible_inhand_icon_state = inhand_icon_state
	SSblackbox.record_feedback("text", "religion_book", 1, "[choice]")

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with the menu
 */
/obj/item/book/bible/proc/check_menu(mob/living/carbon/human/user)
	if(GLOB.bible_icon_state)
		return FALSE
	if(!istype(user) || !user.is_holding(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.mind?.holy_role != HOLY_ROLE_HIGHPRIEST)
		return FALSE
	return TRUE

/obj/item/book/bible/proc/make_new_altar(atom/bible_smacked, mob/user)
	var/new_altar_area = get_turf(bible_smacked)

	balloon_alert(user, "unpacking bible...")
	if(!do_after(user, 15 SECONDS, new_altar_area))
		return
	new /obj/structure/altar_of_gods(new_altar_area)
	qdel(src)

/obj/item/book/bible/proc/bless(mob/living/blessed, mob/living/user)
	if(GLOB.religious_sect)
		return GLOB.religious_sect.sect_bless(blessed,user)
	if(!ishuman(blessed))
		return
	var/mob/living/carbon/human/built_in_his_image = blessed
	for(var/obj/item/bodypart/bodypart as anything in built_in_his_image.bodyparts)
		if(!IS_ORGANIC_LIMB(bodypart))
			balloon_alert(user, "can't heal metal!")
			return FALSE

	var/heal_amt = 10
	var/list/hurt_limbs = built_in_his_image.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC)
	if(length(hurt_limbs))
		for(var/obj/item/bodypart/affecting as anything in hurt_limbs)
			if(affecting.heal_damage(heal_amt, heal_amt, BODYTYPE_ORGANIC))
				built_in_his_image.update_damage_overlays()
		built_in_his_image.visible_message(span_notice("[user] heals [built_in_his_image] with the power of [deity_name]!"))
		to_chat(built_in_his_image, span_boldnotice("May the power of [deity_name] compel you to be healed!"))
		playsound(built_in_his_image, SFX_PUNCH, 25, TRUE, -1)
		built_in_his_image.add_mood_event("blessing", /datum/mood_event/blessing)
	return TRUE

/obj/item/book/bible/attack(mob/living/target_mob, mob/living/carbon/human/user, params, heal_mode = TRUE)
	if(!ISADVANCEDTOOLUSER(user))
		balloon_alert(user, "not dextrous enough!")
		return

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_danger("[src] slips out of your hand and hits your head."))
		user.take_bodypart_damage(10)
		user.Unconscious(40 SECONDS)
		return

	if(!user.mind?.holy_role)
		to_chat(user, span_danger("The book sizzles in your hands."))
		user.take_bodypart_damage(burn = 10)
		return

	if(!heal_mode)
		return ..()

	if(target_mob.stat == DEAD)
		target_mob.visible_message(span_danger("[user] smacks [target_mob]'s lifeless corpse with [src]."))
		playsound(target_mob, SFX_PUNCH, 25, TRUE, -1)
		return

	if(user == target_mob)
		balloon_alert(user, "can't heal yourself!")
		return

	var/smack = TRUE
	if(prob(60) && bless(target_mob, user))
		smack = FALSE
	else if(iscarbon(target_mob))
		var/mob/living/carbon/carbon_target = target_mob
		if(!istype(carbon_target.head, /obj/item/clothing/head/helmet))
			carbon_target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 60)
			carbon_target.balloon_alert(carbon_target, "you feel dumber!")
	if(smack)
		target_mob.visible_message(span_danger("[user] beats [target_mob] over the head with [src]!"), \
				span_userdanger("[user] beats [target_mob] over the head with [src]!"))
		playsound(target_mob, SFX_PUNCH, 25, TRUE, -1)
		log_combat(user, target_mob, "attacked", src)

/obj/item/book/bible/afterattack(atom/bible_smacked, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(SEND_SIGNAL(bible_smacked, COMSIG_BIBLE_SMACKED, user, proximity_flag, click_parameters) & COMSIG_END_BIBLE_CHAIN)
		return . | AFTERATTACK_PROCESSED_ITEM
	if(isfloorturf(bible_smacked))
		if(user.mind?.holy_role)
			var/area/current_area = get_area(bible_smacked)
			if(!GLOB.chaplain_altars.len && istype(current_area, /area/station/service/chapel))
				make_new_altar(bible_smacked, user)
				return
			for(var/obj/effect/rune/nearby_runes in range(2, user))
				nearby_runes.invisibility = 0
		bible_smacked.balloon_alert(user, "floor smacked!")

	if(user.mind?.holy_role)
		if(bible_smacked.reagents && bible_smacked.reagents.has_reagent(/datum/reagent/water)) // blesses all the water in the holder
			. |= AFTERATTACK_PROCESSED_ITEM
			bible_smacked.balloon_alert(user, "blessed")
			var/water2holy = bible_smacked.reagents.get_reagent_amount(/datum/reagent/water)
			bible_smacked.reagents.del_reagent(/datum/reagent/water)
			bible_smacked.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)
		if(bible_smacked.reagents && bible_smacked.reagents.has_reagent(/datum/reagent/fuel/unholywater)) // yeah yeah, copy pasted code - sue me
			. |= AFTERATTACK_PROCESSED_ITEM
			bible_smacked.balloon_alert(user, "purified")
			var/unholy2holy = bible_smacked.reagents.get_reagent_amount(/datum/reagent/fuel/unholywater)
			bible_smacked.reagents.del_reagent(/datum/reagent/fuel/unholywater)
			bible_smacked.reagents.add_reagent(/datum/reagent/water/holywater,unholy2holy)
		if(istype(bible_smacked, /obj/item/book/bible) && !istype(bible_smacked, /obj/item/book/bible/syndicate))
			. |= AFTERATTACK_PROCESSED_ITEM
			bible_smacked.balloon_alert(user, "converted")
			var/obj/item/book/bible/other_bible = bible_smacked
			other_bible.name = name
			other_bible.icon_state = icon_state
			other_bible.inhand_icon_state = inhand_icon_state
			other_bible.deity_name = deity_name

	if(istype(bible_smacked, /obj/item/cult_bastard) && !IS_CULTIST(user))
		. |= AFTERATTACK_PROCESSED_ITEM
		var/obj/item/cult_bastard/sword = bible_smacked
		bible_smacked.balloon_alert(user, "exorcising...")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,TRUE)
		if(do_after(user, 4 SECONDS, target = sword))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,TRUE)
			for(var/obj/item/soulstone/stone in sword.contents)
				stone.required_role = null
				for(var/mob/living/basic/shade/shade in stone)
					var/datum/antagonist/cult/cultist = shade.mind.has_antag_datum(/datum/antagonist/cult)
					if(cultist)
						cultist.silent = TRUE
						cultist.on_removal()
					shade.icon_state = "shade_holy"
					shade.name = "Purified [shade.name]"
				stone.release_shades(user)
				qdel(stone)
			new /obj/item/nullrod/claymore(get_turf(sword))
			user.visible_message(span_notice("[user] exorcises [sword]!"))
			qdel(sword)

/obj/item/book/bible/booze
	desc = "To be applied to the head repeatedly."

/obj/item/book/bible/booze/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/cup/glass/bottle/whiskey(src)

/obj/item/book/bible/syndicate
	name = "Syndicate Tome"
	desc = "A very ominous tome resembling a bible."
	icon_state ="ebook"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	item_flags = NO_BLOOD_ON_ITEM
	throw_speed = 2
	throw_range = 7
	throwforce = 18
	force = 18
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb_continuous = list("attacks", "burns", "blesses", "damns", "scorches", "curses", "smites")
	attack_verb_simple = list("attack", "burn", "bless", "damn", "scorch", "curses", "smites")
	deity_name = "The Syndicate"
	var/uses = 1
	var/owner_name

/obj/item/book/bible/syndicate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "BEGONE FOUL MAGIKS!!", \
		tip_text = "Clear rune", \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune, /obj/effect/cosmic_rune), \
	)
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)

/obj/item/book/bible/syndicate/attack_self(mob/living/carbon/human/user, modifiers)
	if(!uses || !istype(user))
		return
	user.mind.holy_role = HOLY_ROLE_PRIEST
	uses -= 1
	to_chat(user, span_userdanger("You try to open the book AND IT BITES YOU!"))
	playsound(src.loc, 'sound/effects/snap.ogg', 50, TRUE)
	var/active_hand_zone = (!(user.active_hand_index % RIGHT_HANDS) ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM)
	user.apply_damage(5, BRUTE, active_hand_zone, attacking_item = src)
	to_chat(user, span_notice("Your name appears on the inside cover, in blood."))
	owner_name = user.real_name

/obj/item/book/bible/syndicate/examine(mob/user)
	. = ..()
	if(owner_name)
		. += span_warning("The name [owner_name] is written in blood inside the cover.")

/obj/item/book/bible/syndicate/attack(mob/living/target_mob, mob/living/carbon/human/user, params, heal_mode = TRUE)
	if(!(user.istate & ISTATE_HARM))
		return ..()
	else
		return ..(target_mob, user, heal_mode = FALSE)

/obj/item/book/bible/attack(mob/living/target_mob, mob/living/carbon/human/user, params, heal_mode)
	. = ..()
	//they have holy water in them? deconversion mode activate! anyone can do it. 'cept cultists O B V I O U S L Y
	if (!IS_CULTIST(user) && target_mob.reagents?.has_reagent(/datum/reagent/water/holywater) && !(user.istate & ISTATE_HARM))
		playsound(src, "punch", 25, 1, -1)
		if (target_mob.stat == DEAD)
			to_chat(user, span_warning("You cannot deconvert the dead!") )
			return 1
		if (target_mob.health < 20)
			to_chat(user, span_warning("\The [target_mob] is too weak to handle the deconversion ritual, patch them up a bit first.") )
			return 1
		var/datum/antagonist/cult/cultist
		if(IS_CULTIST(target_mob))
			cultist = target_mob.mind?.has_antag_datum(/datum/antagonist/cult)
			if (cultist.deconversion)
				to_chat(user, span_warning("There is already a deconversion attempt undergoing!") )
				return 1
			else
				to_chat(target_mob, span_userdanger("They are trying to deconvert you!") )
				cultist.deconversion = 1//arbitrary non-null value to prevent deconversion-shade spam, will get replaced with a /datum/deconversion_ritual 5 seconds later

		if (do_after(user, 5 SECONDS, target_mob))
			if(cultist)
				to_chat(user, span_warning("In the name of [deity_name], Nar-Sie forsake this body and soul!") )
				user.visible_message(span_warning("\The [target_mob] begins to radiate with light.") )
				new /datum/deconversion_ritual(user, target_mob, src)
			else
				to_chat(user, span_warning("In the name of [deity_name], Nar-Sie forsake this body and soul!") )
				user.visible_message(span_warning("...but nothing unusual happens.") )
		else
			cultist.deconversion = null//deconversion attempt got interrupted, you can now try again
		return 1

/datum/deconversion_ritual
	var/datum/antagonist/cult/cultist = null
	var/cult_chaplain = FALSE
	var/last_cultist = FALSE
	var/success = DECONVERSION_ACCEPT

/datum/deconversion_ritual/New(mob/living/deconverter, mob/living/deconvertee, obj/item/book/bible/bible)
	..()
	if (!bible || !bible.deity_name || !deconverter || !deconvertee || !IS_CULTIST(deconvertee))
		qdel(src)
		return
	var/mob/target
	deconvertee.overlays += image('monkestation/code/modules/bloody_cult/icons/effects.dmi', src, "deconversion")
	playsound(deconvertee, 'monkestation/code/modules/bloody_cult/sound/deconversion_start.ogg', 50, 0, -4)
	cultist = IS_CULTIST(deconvertee)
	cultist.deconversion = src

	deconvertee.adjust_dizzy(30)
	deconvertee.adjust_stutter(10)
	deconvertee.adjust_jitter(30)
	deconvertee.Paralyze(10 SECONDS)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	var/living_cultists = 0
	for(var/datum/mind/mind in cult.members)
		if (mind.current.stat != DEAD)
			living_cultists++
	if (living_cultists <= 1)
		last_cultist = TRUE

	spawn()
		spawn()
			if (alert(deconvertee, "You are being compelled by the powers of [bible.deity_name][cult_chaplain ? " (wait what?)" : ""] to give up on serving the Cult of Nar-Sie[cult_chaplain ? " (huh!?)" : ""]", "You have 10 seconds to decide", "[!cult_chaplain ? "Abandon the Cult" : "I am so confused right now, ok I guess?"]", "[!cult_chaplain ? "Resist!" : "This is obviously a trick! Resist!"]") == "[!cult_chaplain ? "Abandon the Cult" : "I am so confused right now, ok I guess?"]")
				success = DECONVERSION_ACCEPT
				if (!target && !last_cultist)//no threats if nobody remains to carry them out.
					to_chat(deconvertee, span_cult("[cult_chaplain ? "WERE YOU DECEIVED THAT EASILY? SO BE IT THEN." : "THERE WILL BE A PRICE."]") )
			else
				success = DECONVERSION_REFUSE
				if (!target)
					to_chat(deconvertee, span_warning("You block the sweet promises of forgiveness from your mind.") )
		new /obj/effect/bible_spin(get_turf(deconvertee), deconverter ,bible)
		sleep(10 SECONDS)
		if (!deconvertee || !IS_CULTIST(deconvertee))
			qdel(src)
			return
		deconvertee.take_overall_damage(10)//it's a painful process no matter what.
		var/turf/T = get_turf(deconvertee)
		anim(target = deconvertee, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "cult_jaunt_land", plane = GAME_PLANE_UPPER)

		switch(success)
			if (DECONVERSION_ACCEPT)
				var/mob/living/basic/shade/redshade_A = new(T)
				var/mob/living/basic/shade/redshade_B = new(T)
				var/list/adjacent_turfs = list()
				for (var/turf/U in orange(1, T))
					adjacent_turfs += U
				playsound(deconvertee, 'monkestation/code/modules/bloody_cult/sound/deconversion_complete.ogg', 50, 0, -4)
				deconvertee.visible_message(span_notice("You see [deconvertee]'s eyes become clear. Through the blessing of [cult_chaplain ? "some fanfic headcanon version of [bible.deity_name]" : "[bible.deity_name]"] they have renounced Nar-Sie.") , span_notice("You were forgiven by [bible.deity_name]</span><span class = 'sinister'>[cult_chaplain ? " (YEAH RIGHT...)" : ""]</span><span class = 'notice'>. You no longer share the cult's goals.") )
				deconvertee.visible_message(span_userdanger("A pair of shades manifests from the occult energies that left them and start attacking them.") )
				cultist.owner.current.add_particles(PS_CULT_HALO)
				cultist.owner.current.adjust_particles(PVAR_COLOR, "#00000066", PS_CULT_HALO)
				cultist.owner.current.adjust_particles(PVAR_ICON_STATE, "cult_halo[cultist.get_devotion_rank()]", PS_CULT_HALO)
				cultist.owner.remove_antag_datum(/datum/antagonist/cult)
				var/list/speak = list("...you shall give back the blood we gave you [deconvertee]...", "...one does not simply turn their back on our gift...", "...if you won't dedicate your heart to Nar-Sie, you don't need it anymore...")
				redshade_A.say(pick(speak))
				redshade_B.say(pick(speak))
				target = deconvertee
				spawn(1)
					redshade_A.forceMove(get_turf(pick(adjacent_turfs)))
					redshade_B.forceMove(get_turf(pick(adjacent_turfs)))
					redshade_A.melee_attack(deconvertee)
					redshade_B.melee_attack(deconvertee)
					animate(redshade_A, alpha = 0, time = 2.5 SECONDS)
					animate(redshade_B, alpha = 0, time = 2.5 SECONDS)
					QDEL_IN(redshade_A, 3 SECONDS)
					QDEL_IN(redshade_B, 3 SECONDS)
					deconvertee.blood_volume -= 100 // ouch

			if (DECONVERSION_REFUSE)
				playsound(deconvertee, 'monkestation/code/modules/bloody_cult/sound/deconversion_failed.ogg', 50, 0, -4)
				to_chat(deconvertee, span_notice("You manage to block out the exorcism.") )
				deconvertee.visible_message(span_userdanger("The ritual was resisted!") , span_warning("The energies you mustered take their toll on your body...") )
		deconvertee.overlays -= image('monkestation/code/modules/bloody_cult/icons/effects.dmi', src, "deconversion")
		qdel(src)

/datum/deconversion_ritual/Destroy()
	if (cultist)
		cultist.deconversion = null
	cultist = null
	..()

// Belmont Bible Spin

/obj/effect/bible_spin
	var/mob/living/owner
	var/obj/item/book/bible/source
	var/image/bible_image
	var/current_spin = 0
	var/lifetime = 10 SECONDS
	var/lifetime_max = 10 SECONDS
	var/distance = 0
	var/distance_min = 8
	var/distance_amplitude = 24
	var/spin_speed = 30

/obj/effect/bible_spin/New(var/turf/loc, var/_owner, var/_source)
	..()
	if (!_owner || !_source)
		qdel(src)
		return
	playsound(src, 'monkestation/code/modules/bloody_cult/sound/bible_throw.ogg', 70, 0)
	owner = _owner
	source = _source
	source.forceMove(src)
	//owner.lock_atom(src)
	current_spin = dir2angle(owner.dir)
	bible_image = image(source.icon, source, source.icon_state)
	bible_image.plane = ABOVE_LIGHTING_PLANE
	overlays += bible_image
	spawn()
		process_spin()

/obj/effect/bible_spin/proc/process_spin()
	set waitfor = 0

	while(owner && !QDELETED(owner)&& source && !QDELETED(source) && (source.loc == src) && lifetime > 0)
		update_spin()
		var/obj/effect/afterimage/A = new(loc, null, 15)
		animate(A)
		A.appearance = appearance
		A.pixel_x = pixel_x
		A.pixel_y = pixel_y
		animate(A, alpha = 0, time = 10)
		A.layer--
		A.add_particles(PS_BIBLE_PAGE)
		A.adjust_particles(PVAR_VELOCITY, list(pixel_x/2, pixel_y/2), PS_BIBLE_PAGE)
		A.adjust_particles(PVAR_SPAWNING, 2, PS_BIBLE_PAGE)
		if ((lifetime % 10) == 0)
			playsound(src, 'monkestation/code/modules/bloody_cult/sound/bible_spin.ogg', 50, 0)
			for (var/mob/living/L in range(1, src))
				source.throw_impact(L, source.throw_speed*2, owner)
		lifetime--
		spawn(1)//making sure we're only spawning one page per afterimage
			A.adjust_particles(PVAR_SPAWNING, 0, PS_BIBLE_PAGE)
		sleep(1)

	if (source && !QDELETED(source))
		source.forceMove(loc)
		if (owner)
			owner.put_in_hands(source)
	qdel(src)

/obj/effect/bible_spin/proc/update_spin()
	current_spin += spin_speed
	distance = distance_min + distance_amplitude*sin(180*(lifetime/lifetime_max))
	animate(src, pixel_x = distance*cos(current_spin), pixel_y = distance*sin(current_spin), time = 1)
