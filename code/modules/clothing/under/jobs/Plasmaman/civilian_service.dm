//Basically the assistant suit
/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, \
		and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	icon = 'icons/obj/clothing/under/plasmaman.dmi'
	worn_icon = 'icons/mob/clothing/under/plasmaman.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/plasmaman_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/plasmaman_righthand.dmi'
	icon_state = "plasmaman_suit"
	worn_icon_state = "plasmaman_suit_w"
	inhand_icon_state = "plasmaman_suit"
	greyscale_config = /datum/greyscale_config/plasmaman_suit
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right
	/// suit (upper) -> pants (lower) -> bands -> belt (horizontal stripe) -> seal (vertical stripe) -> buttons
	greyscale_colors = "#d15b1b#d15b1b#a747c0#d15b1b#d15b1b#612313"
	/// Used for the "sleek" icon state variant of this suit
	var/sleek_greyscale_colors = "#d15b1b#39393f#d15b1b#39393f#d15b1b"
	clothing_flags = PLASMAMAN_PREVENT_IGNITION
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/under_plasmaman
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 8 SECONDS
	var/next_extinguish = 0
	var/extinguish_cooldown = 10 SECONDS
	var/extinguishes_left = 5

/datum/armor/under_plasmaman
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There are [extinguishes_left] extinguisher charges left in this suit.")

/obj/item/clothing/under/plasmaman/proc/handle_style_change(style)
	if(style != PREF_SKIRT)
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		return
	icon_state = "plasmaman_suit_s"
	worn_icon_state = "plasmaman_suit_s_w"
	inhand_icon_state = "plasmaman_suit_s"
	greyscale_config = /datum/greyscale_config/plasmaman_suit/sleek
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/sleek
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/sleek
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/sleek
	greyscale_colors = sleek_greyscale_colors
	update_appearance(UPDATE_ICON)

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.extinguish_mob()
			new /obj/effect/particle_effect/water(get_turf(H))

/obj/item/clothing/under/plasmaman/attackby(obj/item/E, mob/user, params)
	..()
	if (istype(E, /obj/item/extinguisher_refill))
		if (extinguishes_left == 5)
			to_chat(user, span_notice("The inbuilt extinguisher is full."))
		else
			extinguishes_left = 5
			to_chat(user, span_notice("You refill the suit's built-in extinguisher, using up the cartridge."))
			qdel(E)

/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "A cartridge loaded with a compressed extinguisher mix, used to refill the automatic extinguisher on plasma envirosuits."
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'


/obj/item/clothing/under/plasmaman/cargo
	name = "cargo plasma envirosuit"
	desc = "A joint envirosuit used by plasmamen quartermasters and cargo techs alike, \
		due to the logistical problems of differenciating the two with the length of their pant legs."
	greyscale_colors = "#c99840#d0d7da#d0d7da#c99840#c99840#794421"
	sleek_greyscale_colors = "#c99840#39393f#c99840#d0d7da#d0d7da"

/obj/item/clothing/under/plasmaman/mining
	name = "mining plasma envirosuit"
	desc = "An air-tight khaki suit designed for operations on lavaland by plasmamen."
	greyscale_colors = "#717261#796755#9a428e#717261#717261#989898"
	sleek_greyscale_colors = "#939393#39393f#939393#39393f#939393"

/obj/item/clothing/under/plasmaman/chef
	name = "chef's plasma envirosuit"
	desc = "A white plasmaman envirosuit designed for cullinary practices. One might question why a member of a species that doesn't need to eat would become a chef."
	greyscale_config = /datum/greyscale_config/plasmaman_suit/striped
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/striped
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/striped
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/striped
	greyscale_colors = "#eeeeee#39393f#39393f#eeeeee#eeeeee#eeeeee#747182"
	sleek_greyscale_colors = "#f1f1f1#39393f#f1f1f1#39393f#f1f1f1"

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = "The pet project of a particularly posh plasmaman, this custom suit was quickly appropriated by Nanotrasen for its detectives, lawyers, and bartenders alike."
	greyscale_colors = "#eeeeee#87502e#a747c0#eeeeee#eeeeee#747182"
	sleek_greyscale_colors = "#6a84be#39393f#6a84be#39393f#6a84be"

