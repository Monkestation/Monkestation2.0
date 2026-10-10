/obj/item/slimecross/gentle
	name = "gentle extract"
	desc = "It pulses slowly, as if breathing."
	effect = "gentle"
	effect_desc = "Use to activate minor effect, Alt-click to activate major effect."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
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

/obj/item/slimecross/gentle/orange
	extract_type = /obj/item/slime_extract/orange
	slime_type = /datum/slime_type/orange

/obj/item/slimecross/gentle/purple
	extract_type = /obj/item/slime_extract/purple
	slime_type = /datum/slime_type/purple

/obj/item/slimecross/gentle/blue
	extract_type = /obj/item/slime_extract/blue
	slime_type = /datum/slime_type/blue

/obj/item/slimecross/gentle/metal
	extract_type = /obj/item/slime_extract/metal
	slime_type = /datum/slime_type/metal

/obj/item/slimecross/gentle/yellow
	extract_type = /obj/item/slime_extract/yellow
	slime_type = /datum/slime_type/yellow

/obj/item/slimecross/gentle/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	slime_type = /datum/slime_type/darkpurple

/obj/item/slimecross/gentle/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	slime_type = /datum/slime_type/darkblue

/obj/item/slimecross/gentle/silver
	extract_type = /obj/item/slime_extract/silver
	slime_type = /datum/slime_type/silver

/obj/item/slimecross/gentle/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	slime_type = /datum/slime_type/bluespace

/obj/item/slimecross/gentle/sepia
	extract_type = /obj/item/slime_extract/sepia
	slime_type = /datum/slime_type/sepia

/obj/item/slimecross/gentle/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	slime_type = /datum/slime_type/cerulean

/obj/item/slimecross/gentle/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	slime_type = /datum/slime_type/pyrite

/obj/item/slimecross/gentle/red
	extract_type = /obj/item/slime_extract/red
	slime_type = /datum/slime_type/red

/obj/item/slimecross/gentle/green
	extract_type = /obj/item/slime_extract/green
	slime_type = /datum/slime_type/green

/obj/item/slimecross/gentle/pink
	extract_type = /obj/item/slime_extract/pink
	slime_type = /datum/slime_type/pink

/obj/item/slimecross/gentle/gold
	extract_type = /obj/item/slime_extract/gold
	slime_type = /datum/slime_type/gold

/obj/item/slimecross/gentle/oil
	extract_type = /obj/item/slime_extract/oil
	slime_type = /datum/slime_type/oil

/obj/item/slimecross/gentle/black
	extract_type = /obj/item/slime_extract/black
	slime_type = /datum/slime_type/black

/obj/item/slimecross/gentle/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	slime_type = /datum/slime_type/lightpink

/obj/item/slimecross/gentle/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	slime_type = /datum/slime_type/adamantine

/obj/item/slimecross/gentle/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	slime_type = /datum/slime_type/rainbow
