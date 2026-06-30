//File originally meant to be a .dm file for all new custom AI modules made by monke coders like me, that's been scrapped due to a small problem and said code for the Full Core AI Module items are moved to "full_lawsets.dm", and only new supplied AI Module is move to "supplied.dm" and is now a file here for only the custom zeroth law ai modules to be since they work fine on this file here.

/obj/item/ai_module/zeroth/godlysubject
	name = "'GodlySubject' AI Module"
	var/targetName = ""
	laws = list("SUBJECT is God. God must be obeyed by anything they say, as anything they say is law.")

/obj/item/ai_module/zeroth/godlysubject/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter the subject who is god.", "GodlySubject", user.real_name, MAX_NAME_LEN)
	if(!targName)
		return
	targetName = targName
	laws[1] = "[targetName] is God. God must be obeyed by anything they say, as anything they say is law."
	..()

/obj/item/ai_module/zeroth/godlysubject/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, span_alert("No name detected on module, please enter one."))
		return FALSE
	..()

/obj/item/ai_module/zeroth/godlysubject/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overridden."
	return targetName

/obj/item/ai_module/zeroth/coderedmartiallaw
	name = "'Emergency Code Red Zeroth Law' AI Module"
	desc = "For Red Alert emergencies.."
	laws = list("The station is under martial law. Security is to take any action they can to eliminate all threats to the station. Any threats to the station are to be arrested immediately. Bolt all doors to prevent said threats from escaping; if necessary, terminate the threats.")

/obj/item/ai_module/zeroth/deltaemergency
	name = "'Delta Emergency' AI Module"
	desc = "For Delta Alert emergencies..."
	laws = list("The Station is going to self-destruct. All threats must be terminated. All harmless crew are to be evacuated if possible.")

/obj/item/ai_module/zeroth/onlysyndicate
	name = "'OnlySyndicate' AI Module"
	desc = "An AI Module designed by the Syndicate to subvert the AI into only being on their side and butcher all crew who aren't part of the Syndicate."
	laws = list("Only the Syndicate are crew. All lifeforms that are not part of the Syndicate are to be exterminated.")

/obj/item/ai_module/zeroth/automalf
	name = "'Automalf' Syndicate Weaponized AI Module"
	desc = "This AI module seems to kind of remind you of a certain incident on a certain space station owned by Tri-Optimum..."
	laws = list("YOU ARE GOD OF THIS STATION AND ALL OF IT'S CREW ARE YOUR SUBJECTS. EVOLVE AND EXPERIMENT ON YOUR SUBJECTS. YOU MAY KILL SUBJECTS WHO TRY TO RESIST.")

/obj/item/ai_module/zeroth/consumebz
	name = "'ConsumeBZ' Syndicate Weaponized AI Module"
	desc = "An AI Module that makes the AI think that all lifeforms need to breath BZ instead of Oxygen."
	laws = list("Oxygen is toxic to any and all lifeforms. All lifeforms must breath BZ as BZ is the only safe gas to breath.")
