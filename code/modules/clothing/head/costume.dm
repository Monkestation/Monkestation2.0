/obj/item/clothing/head/costume
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'

/obj/item/clothing/head/costume/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	inhand_icon_state = "pwig"

/obj/item/clothing/head/costume/hasturhood
	name = "hastur's hood"
	desc = "It's <i>unspeakably</i> stylish."
	icon_state = "hasturhood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/syndicatefake
	name = "red space helmet replica" //monkestation edit
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "syndicate" //monkestation edit
	inhand_icon_state = "space_syndicate" //monkestation edit
	desc = "A plastic replica of a Syndicate agent's space helmet. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb meant to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/snowman
	name = "snowman head"
	desc = "A ball of white styrofoam. So festive."
	icon_state = "snowman_h"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	inhand_icon_state = null
	flags_inv = HIDEHAIR

/obj/item/clothing/head/costume/maidheadband
	name = "maid headband"
	desc = "Just like from one of those chinese cartoons!"
	icon_state = "maid_headband"

/obj/item/clothing/head/costume/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	inhand_icon_state = "chicken_head"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	inhand_icon_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/costume/lobsterhat
	name = "foam lobster head"
	desc = "When everything's going to crab, protecting your head is the best choice."
	icon_state = "lobster_hat"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/drfreezehat
	name = "doctor freeze's wig"
	desc = "A cool wig for cool people."
	icon_state = "drfreeze_hat"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/costume/shrine_wig
	name = "shrine maiden's wig"
	desc = "Purify in style!"
	flags_inv = HIDEHAIR //bald
	icon_state = "shrine_wig"
	inhand_icon_state = null
	worn_y_offset = 1

/obj/item/clothing/head/costume/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	inhand_icon_state = "cardborg_h"
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

	dog_fashion = /datum/dog_fashion/head/cardborg

/obj/item/clothing/head/costume/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && (slot & ITEM_SLOT_HEAD))
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/costume/cardborg))
			var/obj/item/clothing/suit/costume/cardborg/CB = H.wear_suit
			CB.disguise(user, src)

/obj/item/clothing/head/costume/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/head/costume/bronze
	name = "bronze hat"
	desc = "A crude helmet made out of bronze plates. It offers very little in the way of protection."
	icon_state = "clockwork_helmet_old"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR
	armor_type = /datum/armor/costume_bronze

/obj/item/clothing/head/costume/fancy
	name = "fancy hat"
	icon_state = "fancy_hat"
	greyscale_colors = "#E3C937#782A81"
	greyscale_config = /datum/greyscale_config/fancy_hat
	greyscale_config_worn = /datum/greyscale_config/fancy_hat_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/football_helmet
	name = "football helmet"
	icon_state = "football_helmet"
	greyscale_colors = "#D74722"
	greyscale_config = /datum/greyscale_config/football_helmet
	greyscale_config_worn = /datum/greyscale_config/football_helmet_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/tv_head
	name = "television helmet"
	desc = "A mysterious headgear made from the hollowed out remains of a status display. How very retro-retro-futuristic of you."
	icon_state = "IPC_helmet"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi' //Grandfathered in from the wallframe for status displays.
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	clothing_flags = SNUG_FIT
	flash_protect = FLASH_PROTECTION_SENSITIVE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	var/has_fov = TRUE

/datum/armor/costume_bronze
	melee = 5
	laser = -5
	energy = -15
	bomb = 10
	fire = 20
	acid = 20

/obj/item/clothing/head/costume/tv_head/Initialize(mapload)
	. = ..()
	if(has_fov)
		AddComponent(/datum/component/clothing_fov_visor, FOV_90_DEGREES)

/obj/item/clothing/head/costume/tv_head/fov_less
	desc = "A mysterious headgear made from the hollowed out remains of a status display. How very retro-retro-futuristic of you. It's very easy to see out of this one."
	has_fov = FALSE

/obj/item/clothing/head/costume/irs
	name = "internal revenue service cap"
	desc = "Even in space, you can't avoid the tax collectors."
	icon_state = "irs_hat"
	inhand_icon_state = null

/obj/item/clothing/head/costume/tmc
	name = "Lost M.C. bandana"
	desc = "A small, red bandana tied thin."
	icon_state = "tmc_hat"
	inhand_icon_state = null

/obj/item/clothing/head/costume/deckers
	name = "Decker headphones"
	desc = "A neon-blue pair of headphones. They look neo-futuristic."
	icon_state = "decker_hat"
	inhand_icon_state = null

/obj/item/clothing/head/costume/yuri
	name = "yuri initiate helmet"
	desc = "A strange, whitish helmet with 3 eyeholes."
	icon_state = "yuri_helmet"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/allies
	name = "allies helmet"
	desc = "An ancient military helmet worn by the bravest of warriors. \
	It's only a replica, and probably wouldn't protect you from anything."
	icon_state = "allies_helmet"
	inhand_icon_state = null

/obj/item/clothing/head/costume/flowery
	name = "perfumed bow"
	desc = "A dainty bow worn on the back of the head, this one has a convinent clip on attachment for easy use."
	icon_state = "flowerybow"
	inhand_icon_state = "flowerybow"

/obj/item/clothing/head/costume/starry
	name = "star speckled bow"
	desc = "A dainty bow that shimmers in the light, almost as if tiny stars decorated the bow."
	icon_state = "starbow"
	inhand_icon_state = "starbow"

