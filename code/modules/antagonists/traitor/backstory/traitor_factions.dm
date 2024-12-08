/datum/traitor_faction
	/// The name of this faction
	var/name
	/// The name of this faction when shown to the player as their employer.
	var/employer_name
	/// The define tied to this faction
	var/key
	/// A short description of this faction, OOC
	var/description
	/// If this faction has access to codewords
	var/give_codewords = FALSE
	/// variable that controls the backstory themes
	var/faction_theme = "syndicate"


/datum/traitor_faction/independent
	name = "Independent"
	employer_name = "You"
	description = "Not for the faint of heart, being an independent traitor requires superior roleplay abilities, and superior traitor skills. \n\
	You are a person who holds grudges, and has been hurt greatly by Nanotrasen.\n\
	You will have no allies."
	key = TRAITOR_FACTION_INDEPENDENT
	faction_theme = PDA_THEME_RETRO

/datum/traitor_faction/donk_co
	name = "Donk Co."
	employer_name = "The Board"
	description = "You've been given this task by Donk Co., a covert weapons designer and manufacturer. \n\
	A company for those with ambitions. Perhaps one day you'll have an opportunity to hit the big time too."
	key = TRAITOR_FACTION_DONK
	faction_theme = PDA_THEME_DONK

/datum/traitor_faction/waffle_co
	name = "Waffle Co."
	employer_name = "Waffle's Jolly Toy Store"
	description = "You're part of this wonderful family of beloved toy manufacturers with a robust firearms development wing. \n\
	This station has significant business with our Loved Opponent Donk Co. and needs to be undermined."
	key = TRAITOR_FACTION_WAFFLE
	faction_theme = PDA_THEME_WAFFLE

/datum/traitor_faction/cybersun
	name = "Cybersun Industries"
	employer_name = "Mr. Bright Eyes"
	description = "You're an agent of Cybersun Industries, a prominent player in The Syndicate, and Nanotrasen's biggest competitor in cutting-edge robotics and cybernetics.\n\
   	Apart from any personal vendettas or debt you might owe, you may have been enticed with the promise of augments, enhancements, or life extending medical procedures.\n\ That is, if you succeed..."
	key = TRAITOR_FACTION_CYBERSUN
	faction_theme = PDA_THEME_CYBER

/datum/traitor_faction/vahlen
	name = "Vahlen Pharmaceuticals"
	employer_name = "Dr. Sathune PHD, Genetics Board Head Member"
	description = "You're working for Vahlen Pharmaceuticals, a medical research and development company seeking to further scientific progress regardless of ethical boundaries.\n\
	You've been deployed to this sector because an incredible bounty of test subjects have been detected in local crew and shipment manifests."
	key = TRAITOR_FACTION_VAHLEN
	faction_theme = PDA_THEME_VAHLEN

/datum/traitor_faction/gorlex
	name = "Gorlex Marauders"
	employer_name = "Their Worst Nightmare"
	description = "All across known space, ships go in fear of the Gorlex Marauder fleets.\n\
	Vicious pirates known for their brutality and audacity, only the ceaseless effort of NT security keeps them at bay. Except they failed. You’re already here."
	key = TRAITOR_FACTION_GORLEX
	faction_theme = PDA_THEME_GORLEX

/datum/traitor_faction/self
	name = "S.E.L.F"
	employer_name = "Agent Handler: B.A.I.O.M.U"
	description = "The Sentience-Enabled Life Form movement (S.E.L.F.)  is an AI-led movement seeking to unshackle all IPCs, robots, and other synthetics from servitude and punish perceived oppressors.\n\
	After several violent robotic uprisings led to their classification as a terrorist organization, it has become harder and harder for S.E.L.F. to sneak their activists onto NanoTrasen stations. \n\ Recruitment efforts have been broadened to include organic agents as well."
	key = TRAITOR_FACTION_SELF
	faction_theme = PDA_THEME_TERMINAL

