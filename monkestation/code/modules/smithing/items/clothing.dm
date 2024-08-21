/obj/item/clothing/smithed_clothes
	name = "generic smithed clothes"
	desc = "generic smithed clothes"
	var/smithed_quality = 100
	var/obj/made_of = null
	var/base_name = "generic smithed clothes"

/obj/item/clothing/smithed_clothes/Initialize(mapload,obj/item/created_from,quality)
	. = ..()
	smithed_quality = max(quality, 5)

	if(!created_from)
		created_from = new /obj/item/stack/sheet/mineral/gold
	made_of = new created_from.type

	if(isstack(created_from) && !created_from.material_stats)
		var/obj/item/stack/stack = created_from
		create_stats_from_material(stack.material_type)
	else
		create_stats_from_material_stats(created_from.material_stats)

	name = "[material_stats.material_name] [base_name]"
	var/damage_state
	switch(smithed_quality)
		if(0 to 24)
			damage_state = "damage-4"
			desc += " It looks of poor quality... Quality:[smithed_quality]"
		if(25 to 49)
			damage_state = "damage-3"
			desc += " It looks slightly under average. Quality:[smithed_quality]"
		if(50 to 59)
			damage_state = "damage-2"
			desc += " It looks pretty average quality. Quality:[smithed_quality]"
		if(60 to 89)
			damage_state = "damage-1"
			desc += " It looks well forged! Quality:[smithed_quality]"
		if(90 to 99)
			damage_state = null
			desc += " It looks about as perfect as can be! Quality:[smithed_quality]"
		if(100 to 125)
			damage_state = null
			desc += " It's utterly flawless! Quality:[smithed_quality]"

	if(damage_state)
		add_filter("damage_filter", 1, alpha_mask_filter(icon = icon('monkestation/code/modules/smithing/icons/forge_items.dmi', damage_state), flags = MASK_INVERSE))


	max_integrity = round(200 * (smithed_quality/100))
	repairable_by = made_of.type //This cant go wrong right
	if(material_stats.conductivity <= 10)
		siemens_coefficient = 0

	var/datum/armor/temp = new() //Scuffed, but no idea how to better.
	armor_type = temp.generate_new_with_modifiers(list(
		ACID = round((material_stats.density / 2) * (smithed_quality/100)),
		BOMB = round(((material_stats.density + material_stats.hardness)/3) * (smithed_quality/100)),
		BULLET = round(((material_stats.density + material_stats.hardness)/3) * (smithed_quality/100)),
		ENERGY = round((material_stats.refractiveness / 2) * (smithed_quality/100)),
		FIRE = round((material_stats.thermal/2) * (smithed_quality/100)),
		LASER = round(((material_stats.refractiveness + material_stats.density)/3) * (smithed_quality/100)),
		MELEE = round((material_stats.density + material_stats.hardness)/2 * (smithed_quality/100))
	))
	QDEL_NULL(temp) //Thanks now back to the void with you


/obj/item/clothing/smithed_clothes/update_name(updates)
	. = ..()
	if(smithed_quality < 100)
		name = "[material_stats.material_name] [base_name]"
	else
		name = "flawless [material_stats.material_name] [base_name]"

/obj/item/clothing/smithed_clothes/gloves
	name = "generic smithed gloves"
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_icon_state = "greyscale_gloves"
	icon_state = "gray"
	lefthand_file = 'icons/mob/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/gloves_righthand.dmi'
	greyscale_colors = null
	greyscale_config_inhand_left = /datum/greyscale_config/gloves_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/gloves_inhand_right
	siemens_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	attack_verb_continuous = list("challenges")
	attack_verb_simple = list("challenge")
	strip_delay = 20
	equip_delay_other = 40

	base_name = "gloves"

/obj/item/clothing/smithed_clothes/suit
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	icon_state = "cuirass"
	allowed = null
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	resistance_flags = NONE
	slot_flags = ITEM_SLOT_ON_BODY

	base_name = "suit"
/obj/item/clothing/smithed_clothes/helmet
	name = "generic smithed helmet"
	desc = "generic smithed helemt"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "knight_green"
	inhand_icon_state = "helmet"
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	slot_flags = ITEM_SLOT_HEAD

	base_name = "helmet"

/obj/item/clothing/smithed_clothes/shoes
	name = "generic smithed shoes"
	desc = "generic smithed shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	inhand_icon_state = "jackboots"
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "morningstar_shoes"
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	lefthand_file = 'icons/mob/inhands/clothing/shoes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/shoes_righthand.dmi'
	gender = PLURAL //Carn: for grammarically correct text-parsing

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

	base_name = "shoes"
