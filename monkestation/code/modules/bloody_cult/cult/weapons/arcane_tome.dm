#define PAGE_FOREWORD		0
#define PAGE_LORE1			101
#define PAGE_LORE2			102
#define PAGE_LORE3			103

var/list/arcane_tomes=list()

///////////////////////////////////////ARCANE TOME////////////////////////////////////////////////
/obj/item/weapon/tome
	name = "arcane tome"
	desc = "A dark, dusty tome with frayed edges and a sinister cover. Its surface is hard and cold to the touch."
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "tome"
	worn_icon = null
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/state = TOME_CLOSED
	var/can_flick = 1
	var/list/talismans = list()
	var/current_page = PAGE_FOREWORD

/obj/item/weapon/tome/New()
	..()
	arcane_tomes.Add(src)

/obj/item/weapon/tome/salt_act()
	fire_act(1000, 200)

/obj/item/weapon/tome/Destroy()
	arcane_tomes.Remove(src)
	for(var/obj/O in talismans)
		talismans.Remove(O)
		qdel(O)
	talismans=list()
	..()

/obj/item/weapon/tome/suicide_act(mob/living/user)
	var/datum/antagonist/cult/cult_datum=user.mind?.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		playsound(get_turf(user), 'monkestation/code/modules/bloody_cult/sound/edibles.ogg', 75, 0)
		anim(target=user, a_icon='monkestation/code/modules/bloody_cult/icons/cult.dmi', a_icon_state="build", lay=BELOW_OBJ_LAYER, plane=GAME_PLANE, sleeptime=20)
		user.Stun(10)
		icon_state="tome-open"
		flick("tome-flickopen", src)
		playsound(user, "pageturn", 50, 1, -2)
		state=TOME_OPEN
		to_chat(viewers(user), span_danger("[user] starts repeating arcane words while holding \the [src] open. Blood begins to spill from their nose, their eyes, ears, and every other orfices! It looks like \he's trying to commit suicide.") )
		sleep(10)
		cult_datum.gain_devotion(500, DEVOTION_TIER_4, "suicide_tome", user)
		anim(target=user, a_icon='icons/effects/effects.dmi', flick_anim="rune_sac", lay=ABOVE_MOB_LAYER, plane=GAME_PLANE_UPPER)
		to_chat(user, span_cult("You offer this shell of flesh to Nar-Sie.") )
		sleep(4)
		user.gib()
	else
		return ..()


