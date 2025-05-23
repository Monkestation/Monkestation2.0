/obj/item/book/granter/martial/carp
	martial = /datum/martial_art/the_sleeping_carp
	name = "mysterious scroll"
	martial_name = "sleeping carp"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	greet = "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles \
		directed toward you while in Combat Mode. Your body has also hardened itself, granting extra protection against lasting wounds that would otherwise mount during extended combat. \
		However, you are also unable to use any ranged weaponry. You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	worn_icon_state = "scroll"
	remarks = list(
		"Wait, a high protein diet is really all it takes to become stabproof...?",
		"Overwhelming force, immovable object...",
		"Focus... And you'll be able to incapacitate any foe in seconds...",
		"I must pierce armor for maximum damage...",
		"I don't think this would combine with other martial arts...",
		"Become one with the carp...",
		"Glub...",
	)

/obj/item/book/granter/martial/carp/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/carp/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)

/obj/item/book/granter/martial/carp/true
	name = "Blood-stained Scroll"
	martial = /datum/martial_art/the_sleeping_carp/awakened_dragon
	martial_name = "awakened dragon"
	greet = "<span class='sciradio'>You have learned the ancient martial art of the Awakened Dragon! Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles \
		directed toward you while in Combat Mode. Your body has also hardened itself, granting extra protection against lasting wounds that would otherwise mount during extended combat. \
		However, you are also unable to use any ranged weaponry. You can learn more about your newfound art by using the Recall Teachings verb in the Awakened Dragon tab.</span>"
	desc = "This scroll appears to be penned with the blood of an entire \
			branch of the Sleeping Carp sect. It pulses with the power of the Awakened Dragon."
	remarks = list(
		"Wait, rice pills and scripture are really all it takes to become stabproof...?",
		"I must rise to the top of the murim...",
		"Focus... And you'll be able to incapacitate any foe in an instant...",
		"Armor is but paper before my claws...",
		"All other martial arts are but imitations...",
		"Awaken the Dragon...",
		"Impudent young masters will not stop me...",
	)
