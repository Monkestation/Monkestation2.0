// CHAPLAIN NULLROD AND CUSTOM WEAPONS //

/obj/item/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian; its very presence disrupts and dampens 'magical forces'. That's what the guidebook says, anyway."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "nullrod"
	inhand_icon_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	obj_flags = UNIQUE_RENAME
	wound_bonus = -10
	/// boolean on whether it's allowed to be picked from the nullrod's transformation ability
	var/chaplain_spawnable = TRUE
	/// Short description of what this item is capable of, for radial menu uses.
	var/menu_description = "A standard chaplain's weapon. Fits in pockets. Can be worn on the belt."
	/// Lazylist, tracks refs()s to all cultists which have been crit or killed by this nullrod.
	var/list/cultists_slain

/obj/item/nullrod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "BEGONE FOUL MAGIKS!!", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune, /obj/effect/cosmic_rune), \
	)
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)

	if(!GLOB.holy_weapon_type && type == /obj/item/nullrod)
		var/list/rods = list()
		for(var/obj/item/nullrod/nullrod_type as anything in typesof(/obj/item/nullrod))
			if(!initial(nullrod_type.chaplain_spawnable))
				continue
			rods[nullrod_type] = initial(nullrod_type.menu_description)
		//special non-nullrod subtyped shit
		rods[/obj/item/gun/ballistic/bow/divine/with_quiver] = "A divine bow and 10 quivered holy arrows."
		AddComponent(/datum/component/subtype_picker, rods, CALLBACK(src, PROC_REF(on_holy_weapon_picked)))

/obj/item/nullrod/proc/on_holy_weapon_picked(obj/item/nullrod/holy_weapon_type)
	GLOB.holy_weapon_type = holy_weapon_type
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NULLROD_PICKED)
	SSblackbox.record_feedback("tally", "chaplain_weapon", 1, "[initial(holy_weapon_type.name)]")

/obj/item/nullrod/proc/on_cult_rune_removed(obj/effect/target, mob/living/user)
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		user.log_message("erased [target_rune.cultist_name] rune using a null rod", LOG_GAME)
		message_admins("[ADMIN_LOOKUPFLW(user)] erased a [target_rune.cultist_name] rune with a null rod.")
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE

/obj/item/nullrod/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get closer to god!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/nullrod/attack(mob/living/target_mob, mob/living/user, params)
	if(!user.mind?.holy_role)
		return ..()
	if(!IS_CULTIST(target_mob) || istype(target_mob, /mob/living/carbon/human/cult_ghost))
		return ..()

	var/old_stat = target_mob.stat
	. = ..()
	if(old_stat < target_mob.stat)
		LAZYOR(cultists_slain, REF(target_mob))
	return .

/obj/item/nullrod/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) || !GET_ATOM_BLOOD_DNA_LENGTH(src))
		return

	var/num_slain = LAZYLEN(cultists_slain)
	. += span_cultitalic("It has the blood of [num_slain] fallen cultist[num_slain == 1 ? "" : "s"] on it. \
		<b>Offering</b> it to Nar'sie will transform it into a [num_slain >= 3 ? "powerful" : "standard"] cult weapon.")

/obj/item/nullrod/godhand
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	slot_flags = null
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb_continuous = list("punches", "cross counters", "pummels")
	attack_verb_simple = list(SFX_PUNCH, "cross counter", "pummel")
	menu_description = "An undroppable god hand dealing burn damage. Disappears if the arm holding it is cut off."

/obj/item/nullrod/godhand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/nullrod/staff
	name = "red holy staff"
	desc = "It has a mysterious, protective aura."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "godstaff-red"
	inhand_icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	slot_flags = ITEM_SLOT_BACK
	block_chance = 50
	block_sound = 'sound/weapons/genhit.ogg'
	menu_description = "A red staff which provides a medium chance of blocking incoming attacks via a protective red aura around its user, but deals very low amount of damage. Can be worn only on the back."
	/// The icon which appears over the mob holding the item
	var/shield_icon = "shield-red"

/obj/item/nullrod/staff/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_icon, MOB_SHIELD_LAYER)

/obj/item/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	inhand_icon_state = "godstaff-blue"
	shield_icon = "shield-old"
	menu_description = "A blue staff which provides a medium chance of blocking incoming attacks via a protective blue aura around its user, but deals very low amount of damage. Can be worn only on the back."

