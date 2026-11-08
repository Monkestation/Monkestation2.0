#define STYLE_BULKY "Jumpsuit"
#define STYLE_NEITHER "Neither"
#define STYLE_SLEEK "Jumpskirt"

//Basically the assistant suit
/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, \
		and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman")
	worn_icon_state = "plasmaman_suit_w"
	greyscale_config = /datum/greyscale_config/plasmaman_suit
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right
	/// suit (upper) -> pants (lower) -> bands -> belt (horizontal stripe) -> seal (vertical stripe) -> buttons
	greyscale_colors = "#d15b1b#d15b1b#a747c0#d15b1b#d15b1b#612313"
	/// Used for the "sleek" icon state variant of this suit
	var/sleek_greyscale_colors = "#d15b1b#39393f#d15b1b#39393f#d15b1b"
	/// Style used for the suit currently. Sleek or Bulky, ditto on helmet
	var/style = STYLE_BULKY
	clothing_flags = PLASMAMAN_PREVENT_IGNITION
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/under_plasmaman
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 8 SECONDS
	COOLDOWN_DECLARE(next_extinguish)
	var/extinguish_cooldown = 10 SECONDS
	var/extinguishes_left = 5

/datum/armor/under_plasmaman
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There are [extinguishes_left] extinguisher charges left in this suit.")

/obj/item/clothing/under/plasmaman/examine_more(mob/user)
	. = ..()
	if(style != STYLE_NEITHER)
		if(style == STYLE_BULKY)
			. += span_notice(span_italics("You notice the suit can be pried loose of some pieces without any function loss."))
		else
			. += span_notice(span_italics("You notice the suit has some open slots for some metal that can be filled in."))

/*
 * Proc that actually handles which sprite to use. -> PREF_JUMPSUIT ("Jumpsuit") for Bulky (old) | PREF_JUMPSKIRT ("Jumpskirt") for Sleek (new)
 * based on PREF defines, but using in-file defines for better readability
 * for consistency's sake we keep bulky vars as the default ones to fall back on using initial().
 */
/obj/item/clothing/under/plasmaman/proc/handle_style_change(new_style)
	if(new_style == STYLE_SLEEK)
		icon_state = "plasmaman_suit_s"
		worn_icon_state = "plasmaman_suit_s_w"
		inhand_icon_state = "plasmaman_suit_s"
		greyscale_config = /datum/greyscale_config/plasmaman_suit/sleek
		greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/sleek
		greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/sleek
		greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/sleek
		greyscale_colors = sleek_greyscale_colors
	else
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		greyscale_config = initial(greyscale_config)
		greyscale_config_worn = initial(greyscale_config_worn)
		greyscale_config_inhand_left = initial(greyscale_config_inhand_left)
		greyscale_config_inhand_right = initial(greyscale_config_inhand_right)
		greyscale_colors = initial(greyscale_colors)
	style = new_style
	update_greyscale()
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/clothing/under/plasmaman/proc/suit_extinguish(mob/living/carbon/human/suitedfellow)
	if(!istype(suitedfellow))
		return

	if(!suitedfellow.on_fire)
		return

	if(!extinguishes_left)
		suitedfellow.balloon_alert(suitedfellow, "no suit extinguish charges left!")
		return

	if(!COOLDOWN_FINISHED(src, next_extinguish))
		return

	if(HAS_TRAIT(suitedfellow, TRAIT_NO_EXTINGUISH))
		to_chat(suitedfellow, span_danger("The suit releases a meager puff of water before it hails: The fire burning you is unable to be extinguished!"))
		return

	COOLDOWN_START(src, next_extinguish, extinguish_cooldown)
	extinguishes_left--
	suitedfellow.visible_message(
		span_warning("[suitedfellow]'s suit automatically extinguishes [suitedfellow.p_them()]!"),
		span_warning("Your suit automatically extinguishes you.")
	)
	suitedfellow.extinguish_mob()
	new /obj/effect/particle_effect/water(get_turf(suitedfellow))

