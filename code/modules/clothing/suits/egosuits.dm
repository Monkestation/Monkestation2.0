// Effectively the same code as costume.dm but separated in order to reduce the length of the code.
// NOTE: I DID NOT CREATE ANY OF THE ART FOR THE PROJECT MOON OUTFITS. All credit for that goes to the original artists
// working on LC13. Some code and descriptions have also been reused from the same place. My art contributions include sprites
// for the EGOdrobe and its restock. Thank you to the original creators, and thank you to Project Moon for creating the
// games these originate from.

// Base code for what the thing is and what it can hold (some of this will change when redefined
// by risk levels, realization, etc)
/obj/item/clothing/suit/egosuits
	icon = 'icons/obj/clothing/egosuits/suits.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/suit.dmi'
	flags_inv = HIDEJUMPSUIT
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/radio,
		/obj/item/storage/belt/holster,
		)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS //Each suit is basically a full outfit
	var/obj/item/clothing/head/egosuits/hat = null

// Code for initializing the hat-toggling
/obj/item/clothing/suit/egosuits/Initialize(mapload)
	. = ..()
	if(hat)
		AddComponent(\
		/datum/component/toggle_attached_clothing,\
		deployable_type = hat,\
		equipped_slot = ITEM_SLOT_HEAD,\
		action_name = "Toggle Hat",\
		)

// Code for how hats are handled (copied from _ego_head.dm)
/obj/item/clothing/head/egosuits
	name = "ego hat"
	desc = "an ego hat that you shouldn't be seeing!"
	icon = 'icons/obj/clothing/egosuits/head.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/head.dmi'
	icon_state = ""
	flags_inv = HIDEMASK
	var/perma = FALSE // So we can stack all LC13 related hats under the same obj path

// ZAYIN
/obj/item/clothing/suit/egosuits/zayin
	icon = 'icons/obj/clothing/egosuits/zayin.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/zayin.dmi'

/obj/item/clothing/suit/egosuits/zayin/wingbeat
	name = "wingbeat"
	desc = "Most of the employees do not know the true meaning of The Fairies’ Care."
	icon_state = "wingbeat"

// TETH
/obj/item/clothing/suit/egosuits/teth
	icon = 'icons/obj/clothing/egosuits/teth.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/teth.dmi'

/obj/item/clothing/suit/egosuits/teth/regret
	name = "regret"
	desc = "Now the straitjacket is nothing but an accessory to the hatred and anger that remains."
	icon_state = "regret"

/obj/item/clothing/suit/egosuits/teth/lantern
	name = "lantern"
	desc = "The luminous organ shines brilliantly, making it useful for lighting up the dark. It’s also great as a lure."
	icon_state = "lantern"

/obj/item/clothing/suit/egosuits/teth/dream
	name = "engulfing dream"
	desc = "The more entrancing it is, the bigger the disappointment will be when dawn breaks."
	icon_state = "dream"

/obj/item/clothing/suit/egosuits/teth/blossoms
	name = "cherry blossoms"
	desc = "Sitting under the tree’s shadow makes you feel like these gloomy days will flutter away like the petals of a flower."
	icon_state = "blossoms"

// HE
/obj/item/clothing/suit/egosuits/he
	icon = 'icons/obj/clothing/egosuits/he.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/he.dmi'

/obj/item/clothing/suit/egosuits/he/sanguine
	name = "sanguine desire"
	desc = "Smells funny, and is surprisingly heavy."
	icon_state = "sanguine"

/obj/item/clothing/suit/egosuits/he/harmony
	name = "harmony"
	desc = "Oh, the sound is so beautiful."
	icon_state = "harmony"

/obj/item/clothing/suit/egosuits/he/frostsplinter
	name = "frost splinter"
	desc = "Surprisingly cold to the touch."
	icon_state = "frost_splinter"

/obj/item/clothing/suit/egosuits/he/prank
	name = "funny prank"
	desc = "The little kid who couldn't leave her friends behind came up with a brilliant idea."
	icon_state = "prank"
	flags_inv = HIDESHOES

/obj/item/clothing/suit/egosuits/he/solemnlament
	name = "solemn lament"
	desc = "The undertaker's outfit belongs to those who pay tribute to the dead.\
	Only a solemn mind is required to express condolences; there is no need for showy accessories."
	icon_state ="solemnlament"

/obj/item/clothing/suit/egosuits/he/magicbullet
	name = "magic bullet"
	desc = "The Devil ultimately wished for despair. For despair wears down the mind and drains one's will to go forward. When one feels there's nothing left to go for, their soul falls down to Hell, the Devil's domain."
	icon_state = "magic_bullet"