/obj/item/nullrod/claymore
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "claymore_gold"
	inhand_icon_state = "claymore_gold"
	worn_icon_state = "claymore_gold"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	block_chance = 30
	block_sound = 'sound/weapons/parry.ogg'
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "A sharp claymore which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/nullrod/claymore/darkblade
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	icon = 'icons/obj/cult/items_and_weapons.dmi'
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	hitsound = 'sound/hallucinations/growl1.ogg'
	menu_description = "A sharp blade which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/chainsaw_sword
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 1.5 //slower than a real saw
	menu_description = "A sharp chainsaw sword which provides a low chance of blocking incoming melee attacks. Can be used as a slower saw tool. Can be worn on the belt."

/obj/item/nullrod/claymore/glowing
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	icon_state = "swordon"
	inhand_icon_state = "swordon"
	worn_icon_state = "swordon"
	menu_description = "A sharp weapon which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/katana
	name = "\improper Hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	inhand_icon_state = "katana"
	worn_icon_state = "katana"
	menu_description = "A sharp katana which provides a low chance of blocking incoming melee attacks. Can be worn on the back or belt."

/obj/item/nullrod/claymore/multiverse
	name = "extradimensional blade"
	desc = "Once the harbinger of an interdimensional war, its sharpness fluctuates wildly."
	icon_state = "multiverse"
	inhand_icon_state = "multiverse"
	worn_icon_state = "multiverse"
	slot_flags = ITEM_SLOT_BACK
	force = 15
	menu_description = "An odd sharp blade which provides a low chance of blocking incoming melee attacks and deals a random amount of damage, which can range from almost nothing to very high. Can be worn on the back."

/obj/item/nullrod/claymore/multiverse/melee_attack_chain(mob/user, atom/target, params)
	var/old_force = force
	force += rand(-14, 15)
	. = ..()
	force = old_force

/obj/item/nullrod/claymore/saber
	name = "light energy sword"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	icon = 'icons/obj/weapons/transforming_energy.dmi'
	icon_state = "e_sword_on_blue"
	inhand_icon_state = "e_sword_on_blue"
	worn_icon_state = "swordblue"
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/blade1.ogg'
	block_sound = 'sound/weapons/block_blade.ogg'
	menu_description = "A sharp energy sword which provides a low chance of blocking incoming melee attacks. Can be worn on the belt."

/obj/item/nullrod/claymore/saber/red
	name = "dark energy sword"
	desc = "Woefully ineffective when used on steep terrain."
	icon_state = "e_sword_on_red"
	inhand_icon_state = "e_sword_on_red"
	worn_icon_state = "swordred"

/obj/item/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	desc = "Convincing HR that your religion involved piracy was no mean feat."
	icon_state = "e_cutlass_on"
	inhand_icon_state = "e_cutlass_on"
	worn_icon_state = "swordred"

/obj/item/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "sord"
	inhand_icon_state = "sord"
	worn_icon_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 4.13
	throwforce = 1
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "An odd s(w)ord dealing a laughable amount of damage. Fits in pockets. Can be worn on the belt."

/obj/item/nullrod/sord/suicide_act(mob/living/user) //a near-exact copy+paste of the actual sord suicide_act()
	user.visible_message(span_suicide("[user] is trying to impale [user.p_them()]self with [src]! It might be a suicide attempt if it weren't so HOLY."), \
	span_suicide("You try to impale yourself with [src], but it's TOO HOLY..."))
	return SHAME

/obj/item/nullrod/scythe
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "scythe1"
	inhand_icon_state = "scythe1"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("chops", "slices", "cuts", "reaps")
	attack_verb_simple = list("chop", "slice", "cut", "reap")
	menu_description = "A sharp scythe which partially penetrates armor. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/scythe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 7 SECONDS, \
	effectiveness = 110, \
	)
	AddElement(/datum/element/bane, mob_biotypes = MOB_PLANT, damage_multiplier = 0.5, requires_combat_mode = FALSE)

