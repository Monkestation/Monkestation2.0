GLOBAL_LIST_EMPTY(bark_groups)
GLOBAL_LIST_INIT(bark_list, gen_barks())

/proc/gen_barks()
	var/list/bark_list = list()
	var/list/goon_barks = list()
	var/list/misc_barks = list()

	for(var/path in subtypesof(/datum/bark_voice))
		var/datum/bark_voice/bark = new path()

		bark_list[bark.name] = bark

	var/goon_sounds = list(
		"blub",
		"buwoo",
		"cow",
		"cyborg",
		"lizard",
		"pug",
		"pugg",
		"roach",
		"skelly",
		"speak_1",
		"speak_2",
		"speak_3",
		"speak_4",
	)

	for (var/name in goon_sounds)
		var/datum/bark_voice/bark = new
		bark.name = name
		bark.talk = sound("goon/sounds/misc/talk/" + name + ".ogg")
		bark.ask_beep = sound("goon/sounds/misc/talk/" + name + "_ask.ogg")
		bark.exclaim_beep = sound("goon/sounds/misc/talk/" + name + "_exclaim.ogg")
		bark.id = "goon/" + bark.name
		bark.group = "Goonstation"
		bark_list[bark.id] = bark
		goon_barks[bark.name] = bark

	var/other_sounds = list(
		"caw",
		"chirp",
		"chitter",
		"dont_starve/wilson",
		"dont_starve/wolfgang",
		"dont_starve/woodie",
		"dont_starve/wurt",
		"dont_starve/wx78",
		"kazooie/birdwhistle",
		"kazooie/birdwhistle2",
		"kazooie/caw",
		"kazooie/caw2",
		"kazooie/caw3",
		"kazooie/chitter1",
		"kazooie/dwoop",
		"kazooie/ehh",
		"kazooie/ehh2",
		"kazooie/ehh3",
		"kazooie/ehh4",
		"kazooie/ehh5",
		"kazooie/faucet",
		"kazooie/faucet2",
		"kazooie/hoot",
		"kazooie/ribbit",
		"kazooie/tweet",
		"kazooie/uhm",
		"kazooie/wurble1",
		"meow1",
		"moth/mothchitter2",
		"mothsqueak",
	)

	for (var/name in other_sounds)
		var/datum/bark_voice/bark = new
		bark.name = name
		bark.talk = sound("monkestation/sound/voice/barks/" + name + ".ogg")
		bark.id = "misc/" + bark.name
		bark.group = "Miscellaneous"
		bark_list[bark.id] = bark
		misc_barks[bark.name] = bark

	GLOB.bark_groups["Goonstation"] = goon_barks
	GLOB.bark_groups["Miscellaneous"] = misc_barks

	return bark_list

//Datums for barks and bark accessories

// /datum/bark
// 	var/name = "Default"
// 	var/id = "Default"
// 	var/soundpath //Path for the actual sound file used for the bark

// 	// Pitch vars. The actual range for a bark is [(pitch - (maxvariance*0.5)) to (pitch + (maxvariance*0.5))]
// 	// Make absolutely sure to take variance into account when curating a sound for bark purposes.
// 	var/minpitch = BARK_DEFAULT_MINPITCH
// 	var/maxpitch = BARK_DEFAULT_MAXPITCH
// 	var/minvariance = BARK_DEFAULT_MINVARY
// 	var/maxvariance = BARK_DEFAULT_MAXVARY

// 	// Speed vars. Speed determines the number of characters required for each bark, with lower speeds being faster with higher bark density
// 	var/minspeed = BARK_DEFAULT_MINSPEED
// 	var/maxspeed = BARK_DEFAULT_MAXSPEED

// 	// Visibility vars. Regardless of what's set below, these can still be obtained via adminbus and genetics. Rule of fun.
// 	var/list/ckeys_allowed
// 	var/ignore = FALSE //Controls whether or not this can be chosen in chargen
// 	var/allow_random = FALSE //Allows chargen randomization to use this. This is mainly to restrict the pool to sounds that fit well for most characters

/datum/bark_voice
	var/name
	var/id
	var/group

	var/sound/talk
	var/sound/ask_beep = null
	var/sound/exclaim_beep = null

// /datum/bark_voice/talk_1
// 	name = "Talk 1"
// 	talk = sound('goon/sounds/misc/talk/speak_1.ogg')
// 	ask_beep = sound('goon/sounds/misc/talk/speak_1_ask.ogg')
// 	exclaim_beep = sound('goon/sounds/misc/talk/speak_1_exclaim.ogg')

// /datum/bark_voice/talk_2
// 	name = "Talk 2"
// 	talk = sound('goon/sounds/misc/talk/speak_2.ogg')
// 	ask_beep = sound('goon/sounds/misc/talk/speak_2_ask.ogg')
// 	exclaim_beep = sound('goon/sounds/misc/talk/speak_2_exclaim.ogg')

// /datum/bark_voice/talk_3
// 	name = "Talk 3"
// 	talk = sound('goon/sounds/misc/talk/speak_3.ogg')
// 	ask_beep = sound('goon/sounds/misc/talk/speak_3_ask.ogg')
// 	exclaim_beep = sound('goon/sounds/misc/talk/speak_3_exclaim.ogg')

