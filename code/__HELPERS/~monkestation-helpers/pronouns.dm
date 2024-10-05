/obj/item/organ/p_s(temp_gender) // these are pretty stupid but im not going to touch fucking pronoun code of all things get me away from here
	if(!temp_gender)
		temp_gender = gender
	return temp_gender != PLURAL ? "s" : null

/obj/item/organ/p_es(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	return temp_gender != PLURAL ? "es" : null