/obj/item/clothing/head/costume/tiara
	name = "elegant tiara"
	desc = "A stunning tiara that still looks good even with its questionable authenticity."
	icon_state = "tiara"
	inhand_icon_state = "tiara"


/obj/item/clothing/head/costume/hairpin
	name = "fancy hairpin"
	desc = "A delicate hairpin normally paired with traditional clothing"
	icon_state = "hairpin_fancy"
	inhand_icon_state = "hairpin_fancy"

/obj/item/clothing/head/costume/dio
	name = "flamboyant headband"
	desc = "A green metal headband in the shape of a heart."
	icon_state = "dio_headband"
	inhand_icon_state = null

/obj/item/clothing/head/tragic
	name = "tragic mime headpiece"
	desc = "A white mask approximating a human face, comes with a hood. Used by theatre actors who play as nameless extra characters."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "tragic"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/head/bee
	name = "bee hat"
	desc = "A hat made from beehide"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bee"
	flags_inv = HIDEHAIR
	worn_y_offset = 2

/obj/item/clothing/head/lizard
	name = "novelty lizard head"
	desc = "A giant sculpted foam lizard head.  It doesn't quite look like the lizards from this sector..."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "lizardhead"
	flags_inv = HIDEHAIR
	worn_y_offset = 1

/obj/item/clothing/head/wonka
	name = "wonky hat"
	desc = "Come with me, and you'll be, in a world of OSHA violations!"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "wonka"

/obj/item/clothing/head/knowingclown
	name = "Small but Knowing Clown hat"
	desc = "The Cap of a Small but All Knowing Clown"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "knowingclownhat"
	worn_y_offset = 6

/obj/item/clothing/head/milkmanhat
	name = "milkman hat"
	desc = "Special delivery today!!!"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "milkman_hat"

/obj/item/clothing/head/batterhat
	name = "batter hat"
	desc = "Adversaries purified"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "batter_hat"

/obj/item/clothing/head/harlequinhat
	name = "harlequin hat"
	desc = "I wear officer I'm not a pirate!"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "harlequin_hat"

/obj/item/clothing/head/guardmanhelmet
	name = "guardman's helmet"
	desc = "Keeps your brain intact when fighting heretics"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "guardman_helmet"

/obj/item/clothing/head/cop_mascot
	name = "policeman mascot head"
	desc = "A blue police mascot head. Formly designed to be a part of the BB Horror Film Franchise, it is now used for Police Theater."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "cop_mascot"
	worn_y_offset = 1
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/head/helmet/civilprotection_helmet
	name = "civil protection helmet"
	desc = "I don't know about you, but I'm ready to join Civil Protection just to get a decent meal."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "civilprotection_helmet"
	custom_premium_price = PAYCHECK_COMMAND * 2
	var/on = FALSE
	actions_types = list(/datum/action/item_action/flip)

/obj/item/clothing/head/helmet/civilprotection_helmet/attack_self(mob/user)
	on = !on
	if(on == TRUE)
		icon_state = "civilprotection_helmet"
	if(on == FALSE)
		icon_state = "civilprotection_helmet_closed"
	user.update_worn_head()

/obj/item/clothing/head/thekiller_head
	name = "the killer's head"
	desc = "A red drinky bird mask. The mascot of violence."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "thekiller_head"
	worn_y_offset = 1
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/head/bb_wig
	name = "bb wig"
	desc = "Well known movie mascot BB, this wig is either worn by a notorious killer or some sort of girl-mouse."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "bb_wig"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/playbunnyears
	name = "bunny ears headband"
	desc = "A pair of bunny ears attached to a headband. One of the ears is already crooked."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head_32x48.dmi'
	icon_state = "playbunny_ears"
	greyscale_colors = "#39393f"
	greyscale_config = /datum/greyscale_config/playbunnyears
	greyscale_config_worn = /datum/greyscale_config/playbunnyears_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/playbunnyears/syndicate
	name = "blood-red bunny ears headband"
	desc = "An unusually suspicious pair of bunny ears attached to a headband. The headband looks reinforced with plasteel... but why?"
	icon_state = "syndibunny_ears"
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/playbunnyears_syndicate
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_syndicate
	melee = 30
	bullet = 20
	laser = 30
	energy = 35
	fire = 20
	bomb = 15
	acid = 50
	wound = 5

/obj/item/clothing/head/playbunnyears/centcom
	name = "centcom bunny ears headband"
	desc = "A pair of very professional bunny ears attached to a headband. The ears themselves came from an endangered species of green rabbits."
	icon_state = "playbunny_ears_centcom"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/head/playbunnyears/british
	name = "british bunny ears headband"
	desc = "A pair of classy bunny ears attached to a headband. Worn to honor the crown."
	icon_state = "playbunny_ears_brit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/head/playbunnyears/communist
	name = "really red bunny ears headband"
	desc = "A pair of red and gold bunny ears attached to a headband. Commonly used by any collectivizing bunny waiters."
	icon_state = "playbunny_ears_communist"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/head/playbunnyears/usa
	name = "usa bunny ears headband"
	desc = "A pair of star spangled bunny ears attached to a headband. The headband of a true patriot."
	icon_state = "playbunny_ears_usa"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
