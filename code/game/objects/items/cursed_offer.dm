/obj/item/cursed_offer
	name = "Strange Contract"
	desc = "A strange contract detailing an offer between you and... something."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	throw_range = 1
	throw_speed = 1
	w_class = WEIGHT_CLASS_TINY
	///What does the admin offer?
	var/admin_offers = "Nothing?"
	///what arena the fight will take place in
	var/arena_condition = /area/station/service/chapel
	///what stakes the fight will have
	var/admin_receives = "Nothing?"
	///Who Signed this poor thing.
	var/datum/weakref/signed_by = null
	///What name are we signed by admin wise?
	var/admin_sign_name = "God"
/obj/item/cursed_offer/Destroy()
	signed_by = null
	return ..()

/obj/item/cursed_offer/examine(mob/user)
	. = ..()
	if(isAdminObserver(user) && tgui_alert(user, "Edit Contract?", "Edit",list("Yes","No")) == "Yes")
		admin_offers = tgui_input_text(user,"What do you offer?","Set Offer",admin_offers, multiline = TRUE, encode =TRUE)
		admin_receives = tgui_input_text(user,"What do you get to do in return?","Set penalty",admin_receives, multiline = TRUE, encode =TRUE)
		admin_sign_name = tgui_input_text(user,"What do you sign this as?","Set Signee",admin_sign_name, encode =TRUE)
		name = tgui_input_text(user,"What do you name this item?","Set Item Name","Strange Contract", encode =TRUE)
		if(signed_by)
			signed_by = null

/obj/item/cursed_offer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BadmemeContract", name)
		ui.open()

/obj/item/cursed_offer/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/right_partner
	if(signed_by)
		right_partner = signed_by.resolve()
	data["left_sign"] = admin_sign_name
	data["right_sign"] = right_partner?.real_name || "none"
	data["our_offer"] = admin_offers
	data["our_stakes"] = admin_receives
	return data

/obj/item/cursed_offer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	. = TRUE

	switch(action)
		if("sign")
			signed_by = WEAKREF(user)
			log_admin("[key_name(user)] has signed an admin bargain! The terms: [admin_offers] for [admin_receives]")
