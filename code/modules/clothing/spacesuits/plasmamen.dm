//Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version

/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like its smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor_type = /datum/armor/eva_plasmaman
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	inhand_icon_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10


/datum/armor/eva_plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charge\s left in this suit.")


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks > 0)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.extinguish_mob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of helmets
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon = 'monkestation/code/modules/blueshift/gags/icons/plasmaman.dmi' //monke -- plasmaman GAGS
	worn_icon = 'monkestation/code/modules/blueshift/gags/icons/plasmaman.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/gags/icons/lefthand/plasmaman.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/gags/icons/righthand/plasmaman.dmi'
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | PLASMAMAN_PREVENT_IGNITION | HEADINTERNALS
	icon_state = "plasmaman_helmet"
	worn_icon_state = "plasmaman_helmet_worn"
	inhand_icon_state = "plasmaman_helmet"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right
	/// helmet -> stripes -> visor
	greyscale_colors = "#d15b1b#a747c0#bd6abd"
	strip_delay = 8 SECONDS
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/space_plasmaman
	resistance_flags = FIRE_PROOF
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_outer_range = 4
	light_on = FALSE
	can_stack_hat = FALSE //has it's own hat stacking logic
	/// Boolean to see if helmet light is on
	var/helmet_on = FALSE
	/// Boolean to see if a smile is drawn on the helmet
	var/smile = FALSE
	/// Color of said smile
	var/smile_color = "#FF0000"
	/// Used to differentiate between different helmet colors on GAGs
	var/smile_state = "envirohelm_smile"
	var/obj/item/clothing/head/attached_hat
	/// Used for the "sleek" icon state variant of this helmet
	var/sleek_greyscale_colors = "#39393f#bd6abd"
	/// Used for security "sleek" icon state variant
	var/cowl = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF
	visor_flags_inv = HIDEFACE

/datum/armor/space_plasmaman
	bio = 100
	fire = 100
	acid = 75

/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	visor_toggling()
	update_appearance(UPDATE_ICON)

/obj/item/clothing/head/helmet/space/plasmaman/examine()
	. = ..()
	if(attached_hat)
		. += span_notice("There's [attached_hat.name] placed on the helmet. Right-click to remove it.")
	else
		. += span_notice("There's nothing placed on the helmet.")

/obj/item/clothing/head/helmet/space/plasmaman/proc/handle_style_change(style)
	if(style != PREF_SKIRT)
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		return
	icon_state = "plasmaman_helmet_sleek"
	worn_icon_state = "plasmaman_helmet_sleek_worn"
	inhand_icon_state = "plasmaman_sleek_helmet_sleek"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet/sleek
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn/sleek
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left/sleek
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right/sleek
	greyscale_colors = sleek_greyscale_colors
	update_appearance(UPDATE_ICON)

/obj/item/clothing/head/helmet/space/plasmaman/click_alt(mob/user)
	toggle_welding_screen(user)
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/head/helmet/space/plasmaman/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_welding_screen))
		toggle_welding_screen(user)
		return

	return ..()

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(!weldingvisortoggle(user))
		return
	if(helmet_on)
		to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
		helmet_on = FALSE
		set_light_on(FALSE)
	playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE) //Welding visors don't just come from nothing
	update_appearance(UPDATE_ICON)

/obj/item/clothing/head/helmet/space/plasmaman/visor_toggling()
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/clothing/head/helmet/space/plasmaman/update_icon_state()
	. = ..()
	if(greyscale_config != /datum/greyscale_config/plasmaman_helmet/sleek)
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)
		inhand_icon_state = initial(inhand_icon_state)
	else
		icon_state = "plasmaman_helmet_sleek"
		worn_icon_state = "plasmaman_helmet_sleek_worn"
		inhand_icon_state = "plasmaman_sleek_helmet_sleek"
	if(helmet_on)
		icon_state = "[icon_state]_light"
		worn_icon_state = "[worn_icon_state]_light"
	if(!up)
		icon_state = "[icon_state]_welding"
		worn_icon_state = "[worn_icon_state]_welding"

/obj/item/clothing/head/helmet/space/plasmaman/update_overlays()
	. = ..()
	if(smile && up)
		var/mutable_appearance/smiley = mutable_appearance(icon, smile_state)
		smiley.color = smile_color
		. += smiley
	if(cowl)
		. += mutable_appearance('monkestation/code/modules/blueshift/gags/icons/plasmaman.dmi', "security_cowl")