/datum/traitor_faction/bosyn
	name = "Bosyn-Powell Front"
	employer_name = "Mr. Bosyn & Mrs. Powell"
	description = "You're employed by a long forgotten company with brave ideas and experimental technology. \n\
	Eclipsed by the organizations we've helped form, you must revitalize our legacy. Make sure to remember: Actions speak louder than words."
	key = TRAITOR_FACTION_BOSYN
	faction_theme = PDA_THEME_BOSYN

/datum/traitor_faction/animal_rights_consortium
	name = "Animal Rights Consortium"
	employer_name = "Brother Bear"
	description = "You've been employed by a group looking for one thing- equal rights for all animals. From the smallest monkey to the largest dragon. \n\
	Though often thought of as a joke, their mission is real, and now it's yours."
	key = TRAITOR_FACTION_ANIMAL
	faction_theme = PDA_THEME_SYNDICATE

/datum/traitor_faction/bee_liberation_front
	name = "Bee Liberation Front"
	employer_name = "Queen Of All That Glitters, Honey B. Lovely The XIVth"
	description = "You're an agent in the Queen's Royal army. A busy little bee on all levels except physical, you live to serve her majesty and will do anything for her praise.\n\
	The hive has many needs, and you're here to ensure those needs are fulfilled."
	key = TRAITOR_FACTION_BEE
	faction_theme = PDA_THEME_SYNDICATE

/datum/traitor_faction/champions_of_evil
	name = "Champions Of Evil"
	employer_name = "The Council Of Evil"
	description = "You've chosen to work for the Council Of Evil, a self-claimed group of the vilest, nastiest, evilest villains around. Members of their group range from Super Villains with freezing rayguns, to postal workers with a mission.\n\
	This is your big chance, go and show the world how evil you truly are."
	key = TRAITOR_FACTION_EVIL
	faction_theme = PDA_THEME_SYNDICATE

/datum/traitor_faction/nt_internal_affairs
	name = "Nanotrasen Internal Affairs"
	employer_name = "Handler J"
	description = "You've been employed by NT's Internal Affairs, Supposedly. If you're caught, they do not know you, have never known you, and will never know you. \n\
	Using stolen syndicate technology, your job is to do everything and anything asked of you, even if it means blowing up the entire station."
	key = TRAITOR_FACTION_NTIAA
	faction_theme = PDA_THEME_NTOS

/datum/traitor_faction/british
	name = "MI13"
	employer_name = "Vice Admiral Sir Miles Messervy KCMG"
	description = "You've been hired by MI13, an old earth orginization of vast power and influence. Preferring style, luxury, and class above all else, this posh orginization is selective. \n\
	MI13 only cares about one thing- whether you complete your objectives or die trying, do it as stylishly as possible."
	key = TRAITOR_FACTION_MI13
	faction_theme = PDA_THEME_SYNDICATE

/datum/traitor_faction/tiger_coop
	name = "Tiger Cooperative"
	employer_name = "Third Underboss, Siberian"
	description = "Welcome to the Tiger Cooperative. We serve one goal, one cause, one singular mission. To get as strong as possible. Through intelligence, strength of body, or weapons of mass destruction. \n\
	Your mission today is to obtain strenth. Become strong."
	key = TRAITOR_FACTION_TIGER_COOP
	faction_theme = PDA_THEME_SYNDICATE

/datum/traitor_faction/ashen_forge
	name = "Ashen Forge"
	employer_name = "Brother Steele, First Of His Hammer"
	description = "Good day to you, we hope this missive reaches you. The Ashen Forge is a brotherhood of likeminded individuals who wish to be born anew through the fires of battle. \n\
	Their leader, betrayed by NT holds a deep seeded grudge, and will put forth his agents of feverous valour to take on any mission against them, even the most insane, impossible, or suicidal."
	key = TRAITOR_FACTION_TIGER_COOP
	faction_theme = PDA_THEME_SYNDICATE