/obj/item/nullrod/scythe/vibro
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "hfrequency0"
	inhand_icon_state = "hfrequency1"
	worn_icon_state = "hfrequency0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	attack_verb_continuous = list("chops", "slices", "cuts", "zandatsu's")
	attack_verb_simple = list("chop", "slice", "cut", "zandatsu")
	hitsound = 'sound/weapons/rapierhit.ogg'
	menu_description = "A sharp blade which partially penetrates armor. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/scythe/spellblade
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "spellblade"
	hitsound = 'sound/weapons/rapierhit.ogg'
	menu_description = "A sharp blade which partially penetrates armor. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/scythe/talking
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "talking_sword"
	inhand_icon_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "talking_sword"
	attack_verb_continuous = list("chops", "slices", "cuts")
	attack_verb_simple= list("chop", "slice", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	menu_description = "A sharp blade which partially penetrates armor. Able to awaken a friendly spirit to provide guidance. Very effective at butchering bodies. Can be worn on the back."

/obj/item/nullrod/scythe/talking/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spirit_holding)

/obj/item/nullrod/scythe/talking/chainsword
	name = "possessed chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	force = 30
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5 //same speed as an active chainsaw
	chaplain_spawnable = FALSE //prevents being pickable as a chaplain weapon (it has 30 force)

/obj/item/nullrod/hammer
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "hammeron"
	inhand_icon_state = "hammeron"
	worn_icon_state = "hammeron"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("smashes", "bashes", "hammers", "crunches")
	attack_verb_simple = list("smash", "bash", "hammer", "crunch")
	menu_description = "A war hammer. Capable of tapping knees to measure brain health. Can be worn on the belt."

/obj/item/nullrod/hammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)

/obj/item/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw_on"
	inhand_icon_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = null
	item_flags = ABSTRACT
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 2 //slower than a real saw
	menu_description = "An undroppable sharp chainsaw hand. Can be used as a very slow saw tool. Capable of slowly butchering bodies. Disappears if the arm holding it is cut off."

/obj/item/nullrod/chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 3 SECONDS, \
	effectiveness = 100, \
	bonus_modifier = 0, \
	butcher_sound = hitsound, \
	)

/obj/item/nullrod/clown
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	inhand_icon_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "render"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	menu_description = "A sharp dagger. Fits in pockets. Slippery. Can be worn on the belt. Honk."

/obj/item/nullrod/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 140) //Same as maximum potency banana peel.

/obj/item/nullrod/clown/afterattack(atom/target, mob/living/user)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.emote("laugh")
	living_target.add_mood_event("chemical_laughter", /datum/mood_event/chemical_laughter)
	user.add_mood_event("chemical_laughter", /datum/mood_event/chemical_laughter) //Hitting people with it makes you feel good.

#define CHEMICAL_TRANSFER_CHANCE 30

/obj/item/nullrod/pride_hammer
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "pride"
	inhand_icon_state = "pride"
	worn_icon_state = "pride"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	force = 16
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "smashes", "crushes", "splatters", "cracks")
	attack_verb_simple = list("attack", "smash", "crush", "splatter", "crack")
	hitsound = 'sound/weapons/blade1.ogg'
	menu_description = "A hammer dealing a little less damage due to its user's pride. Has a low chance of transferring some of the user's reagents to the target. Capable of tapping knees to measure brain health. Can be worn on the back."

/obj/item/nullrod/pride_hammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)
	AddElement(
		/datum/element/chemical_transfer,\
		span_notice("Your pride reflects on %VICTIM."),\
		span_userdanger("You feel insecure, taking on %ATTACKER's burden."),\
		CHEMICAL_TRANSFER_CHANCE\
	)

#undef CHEMICAL_TRANSFER_CHANCE

/obj/item/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon = 'icons/obj/weapons/whip.dmi'
	icon_state = "chain"
	inhand_icon_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes")
	attack_verb_simple = list("whip", "lash")
	hitsound = 'sound/weapons/chainhit.ogg'
	menu_description = "A whip. Deals extra damage to vampires. Fits in pockets. Can be worn on the belt."

/obj/item/nullrod/fedora
	name = "atheist's fedora"
	desc = "The brim of the hat is as sharp as your wit. The edge would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	inhand_icon_state = "fedora"
	slot_flags = ITEM_SLOT_HEAD
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/hats_righthand.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("enlightens", "redpills")
	attack_verb_simple = list("enlighten", "redpill")
	menu_description = "A sharp fedora dealing a very high amount of throw damage, but none of melee. Fits in pockets. Can be worn on the head, obviously."

