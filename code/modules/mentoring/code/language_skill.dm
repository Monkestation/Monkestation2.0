//PORTED FROM NOVA/IRIS/OCULIS FORK
/datum/skill/language
	name = "Language"
	title = "Linguist"
	desc = "Do not limit yourself to one language. Languages are doors to different cultures."
	modifiers = list(SKILL_SPEED_MODIFIER = list(1, 0.95, 0.9, 0.85, 0.75, 0.6, 0.5))
	skill_item_path = /obj/item/clothing/accessory/language

/datum/skill/language/level_gained(datum/mind/mind, new_level, old_level, silent)
	. = ..()
	if(new_level >= SKILL_LEVEL_APPRENTICE && old_level < SKILL_LEVEL_APPRENTICE)
		ADD_TRAIT(mind.current, TRAIT_LITERATE, SKILL_TRAIT)

	var/datum/language_holder/language_holder = mind.current.get_language_holder()
	var/list/learnable_languages = GLOB.all_languages.Copy() - language_holder.understood_languages
	if(!length(learnable_languages)) // Once there are no more languages to learn, we make sure we stop running
		return

	var/language_amount = (new_level > SKILL_LEVEL_MASTER ? length(learnable_languages) : min(length(learnable_languages), new_level)) // If we're legendary, learn em all
	var/learned_string = ""
	for(var/index in 1 to language_amount)
		var/datum/language/language = pick_n_take(learnable_languages)
		mind.current.grant_language(language, source = LANGUAGE_MIND)
		var/separator = ""
		if(index > 1)
			separator = (index == language_amount) ? " and" : ","

		learned_string = "[learned_string][separator][index > 1 ? " " : ""][initial(language.name)]"

	to_chat(mind.current, span_nicegreen("I feel like my understanding of [learned_string] became a lot better!"))

/obj/item/clothing/accessory/language
	name = "language master badge"
	desc = "A small medal showing your dedication to learning all languages across the galaxy"
	icon_state = "bronze"

/obj/item/clothing/accessory/language/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/skill_reward, /datum/skill/language)

/datum/job/curator/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	spawned.mind?.set_level(/datum/skill/language, SKILL_LEVEL_LEGENDARY, silent = TRUE)
