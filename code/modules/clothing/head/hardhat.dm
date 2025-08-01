/obj/item/clothing/head/utility
	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'

/obj/item/clothing/head/utility/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	inhand_icon_state = null
	armor_type = /datum/armor/utility_hardhat
	flags_inv = 0
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	resistance_flags = FIRE_PROOF

	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_outer_range = 4
	light_power = 0.8
	light_on = FALSE
	dog_fashion = /datum/dog_fashion/head

	///Determines used sprites: `hardhat[on]_[hat_type]` and `hardhat[on]_[hat_type]2` (lying down sprite)
	var/hat_type = "yellow"
	///Whether the headlamp is on or off.
	var/on = FALSE


/datum/armor/utility_hardhat
	melee = 15
	bullet = 5
	laser = 20
	energy = 10
	bomb = 20
	bio = 50
	fire = 100
	acid = 50
	wound = 10

/obj/item/clothing/head/utility/hardhat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HEAD)

/obj/item/clothing/head/utility/hardhat/proc/toggle_helmet_light(mob/living/user)
	on = !on
	if(on)
		turn_on(user)
	else
		turn_off(user)
	update_appearance()

/obj/item/clothing/head/utility/hardhat/update_icon_state()
	icon_state = inhand_icon_state = "hardhat[on]_[hat_type]"
	return ..()

/obj/item/clothing/head/utility/hardhat/proc/turn_on(mob/user)
	set_light_on(TRUE)

/obj/item/clothing/head/utility/hardhat/proc/turn_off(mob/user)
	set_light_on(FALSE)

/obj/item/clothing/head/utility/hardhat/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(on)
		toggle_helmet_light()
		return TRUE

/obj/item/clothing/head/utility/hardhat/attack_self(mob/living/user)
	toggle_helmet_light(user)

/obj/item/clothing/head/utility/hardhat/orange
	icon_state = "hardhat0_orange"
	inhand_icon_state = null
	hat_type = "orange"
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/red
	icon_state = "hardhat0_red"
	inhand_icon_state = null
	hat_type = "red"
	dog_fashion = null
	name = "firefighter helmet"
	clothing_flags = STOPSPRESSUREDAMAGE | PLASMAMAN_HELMET_EXEMPT

	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/utility/hardhat/red/upgraded
	name = "workplace-ready firefighter helmet"
	desc = "By applying state of the art lighting technology to a fire helmet, and using photo-chemical hardening methods, this hardhat will protect you from robust workplace hazards."
	icon_state = "hardhat0_purple"
	inhand_icon_state = null
	light_outer_range = 5
	resistance_flags = FIRE_PROOF | ACID_PROOF
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plastic = SHEET_MATERIAL_AMOUNT*1.5, /datum/material/silver = SMALL_MATERIAL_AMOUNT*5)
	hat_type = "purple"

/obj/item/clothing/head/utility/hardhat/white
	icon_state = "hardhat0_white"
	inhand_icon_state = null
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE | PLASMAMAN_HELMET_EXEMPT

	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/utility/hardhat/dblue
	icon_state = "hardhat0_dblue"
	inhand_icon_state = null
	hat_type = "dblue"
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/welding
	name = "welding hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield! The bulb seems a little smaller though."
	light_outer_range = 3 //Needs a little bit of tradeoff
	dog_fashion = null
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	visor_flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	///Icon state of the welding visor.
	var/visor_state = "weldvisor"

/obj/item/clothing/head/utility/hardhat/welding/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/clothing/head/utility/hardhat/welding/attack_self_secondary(mob/user, modifiers)
	toggle_welding_screen(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/utility/hardhat/welding/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_welding_screen))
		toggle_welding_screen(user)
		return

	return ..()

/obj/item/clothing/head/utility/hardhat/welding/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE) //Visors don't just come from nothing
	update_appearance()

/obj/item/clothing/head/utility/hardhat/welding/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(isinhands)
		return

	if(!up)
		. += mutable_appearance('icons/mob/clothing/head/utility.dmi', visor_state)

/obj/item/clothing/head/utility/hardhat/welding/update_overlays()
	. = ..()
	if(!up)
		. += visor_state