/obj/item/nullrod/fedora/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get further from god!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted deities grant gifts of dubious value."
	icon = 'icons/obj/weapons/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	slot_flags = null
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	wound_bonus = -20
	bare_wound_bonus = 25
	menu_description = "An undroppable sharp armblade capable of inflicting deep wounds. Capable of an ineffective butchering of bodies. Disappears if the arm holding it is cut off."

/obj/item/nullrod/armblade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS, \
	effectiveness = 70, \
	)

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"
	menu_description = "An undroppable sharp tentacle capable of inflicting deep wounds. Capable of an ineffective butchering of bodies. Disappears if the arm holding it is cut off."

/obj/item/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to receive the blessing of Carp-Sie."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "map_plushie_carp"
	greyscale_config = /datum/greyscale_config/plush_carp
	greyscale_colors = "#cc99ff#000000"
	inhand_icon_state = "carp_plushie"
	worn_icon_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	attack_verb_continuous = list("bites", "eats", "fin slaps")
	attack_verb_simple = list("bite", "eat", "fin slap")
	hitsound = 'sound/weapons/bite.ogg'
	menu_description = "A plushie dealing a little less damage due to its cute form. Capable of blessing one person with the Carp-Sie favor, which grants friendship of all wild space carps. Fits in pockets. Can be worn on the belt."

/obj/item/nullrod/carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/faction_granter, FACTION_CARP, holy_role_required = HOLY_ROLE_PRIEST, grant_message = span_boldnotice("You are blessed by Carp-Sie. Wild space carp will no longer attack you."))

/obj/item/nullrod/claymore/bostaff //May as well make it a "claymore" and inherit the blocking
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, it is now used to harass the clown."
	force = 15
	block_chance = 40
	block_sound = 'sound/weapons/genhit.ogg'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	sharpness = NONE
	hitsound = SFX_SWING_HIT
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	inhand_icon_state = "bostaff0"
	worn_icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	menu_description = "A staff which provides a medium-low chance of blocking incoming melee attacks and deals a little less damage due to being made of wood. Can be worn on the back."

/obj/item/nullrod/tribal_knife
	name = "arrhythmic knife"
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "crysknife"
	inhand_icon_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	slot_flags = null
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	item_flags = SLOWS_WHILE_IN_HAND
	menu_description = "A sharp knife. Randomly speeds or slows its user at a regular intervals. Capable of butchering bodies. Cannot be worn anywhere."

/obj/item/nullrod/tribal_knife/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/butchering, \
	speed = 5 SECONDS, \
	effectiveness = 100, \
	)

/obj/item/nullrod/tribal_knife/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nullrod/tribal_knife/process()
	slowdown = rand(-10, 10)/10
	if(iscarbon(loc))
		var/mob/living/carbon/wielder = loc
		if(wielder.is_holding(src))
			wielder.update_equipment_speed_mods()

