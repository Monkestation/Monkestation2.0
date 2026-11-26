/mob/living/basic/fish
	name = "concept of a fish"
	desc = "Fishy."
	icon = 'monkestation/code/modules/ghost_players/arena/arena_assets/icons/fish.dmi'
	icon_state = "guppy"
	icon_living = "guppy"
	speak_emote = list("blubs")
	maxHealth = 20
	health = 20
	basic_mob_flags = DEL_ON_DEATH
	movement_type = FLYING
	ai_controller = /datum/ai_controller/basic_controller/fish
	/// What we drop when we die
	var/fish_loot
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"
	verb_say = "blubs"
	verb_ask = "blubs inquisitively"
	verb_exclaim = "blubs intensely"
	verb_yell = "blubs intensely"

/mob/living/basic/fish/Initialize(mapload)
	. = ..()
	if(fish_loot)
		AddElement(/datum/element/death_drops, string_list(list(fish_loot)))

/// Fish just swim around
/datum/ai_controller/basic_controller/fish
	behavior_tree_json = "code/modules/mob/living/basic/vermin/butterfly.bt.json"

/mob/living/basic/fish/guppy
	name = "guppy"
	desc = "Guppy is also known as rainbow fish because of the brightly colored body and fins."
	icon_state = "guppy"
	fish_loot = /obj/item/fish/guppy

/mob/living/basic/fish/firefish
	name = "firefish goby"
	desc = "To communicate in the wild, the firefish uses its dorsal fin to alert others of potential danger."
	icon_state = "firefish"
	fish_loot = /obj/item/fish/firefish

/mob/living/basic/fish/greenchromis
	name = "green chromis"
	desc = "The Chromis can vary in color from blue to green depending on the lighting and distance from the lights."
	icon_state = "greenchromis"
	fish_loot = /obj/item/fish/greenchromis

/mob/living/basic/fish/catfish
	name = "cory catfish"
	desc = "A catfish has about 100,000 taste buds, and their bodies are covered with them to help detect chemicals present in the water and also to respond to touch."
	icon_state = "catfish"
	fish_loot = /obj/item/fish/catfish

/mob/living/basic/fish/plasmatetra
	name = "plasma tetra"
	desc = "Due to their small size, tetras are prey to many predators in their watery world, including eels, crustaceans, and invertebrates."
	icon_state = "plastetra"
	fish_loot = /obj/item/fish/plasmatetra

/mob/living/basic/fish/angelfish
	name = "angelfish"
	desc = "Young Angelfish often live in groups, while adults prefer solitary life. They become territorial and aggressive toward other fish when they reach adulthood."
	icon_state = "angelfish"
	fish_loot = /obj/item/fish/angelfish

/mob/living/basic/fish/clownfish
	name = "clownfish"
	desc = "Clownfish catch prey by swimming onto the reef, attracting larger fish, and luring them back to the anemone. The anemone will sting and eat the larger fish, leaving the remains for the clownfish."
	icon_state = "clownfish"
	fish_loot = /obj/item/fish/clownfish

/mob/living/basic/fish/goldfish
	name = "goldfish"
	desc = "Despite common belief, goldfish do not have three-second memories. They can actually remember things that happened up to three months ago."
	icon_state = "goldfish"
	fish_loot = /obj/item/fish/goldfish

/mob/living/basic/fish/dwarf_moonfish
	name = "dwarf moonfish"
	desc = "Ordinarily in the wild, the Zagoskian moonfish is around the size of a tuna, however through selective breeding a smaller breed suitable for being kept as an aquarium pet has been created."
	icon_state = "dwarf_moonfish"
	fish_loot = /obj/item/fish/moonfish/dwarf

/mob/living/basic/fish/gunner_jellyfish
	name = "gunner jellyfish"
	desc = "So called due to their resemblance to an artillery shell, the gunner jellyfish is native to Tizira, where it is enjoyed as a delicacy. Produces a mild hallucinogen that is destroyed by cooking."
	icon_state = "gunner_jellyfish"
	fish_loot = /obj/item/fish/gunner_jellyfish
