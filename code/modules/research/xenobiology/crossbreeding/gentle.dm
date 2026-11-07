/obj/item/slimecross/gentle
	name = "gentle extract"
	desc = "It pulses slowly, as if breathing."
	effect = "gentle"
	effect_desc = "Use to activate minor effect, alt-click to activate major effect."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "gentle"
	/// Type of extract this crossbreed makes. Defaults to grey so a missing override is obvious to players.
	var/extract_type = /obj/item/slime_extract/grey
	/// The real extract inside, made from extract_type.
	var/obj/item/slime_extract/extract = null
	COOLDOWN_DECLARE(use_cooldown)

/obj/item/slimecross/gentle/Initialize(mapload)
	. = ..()
	visible_message(span_notice("[src] glows and pulsates softly."))
	extract = new extract_type(src)
	extract.name = name
	extract.desc = desc
	extract.icon = icon
	extract.icon_state = icon_state
	extract.color = color

/obj/item/slimecross/gentle/Destroy(force)
	QDEL_NULL(extract)
	return ..()

/obj/item/slimecross/gentle/attack_self(mob/living/carbon/user)
	if(preactivate_core(user))
		COOLDOWN_START(src, use_cooldown, extract.activate(user, user.dna.species, SLIME_ACTIVATE_MINOR))
		return CLICK_ACTION_SUCCESS

/obj/item/slimecross/gentle/click_alt(mob/living/carbon/user, modifiers)
	if(preactivate_core(user))
		COOLDOWN_START(src, use_cooldown, extract.activate(user, user.dna.species, SLIME_ACTIVATE_MAJOR))
		return CLICK_ACTION_SUCCESS

/obj/item/slimecross/gentle/proc/preactivate_core(mob/living/carbon/user)
	if(!iscarbon(user) || user.incapacitated())
		return FALSE
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_notice("[src] isn't ready yet!"))
		return FALSE
	COOLDOWN_START(src, use_cooldown, 10 SECONDS) // This will be overwritten depending on exact activation, but prevents bypassing cooldowns on extracts with a do_after.
	return TRUE

/obj/item/slimecross/gentle/grey
	slime_type = /datum/slime_type/grey
	effect_desc = "Use to spit out a biomass stack, alt-click to spit out a baby slime."

/obj/item/slimecross/gentle/orange
	extract_type = /obj/item/slime_extract/orange
	slime_type = /datum/slime_type/orange
	effect_desc = "Use to fill yourself with capsaicin, alt-click to burst out a cloud of smoke."

/obj/item/slimecross/gentle/purple
	extract_type = /obj/item/slime_extract/purple
	slime_type = /datum/slime_type/purple
	effect_desc = "Use to refill your nutrition and blood, alt-click to inject yourself with regenerative jelly."

/obj/item/slimecross/gentle/blue
	extract_type = /obj/item/slime_extract/blue
	slime_type = /datum/slime_type/blue
	effect_desc = "Use to heal clone damage and clear mutations, alt-click to spew foam."

/obj/item/slimecross/gentle/metal
	extract_type = /obj/item/slime_extract/metal
	slime_type = /datum/slime_type/metal
	effect_desc = "Use to spit out 5 glass sheets, alt-click to spit out 5 iron sheets."

/obj/item/slimecross/gentle/yellow
	extract_type = /obj/item/slime_extract/yellow
	slime_type = /datum/slime_type/yellow
	effect_desc = "Use to glow brighter for a minute (luminescents only), alt-click to give off a small EMP."

/obj/item/slimecross/gentle/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	slime_type = /datum/slime_type/darkpurple
	effect_desc = "Use to spit out a plasma sheet, alt-click to burst out a cloud of plasma."

/obj/item/slimecross/gentle/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	slime_type = /datum/slime_type/darkblue
	effect_desc = "Use to put yourself out and chill down, alt-click to burst out freezing nitrogen."

/obj/item/slimecross/gentle/silver
	extract_type = /obj/item/slime_extract/silver
	slime_type = /datum/slime_type/silver
	effect_desc = "Use to spit out a random food, alt-click to spit out a random drink."

/obj/item/slimecross/gentle/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	slime_type = /datum/slime_type/bluespace
	effect_desc = "Use to teleport a short distance, alt-click to set an anchor, then alt-click again to snap back to it."

/obj/item/slimecross/gentle/sepia
	extract_type = /obj/item/slime_extract/sepia
	slime_type = /datum/slime_type/sepia
	effect_desc = "Use to spit out a camera, alt-click to stop time around you for a few seconds."

/obj/item/slimecross/gentle/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	slime_type = /datum/slime_type/cerulean
	effect_desc = "Use to breathe easy without air for a while, alt-click to burst out a cloud of fresh air."

/obj/item/slimecross/gentle/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	slime_type = /datum/slime_type/pyrite
	effect_desc = "Use to spit out a random crayon, alt-click to spit out a random spraycan."

/obj/item/slimecross/gentle/red
	extract_type = /obj/item/slime_extract/red
	slime_type = /datum/slime_type/red
	effect_desc = "Use to speed yourself up with ephedrine, alt-click to drive nearby slimes into a rabid frenzy."

/obj/item/slimecross/gentle/green
	extract_type = /obj/item/slime_extract/green
	slime_type = /datum/slime_type/green
	effect_desc = "Use to turn yourself into a human, alt-click to turn yourself into a random kind of slime person."

/obj/item/slimecross/gentle/pink
	extract_type = /obj/item/slime_extract/pink
	slime_type = /datum/slime_type/pink
	effect_desc = "Use to swap your gender, alt-click to pacify everyone around you."

/obj/item/slimecross/gentle/gold
	extract_type = /obj/item/slime_extract/gold
	slime_type = /datum/slime_type/gold
	effect_desc = "Use to spit out a friendly random animal, alt-click to spit out a hostile one (friendly unless you're on harm intent)."

/obj/item/slimecross/gentle/oil
	extract_type = /obj/item/slime_extract/oil
	slime_type = /datum/slime_type/oil
	effect_desc = "Use to puke a slippery oil puddle, alt-click to explode and gib yourself."

/obj/item/slimecross/gentle/black
	extract_type = /obj/item/slime_extract/black
	slime_type = /datum/slime_type/black
	effect_desc = "Use to catch the slime virus, alt-click to turn yourself into a shadow person."

/obj/item/slimecross/gentle/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	slime_type = /datum/slime_type/lightpink
	effect_desc = "Use to spit out a slime renaming potion, alt-click to spit out a slime sentience potion."

/obj/item/slimecross/gentle/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	slime_type = /datum/slime_type/adamantine
	effect_desc = "Use to harden your skin for a while (luminescents only), alt-click to turn yourself into an adamantine golem."

/obj/item/slimecross/gentle/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	slime_type = /datum/slime_type/rainbow
	effect_desc = "Use to shuffle your color, alt-click to spit out a random slime extract."
