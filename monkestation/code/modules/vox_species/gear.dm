// Vox-only clothing. Can't be equipped by any other species due to bone structure and vox cybernetics.

/// Shared check for clothing that only fits vox.
/proc/vox_only_equip_check(obj/item/gear, mob/living/wearer, slot, disable_warning)
	if(!(slot & gear.slot_flags) || isvox(wearer))
		return TRUE
	if(!disable_warning)
		to_chat(wearer, span_warning("[gear] is shaped for a vox, it won't fit you."))
	return FALSE

// Space gear (vacuum suit, low pressure armour)

/datum/armor/vox_space
	melee = 40
	bullet = 40
	laser = 30
	energy = 15
	bomb = 30
	bio = 30
	fire = 80
	acid = 85

/obj/item/clothing/suit/space/vox
	icon = 'icons/obj/species/vox/suits.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/suit.dmi'
	inhand_icon_state = "s_suit"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
	)
	armor_type = /datum/armor/vox_space
	slowdown = 2

/obj/item/clothing/suit/space/vox/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

/obj/item/clothing/head/helmet/space/vox
	icon = 'icons/obj/species/vox/hats.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/head.dmi'
	armor_type = /datum/armor/vox_space
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | HEADINTERNALS
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/space/vox/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	icon_state = "vox-pressure"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	icon_state = "vox-pressure"

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	icon_state = "vox-carapace"

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	icon_state = "vox-carapace"
	slowdown = 1

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	desc = "A smoothly contoured, matte-black alien helmet."
	icon_state = "vox-stealth"

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."
	icon_state = "vox-stealth"

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	desc = "An alien helmet with enormous goggled lenses."
	icon_state = "vox-medic"

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	desc = "An almost organic looking nonhuman pressure suit."
	icon_state = "vox-medic"

// Magclaws

/obj/item/clothing/shoes/magboots/vox
	name = "vox magclaws"
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	icon = 'icons/obj/species/vox/shoes.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/shoes.dmi'
	icon_state = "boots-vox"
	base_icon_state = "boots-vox"
	supports_variations_flags = NONE

/obj/item/clothing/shoes/magboots/vox/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

/obj/item/clothing/shoes/magboots/vox/update_icon_state()
	. = ..()
	icon_state = base_icon_state // one sprite, gripping or not

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(!magpulse)
		//make sure these can only be used when equipped.
		var/mob/living/carbon/human/wearer = user
		if(!istype(wearer) || wearer.shoes != src)
			to_chat(user, span_warning("You will have to put on [src] before you can do that."))
			return
	. = ..()
	if(magpulse)
		//kinda hard to take off magclaws when you are gripping them tightly.
		ADD_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		to_chat(user, span_notice("You dig your claws deeply into the flooring, bracing yourself."))
		to_chat(user, span_notice("It would be hard to take off [src] without relaxing your grip first."))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		to_chat(user, span_notice("You relax your deathgrip on the flooring."))

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user)
	. = ..()
	if(magpulse)
		user.visible_message(span_notice("[src] go limp as they are removed from [user]'s feet."), span_notice("[src] go limp as they are removed from your feet."))
		REMOVE_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		attack_self(user)

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	. = ..()
	if(magpulse)
		. += span_notice("It would be hard to take these off without relaxing your grip first.")

// Gauntlets

/obj/item/clothing/gloves/color/yellow/vox
	name = "insulated gauntlets"
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	icon = 'icons/obj/species/vox/gloves.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/gloves.dmi'
	icon_state = "gloves-vox"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
	cut_type = null

/obj/item/clothing/gloves/color/yellow/vox/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

// Robes and armor

/obj/item/clothing/suit/hooded/vox_robes
	name = "alien hooded robes"
	desc = "Large, comfortable robes worn by those who need a bit more covering. The thick fabric contains a pocket suitable for those that need their hands free during their work, while the cloth serves to cover scars or other injuries to the wearer's body."
	icon = 'icons/mob/clothing/species/vox/suit.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/suit.dmi'
	icon_state = "vox-robes"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/vox_robe_hood

/obj/item/clothing/suit/hooded/vox_robes/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

/obj/item/clothing/head/hooded/vox_robe_hood
	name = "alien hood"
	desc = "The thick fabric of this hood serves a variety of purposes to the vox wearing it - serving as a method to hide a scarred face or a way to keep warm in the coldest areas onboard the ship."
	icon = 'icons/mob/clothing/species/vox/head.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/head.dmi'
	icon_state = "vox-robes-hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/datum/armor/vox_scrap //Higher melee armor versus lower everything else.
	melee = 70
	bullet = 30
	laser = 20
	energy = 5
	bomb = 40
	fire = 50
	acid = 50
	wound = 15

/obj/item/clothing/suit/armor/vox_scrap
	name = "rusted metal armor"
	desc = "A hodgepodge of various pieces of metal scrapped together into a rudimentary vox-shaped piece of armor."
	icon = 'icons/obj/species/vox/suits.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/suit.dmi'
	icon_state = "vox-scrap"
	inhand_icon_state = "armor"
	allowed = list(/obj/item/gun, /obj/item/tank)
	armor_type = /datum/armor/vox_scrap
	body_parts_covered = CHEST|ARMS|GROIN|LEGS

/obj/item/clothing/suit/armor/vox_scrap/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

// Uniforms

/obj/item/clothing/under/vox
	icon = 'icons/obj/species/vox/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/species/vox/uniform.dmi'
	inhand_icon_state = null
	can_adjust = FALSE
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/vox/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	return vox_only_equip_check(src, M, slot, disable_warning) && ..()

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"

/obj/item/clothing/under/vox/vox_jumpsuit
	name = "alien jumpsuit"
	desc = "These loose clothes are optimized for the labors of the lower castes onboard the arkships. Large openings in the top allow for breathability while the pants are durable yet flexible enough to not restrict movement."
	icon = 'icons/mob/clothing/species/vox/uniform.dmi'
	icon_state = "vox-jumpsuit"

// Greyscale jumpsuits and sneakers get vox shaped versions of their worn configs.

/datum/greyscale_config/jumpsuit/worn/vox
	name = "Jumpsuit (Worn, Vox)"
	icon_file = 'icons/mob/clothing/species/vox/greyscale.dmi'

/datum/greyscale_config/jumpsuit_prison_worn/vox
	name = "Worn Prison Jumpsuit (Vox)"
	icon_file = 'icons/mob/clothing/species/vox/greyscale.dmi'

/datum/greyscale_config/sneakers/worn/vox
	name = "Sneakers (Worn, Vox)"
	icon_file = 'icons/mob/clothing/species/vox/greyscale.dmi'

/datum/greyscale_config/sneakers_orange/worn/vox
	name = "Orange Sneakers (Worn, Vox)"
	icon_file = 'icons/mob/clothing/species/vox/greyscale.dmi'