/obj/item/clothing/under/plasmaman/enviroslacks/handle_style_change(style)
	. = ..()
	if(style != PREF_SKIRT)
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		return
	icon_state = "tie"
	worn_icon_state = "tie_w"
	inhand_icon_state = "tie"
	update_appearance(UPDATE_ICON)

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's plasma envirosuit"
	desc = "An envirosuit specially designed for only the most pious of plasmamen."
	greyscale_colors = "#39393f#39393f#a747c0#39393f#39393f#18191e"
	sleek_greyscale_colors = "#f1f1f1#39393f#f1f1f1#ffc518#dbaa14"

/obj/item/clothing/under/plasmaman/curator
	name = "curator's plasma envirosuit"
	desc = "Made out of a modified voidsuit, this suit was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. \
		Due to the modifications, the suit is no longer space-worthy. \
		Despite their limitations, these suits are still in used by historian and old-styled plasmamen alike."
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	icon_state = "prototype_envirosuit"
	worn_icon_state = "prototype_envirosuit"
	inhand_icon_state = "void_suit"

/obj/item/clothing/under/plasmaman/curator/handle_style_change(style)
	return

/obj/item/clothing/under/plasmaman/janitor
	name = "janitor's plasma envirosuit"
	desc = "A grey and purple envirosuit designated for plasmamen janitors."
	greyscale_config = /datum/greyscale_config/plasmaman_suit/striped
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/striped
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/striped
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/striped
	greyscale_colors = "#b3b3b3#b3b3b3#ffe269#a747c0#b3b3b3#a747c0#514f5b"
	sleek_greyscale_colors = "#9167b3#39393f#9167b3#39393f#9167b3"

/obj/item/clothing/under/plasmaman/botany
	name = "botany envirosuit"
	desc = "A green and blue envirosuit designed to protect plasmamen from minor plant-related injuries."
	greyscale_colors = "#50d967#50d967#557efc#557efc#557efc#215740"
	sleek_greyscale_colors = "#59c18a#39393f#557efc#39393f#557efc"

/obj/item/clothing/under/plasmaman/mime
	name = "mime envirosuit"
	desc = "It's not very colourful."
	greyscale_config = /datum/greyscale_config/plasmaman_suit/mime
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/mime
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/mime
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/mime
	greyscale_colors = "#eeeeee#39393f#eeeeee#eeeeee#eeeeee#747182"

/obj/item/clothing/under/plasmaman/mime/handle_style_change(style)
	return

/obj/item/clothing/under/plasmaman/clown
	name = "clown envirosuit"
	desc = "<i>'HONK!'</i>"
	greyscale_config = /datum/greyscale_config/plasmaman_suit/clown
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/clown
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/clown
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/clown
	greyscale_colors = "#ffc0ff#ffc0ff"

/obj/item/clothing/under/plasmaman/clown/handle_style_change(style)
	return

/obj/item/clothing/under/plasmaman/clown/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/under/plasmaman/clown/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit spews space lube everywhere!"),span_warning("Your suit spews space lube everywhere!"))
			H.extinguish_mob()
			var/datum/effect_system/fluid_spread/foam/foam = new
			var/datum/reagents/foamreagent = new /datum/reagents(15)
			foamreagent.add_reagent(/datum/reagent/lube, 15)
			foam.set_up(4, holder = src, location = H.loc, carry = foamreagent)
			foam.start() //Truly terrifying.

/obj/item/clothing/under/plasmaman/bitrunner
	name = "bitrunner envirosuit"
	desc = "An envirosuit specially designed for plasmamen with bad posture."
	greyscale_colors = "#39393f#39393f#c99840#39393f#39393f#915d2b"
	sleek_greyscale_colors = "#c99840#39393f#c99840#39393f#c99840"

/obj/item/clothing/under/plasmaman/prisoner
	name = "prisoner envirosuit"
	desc = "An orange envirosuit identifying and protecting a criminal plasmaman. Its suit sensors are stuck in the \"Fully On\" position."
	greyscale_colors = "#d15b1b#d15b1b#39393f#39393f#d15b1b#612313"
	sleek_greyscale_colors = "#d15b1b#39393f#39393f#39393f#39393f"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/plasmaman/plasma_bun // i would remove this if it wasn't for the fact the bunny wand would kill plasmamen without it - NK
	name = "plasmabunny envirosuit"
	desc = "A plasmaman envirosuit designed for bunny themed waiters, it appears to just be a normal envirosuit with a bunnysuit on top of it"
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	icon_state = "plasmabunny_envirosuit"
	worn_icon_state = "plasmabunny_envirosuit"
	inhand_icon_state = "plasmaman"

/obj/item/clothing/under/plasmaman/plasma_bun/handle_style_change(style)
	return
