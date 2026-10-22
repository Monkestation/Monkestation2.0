/datum/religion_sect/burden
	name = "Punished"
	quote = "To feel the freedom, you must first understand captivity."
	desc = "Incapacitate yourself in any way possible. Bad mutations, lost limbs, traumas, \
	even addictions. You will learn the secrets of the universe from your defeated shell."
	tgui_icon = "user-injured"
	altar_icon_state = "convertaltar-burden"
	alignment = ALIGNMENT_NEUT
	candle_overlay = FALSE
	rites_list = list(/datum/religion_rites/nullrod_transformation)

/datum/religion_sect/burden/on_conversion(mob/living/carbon/human/new_convert)
	. = ..()
	if(!istype(new_convert))
		to_chat(new_convert, span_warning("[GLOB.deity] needs higher level creatures to fully comprehend the suffering. You are not burdened."))
		return
	new_convert.gain_trauma(/datum/brain_trauma/special/burdened, TRAUMA_RESILIENCE_MAGIC)

/datum/religion_sect/burden/tool_examine(mob/living/carbon/human/burdened) //display burden level
	if(!ishuman(burdened))
		return FALSE
	var/datum/brain_trauma/special/burdened/burden = burdened.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(burden)
		return "You are at burden level [burden.burden_level]/9."
	return "You are not burdened."

/datum/religion_rites/nullrod_transformation
	name = "Transmogrify"
	desc = "Your full power needs a firearm to be realized. You may transform your null rod into one."
	ritual_length = 10 SECONDS
	///The rod that will be transmogrified.
	var/obj/item/nullrod/transformation_target

/datum/religion_rites/nullrod_transformation/perform_rite(mob/living/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	var/datum/brain_trauma/special/burdened/burden = human_user.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(!burden?.burden_level < 9)
		to_chat(human_user, span_warning("You aren't burdened enough."))
		return FALSE
	for(var/obj/item/nullrod/null_rod in get_turf(religious_tool))
		transformation_target = null_rod
		return ..()
	to_chat(human_user, span_warning("You need to place a null rod on [religious_tool] to do this!"))
	var/obj/item/nullrod/null_rod = locate() in get_turf(religious_tool)
	if(!null_rod)
		to_chat(human_user, span_warning("You need to place a null rod on [religious_tool] to do this!"))
		return
	transformation_target = null_rod
	return ..()
	

/datum/religion_rites/nullrod_transformation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/obj/item/nullrod/null_rod = transformation_target
	transformation_target = null
	if(QDELETED(null_rod) || null_rod.loc != get_turf(religious_tool))
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[null_rod] turns into a gun!"))
	user.emote("smile")
	qdel(null_rod)
	new /obj/item/gun/ballistic/revolver/chaplain(get_turf(religious_tool))
	return TRUE

/obj/item/gun/ballistic/revolver/chaplain
	name = "chaplain's revolver"
	desc = "Holy smokes."
	icon_state = "chaplain"
	force = 10
	fire_sound = 'sound/weapons/gun/revolver/shot.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/rev77
	obj_flags = UNIQUE_RENAME
	custom_materials = null
	actions_types = list(/datum/action/item_action/pray_refill)
	/// Needs burden level nine to refill.
	var/needs_burden = TRUE
	/// List of all possible names and descriptions.
	var/static/list/possible_names = list(
		"Requiescat" = "May they rest in peace.",
		"Requiem" = "They will never reach truth.",
		"Vade Retro" = "Having a gun might make exorcisms more effective, who knows?",
		"Extra Nos" = "Salvation is given externally.",
		"Ordo Salutis" = "First step? Fire.",
		"Absolution" = "Free of your sins.",
		"Rod of God" = "Splitting the red sea again.",
		"Holy Grail" = "You found it!",
		"Burning Bush" = "Useful for any burning ambush.",
		"Judgement" = "First of all, damn. Alpha much? Dude, so cool, and so are you! Strong, too!",
		"Paradiso" = "A divine end to the comedy of life.",
		"DVNO" = "Don't need to ask my name to figure out how cool I am.",
		"Venus Supermax" = "Did you know nearly everyone working and living on Venus is involved in sulfur extraction? Quite fitting for this weapon of gunpowder.",
		"Nirvana" = "The giver of quietude, freedom, and highest happiness.",
		"Cerebrum Dispersio" = "Latin for \"brain splitting\". How fitting.",
		"Ultimort" = "Your hope dies last.",
		"Lifelight" = "No escape, no greater fate to be made.",
		"Bendbreaker" = "FRAGILE: Please do not bend or break.",
		"Pop Pop" = "The name referring to an onomatopeia (phonetic imitation) of a gun firing.",
		"Justice" = "Justice is Splendor.",
		"Splendor" = "Splendor is Justice.",
		"Revelation" = "Awaken your faith.",
		"New Safety M62" = "This model of firearm is popular hundreds of years later due to masculine associations created by the film industry.",
		"Unmaker" = "What the !@#%* is this!",
		"INKVD" = "Savior of the soul and fighter against dirty thoughts.",
		"Life Leech" = "An artifact said to draw its power from the life energy of others.",
		"Nullray" = "Starless metal on the barrel imbibes light and routes it to the null place. The grip acrylic is patterned after ley lines.",
		"Mortis" = "Put your faith into this weapon working.",
		"Ramiel" = "Literally meaning \"God has thundered\". You could even interpret the gunshot as a thunder.",
		"Daredevil" = "Hey now, you won't be reckless with this, will you?",
		"Lacytanga" = "Rules are written by the strong.",
		"A10" = "The fist of God. Keep away from the terrible.",
	)

/obj/item/gun/ballistic/revolver/chaplain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddElement(/datum/element/bane, target_type = /mob/living/basic/revenant, damage_multiplier = 0, added_damage = 25)
	name = pick(possible_names)
	desc = possible_names[name]

/obj/item/gun/ballistic/revolver/chaplain/suicide_act(mob/living/user)
	. = ..()
	name = "Habemus Papam"
	desc = "I announce to you a great joy."

/obj/item/gun/ballistic/revolver/chaplain/attack_self(mob/living/user)
	pray_refill(user)

/obj/item/gun/ballistic/revolver/chaplain/proc/pray_refill(mob/living/carbon/human/user)
	if(DOING_INTERACTION_WITH_TARGET(user, src) || !istype(user))
		return
	var/datum/brain_trauma/special/burdened/burden = user.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(needs_burden && (!burden || burden.burden_level < 9))
		to_chat(user, span_warning("You aren't burdened enough."))
		return
	user.manual_emote("presses [user.p_their()] palms together...")
	if(!do_after(user, 5 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return
	user.say("#Oh great [GLOB.deity], give me the ammunition I need!", forced = "ammo prayer")
	magazine.top_off()
	user.playsound_local(get_turf(src), 'sound/magic/magic_block_holy.ogg', 50, TRUE)
	chamber_round()

/datum/action/item_action/pray_refill
	name = "Refill"
	desc = "Perform a prayer, to refill your weapon."

/obj/item/ammo_box/magazine/internal/cylinder/rev77
	name = "chaplain revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c77
	caliber = CALIBER_77
	max_ammo = 5

/obj/item/ammo_casing/c77
	name = ".77 bullet casing"
	desc = "A .77 bullet casing."
	caliber = CALIBER_77
	projectile_type = /obj/projectile/bullet/c77
	custom_materials = null

/obj/projectile/bullet/c77
	name = ".77 bullet"
	damage = 18
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3
	wound_bonus = -10
	embed_type = null