/obj/item/clothing/under/plasmaman/attackby(obj/item/hitting_item, mob/living/user, params)
	. = ..()
	if(istype(hitting_item, /obj/item/extinguisher_refill))
		if(extinguishes_left == 5)
			to_chat(user, span_notice("The inbuilt extinguisher is full."))
		else
			extinguishes_left = 5
			to_chat(user, span_notice("You refill the suit's built-in extinguisher, using up the cartridge."))
			qdel(hitting_item)

	if(hitting_item.tool_behaviour == TOOL_CROWBAR && style == STYLE_BULKY)
		hitting_item.play_tool_sound(src)
		user.balloon_alert(user, "removing parts...")
		if(do_after(user, 3 SECONDS, src))
			if(handle_style_change(STYLE_SLEEK))
				new /obj/item/stack/sheet/iron(get_turf(src))
		return

	if(istype(hitting_item, /obj/item/stack/sheet/iron) && style == STYLE_SLEEK)
		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		user.balloon_alert(user, "adding parts...")
		var/obj/item/stack/sheet/iron/metal_stack = hitting_item
		if(do_after(user, 3 SECONDS, src))
			if(handle_style_change(STYLE_BULKY))
				metal_stack.use(1)
		return

/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "A cartridge loaded with a compressed extinguisher mix, used to refill the automatic extinguisher on plasma envirosuits."
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'


/obj/item/clothing/under/plasmaman/cargo
	name = "cargo plasma envirosuit"
	desc = "A joint envirosuit used by plasmamen quartermasters and cargo techs alike, \
		due to the logistical problems of differenciating the two with the length of their pant legs."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/cargo")
	greyscale_colors = "#c99840#d0d7da#d0d7da#c99840#c99840#794421"
	sleek_greyscale_colors = "#c99840#39393f#c99840#d0d7da#d0d7da"

/obj/item/clothing/under/plasmaman/mining
	name = "mining plasma envirosuit"
	desc = "An air-tight khaki suit designed for operations on lavaland by plasmamen."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/mining")
	greyscale_colors = "#717261#796755#9a428e#717261#717261#989898"
	sleek_greyscale_colors = "#939393#39393f#939393#39393f#939393"

/obj/item/clothing/under/plasmaman/chef
	name = "chef's plasma envirosuit"
	desc = "A white plasmaman envirosuit designed for cullinary practices. One might question why a member of a species that doesn't need to eat would become a chef."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/chef")
	greyscale_config = /datum/greyscale_config/plasmaman_suit/striped
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/striped
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/striped
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/striped
	greyscale_colors = "#eeeeee#39393f#39393f#eeeeee#eeeeee#eeeeee#747182"
	sleek_greyscale_colors = "#f1f1f1#39393f#f1f1f1#39393f#f1f1f1"

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = "The pet project of a particularly posh plasmaman, this custom suit was quickly appropriated by Nanotrasen for its detectives, lawyers, and bartenders alike."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/enviroslacks")
	greyscale_colors = "#eeeeee#87502e#a747c0#eeeeee#eeeeee#747182"
	sleek_greyscale_colors = "#6a84be#39393f#6a84be#39393f#6a84be"

/obj/item/clothing/under/plasmaman/enviroslacks/handle_style_change(new_style)
	. = ..()
	if(new_style == STYLE_BULKY)
		return TRUE
	icon_state = "tie"
	worn_icon_state = "tie_w"
	inhand_icon_state = "tie"
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's plasma envirosuit"
	desc = "An envirosuit specially designed for only the most pious of plasmamen."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/chaplain")
	greyscale_colors = "#39393f#39393f#a747c0#39393f#39393f#18191e"
	sleek_greyscale_colors = "#f1f1f1#39393f#f1f1f1#ffc518#dbaa14"

/obj/item/clothing/under/plasmaman/curator
	name = "curator's plasma envirosuit"
	desc = "Made out of a modified voidsuit, this suit was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. \
		Due to the modifications, the suit is no longer space-worthy. \
		Despite their limitations, these suits are still in used by historian and old-styled plasmamen alike."
	icon = 'icons/obj/clothing/under/plasmaman.dmi'
	worn_icon = 'icons/mob/clothing/under/plasmaman.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	icon_state = "prototype_envirosuit"
	worn_icon_state = "prototype_envirosuit"
	inhand_icon_state = "void_suit"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	style = STYLE_NEITHER

/obj/item/clothing/under/plasmaman/curator/handle_style_change(new_style)
	return FALSE

/obj/item/clothing/under/plasmaman/janitor
	name = "janitor's plasma envirosuit"
	desc = "A grey and purple envirosuit designated for plasmamen janitors."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/janitor")
	greyscale_config = /datum/greyscale_config/plasmaman_suit/striped
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/striped
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/striped
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/striped
	greyscale_colors = "#b3b3b3#b3b3b3#ffe269#a747c0#b3b3b3#a747c0#514f5b"
	sleek_greyscale_colors = "#9167b3#39393f#9167b3#39393f#9167b3"