/obj/item/clothing/head/helmet/space/plasmaman/attackby(obj/item/hitting_item, mob/living/user)
	. = ..()
	if(istype(hitting_item, /obj/item/toy/crayon))
		if(!smile)
			var/obj/item/toy/crayon/CR = hitting_item
			to_chat(user, span_notice("You start drawing a smiley face on the helmet's visor.."))
			if(do_after(user, 2.5 SECONDS, target = src))
				smile = TRUE
				smile_color = CR.paint_color
				to_chat(user, "You draw a smiley on the helmet visor.")
				update_appearance(UPDATE_ICON)
		else
			to_chat(user, span_warning("Seems like someone already drew something on this helmet's visor!"))
		return
	if(istype(hitting_item, /obj/item/clothing/head))
		var/obj/item/clothing/hitting_clothing = hitting_item
		if(hitting_clothing.clothing_flags & PLASMAMAN_HELMET_EXEMPT)
			to_chat(user, span_notice("You cannot place [hitting_clothing.name] on helmet!"))
			return
		if(attached_hat)
			to_chat(user, span_notice("There's already something placed on helmet!"))
			return
		attached_hat = hitting_clothing
		to_chat(user, span_notice("You placed [hitting_clothing.name] on helmet!"))
		hitting_clothing.forceMove(src)
		update_appearance(UPDATE_ICON)

///By the by, helmets have the update_icon_updates_onmob element, so we don't have to call mob.update_worn_head()
/obj/item/clothing/head/helmet/space/plasmaman/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(isinhands)
		return
	if(smile)
		var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/head/plasmaman_head.dmi', smile_state)
		M.color = smile_color
		. += M
	if(cowl)
		. += mutable_appearance('monkestation/code/modules/blueshift/gags/icons/plasmaman.dmi', "security_cowl_w")
	if(attached_hat)
		. += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')

/obj/item/clothing/head/helmet/space/plasmaman/wash(clean_types)
	. = NONE
	if(smile && (clean_types & CLEAN_TYPE_HARD_DECAL))
		smile = FALSE
		update_appearance(UPDATE_OVERLAYS)
		. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP
	. |= ..()

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	helmet_on = !helmet_on

	if(helmet_on)
		if(!up)
			to_chat(user, span_notice("Your helmet's torch can't pass through your welding visor!"))
			set_light_on(FALSE)
			helmet_on = FALSE
		else
			set_light_on(TRUE)
	else
		set_light_on(FALSE)

	update_appearance(UPDATE_ICON)
	update_item_action_buttons()

/obj/item/clothing/head/helmet/space/plasmaman/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(!helmet_on)
		return FALSE
	helmet_on = FALSE
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/clothing/head/helmet/space/plasmaman/attack_hand_secondary(mob/user)
	..()
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return
	user.put_in_active_hand(attached_hat)
	to_chat(user, span_notice("You removed [attached_hat.name] from helmet!"))
	attached_hat = null
	update_appearance(UPDATE_ICON)

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from burning alive, alongside other undesirables."
	armor_type = /datum/armor/plasmaman_security
	greyscale_colors = "#a52f29#39393f#bd6abd"
	sleek_greyscale_colors = "#39393f#a52f29"

/obj/item/clothing/head/helmet/space/plasmaman/security/handle_style_change(style)
	. = ..()
	if(style != PREF_SKIRT)
		cowl = FALSE
		return
	cowl = TRUE

/obj/item/clothing/head/helmet/space/plasmaman/secmed
	name = "security medical envirosuit helmet"
	desc = "A new pattern plasmaman helmet for those qualified as security medical personnel. This is still EVA rated too!"
	greyscale_colors = "#918f8c#a52f29#bd6abd"
	sleek_greyscale_colors = "#39393f#a52f29"

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden. A pair of white stripes being added to differeciate them from other members of security."
	greyscale_config = /datum/greyscale_config/plasmaman_helmet/stripe
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn/stripe
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left/stripe
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right/stripe
	greyscale_colors = "#a52f29#39393f#ebebeb#bd6abd"
	sleek_greyscale_colors = "#39393f#a52f29"

/obj/item/clothing/head/helmet/space/plasmaman/security/head_of_security
	name = "head of security's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Head of Security. \
		A pair of gold stripes are added to differentiate them from other members of security."
	armor_type = /datum/armor/security_head_of_security
	greyscale_config = /datum/greyscale_config/plasmaman_helmet/stripe
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn/stripe
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left/stripe
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right/stripe
	greyscale_colors = "#a52f29#39393f#e6a345#bd6abd"
	sleek_greyscale_colors = "#39393f#a52f29"

/obj/item/clothing/head/helmet/space/plasmaman/prisoner
	name = "prisoner's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet for prisoners."
	greyscale_colors = "#d15b1b#39393f#bd6abd"
	sleek_greyscale_colors = "#39393f#bd6abd"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical doctor's plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman medical doctors, having two stripes down its length to denote as much."
	greyscale_colors = "#eeeeee#5fa4cc#bd6abd"
	sleek_greyscale_colors = "#39393f#5fa4cc"