// WAW
/obj/item/clothing/suit/egosuits/waw
	icon = 'icons/obj/clothing/egosuits/waw.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/waw.dmi'

/obj/item/clothing/suit/egosuits/waw/hatred
	name = "in the name of love and hate"
	desc = "A magical one-piece dress imbued with the love and justice of a magical girl. \
	Wearing it may ignite your spirit of justice and the desire to protect the world. \
	Then you'll hear the sound of hatred, sinking deeper than love."
	icon_state = "hatred"

/obj/item/clothing/suit/egosuits/waw/stem
	name = "green stem"
	desc = "Letting go of the obsession may ease the suffering a little."
	icon_state = "green_stem"

/obj/item/clothing/suit/egosuits/waw/hornet
	name = "hornet armor"
	desc = "A dark coat with yellow details. You feel as if you can hear faint buzzing coming out of it."
	icon_state = "hornet"

/obj/item/clothing/suit/egosuits/waw/aroma
	name = "faint aroma"
	desc = "The ceramic surface is tough as if it had been glazed several times. \
			It may crumble back into primal clay if it is exposed to a powerful mental attack."
	icon_state = "aroma"

/obj/item/clothing/suit/egosuits/waw/crimson
	name = "crimson scar"
	desc = "It seems only darkness awaits those who find the value of their lives in nothing but destruction."
	icon_state = "crimson_scar"

/obj/item/clothing/suit/egosuits/waw/cobalt
	name = "cobalt scar"
	desc = "The armor is torn up with countless traces that recount the history of the unending battle."
	icon_state = "cobalt_scar"

/obj/item/clothing/suit/egosuits/waw/heaven
	name = "heaven"
	desc = "That's what a gaze is. Attention. An invisible string that connects us."
	icon_state = "heaven"

/obj/item/clothing/suit/egosuits/waw/despair
	name = "armor sharpened with tears"
	desc = "Tears fall like ash, embroidered as if they were constellations."
	icon_state = "despair"

/obj/item/clothing/suit/egosuits/waw/feather
	name = "Feather of Honor"
	desc = "Bright as the abnormality it was extracted from, but somehow does not give off any heat. \
			Maybe keep it away from the cold..."
	icon_state = "featherofhonor"

/obj/item/clothing/suit/egosuits/waw/amrita
	name = "amrita"
	desc = "You can smell old dirt and fire if you put your nose close enough."
	icon_state = "amrita"

// ALEPH
/obj/item/clothing/suit/egosuits/aleph
	icon = 'icons/obj/clothing/egosuits/aleph.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/aleph.dmi'

/obj/item/clothing/suit/egosuits/aleph/paradise
	name = "paradise lost"
	desc = "\"My loved ones, do not worry; I have heard your prayers. \
	Have you not yet realized that pain is but a speck to a determined mind?\""
	icon_state = "paradise"

/obj/item/clothing/suit/egosuits/aleph/twilight
	name = "twilight"
	desc = "The three birds united their efforts to defeat the beast. \
	This could stop countless incidents, but you’ll have to be prepared to step into the Black Forest…"
	icon_state = "twilight"

/obj/item/clothing/suit/egosuits/aleph/censored
	name = "CENSORED"
	desc = "Goodness, that’s disgusting."
	icon_state = "censored"

/obj/item/clothing/suit/egosuits/aleph/star
	name = "sound of a star"
	desc = "At the heart of the armor is a shard that emits an arcane gleam. \
	The gentle glow feels somehow more brilliant than a flashing light."
	icon_state = "star"

/obj/item/clothing/suit/egosuits/aleph/adoration
	name = "adoration"
	desc = "It is not as unpleasant to wear as it is to look at. \
	In fact, it seems to give you an illusion of comfort and bravery."
	icon_state = "adoration"

// REALIZED
/obj/item/clothing/suit/egosuits/realized
	icon = 'icons/obj/clothing/egosuits/realization.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/realized.dmi'

/obj/item/clothing/suit/egosuits/realized/confessional
	name = "confessional"
	desc = "Come my child. Tell me your sins."
	icon_state = "confessional"

/obj/item/clothing/suit/egosuits/realized/prophet
	name = "prophet"
	desc = "And they have conquered him by the blood of the Lamb and by the word of their testimony, for they loved not their lives even unto death."
	icon_state = "prophet"
	hat = /obj/item/clothing/head/egosuits/prophet_hat

