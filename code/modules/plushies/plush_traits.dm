/datum/plush_trait
	var/name = "Buggy Nonsense"
	var/desc = "means that the neurodivergent frog guy did a fail. Please report this thing's presence with the report issue button. Include how you found it, please."
	var/examine_text = ""
	var/removable = TRUE
	var/processes = FALSE
	var/shapestring_icon_state = ""
	var/list/recipe = list()
	var/flags
	var/tier = 1
	var/category
	var/list/incompatible_traits = list()

/datum/plush_trait/proc/activate(obj/item/toy/plush/plush)
	if(flags)
		plush.plush_flags |= flags
	return

/datum/plush_trait/proc/deactivate(obj/item/toy/plush/plush)
	if(flags)
		plush.plush_flags &= ~(flags)
	return

/datum/plush_trait/proc/process_trigger(seconds_per_tick, obj/item/toy/plush/plush)
	return

/datum/plush_trait/proc/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	return

/datum/plush_trait/prickly
	name = "Cactaceous"
	desc = "shapes the fabric of the plush into microscopic spines, which, though mostly harmless, are extremely painful."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/prickly/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	var/ouched = TRUE
	if(iscarbon(squeezer))
		var/mob/living/carbon/carbsqueezer = squeezer
		if(carbsqueezer.gloves && !HAS_TRAIT(carbsqueezer.gloves, TRAIT_FINGERPRINT_PASSTHROUGH))
			ouched = FALSE
		if(HAS_TRAIT(carbsqueezer, TRAIT_PIERCEIMMUNE))
			ouched = FALSE
		if(!ouched)
			return
		to_chat(carbsqueezer, span_warning("Your hand stings horribly with a wave of needling pain!"))
		var/ouchy_arm = (carbsqueezer.get_held_index_of_item(plush) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
		carbsqueezer.apply_damage(1, BRUTE, ouchy_arm)





/datum/plush_trait/life_sponge
	name = "Viviphagous"
	desc = "allows the plush to absorb and infuse the life forces of any who hug it. Squeeze it HARMfully to give and HELPfully to take. The longer either process goes, the more potent the drain or infusion."
	var/stored_flesh = 0
	var/stored_blood = 0
	var/stored_life = 0
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	tier = 3
	recipe = list(/datum/plush_trait/wet, /datum/plush_trait/bloody, /datum/plush_trait/energetic)

/datum/plush_trait/life_sponge/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	if(!ishuman(squeezer))
		return
	var/mob/living/carbon/human/humsqueezer = squeezer
	if((humsqueezer.istate & ISTATE_HARM) || istype(humsqueezer.client?.imode, /datum/interaction_mode/combat_mode))
		var/numcycles = 0
		humsqueezer.visible_message(span_warning("[plush] prickles painfully in your hands and begins to drain the life from your flesh!"), span_warning("A cloud of shimmering red vapor begins flowing from [humsqueezer] into [plush]!"))
		while(do_after(humsqueezer, 0.2 SECONDS, plush))
			if(((humsqueezer.getBruteLoss() + humsqueezer.getFireLoss()) < 100) && stored_flesh < 100)
				humsqueezer.adjustBruteLoss(0.5)
				humsqueezer.adjustFireLoss(0.5)
				stored_flesh = min(100, stored_flesh + 1)
			if(numcycles == 20 && stored_blood < 560)
				to_chat(span_warning("[plush] grows uncomfortably cold. You feel dizzy."))
			if(numcycles >= 20 && stored_blood < 560 && (humsqueezer.getToxLoss() < 100))
				humsqueezer.adjustToxLoss(1)
				stored_blood = min(500, stored_blood + 5)
			if(numcycles == 40 && stored_life < 100)
				to_chat(span_warning("[plush] is freezing to the touch! It's... tiring..."))
			if(numcycles >= 40 && stored_life < 100)
				humsqueezer.adjustCloneLoss(1)
				stored_life = min(100, stored_life + 1)
	else
		var/numcycles = 0
		humsqueezer.visible_message(span_notice("[plush] feels warm and so very soft..."), span_notice("A cloud of shimmering red vapor steams from [plush], flowing into [humsqueezer]'s flesh!"))
		while(do_after(humsqueezer, 0.2 SECONDS, plush))
			if(humsqueezer.getBruteLoss() && stored_flesh > 0)
				humsqueezer.adjustBruteLoss(-1)
				stored_flesh = max(0, stored_flesh - 1)
			if(humsqueezer.getFireLoss() && stored_flesh > 0)
				humsqueezer.adjustFireLoss(-1)
				stored_flesh = max(0, stored_flesh - 1)
			if(numcycles == 20)
				to_chat(span_notice("Your insides are all warm and fuzzy. It feels good."))
			if(numcycles >= 20)
				if(humsqueezer.getToxLoss() && stored_blood >= 5)
					humsqueezer.adjustToxLoss(-1)
					stored_blood = max(0, stored_blood - 5)
				if(humsqueezer.blood_volume < BLOOD_VOLUME_NORMAL && stored_blood >= 5)
					humsqueezer.blood_volume += 5
					stored_blood = min(0, stored_blood - 5)
			if(numcycles == 40)
				to_chat(span_notice("Your whole body is suffused with a sort of rejuvinating heat. It feels amazing."))
			if(numcycles >= 40)
				if(humsqueezer.getCloneLoss() && stored_life > 0)
					humsqueezer.adjustCloneLoss(-1)
					stored_life = max(0, stored_life - 1)
				for(var/obj/item/organ/internal/thing in humsqueezer.organs)
					if(!istype(thing))
						continue
					if(thing.damage > 0 && stored_life > 0)
						thing.apply_organ_damage(-5)
						stored_life = max(0, stored_life - 1)
				for(var/datum/wound/ouchy in humsqueezer.all_wounds)
					if((stored_life >= ouchy.severity * 5) && ouchy.severity < WOUND_SEVERITY_LOSS)
						ouchy.remove_wound()
						stored_life = max(0, stored_life - (ouchy.severity * 5))







/datum/plush_trait/ominous_levitation
	name = "Unnervingly Hovering"
	desc = "imbues the stuffing of the plush with an anti-gravitational telekinetic field, enabling it to levitate."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/ominous_levitation/activate(obj/item/toy/plush/plush)
	. = ..()
	DO_FLOATING_ANIM(plush)
	plush.visible_message(span_warning("[plush] begins to float for no conceivable reason!"))

/datum/plush_trait/ominous_levitation/deactivate(obj/item/toy/plush/plush)
	. = ..()
	STOP_FLOATING_ANIM(plush)
	plush.visible_message(span_notice("[plush] stops floating."))






/datum/plush_trait/energetic
	name = "Estiferous"
	desc = "directly imbues the cloth of the plush with a fragment of the energy of its Cotton. This manifests as a pervasive heat suffusing the plush's surface. Handle with care, and thermally insulative gloves."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/energetic/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	var/ouched = TRUE
	if(iscarbon(squeezer))
		var/mob/living/carbon/carbsqueezer = squeezer
		if(carbsqueezer.gloves)
			var/obj/item/clothing/gloves/electrician_gloves = carbsqueezer.gloves
			if(electrician_gloves.max_heat_protection_temperature > 360)
				ouched = FALSE
		if(HAS_TRAIT(carbsqueezer, TRAIT_RESISTHEAT) || HAS_TRAIT(carbsqueezer, TRAIT_RESISTHEATHANDS))
			ouched = FALSE
		if(!ouched)
			return
		to_chat(carbsqueezer, span_warning("[plush] burns painfully in your hand!"))
		var/ouchy_arm = (carbsqueezer.get_held_index_of_item(plush) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
		carbsqueezer.apply_damage(1, BURN, ouchy_arm)
		carbsqueezer.emote("gasp")
		carbsqueezer.Stun(1 SECOND)
		carbsqueezer.drop_all_held_items()






/datum/plush_trait/slippery
	name = "Lubricating"
	desc = "causes the plush to become extremely slippery."
	tier = 2
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/slippery/activate(obj/item/toy/plush/plush)
	. = ..()
	plush.AddComponentFrom(REF(src), /datum/component/slippery, 50, SLIDE)

/datum/plush_trait/slippery/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.RemoveComponentSource(REF(src), /datum/component/slippery)






/datum/plush_trait/big
	name = "Sizable"
	desc = "causes the plush to enlarge greatly."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/big/activate(obj/item/toy/plush/plush)
	. = ..()
	plush.w_class += 1
	plush.transform *= 2

/datum/plush_trait/big/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.w_class -= 1
	plush.transform *= 0.5





/datum/plush_trait/sparky
	name = "Electroreceptive"
	desc = "causes the plushie to emit small sparks."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/sparky/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	new /obj/effect/particle_effect/sparks(get_turf(plush))



/datum/plush_trait/electrical
	name = "Electrogenerative"
	desc = "suffuses the plushie with electrical energy."
	tier = 2
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/electrical/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	new /obj/effect/particle_effect/sparks(get_turf(plush))
	if(!iscarbon(squeezer))
		return
	var/mob/living/carbon/carbsqueezer = squeezer
	carbsqueezer.electrocute_act(10, plush, 1)

/datum/plush_trait/light
	name = "Luminant"
	desc = "causes the plushie to glow."
	tier = 3
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	recipe = list(/datum/plush_trait/electrical, /datum/plush_trait/colorful)

/datum/plush_trait/light/activate(obj/item/toy/plush/plush)
	. = ..()
	plush.light_system = OVERLAY_LIGHT
	plush.light_outer_range = 6
	plush.light_power = 2
	plush.set_light_on(TRUE)

/datum/plush_trait/light/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.set_light_on(FALSE)

/datum/plush_trait/wet
	name = "Hydrogenic"
	desc = "causes the plushie to be constantly suffused with water."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	var/made_resistant = FALSE

/datum/plush_trait/wet/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	var/turf/open/turf = get_turf(plush)
	turf.add_liquid_list(list(/datum/reagent/water = 5), TRUE)

/datum/plush_trait/wet/activate(obj/item/toy/plush/plush)
	. = ..()
	if(!(plush.resistance_flags & FIRE_PROOF))
		plush.resistance_flags |= FIRE_PROOF
		made_resistant = TRUE

/datum/plush_trait/wet/deactivate(obj/item/toy/plush/plush)
	. = ..()
	if(made_resistant)
		plush.resistance_flags &= ~(FIRE_PROOF)
		made_resistant = FALSE




//funny admin suggested traits
/datum/plush_trait/wolfy
	name = "Autoaerolocomotive"
	desc = "The plushie moves towards the first person to hug the plushie after the Shape-string is inserted."
	var/datum/weakref/our_owner
	tier = 2
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/wolfy/process_trigger(seconds_per_tick, obj/item/toy/plush/plush)
	if(our_owner.resolve())
		SSmove_manager.move_towards(plush, our_owner.resolve(), 5 SECONDS, TRUE)

/datum/plush_trait/wolfy/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	if(!our_owner)
		our_owner = WEAKREF(squeezer)
		to_chat(squeezer, "It feels like [plush] is staring at you...")

/datum/plush_trait/puce
	name = "Pucetrifying"
	desc = "releases a wave of... Puce? what the fuck is puce?"
	COOLDOWN_DECLARE(puceify)
	tier = 3

/datum/plush_trait/puce/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	if(COOLDOWN_FINISHED(src, puceify))
		for(var/atom/ough in range(5, plush))
			plush.visible_message(span_danger("As [squeezer] hugs [plush], it releases a devastating wave of pucetrifacting energy!"))
			ough.add_atom_colour("#cc8899", FIXED_COLOUR_PRIORITY) // woe, for you are puce forever
			if(isliving(ough))
				to_chat(ough, span_reallybig(span_hypnophrase("P U C E")))
		COOLDOWN_START(src, puceify, 30 SECONDS)




/datum/plush_trait/colorful
	name = "Colorful"
	desc = "makes the plushie cute colors."
	var/our_color
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	tier = 1

/datum/plush_trait/colorful/activate(obj/item/toy/plush/plush)
	. = ..()
	our_color = "#[random_color()]"
	plush.add_atom_colour(our_color, FIXED_COLOUR_PRIORITY)

/datum/plush_trait/colorful/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.remove_atom_colour(FIXED_COLOUR_PRIORITY, our_color)

/datum/plush_trait/kind
	name = "Chrysocardiac" // man i love grandeloquence
	desc = "instills love and kindness in the plushie."
	flags = PLUSH_KIND
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY

/datum/plush_trait/charming
	name = "Argyroglossitic" // wow these are so nuancedly uninspired
	desc = "makes the plushie cuter and more charming than usual."
	flags = PLUSH_CHARMING
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY
	tier = 1

/datum/plush_trait/ugly
	name = "Dysmorphic"
	desc = "makes the plushie conventionally unattractive (by whatever obtuse standards plushies judge attractiveness by)."
	flags = PLUSH_FUGLY
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY

/datum/plush_trait/hearts_of_iron_four
	name = "Cold-souled"
	desc = "instills stoic resolve."
	flags = PLUSH_STOIC
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY

/datum/plush_trait/promiscuous
	name = "Meretricious"
	desc = "makes the affected plush scandalous and disloyal."
	flags = PLUSH_PROMISCUOUS
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY
	tier = 1

/datum/plush_trait/bloody
	name = "Haemokinetic"
	desc = "imbues the plushie with the fundamental power of blood."
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	recipe = list(/datum/plush_trait/wet, /datum/plush_trait/hearts_of_iron_four)
	tier = 2
	var/datum/component/bloody_spreader/blood0

/datum/plush_trait/bloody/activate(obj/item/toy/plush/plush, mob/living/squeezer)
	plush.AddComponent(
	/datum/component/bloody_spreader,\
	blood_left = INFINITY,\
	blood_dna = list("cotton-filled blood" = "PLSH-"),\
	diseases = null,\
	)