/obj/item/clothing/under/plasmaman/botany
	name = "botany envirosuit"
	desc = "A green and blue envirosuit designed to protect plasmamen from minor plant-related injuries."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/botany")
	greyscale_colors = "#50d967#50d967#557efc#557efc#557efc#215740"
	sleek_greyscale_colors = "#59c18a#39393f#557efc#39393f#557efc"

/obj/item/clothing/under/plasmaman/mime
	name = "mime envirosuit"
	desc = "It's not very colourful."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/mime")
	greyscale_config = /datum/greyscale_config/plasmaman_suit/mime
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/mime
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/mime
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/mime
	greyscale_colors = "#eeeeee#39393f#eeeeee#eeeeee#eeeeee#747182"
	style = STYLE_NEITHER

/obj/item/clothing/under/plasmaman/mime/handle_style_change(new_style)
	return FALSE

/obj/item/clothing/under/plasmaman/clown
	name = "clown envirosuit"
	desc = "<i>'HONK!'</i>"
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/clown")
	greyscale_config = /datum/greyscale_config/plasmaman_suit/clown
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/clown
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/clown
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/clown
	greyscale_colors = "#ffc0ff#ffc0ff"
	style = STYLE_NEITHER

/obj/item/clothing/under/plasmaman/clown/handle_style_change(new_style)
	return FALSE

/obj/item/clothing/under/plasmaman/clown/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/under/plasmaman/clown/suit_extinguish(mob/living/carbon/human/suitedfellow)
	if(!istype(suitedfellow))
		return

	if(!suitedfellow.on_fire)
		return

	if(!extinguishes_left)
		suitedfellow.balloon_alert(suitedfellow, "no suit extinguish charges left!")
		return

	if(!COOLDOWN_FINISHED(src, next_extinguish))
		return

	if(!suitedfellow.extinguish_mob())
		to_chat(suitedfellow, span_danger("The suit releases a meager puff of space lube before it hails: The fire burning you is unable to be extinguished!"))
		return

	COOLDOWN_START(src, next_extinguish, extinguish_cooldown)
	extinguishes_left--
	suitedfellow.visible_message(
		span_warning("[suitedfellow]'s suit spews space lube everywhere!"),
		span_warning("Your suit spews space lube everywhere!")
	)
	var/datum/effect_system/fluid_spread/foam/foam = new
	var/datum/reagents/foamreagent = new /datum/reagents(15)
	foamreagent.add_reagent(/datum/reagent/lube, 15)
	foam.set_up(4, holder = src, location = suitedfellow.loc, carry = foamreagent)
	foam.start() //Truly terrifying.

/obj/item/clothing/under/plasmaman/bitrunner
	name = "bitrunner envirosuit"
	desc = "An envirosuit specially designed for plasmamen with bad posture."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/bitrunner")
	greyscale_colors = "#39393f#39393f#c99840#39393f#39393f#915d2b"
	sleek_greyscale_colors = "#c99840#39393f#c99840#39393f#c99840"

/obj/item/clothing/under/plasmaman/prisoner
	name = "prisoner envirosuit"
	desc = "An orange envirosuit identifying and protecting a criminal plasmaman. Its suit sensors are stuck in the \"Fully On\" position."
	SETUP_MAP_ICONS("plasmaman_suit", "/obj/item/clothing/under/plasmaman/prisoner")
	greyscale_colors = "#d15b1b#d15b1b#39393f#39393f#d15b1b#612313#eeeeee"
	sleek_greyscale_colors = "#d15b1b#39393f#39393f#39393f#39393f"
	greyscale_config = /datum/greyscale_config/plasmaman_suit/doublebelt
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/doublebelt
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/plasmaman/plasma_bun // i would remove this if it wasn't for the fact the bunny wand would kill plasmamen without it - NK
	name = "plasmabunny envirosuit"
	desc = "A plasmaman envirosuit designed for bunny themed waiters, it appears to just be a normal envirosuit with a bunnysuit on top of it"
	icon = 'icons/obj/clothing/under/plasmaman.dmi'
	worn_icon = 'icons/mob/clothing/under/plasmaman.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	icon_state = "plasmabunny_envirosuit"
	worn_icon_state = "plasmabunny_envirosuit"
	inhand_icon_state = "plasmaman"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	style = STYLE_NEITHER

/obj/item/clothing/under/plasmaman/plasma_bun/handle_style_change(new_style)
	return FALSE

#undef STYLE_SLEEK
#undef STYLE_NEITHER
#undef STYLE_BULKY
