///Variant of bodypart_overlay meant to work synchronously with external organs. Gets imprinted upon Insert in on_species_gain
/datum/bodypart_overlay/mutant
	///Sprite datum we use to draw on the bodypart
	var/datum/sprite_accessory/sprite_datum

	///Defines what kind of 'organ' we're looking at. Sprites have names like 'm_mothwings_firemoth_ADJ'. 'mothwings' would then be feature_key
	var/feature_key = ""

	///The color this organ draws with. Updated by bodypart/inherit_color()
	var/draw_color
	///Where does this organ inherit it's color from?
	var/color_source = ORGAN_COLOR_INHERIT
	///Take on the dna/preference from whoever we're gonna be inserted in
	var/imprint_on_next_insertion = TRUE

///Completely random image and color generation (obeys what a player can choose from)
/datum/bodypart_overlay/mutant/proc/randomize_appearance()
	randomize_sprite()
	draw_color = "#[random_color()]"
	imprint_on_next_insertion = FALSE

/datum/bodypart_overlay/mutant/get_extended_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	var/passed_color = sprite_datum.color_src ? draw_color : null
	var/mob/living/carbon/human/owner = limb.owner
	if(!owner)
		return
	var/datum/species/owner_species = owner.dna.species

	return owner_species.return_accessory_layer(-layer, sprite_datum, owner, passed_color)


///Grab a random sprite
/datum/bodypart_overlay/mutant/proc/randomize_sprite()
	sprite_datum = get_random_appearance()

///Grab a random appearance datum (thats not locked)
/datum/bodypart_overlay/mutant/proc/get_random_appearance()
	var/list/valid_restyles = list()
	var/list/feature_list = get_global_feature_list()
	for(var/accessory in feature_list)
		var/datum/sprite_accessory/accessory_datum = feature_list[accessory]
		if(initial(accessory_datum.locked)) //locked is for stuff that shouldn't appear here
			continue
		valid_restyles += accessory_datum
	return pick(valid_restyles)

///Return the BASE icon state of the sprite datum (so not the gender, layer, feature_key)
/datum/bodypart_overlay/mutant/proc/get_base_icon_state()
	return sprite_datum.icon_state

///Get the image we need to draw on the person. Called from get_overlay() which is called from _bodyparts.dm. Limb can be null
/datum/bodypart_overlay/mutant/get_image_inner(image_layer, obj/item/bodypart/limb)
	if(!sprite_datum)
		CRASH("Trying to call get_image() on [type] while it didn't have a sprite_datum. This shouldn't happen, report it as soon as possible.")

	if(!sprite_datum.hasinner)
		return null

	var/gender = (limb?.limb_gender == FEMALE) ? "f" : "m"
	var/list/icon_state_builder = list()
	icon_state_builder += sprite_datum.gender_specific ? gender : "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
	icon_state_builder += "[feature_key]inner"
	icon_state_builder += get_base_icon_state()
	icon_state_builder += mutant_bodyparts_layertext(image_layer)

	var/finished_icon_state = icon_state_builder.Join("_")

	var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = image_layer)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance

/datum/bodypart_overlay/mutant/added_to_limb(obj/item/bodypart/limb)
	inherit_color(limb)

///Change our accessory sprite, using the accesssory type. If you need to change the sprite for something, use simple_change_sprite()
/datum/bodypart_overlay/mutant/set_appearance(accessory_type)
	sprite_datum = fetch_sprite_datum(accessory_type)
	cache_key = jointext(generate_icon_cache(), "_")

///In a lot of cases, appearances are stored in DNA as the Name, instead of the path. Use set_appearance instead of possible
/datum/bodypart_overlay/mutant/proc/set_appearance_from_name(accessory_name)
	sprite_datum = fetch_sprite_datum_from_name(accessory_name)
	cache_key = jointext(generate_icon_cache(), "_")

///Generate a unique key based on our sprites. So that if we've aleady drawn these sprites, they can be found in the cache and wont have to be drawn again (blessing and curse, but mostly curse)
/datum/bodypart_overlay/mutant/generate_icon_cache()
	. = list()
	. += "[get_base_icon_state()]"
	. += "[feature_key]"
	. += "[draw_color]"
	return .

///Return a dumb glob list for this specific feature (called from parse_sprite)
/datum/bodypart_overlay/mutant/proc/get_global_feature_list()
	CRASH("External organ has no feature list, it will render invisible")

///Give the organ its color. Force will override the existing one.
/datum/bodypart_overlay/mutant/proc/inherit_color(obj/item/bodypart/ownerlimb, force)
	if(isnull(ownerlimb))
		draw_color = null
		return TRUE

	if(draw_color && !force)
		return FALSE

	if(palette)
		var/datum/color_palette/located = ownerlimb.owner.dna.color_palettes[palette]
		draw_color = located.return_color(palette_key, fallback_key)
	else
		switch(color_source)
			if(ORGAN_COLOR_OVERRIDE)
				draw_color = override_color(ownerlimb.draw_color)
			if(ORGAN_COLOR_INHERIT)
				draw_color = ownerlimb.draw_color
			if(ORGAN_COLOR_HAIR)
				if(!ishuman(ownerlimb.owner))
					return
				var/mob/living/carbon/human/human_owner = ownerlimb.owner
				var/obj/item/bodypart/head/my_head = human_owner.get_bodypart(BODY_ZONE_HEAD) //not always the same as ownerlimb
				//head hair color takes priority, owner hair color is a backup if we lack a head or something
				if(my_head)
					draw_color = my_head.hair_color
				else
					draw_color = human_owner.hair_color
			if(ORGAN_COLOR_ANIME)
				if(!ishuman(ownerlimb.owner))
					return
				var/mob/living/carbon/human/human_owner = ownerlimb.owner
				draw_color = human_owner.dna.features["animecolor"]

	return TRUE

///Sprite accessories are singletons, stored list("Big Snout" = instance of /datum/sprite_accessory/snout/big), so here we get that singleton
/datum/bodypart_overlay/mutant/proc/fetch_sprite_datum(datum/sprite_accessory/accessory_path)
	var/list/feature_list = get_global_feature_list()

	return feature_list[initial(accessory_path.name)]

///Get the singleton from the sprite name
/datum/bodypart_overlay/mutant/proc/fetch_sprite_datum_from_name(accessory_name)
	var/list/feature_list = get_global_feature_list()

	return feature_list[accessory_name]
