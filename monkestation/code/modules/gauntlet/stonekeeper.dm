//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/datum/antagonist/stonekeeper
	name = "Stonekeeper"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	prevent_roundtype_conversion = FALSE

/datum/antagonist/stonekeeper/greet()
	to_chat(owner, "<span class='userdanger'>You are a stonekeeper!</span>")
	to_chat(owner, "<span class='danger'>You have an badmin stone in your backpack. <b>Keep it safe at all costs, even if it means killing.</b></span>")
	to_chat(owner, "<span class='danger'>You can examine your stone to see details on how to use it.</span>")

/datum/objective/stonekeeper
	name = "keep badmin stone secure"
	explanation_text = "Keep your Badmin Stone secure."
	var/obj/item/badmin_stone/stone

/datum/objective/stonekeeper/update_explanation_text()
	if(stone)
		explanation_text = "Keep the [stone] secured at all costs."

/datum/objective/stonekeeper/check_completion()
	if(!owner || !owner.current)
		return FALSE
	if(locate(stone) in owner.current)
		return TRUE
	return FALSE