/obj/item/clothing/head/utility/hardhat/welding/orange
	icon_state = "hardhat0_orange"
	inhand_icon_state = null
	hat_type = "orange"

/obj/item/clothing/head/utility/hardhat/welding/white
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield!" //This bulb is not smaller
	icon_state = "hardhat0_white"
	inhand_icon_state = null
	light_outer_range = 4 //Boss always takes the best stuff
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE | PLASMAMAN_HELMET_EXEMPT

	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/utility/hardhat/welding/dblue
	icon_state = "hardhat0_dblue"
	inhand_icon_state = null
	hat_type = "dblue"

/obj/item/clothing/head/utility/hardhat/welding/atmos
	icon_state = "hardhat0_atmos"
	inhand_icon_state = null
	hat_type = "atmos"
	dog_fashion = null
	name = "atmospheric firefighter helmet"
	desc = "A firefighter's helmet, able to keep the user cool in any situation. Comes with a light and a welding visor."
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | PLASMAMAN_HELMET_EXEMPT | HEADINTERNALS

	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	visor_flags_cover = NONE
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = NONE
	visor_state = "weldvisor_atmos"

/obj/item/clothing/head/utility/hardhat/welding/atmos/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/utility/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hardhat0_pumpkin"
	inhand_icon_state = null
	hat_type = "pumpkin"
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	armor_type = /datum/armor/none
	light_outer_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES
	light_color = "#fff2bf"
	worn_y_offset = 1
	dog_fashion = /datum/dog_fashion/head/pumpkin/unlit

/obj/item/clothing/head/utility/hardhat/pumpkinhead/set_light_on(new_value)
	. = ..()
	if(isnull(.))
		return
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/head/utility/hardhat/pumpkinhead/update_overlays()
	. = ..()
	if(light_on)
		. += emissive_appearance(icon, "carved_pumpkin-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/utility/hardhat/pumpkinhead/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(light_on && !isinhands)
		. += emissive_appearance(icon_file, "carved_pumpkin-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/utility/hardhat/pumpkinhead/turn_on(mob/user)
	. = ..()
	dog_fashion = /datum/dog_fashion/head/pumpkin/lit

/obj/item/clothing/head/utility/hardhat/pumpkinhead/turn_off(mob/user)
	. = ..()
	dog_fashion = /datum/dog_fashion/head/pumpkin/unlit

/obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin
	name = "carved blumpkin"
	desc = "A very blue jack o' lantern! Believed to ward off vengeful chemists."
	icon_state = "hardhat0_blumpkin"
	inhand_icon_state = null
	hat_type = "blumpkin"
	light_color = "#76ff8e"
	dog_fashion = /datum/dog_fashion/head/blumpkin/unlit

/obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin/turn_on(mob/user)
	. = ..()
	dog_fashion = /datum/dog_fashion/head/blumpkin/lit

/obj/item/clothing/head/utility/hardhat/pumpkinhead/blumpkin/turn_off(mob/user)
	. = ..()
	dog_fashion = /datum/dog_fashion/head/blumpkin/unlit

/obj/item/clothing/head/utility/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hardhat0_reindeer"
	inhand_icon_state = null
	hat_type = "reindeer"
	flags_inv = 0
	armor_type = /datum/armor/none
	light_outer_range = 1 //luminosity when on


	dog_fashion = /datum/dog_fashion/head/reindeer

/obj/item/clothing/head/utility/hardhat/jack
	name = "carved square pumpkin"
	desc = "A very square jack o' lantern, with nails included! Believed to ward off laight, but makes you feel as if your taking too long."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hardhat0_jack"
	inhand_icon_state = null
	hat_type = "jack"
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	armor_type = /datum/armor/none
	flags_cover = HEADCOVERSEYES
	worn_y_offset = 1

	light_system = null
	light_outer_range = 0
	light_power = 0

/obj/item/clothing/head/utility/hardhat/jack/update_overlays()
	. = ..()
	if(light_on)
		. += emissive_appearance(icon, "jack-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/utility/hardhat/jack/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(light_on && !isinhands)
		. += emissive_appearance(icon_file, "jack-emissive", src, alpha = src.alpha)