/obj/item/nullrod/pitchfork
	name = "unholy pitchfork"
	desc = "Holding this makes you look absolutely devilish."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "pitchfork0"
	inhand_icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	worn_icon_state = "pitchfork0"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("pokes", "impales", "pierces", "jabs")
	attack_verb_simple = list("poke", "impale", "pierce", "jab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	menu_description = "A sharp pitchfork. Can be worn on the back."

/obj/item/nullrod/egyptian
	name = "egyptian staff"
	desc = "A tutorial in mummification is carved into the staff. You could probably craft the wraps if you had some cloth."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "pharoah_sceptre"
	inhand_icon_state = "pharoah_sceptre"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	worn_icon_state = "pharoah_sceptre"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("bashes", "smacks", "whacks")
	attack_verb_simple = list("bash", "smack", "whack")
	menu_description = "A staff. Can be used as a tool to craft exclusive egyptian items. Easily stored. Can be worn on the back."

/obj/item/nullrod/hypertool
	name = "hypertool"
	desc = "A tool so powerful even you cannot perfectly use it."
	icon = 'icons/obj/device.dmi'
	icon_state = "hypertool"
	inhand_icon_state = "hypertool"
	worn_icon_state = "hypertool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	damtype = BRAIN
	armour_penetration = 35
	attack_verb_continuous = list("pulses", "mends", "cuts")
	attack_verb_simple = list("pulse", "mend", "cut")
	hitsound = 'sound/effects/sparks4.ogg'
	menu_description = "A tool dealing brain damage which partially penetrates armor. Fits in pockets. Can be worn on the belt."

/obj/item/nullrod/spear
	name = "ancient spear"
	desc = "An ancient spear made of brass, I mean gold, I mean bronze. It looks highly mechanical."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "ratvarian_spear"
	inhand_icon_state = "ratvarian_spear"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	armour_penetration = 10
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("stabs", "pokes", "slashes", "clocks")
	attack_verb_simple = list("stab", "poke", "slash", "clock")
	hitsound = 'sound/weapons/bladeslice.ogg'
	menu_description = "A pointy spear which penetrates armor a little. Can be worn only on the belt."

/obj/projectile/boomerang
	name = "boomerang"
	icon = 'monkestation/code/modules/bloody_cult/icons/boomerang.dmi'
	icon_state = "boomerang-spin"
	damage = 20
	damage_type = BRUTE
	speed = 0.66
	var/obj/item/nullrod/cross_boomerang/boomerang
	var/list/hit_atoms = list()


/obj/projectile/boomerang/Bump(atom/A)
	. = ..()
	if (!(A in hit_atoms))
		hit_atoms += A
		if (boomerang)
			boomerang.throw_impact(A, null)
			if (boomerang.loc != src)//boomerang got grabbed most likely
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return
			else if (iscarbon(A))
				boomerang.apply_status_effects(A)
				forceMove(A.loc)
				A.Bumped(boomerang)
				qdel(src)
				return
			A.Bumped(boomerang)
	return ..(A)

/obj/projectile/boomerang/Destroy()
	if(boomerang)
		return_to_sender()
	. = ..()

/obj/projectile/boomerang/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!boomerang)
		qdel(src)

/obj/projectile/boomerang/proc/return_to_sender()
	if (!boomerang)
		qdel(src)
		return
	var/turf/T = get_turf(src)
	if (!boomerang.return_check())
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang = null
		return

	var/atom/return_target
	if (firer)
		if (isturf(firer.loc) && (firer.z == z) && (get_dist(firer,src) <= 26))
			return_target = firer

	if (!return_target)
		return_target = starting

	var/obj/effect/tracker/boomerang/Tr = new (T)
	Tr.target = return_target
	Tr.appearance = appearance
	Tr.refresh = speed
	Tr.luminosity = luminosity
	Tr.boomerang = boomerang
	Tr.hit_atoms = hit_atoms.Copy()
	boomerang.forceMove(Tr)
	boomerang = null

/obj/effect/tracker/boomerang
	name = "boomerang"
	icon = 'monkestation/code/modules/bloody_cult/icons/boomerang.dmi'
	icon_state = "boomerang-spin"
	mouse_opacity = 1
	density = 1
	pass_flags = PASSTABLE
	var/obj/item/nullrod/cross_boomerang/boomerang
	var/list/hit_atoms = list()

/obj/effect/tracker/boomerang/Destroy()
	var/turf/T = get_turf(src)
	if (T && boomerang)
		boomerang.forceMove(T)
		boomerang.thrown = FALSE
		boomerang.dropped()
		boomerang.originator = null
		boomerang = null
	..()

/obj/effect/tracker/boomerang/on_step()
	if (boomerang && !QDELETED(boomerang))
		boomerang.on_step(src)
	else
		qdel(src)

/obj/effect/tracker/boomerang/Bumped(var/atom/movable/AM)
	make_contact(AM)

/obj/effect/tracker/boomerang/proc/make_contact(var/atom/Obstacle)
	if (boomerang)
		if (!(Obstacle in hit_atoms))
			hit_atoms += Obstacle
			if (Obstacle == boomerang.originator)
				if (on_expire(FALSE))
					qdel(src)
					return TRUE
			boomerang.throw_impact(Obstacle,boomerang.throw_speed,boomerang.originator)
			if (boomerang.loc != src)//boomerang got grabbed most likely
				boomerang.originator = null
				boomerang = null
				qdel(src)
				return TRUE
			else if (iscarbon(Obstacle))
				boomerang.apply_status_effects(Obstacle)
				return FALSE
			Obstacle.Bumped(boomerang)
			if (!ismob(Obstacle))
				on_expire(TRUE)
				qdel(src)
				return TRUE
		return FALSE
	else
		qdel(src)
		return FALSE