/obj/item/clothing/head/helmet/space/plasmaman/paramedic
	name = "paramedic plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman paramedics, with darker blue stripes compared to the medical model."
	greyscale_colors = "#364660#eeeeee#bd6abd"
	sleek_greyscale_colors = "#39393f#364660"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	greyscale_colors = "#eeeeee#40992e#bd6abd"
	sleek_greyscale_colors = "#39393f#40992e"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
	desc = "A plasmaman envirosuit designed for chemists, two orange stripes going down its face."
	greyscale_colors = "#eeeeee#d15b1b#bd6abd"
	sleek_greyscale_colors = "#39393f#d15b1b"

/obj/item/clothing/head/helmet/space/plasmaman/chief_medical_officer
	name = "chief medical officer's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Chief Medical Officer. A gold stripe applied to differentiate them from other medical staff."
	greyscale_colors = "#eeeeee#5eb8b8#bd6abd"
	sleek_greyscale_colors = "#254559#5eb8b8"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	greyscale_colors = "#eeeeee#b347a1#bd6abd"
	sleek_greyscale_colors = "#39393f#b347a1"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	greyscale_colors = "#39393f#88242d#bd6abd"
	sleek_greyscale_colors = "#39393f#88242d"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	greyscale_colors = "#eeeeee#4a77a1#bd6abd"
	sleek_greyscale_colors = "#39393f#4a77a1"

/obj/item/clothing/head/helmet/space/plasmaman/research_director
	name = "research director's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Research Director. A light brown design is applied to differentiate them from other scientists."
	greyscale_colors = "#bcad6c#b347a1#bd6abd"
	sleek_greyscale_colors = "#254559#b347a1"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	armor_type = /datum/armor/plasmaman_engineering
	greyscale_colors = "#deb63d#d15b1b#bd6abd"
	sleek_greyscale_colors = "#39393f#d15b1b"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, \
		the usual purple stripes being replaced by atmos' blue. Has improved thermal shielding."
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT // Same protection as the Atmospherics Hardhat
	greyscale_colors = "#deb63d#47bfff#bd6abd"
	sleek_greyscale_colors = "#39393f#47bfff"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/chief_engineer
	name = "chief engineer's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Chief Engineer, \
		the usual purple stripes being replaced by the chief's green. Has improved thermal shielding."
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT // Same protection as the Atmospherics Hardhat
	greyscale_colors = "#deb63d#2e992e#bd6abd"
	sleek_greyscale_colors = "#254559#2e992e"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for cargo techs and quartermasters."
	greyscale_colors = "#d0d7da#c99840#bd6abd"
	sleek_greyscale_colors = "#39393f#c99840"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "A khaki helmet given to plasmamen miners operating on lavaland."
	greyscale_colors = "#796755#9a428e#bd6abd"
	sleek_greyscale_colors = "#39393f#9a428e"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	greyscale_colors = "39393f#a747c0#bd6abd"
	sleek_greyscale_colors = "#39393f#dbaa14"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	greyscale_colors = "#eeeeee#a747c0#bd6abd"
	sleek_greyscale_colors = "#39393f#eeeeee"

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "curator's plasma envirosuit helmet"
	desc = "A slight modification on a traditional voidsuit helmet, \
		this helmet was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. \
		Despite their limitations, these helmets still see use by historians and old-school plasmamen alike."
	icon = 'icons/obj/clothing/head/plasmaman_hats.dmi'
	worn_icon = 'icons/mob/clothing/head/plasmaman_head.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	actions_types = list(/datum/action/item_action/toggle_welding_screen)
	icon_state = "prototype_envirohelm"
	inhand_icon_state = "void_helmet"
	worn_icon_state = "prototype_envirohelm"
	smile_state = "prototype_smile"

/obj/item/clothing/head/helmet/space/plasmaman/curator/handle_style_change(style)
	return

/obj/item/clothing/head/helmet/space/plasmaman/curator/update_icon_state()
	. = ..()
	if(helmet_on)
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "A green and blue envirohelmet designating its wearer as a botanist. \
		While not specifically designed for it, it would protect against minor plant-related injuries."
	greyscale_colors = "#50d967#557efc#bd6abd"
	sleek_greyscale_colors = "#39393f#557efc"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	greyscale_config = /datum/greyscale_config/plasmaman_helmet/stripe
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn/stripe
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left/stripe
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right/stripe
	greyscale_colors = "#b3b3b3#a747c0#ffe269#bd6abd"
	sleek_greyscale_colors = "#39393f#a747c0"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. It's not very colourful."
	greyscale_config = /datum/greyscale_config/plasmaman_helmet/mime
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn/mime
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left/mime
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right/mime
	greyscale_colors = "#eeeeee#a52f29"