/obj/item/weapon/tome/proc/tome_text()
	var/page_data=null
	var/dat={"<title>arcane tome</title><body style="color:#FFFFFF" bgcolor="#110000">

			<style>
				label {display: inline-block; width: 50px;text-align: right;float: left;margin: 0 0 0 10px;}
				ul {list-style-type: none;}
				li:before {content: "-";padding-left: 4px;}
				a {text-decoration: none; color:#FFEC66}
				.column {float: left; width: 400px; padding: 0px; height: 300px;}
				.row:after {content: ""; display: table; clear: both;}
			</style>

			<div class="row">
			<div class="column" style="font-size:18px">
			<div align="center" style="margin: 0 0 0 -10px;"><div style="font-size:30px"><b>The scriptures of <font color=#FF250F>Nar-Sie</b></font></div>The Geometer of Blood</div>
			<ul>
			<a href='byond://?src=\ref[src];page=[PAGE_FOREWORD]'><label> * </label> <li> Foreword</a> </li>"}

	var i=1
	for(var/subtype in subtypesof(/datum/rune_spell))
		var/datum/rune_spell/instance=subtype
		if (initial(instance.secret))
			continue
		dat += "<a href='byond://?src=\ref[src];page=[i]'><label> \Roman[i] </label> <li>  [initial(instance.name)] </li></a>"
		if (i == current_page)
			var/datum/rune_word/word1=initial(instance.word1)
			var/datum/rune_word/word2=initial(instance.word2)
			var/datum/rune_word/word3=initial(instance.word3)
			page_data={"<div align="center"><b>\Roman[i]<br>[initial(instance.name)]</b><br><i>[initial(word1.english)], [initial(word2.english)], [word3 ? "[initial(word3.english)]" : "<any>"]</i></div><br>"}
			page_data += initial(instance.page)
		i++

	dat += {"<a href='byond://?src=\ref[src];page=[PAGE_LORE1]'><label> * </label> <li>  Addendum I </li></a>
			<a href='byond://?src=\ref[src];page=[PAGE_LORE2]'><label> * </label> <li>  Addendum II </li></a>
			<a href='byond://?src=\ref[src];page=[PAGE_LORE3]'><label> * </label> <li>  Addendum III </li></a>
			</ul></div>
			<div style="font-size:18px" class="column">      <div align="left">      <b><ul>"}

	for (var/obj/item/weapon/talisman/T in talismans)
		dat += {"<label> * </label><li>  <a style="color:#FFEC66" href='byond://?src=\ref[src];talisman=\ref[T]'>[T.talisman_name()][(T.uses > 1) ? " [T.uses] uses" : ""]</a> <a style="color:#AE250F" href='byond://?src=\ref[src];remove=\ref[T]'>(x)</a> </li>"}

	dat += {"</ul></b></div><div align="justify">"}

	if (page_data)
		dat += page_data
	else
		dat += page_special()

	dat += {"</div></div></div></body>"}

	return dat

/obj/item/weapon/tome/proc/page_special()
	var/dat=null
	switch (current_page)
		if (PAGE_FOREWORD)
			dat={"<div align="center"><b>Foreword</b></div><br>"}
			dat += "<i>Written over the ages by a collection of arch-cultists, under the guidance of the geometer himself.</i>\
				<br><br>Touch a chapter to read it."
		if (PAGE_LORE1)
			dat={"<div align="center"><b>Addendum I: "From the other side of the veil"</b></div><br>"}
			dat += "<i>It is by chance that humanity stumbled upon the realm of Nar-Sie some centuries ago, \
					although while some of those so called wizards called it a happy little accident, few of them know that the dice was loaded from the start.\
					<br><br>Nar-Sie threw some artifacts adrift in the bluespace, waiting for some intelligent life to pick them up and trace their way back to him. \
					For you see, Nar-Sie loves two things about humans, the blood that flows from their veins, and the dramatic circumstances around which said blood ends up flowing from their gaping wounds.\
					<br><br>How did he know about humanity's existence before they even reached him you might ask? It's quite simple, he could hear the drumming of our heartbeats all the way from the other side of the veil.</i>"
		if (PAGE_LORE2)
			dat={"<div align="center"><b>Addendum II: "From whom the blood spills"</b></div><br>"}
			dat += "<i>After contact was made between the planes, it was a matter of time before some people would appear who would actively seek Nar-Sie.\
					<br><br>Either because his love of drama and chaos resonated with them, and they wanted to become his heralds, performing sacrifices for his amusement, \
					or because they were in awe with his... \"otherworldlyness?\" People who had lived until now grounded in reality, and became quite fascinated with something mystic, yet tangible.\
					<br><br>And of course, then came those who seeked to defy him. Either in the name of their own gods, or out of their own sense of morality, but little do those know, \
					Nar-Sie loves them equally, and doesn't care too much from whom the blood spills.</i>"
		if (PAGE_LORE3)
			dat={"<div align="center"><b>Addendum III: "The geometer's calling card"</b></div><br>"}
			dat += "<i>A common misconception about Nar-Sie is about his title, why is he the Geometer of Blood? Nobody dared ask him directly by fear of offending him, so for a long time, \
					many cultists just assumed that he was really into geometry, and his powers manifesting from blood drawings of precise patterns would corroborate this hypothesis.\
					<br><br>Some cultists eventually took it upon themselves to commune with him to get an answer, after performing some sacrifices for good measure. The answer was unexpected, and shed more light on the cult's origins. \
					They learned that after the wizards cut their way into his plane, it took some time for them to run into him, just like humans aren't aware of every single ant living in their garden. \
					But when they did arrive upon him, his gigantic form twisted upon the scenery gave them the image of a geometer moth.\
					<br><br>And just like moths tend to be attracted by light, they saw that Nar-Sie was attracted by blood, so they called him the Geometer of Blood, a title very much to his liking.\
					<br><br>As humanity ventures deeper and deeper into the darkness of space and toys with powers they understand less and less, Nar-Sie feels them coming closer and closer to him, and wants now to hasten the process. \
					His cult sends heralds to let humanity know how much he likes them (their blood mostly), and until he's ready to invite them into his realm, they leave blood-splattered space stations across the stars as his calling card.</i>"
	return dat

/obj/item/weapon/tome/Topic(href, href_list)
	if (..())
		return
	if(!usr.held_items.Find(src))
		return
	if(href_list["page"])
		current_page=text2num(href_list["page"])
		flick("tome-flick", src)
		playsound(usr, "pageturn", 50, 1, -5)

	if(href_list["talisman"])
		var/obj/item/weapon/talisman/T=locate(href_list["talisman"])
		if(!talismans.Find(T))
			return
		T.trigger(usr)

	if(href_list["remove"])
		var/obj/item/weapon/talisman/T=locate(href_list["remove"])
		if(!talismans.Find(T))
			return
		talismans.Remove(T)
		usr.put_in_hands(T)

	usr << browse(tome_text(), "window=arcanetome;size=900x600")

/obj/item/weapon/tome/attack(var/mob/living/M, var/mob/living/user)
	/*
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used [name] on [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	M.assaulted_by(user)
	*/

	if(!istype(M))
		return

	if(IS_CULTIST(M))//don't want to harm our team mates using tomes
		return

	..()

	if (!M.stat == DEAD)
		M.adjustOrganLoss(ORGAN_SLOT_STOMACH, rand(1, 10))
		to_chat(M, span_warning("You feel a searing heat inside of you!") )
		var/datum/antagonist/cult/cult_datum=user.mind.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			if (M.mind)
				cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_tome", M)
			else
				cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_tome_nomind", M)

/obj/item/weapon/tome/attack_hand(var/mob/living/user)
	if(!IS_CULTIST(user) && state == TOME_OPEN)
		to_chat(user, span_warning("As you reach to pick up \the [src], you feel a searing heat inside of you!") )
		playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, 0, 0, 0)
		user.Knockdown(5)
		user.Stun(5)
		flick("tome-stun", src)
		state=TOME_CLOSED
		return
	..()

/obj/item/weapon/tome/pickup(var/mob/user)
	.=..()
	if(IS_CULTIST(user) && state == TOME_OPEN)
		usr << browse(tome_text(), "window=arcanetome;size=900x600")

/obj/item/weapon/tome/dropped(var/mob/user)
	.=..()
	usr << browse(null, "window=arcanetome")

/obj/item/weapon/tome/attack_self(var/mob/living/user)
	if(!IS_CULTIST(user))//Too dumb to live.
		to_chat(user, span_warning("You try to peek inside \the [src], only to feel a discharge of energy and a searing heat inside of you!") )
		playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, 0, 0, 0)
		user.Knockdown(5)
		user.Stun(5)
		if (state == TOME_OPEN)
			icon_state="tome"
			flick("tome-stun", src)
			state=TOME_CLOSED
		else
			flick("tome-stun2", src)
		return
	else
		if (state == TOME_CLOSED)
			icon_state="tome-open"
			flick("tome-flickopen", src)
			playsound(user, "pageturn", 50, 1, -5)
			state=TOME_OPEN
			usr << browse(tome_text(), "window=arcanetome;size=900x600")
		else
			icon_state="tome"
			flick("tome-flickclose", src)
			state=TOME_CLOSED
			usr << browse(null, "window=arcanetome")

//absolutely no use except letting cultists know that you're here.
/obj/item/weapon/tome/attack_ghost(var/mob/dead/observer/user)
	if (state == TOME_OPEN && can_flick)
		if (Adjacent(user))
			to_chat(user, "You flick a page.")
			flick("tome-flick", src)
			playsound(user, "pageturn", 50, 1, -3)
			can_flick=0
			spawn(5)
				can_flick=1
		else
			to_chat(user, span_warning("You need to get closer to interact with the pages.") )

/obj/item/weapon/tome/attackby(var/obj/item/I, var/mob/user)
	if (..())
		return
	if (istype(I, /obj/item/weapon/talisman))
		if (talismans.len < MAX_TALISMAN_PER_TOME)
			if(user.dropItemToGround(I))
				talismans.Add(I)
				I.forceMove(src)
				to_chat(user, span_notice("You slip \the [I] into \the [src].") )
				if (state == TOME_OPEN)
					usr << browse(tome_text(), "window=arcanetome;size=900x600")
		else
			to_chat(user, span_warning("This tome cannot contain any more talismans. Use or remove some first.") )

/obj/item/weapon/tome/AltClick(var/mob/user)
	var/list/choices=list()
	var/datum/rune_spell/instance
	var/list/choice_to_talisman=list()
	var/image/talisman_image
	var/blood_messages=0
	var/blanks=0
	for(var/obj/item/weapon/talisman/T in talismans)
		talisman_image=new(T)
		if (T.blood_text)
			choices += list(list("Bloody Message[blood_messages ? " #[blood_messages+1]" : ""]", talisman_image, "A ghost has scribled a message on this talisman."))
			choice_to_talisman["Bloody Message[blood_messages ? " #[blood_messages+1]" : ""]"]=T
			blood_messages++
		else if (T.spell_type)
			instance=T.spell_type
			choices += list(list(T.talisman_name(), talisman_image, initial(instance.desc_talisman)))
			choice_to_talisman[T.talisman_name()]=T
		else
			choices += list(list("Blank Talisman[blanks ? " #[blanks+1]" : ""]", talisman_image, "Just an empty talisman."))
			choice_to_talisman["Blank Talisman[blanks ? " #[blanks+1]" : ""]"]=T
			blanks++


	var/list/made_choices=list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option=new
		option.image=image(choice[2])
		option.info=span_boldnotice(choice[3])
		made_choices[choice[1]]=option

	if (state == TOME_CLOSED)
		icon_state="tome-open"
		flick("tome-flickopen", src)
		playsound(user, "pageturn", 50, 1, -5)
		state=TOME_OPEN

	var/choice=show_radial_menu(user, loc, made_choices, tooltips=TRUE, radial_icon='monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi')
	if(!choice)
		return
	var/obj/item/weapon/talisman/chosen_talisman=choice_to_talisman[choice]
	if(!usr.held_items.Find(src))
		return
	if (state == TOME_OPEN)
		icon_state="tome"
		flick("tome-stun", src)
		state=TOME_CLOSED
	talismans.Remove(chosen_talisman)
	usr.put_in_hands(chosen_talisman)

#undef PAGE_FOREWORD
#undef PAGE_LORE1
#undef PAGE_LORE2
#undef PAGE_LORE3