/obj/effect/tracker/boomerang/on_expire(var/bumped_atom = FALSE)
	if (boomerang && boomerang.originator && Adjacent(boomerang.originator))
		if (boomerang.on_return())
			if (boomerang)
				boomerang.originator = null
			boomerang = null
			return TRUE
	return FALSE

/obj/item/nullrod/cross_boomerang
	name = "battle cross"
	desc = "A holy silver cross that dispels evil and smites unholy creatures."
	throwforce = 20

	icon = 'monkestation/code/modules/bloody_cult/icons/boomerang.dmi'
	icon_state = "cross_modern"
	worn_icon = null
	var/thrown = FALSE

	var/flickering = 0
	var/classic = FALSE
	var/mob/living/carbon/originator
	COOLDOWN_DECLARE(last_sound_loop)

	var/sound_throw = 'monkestation/code/modules/bloody_cult/sound/boomerang_cross_start.ogg'
	var/sound_loop = 'monkestation/code/modules/bloody_cult/sound/boomerang_cross_loop.ogg'

/obj/item/nullrod/cross_boomerang/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/nullrod/cross_boomerang/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]-moody", src)

/obj/item/nullrod/cross_boomerang/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle, quickstart)
	thrown = TRUE
	playsound(loc, sound_throw, 70, 0)
	if (thrower)
		originator = thrower

	SET_PLANE_EXPLICIT(src, ABOVE_LIGHTING_PLANE, thrower)

	var/turf/starting = get_turf(src)
	target = get_turf(target)
	var/obj/projectile/boomerang/rang = new (starting)
	rang.boomerang = src
	rang.firer = thrower
	rang.def_zone = ran_zone(thrower.zone_selected)
	rang.preparePixelProjectile(target, thrower)
	rang.icon_state = "[icon_state]-spin"
	rang.overlays += overlays
	rang.plane = plane
	rang.stun = 1 SECONDS

	forceMove(rang)
	rang.fire()
	rang.process()

/obj/item/nullrod/cross_boomerang/proc/on_step(var/obj/O)
	if (COOLDOWN_FINISHED(src, last_sound_loop))
		COOLDOWN_START(src, last_sound_loop, 1 SECONDS)
		playsound(loc,sound_loop, 35, 0)
	dir = turn(dir, 45)
	var/obj/effect/afterimage/A = new(O.loc, O, fadout = 5, initial_alpha = 100, pla = ABOVE_LIGHTING_PLANE)
	A.layer = O.layer - 1
	A.color = "#1E45FF"
	if (istype(O,/obj/effect/tracker))//only display those particles on the way back
		A.add_particles(PS_CROSS_DUST)
		A.add_particles(PS_CROSS_ORB)

	flickering = (flickering + 1) % 4
	if (flickering > 1)
		O.color = "#53A6FF"
	else
		O.color = null

/obj/item/nullrod/cross_boomerang/proc/return_check()//lets you add conditions for the boomerang to come back
	return TRUE

/obj/item/nullrod/cross_boomerang/proc/apply_status_effects(var/mob/living/carbon/C, var/minimal_effect = 0)
	C.Stun(max(minimal_effect, 1 SECONDS))

/obj/item/nullrod/cross_boomerang/proc/on_return()
	return (istype(originator) && originator.put_in_hands(src))

/obj/item/nullrod/cross_boomerang/pickup(mob/user)
	. = ..()
	thrown = FALSE

/obj/item/nullrod/cross_boomerang/dropped(mob/user, silent)
	. = ..()
	SET_PLANE_EXPLICIT(src, initial(plane), user)

/obj/item/nullrod/cross_boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(istype(hit_atom,/obj/machinery/computer/arcade))
		playsound(hit_atom,'monkestation/code/modules/bloody_cult/sound/boomerang_cross_transform.ogg', 30, 0)
		classic = !classic
		icon_state = "[classic ? "cross_classic" : "cross_modern"]"
		if (istype(loc,/obj))
			var/obj/O = loc
			O.icon_state = "[icon_state]-spin"
		update_appearance()
	. = ..()