/obj/item/clothing/head/egosuits/prophet_hat
	name = "prophet"
	desc = "For this reason, rejoice, you heavens and you who dwell in them. Woe to the earth and the sea, because the devil has come down to you with great wrath, knowing that he has only a short time."
	icon_state = "prophet"

/obj/item/clothing/suit/egosuits/realized/wellcheers
	name = "wellcheers"
	desc = " I’ve found true happiness in cracking open a cold one after a hard day’s work, covered in sea water and sweat. \
	I’m at the port now but we gotta take off soon to catch some more shrimp. Never know what your future holds, bros."
	icon_state = "wellcheers"
	hat = /obj/item/clothing/head/egosuits/wellcheers_hat

/obj/item/clothing/head/egosuits/wellcheers_hat
	name = "wellcheers"
	desc = "You’re really missing out on life if you’ve never tried shrimp."
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT|HIDEEYES
	icon_state = "wellcheers"

/obj/item/clothing/suit/egosuits/realized/ember_matchlight
	name = "ember matchlight"
	desc = "If I must perish, then I'll make you meet the same fate."
	icon_state = "ember_matchlight"

/obj/item/clothing/suit/egosuits/realized/mouth
	name = "mouth of god"
	desc = "And the mouth of god spoke: You will be punished."
	icon_state = "mouth"

/obj/item/clothing/suit/egosuits/realized/universe
	name = "one with the universe"
	desc = "One with all, it all comes back to yourself."
	icon_state = "universe"
	hat = /obj/item/clothing/head/egosuits/universe_hat

/obj/item/clothing/head/egosuits/universe_hat
	name = "one with the universe"
	desc = "See. All. Together. Know. Us."
	icon_state = "universe"
	flags_inv = HIDEHAIR

/obj/item/clothing/suit/egosuits/realized/grinder
	name = "grinder MK52"
	desc = "The blades are not just decorative."
	icon_state = "grinder"

/obj/item/clothing/suit/egosuits/realized/galaxy
	name = "our galaxy"
	desc = "Walk this night sky with me. The galaxy dotted with numerous hopes. We'll count the stars and never be alone."
	icon_state = "ourgalaxy"

/obj/item/clothing/suit/egosuits/realized/eyes
	name = "eyes of god"
	desc = "And the eyes of god spoke: You will be saved."
	icon_state = "eyes"

/obj/item/clothing/suit/egosuits/realized/head
	name = "head of god"
	desc = "And the head of god spoke: You will be judged."
	icon_state = "head"

/obj/item/clothing/suit/egosuits/realized/goldexperience
	name = "gold experience"
	desc = "A jacket made of gold is hardly light. But it shines like the sun."
	icon_state = "gold_experience"

/obj/item/clothing/suit/egosuits/realized/duality_yang
	name = "duality of harmony"
	desc = "When good and evil meet discord and assonance will be quelled."
	icon_state = "duality_yang"

/obj/item/clothing/suit/egosuits/realized/duality_yin
	name = "harmony of duality"
	desc = "All that isn't shall become all that is."
	icon_state = "duality_yin"

/obj/item/clothing/suit/egosuits/realized/shell
	name = "shell"
	desc = "Armor of humans, for humans, by humans. Is it as 'human' as you?"
	icon_state = "shell"

/obj/item/clothing/suit/egosuits/realized/alcoda
	name = "al coda"
	desc = "Harmonizes well."
	icon_state = "coda"

/obj/item/clothing/suit/egosuits/realized/laughter
	name = "laughter"
	desc = "I do not recognize them, I must not, lest I end up like them. \
			Through the silence, I hear them, I see them. The faces of all my friends are with me laughing too."
	icon_state = "laughter"

// NON-ABNORMALITY/OTHER
// NOTE: This category includes anything that isn't an outfit based on an Abnormality.
// Subcategories will be provided based on origin of outfit (K Corp, Liu Association, etc)
/obj/item/clothing/suit/egosuits/other
	icon = 'icons/obj/clothing/egosuits/lc13_armor.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/lc13_armor.dmi'

// K Corp
/obj/item/clothing/suit/egosuits/other/kcorp_sci
	name = "K Corp scientist uniform"
	desc = "A white labcoat with K Corp's signature green. Appears to be specifically designed to not protect the wearer."
	icon_state = "kcorp_sci"

// Zwei
/obj/item/clothing/suit/egosuits/other/zweijunior
	name = "Zwei Association casual jacket"
	desc = "Armor worn by initiate Zwei Association Fixers when not on duty."
	icon_state = "zweicasual"