// /datum/bark_voice/talk_4
// 	name = "Talk 4"
// 	talk = sound('goon/sounds/misc/talk/speak_4.ogg')
// 	ask_beep = sound('goon/sounds/misc/talk/speak_4_ask.ogg')
// 	exclaim_beep = sound('goon/sounds/misc/talk/speak_4_exclaim.ogg')

/*
// So the basic jist of the sound design here: We make use primarily of shorter instrument samples for barks. We would've went with animalese instead, but doing so would've involved quite a bit of overhead to saycode.
// Short instrument samples tend to sound surprisingly nice for barks, being able to be played in rapid succession without being outright obnoxious.
// It isn't just instruments that work well here, however. Anything that works well as a stab? Short attack, no sustain, a decent amount of release? Also works extremely well for barks.

/datum/bark/mutedc2
	name = "Muted String (Low)"
	id = "mutedc2"
	soundpath = 'sound/instruments/synthesis_samples/guitar/crisis_muted/C2.ogg'
	allow_random = TRUE

/datum/bark/mutedc3
	name = "Muted String (Medium)"
	id = "mutedc3"
	soundpath = 'sound/instruments/synthesis_samples/guitar/crisis_muted/C3.ogg'
	allow_random = TRUE

/datum/bark/mutedc4
	name = "Muted String (High)"
	id = "mutedc4"
	soundpath = 'sound/instruments/synthesis_samples/guitar/crisis_muted/C4.ogg'
	allow_random = TRUE

/datum/bark/banjoc3
	name = "Banjo (Medium)"
	id = "banjoc3"
	soundpath = 'sound/instruments/banjo/Cn3.ogg'
	allow_random = TRUE

/datum/bark/banjoc4
	name = "Banjo (High)"
	id = "banjoc4"
	soundpath = 'sound/instruments/banjo/Cn4.ogg'
	allow_random = TRUE

/datum/bark/squeaky
	name = "Squeaky"
	id = "squeak"
	soundpath = 'sound/items/toysqueak1.ogg'
	maxspeed = 4

/datum/bark/beep
	name = "Beepy"
	id = "beep"
	soundpath = 'sound/machines/terminal_select.ogg'
	maxpitch = 1 //Bringing the pitch higher just hurts your ears :<
	maxspeed = 4 //This soundbyte's too short for larger speeds to not sound awkward

/datum/bark/chitter
	name = "Chittery"
	id = "chitter"
	minspeed = 4 //Even with the sound being replaced with a unique, shorter sound, this is still a little too long for higher speeds
	soundpath = 'sound/voice/barks/chitter.ogg'

/datum/bark/synthetic_grunt
	name = "Synthetic (Grunt)"
	id = "synthgrunt"
	soundpath = 'sound/misc/bloop.ogg'

/datum/bark/synthetic
	name = "Synthetic (Normal)"
	id = "synth"
	soundpath = 'sound/machines/uplinkerror.ogg'

/datum/bark/bullet
	name = "Windy"
	id = "bullet"
	maxpitch = 1.6 //This works well with higher pitches!
	soundpath = 'sound/weapons/bulletflyby.ogg' //This works... Surprisingly well as a bark? It's neat!

/datum/bark/coggers
	name = "Brassy"
	id = "coggers"
	soundpath = 'sound/machines/clockcult/integration_cog_install.ogg' //Yet another unexpectedly good bark sound


// Genetics-only/admin-only sounds. These either clash hard with the audio design of the above sounds, or have some other form of audio design issue, but aren't *too* awful as a sometimes thing.
// Rule of fun very much applies to this section. Audio design is extremely important for the above section, but down here? No gods, no masters, pure anarchy.
// The min/max variables simply don't apply to these, as only chargen cares about them. As such, there's no need to define those.

/datum/bark/bikehorn
	name = "Bikehorn"
	id = "horn"
	soundpath = 'sound/instruments/bikehorn/Cn4.ogg'
	ignore = TRUE // This is an unusually quiet sound.

/datum/bark/bwoink
	name = "Bwoink"
	id = "bwoink"
	soundpath = 'sound/effects/adminhelp.ogg'
	ignore = TRUE // Emergent heart attack generation

/datum/bark/merp
	name = "Merp"
	id = "merp"
	soundpath = 'modular_citadel/sound/voice/merp.ogg'
	ignore = TRUE

/datum/bark/bark
	name = "Bark"
	id = "bark"
	soundpath = 'modular_citadel/sound/voice/bark1.ogg'
	ignore = TRUE

/datum/bark/nya
	name = "Nya"
	id = "nya"
	soundpath = 'modular_citadel/sound/voice/nya.ogg'
	ignore = TRUE

/datum/bark/moff
	name = "Moff"
	id = "moff"
	soundpath = 'modular_citadel/sound/voice/mothsqueak.ogg'
	ignore = TRUE

/datum/bark/weh
	name = "Weh"
	id = "weh"
	soundpath = 'modular_citadel/sound/voice/weh.ogg'
	ignore = TRUE

/datum/bark/honk
	name = "Annoying Honk"
	id = "honk"
	soundpath = 'sound/creatures/goose1.ogg'
	ignore = TRUE
*/