/obj/item/clothing/head/helmet/space/plasmaman/mime/handle_style_change(style)
	return

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. <i>'HONK!'</i>"
	greyscale_config = /datum/greyscale_config/plasmaman_helmet/clown
	greyscale_config_worn = /datum/greyscale_config/plasmaman_helmet/worn/clown
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_helmet/inhand_left/clown
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_helmet/inhand_right/clown
	smile_state = "clown_smile"
	greyscale_colors = "#ffc0ff#e91111"

/obj/item/clothing/head/helmet/space/plasmaman/clown/handle_style_change(style)
	return

/obj/item/clothing/head/helmet/space/plasmaman/head_of_personnel
	name = "head of personnel's envirosuit helmet"
	desc = "A special containment helmet designed for the Head of Personnel. \
		Embarrassingly enough, it looks way too much like the captain's design save for the red stripes."
	greyscale_colors = "#3e6588#a52f29#bd6abd"
	sleek_greyscale_colors = "#254559#3e6588"

/obj/item/clothing/head/helmet/space/plasmaman/captain
	name = "captain's plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Captain. \
		Embarrassingly enough, it looks way too much like the Head of Personnel's design save for the gold stripes. \
		I mean, come on. Gold stripes can fix anything."
	armor_type = /datum/armor/plasmaman_captain
	greyscale_colors = "#41579a#e6a345#bd6abd"
	sleek_greyscale_colors = "#254559#e6a345"

/obj/item/clothing/head/helmet/space/plasmaman/centcom_commander
	name = "CentCom commander plasma envirosuit helmet"
	desc = "A special containment helmet designed for the Higher Central Command Staff. \
		Not many of these exist, as CentCom does not usually employ plasmamen to higher staff positions due to their complications."
	greyscale_colors = "#46b946#e6b917#bd6abd"
	sleek_greyscale_colors = "#46b946#e6b917"

/obj/item/clothing/head/helmet/space/plasmaman/centcom_official
	name = "CentCom official plasma envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. They sure do love their green."
	greyscale_colors = "#336637#cbcdd1#bd6abd"
	sleek_greyscale_colors = "#46b946#cbcdd1"

/obj/item/clothing/head/helmet/space/plasmaman/centcom_intern
	name = "CentCom intern plasma envirosuit helmet"
	desc = "A special containment helmet designed for CentCom Staff. You know, so any coffee spills don't kill the poor sod."
	greyscale_colors = "#12b560#39393f#bd6abd"
	sleek_greyscale_colors = "#46b946#39393f"

/obj/item/clothing/head/helmet/space/plasmaman/syndie
	name = "tacticool envirosuit helmet"
	desc = "There's no doubt about it, this helmet puts you above ALL of the other plasmamen. If you see another plasmaman wearing a helmet like this, \
		it's either because they're a fellow badass, or they've murdered one of your fellow badasses and have taken it from them as a trophy. \
		Either way, anyone wearing this deserves at least a cursory nod of respect."
	greyscale_colors = "#61423f#b22c20#b22c20"
	sleek_greyscale_colors = "#61423f#b22c20"

/obj/item/clothing/head/helmet/space/plasmaman/bitrunner
	name = "bitrunner's plasma envirosuit helmet"
	desc = "An envirohelmet with extended blue light filters for bitrunning plasmamen."
	greyscale_colors = "#39393f#c99840#c99840"
	sleek_greyscale_colors = "#39393f#c99840"

/obj/item/clothing/head/helmet/space/plasmaman/engineering/signal_tech
	name = "network admin's plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for network admin plasmamen, the usual purple stripes being replaced by a unique bright green."
	greyscale_colors = "#deb63d#00ff33#bd6abd"
	sleek_greyscale_colors = "#39393f#00ff33"

/obj/item/clothing/head/helmet/space/plasmaman/bunny_ears // i would remove this if it wasn't for the fact the bunny wand would kill plasmamen without it - NK
	name = "bunny eared plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman bunny themed waiters, it has a pair of bunny ears welded onto the helmet."
	icon = 'icons/obj/clothing/head/plasmaman_hats.dmi'
	worn_icon = 'icons/mob/clothing/head_32x48.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null
	icon_state = "bunny_envirohelm"
	inhand_icon_state = "plasmaman-helm"
	worn_icon_state = "bunny_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/bunny_ears/handle_style_change(style)
	return