/obj/item/clothing/suit/egosuits/other/zwei
	name = "Zwei Association armor"
	desc = "Armor worn by Zwei Association Fixers."
	icon_state = "zwei"

/obj/item/clothing/suit/egosuits/other/zweivet
	name = "Zwei Association veteran armor"
	desc = "Armor worn by Zwei Association veteran Fixers."
	icon_state = "zweivet"

/obj/item/clothing/suit/egosuits/other/zweileader
	name = "Zwei Association director armor"
	desc = "Armor worn by Zwei Association directors."
	icon_state = "zweileader"

// Shi
/obj/item/clothing/suit/egosuits/other/shi
	name = "Shi Association jacket"
	desc = "A light armor vest worn by Shi Association Section 2."
	icon_state = "shi"

/obj/item/clothing/suit/egosuits/other/shivet
	name = "Shi Association veteran jacket"
	desc = "A light armor vest worn by veterans of Shi Association Section 2."
	icon_state = "shivet"

/obj/item/clothing/suit/egosuits/other/shidirector
	name = "Shi Association director jacket"
	desc = "A light armor vest worn by the director of Shi Association Section 2."
	icon_state = "shileader"

// Liu
/obj/item/clothing/suit/egosuits/other/liusection2
	name = "Liu Association Section 2 combat coat"
	desc = "Armor worn by Liu Association Section 2's director, as well as its veterans."
	icon_state = "liusection2"

/obj/item/clothing/suit/egosuits/other/liusection4
	name = "Liu Association Section 4 combat jacket"
	desc = "Armor worn by Liu Association Section 4's director, as well as its veterans."
	icon_state = "liusection4"

/obj/item/clothing/suit/egosuits/other/liuvet
	name = "Liu Association combat coat"
	desc = "Armor worn by Liu Association Section 1 veterans."
	icon_state = "liufire_vet"

/obj/item/clothing/suit/egosuits/other/liuleader
	name = "Liu Association heavy combat coat"
	desc = "Armor worn by the director of Liu Association Section 1."
	icon_state = "liufire_director"

// Reverb Ensemble
//tried looking the code for who knows how long but never found any mention of ensemble suit in the lc13 repo?
//possibly unused originally, ended up creating a name/description for it
/obj/item/clothing/suit/egosuits/other/reverbensemble
	name = "Reverberation Ensemble suit"
	desc = "An outfit worn by members of the Reverberation Ensemble."
	icon_state = "ensemble"

/obj/item/clothing/suit/egosuits/other/blue_reverb
	name = "Jacket of Blue"
	desc = "A regal jacket used by The Blue Reverberation."
	icon_state = "breverb"

// Thumb
/obj/item/clothing/suit/egosuits/other/thumb
	flags_inv = HIDEJUMPSUIT | HIDEGLOVES
	name = "Thumb Soldato armor"
	desc = "Armor worn by Thumb grunts."
	icon_state = "thumb"

/obj/item/clothing/suit/egosuits/other/thumb_capo
	name = "Thumb Capo armor"
	desc = "Armor worn by Thumb Capos."
	icon_state = "capo"

/obj/item/clothing/suit/egosuits/other/thumb_sottocapo
	name = "Thumb Sottocapo armor"
	desc = "Armor worn by Thumb Sottocapos."
	icon_state = "sottocapo"

// Limbus Company
/obj/item/clothing/suit/egosuits/limbus
	icon = 'icons/obj/clothing/egosuits/limbus_suits.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/limbus_suit.dmi'

/obj/item/clothing/suit/egosuits/limbus/limbus_coat
	name = "LCB armored coat"
	desc = "It says Limbus Company on the tag."
	icon_state = "longcoat"
	flags_inv = NONE

/obj/item/clothing/suit/egosuits/limbus/limbus_coat_short
	name = "LCB armored shortcoat"
	desc = "It says Limbus Company on the tag."
	icon_state = "shortcoat"
	flags_inv = NONE

/obj/item/clothing/suit/egosuits/limbus/durante
	name = "Durante"
	desc = "Follow your star."
	icon_state = "durante"
	flags_inv = NONE

// W Corp
/obj/item/clothing/suit/egosuits/other/wcorp
	name = "W Corp armor vest"
	desc = "A light armor vest worn by W Corp."
	icon = 'icons/obj/clothing/egosuits/suits.dmi'
	worn_icon = 'icons/mob/clothing/egosuits/suit.dmi'
	icon_state = "w_corp"

/obj/item/clothing/head/egosuits/wcorp
	name = "W Corp cap"
	desc = "A ball cap worn by W Corp."
	icon_state = "what"
	perma = TRUE
