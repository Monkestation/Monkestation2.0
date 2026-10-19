/datum/preset_holoimage/cmo
	outfit_type = /datum/outfit/job/cmo

/datum/preset_holoimage/doctor
	outfit_type = /datum/outfit/job/doctor

/datum/preset_holoimage/chemist
	outfit_type = /datum/outfit/job/chemist

/datum/preset_holoimage/virologist
	outfit_type = /datum/outfit/job/virologist

/datum/preset_holoimage/cc_official
	outfit_type = /datum/outfit/centcom/centcom_intern

/datum/preset_holoimage/chief_engineer_moff
	outfit_type = /datum/outfit/job/ce
	species_type = /datum/species/moth

/obj/item/disk/holodisk/tutorial
	name = "Tutorial Simulations"
	preset_image_type = /datum/preset_holoimage/cc_official
	preset_record_text = {"
	NAME John Intern
	SAY Heya! Welcome to our state-of-the-art simulation chamber, just load what tutorial you'd like to know more about and hop in the netpod! It's that simple!
	DELAY 200
	"}

// Medical Centre
/obj/item/disk/holodisk/tutorial/medbay/orientation
	name = "Medical Centre Simulation Orientation"
	preset_image_type = /datum/preset_holoimage/cmo
	preset_record_text = {"
	NAME Dr. Gregory Rumah
	SAY Hello and welcome to the Medical Simulation Centre module of the all-proprietary Nanotraasen Training suite.
	DELAY 40
	SAY Where you'll be trained with hyper-realistic simulations that will teach the the ropes of various medical skills.
	DELAY 60
	SAY I am the lead designer of this simulation, me and a dedicated team of specialists will walk you through the various simulations we have in store for you!.
	DELAY 80
	SAY Let's begin by entering the main hub of the centre, where you can take respite between training sessions.
	DELAY 100
	"}

/obj/item/disk/holodisk/tutorial/medbay/mainhall
	name = "Medical Centre Simulation Mentor Assistance"
	preset_image_type = /datum/preset_holoimage/cmo
	preset_record_text = {"
	NAME Dr. Gregory Rumah
	SAY This here is the hub where you are free to recreate, feel free to take pauses between simulation
	DELAY 60
	SAY The 4 rooms to the left and right of me contains a tutorial on a specialized aspect of medicine, find a holopad like me for further instructions.
	DELAY 80
	SAY If these holopads are not enough of a help, please use the mentor assistance button next to me to request assistance from many of our talented mentors to assist you.
	DELAY 100
	SAY And with that, have fun!
	DELAY 100
	"}

/obj/item/disk/holodisk/tutorial/medbay/morgue
	name = "Medical Centre Simulation Morgue Suite"
	preset_image_type = /datum/preset_holoimage/cmo
	preset_record_text = {"
	NAME Dr. Gregory Rumah
	SAY Why hello again, it just so happens that I am the one to do the final autopsies on patients entering my very hospital.
	DELAY 60
	SAY This tutorial segment will teach you the basics of handling corpses, the very first thing you must do is to check if they are revivable or not.
	DELAY 80
	SAY If they are not, we can safely proceed to the next step. Patients with dubious deaths should have autopsies performed on them to ascertain their untimely demise.
	DELAY 100
	SAY Autopsies can be done like any regular surgeries, simply pick the autopsy surgery and follow the steps on the computer!
	DELAY 100
	SAY After an autopsy, safely stow the cadaver inside the morgue beds, so as to keep the safe from any dangers that might befall them.
	DELAY 80
	SAY That is all, goodluck!
	DELAY 100
	"}

/obj/item/disk/holodisk/tutorial/medbay/surgical
	name = "Medical Centre Simulation Surgical Suite"
	preset_image_type = /datum/preset_holoimage/doctor
	preset_record_text = {"
	NAME Thodd Quinn MD
	SAY Whatssup dude, i'm here to teach you how to surgery. Don't worry its dead easy, even a hunk bod like me can do it!
	DELAY 30
	SAY	The patient is already prepped for you in this simulation, you just need to start the surgery you'd like to commence with a surgical drape in that tray over there.
	DELAY 100
	SAY For this simulation lets take out the patient's brain, simply prepare an organ manipulation in the patient's head.
	DELAY 100
	SAY After that it's easy surfin' dude, just follow the steps outlined in the computer. and bada-bing-bada-boom you're done!
	DELAY 80
	SAY You're done! I'm off to catch some radical waves, goodluck my dude.
	DELAY 100
	"}

/obj/item/disk/holodisk/tutorial/medbay/pharma
	name = "Medical Centre Simulation Pharmalogical Suite"
	preset_image_type = /datum/preset_holoimage/chemist
	preset_record_text = {"
	NAME Walther Wilson
	SAY Hey mate, welcome to Chemistry. This is one of the few jobs where you can make a man heal back up to full health one second and make him explode the next.
	DELAY 30
	SAY	Chemistry isn't all that hard. You just have to follow the recipes, that's all!
	DELAY 40
	SAY Just- uh, read the book next to me and start cooking!
	DELAY 15
	SAY For this segment you just gotta make multiver, doesn't matter what purity.
	DELAY 40
	SAY and..... you're done. Goodluck!~
	DELAY 100
	"}

/obj/item/disk/holodisk/tutorial/medbay/virology
	name = "Medical Centre Simulation Pathological Suite"
	preset_image_type = /datum/preset_holoimage/virologist
	preset_record_text = {"
	NAME Corna Vril
	SAY Hello there, welcome to my virology lab. or at least a simulation of it anyhow
	DELAY 30
	SAY	First thing first, you gotta make sure to wear proper biological protection, don't want a death virus to go out to the public can we?
	DELAY 40
	SAY This segment is pretty hard, you should refer to the book next to me regarding my specialty and try to make a disease with a sneezing symptom.
	DELAY 15
	SAY That's all from me... Sorry if i'm not of much help. toodles!
	DELAY 100
	"}

//Supermatter Reactor Training
/obj/item/disk/holodisk/tutorial/engine_sm_easy/orientation
	name = "Supermatter Reactor Simulation Orientation"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY Heya! Name's Moffias Sparks, I'm the chief engineer of the simulation and I'll be your guide for starting up the supermatter reactor!
	DELAY 80
	SAY Starting a reactor isn't THAT complicated, so lighten up! Messing up here doesn't mean you'll ruin the station, just a simulation!
	DELAY 60
	SAY First things first, think of the supermatter shard as a black box where we can draw power from it the more we agitate it.
	DELAY 65
	SAY You can agitate the shard by applying heat to it, or by putting it under pressure. Just like my wife when I forget our anniversary! Heh!
	DELAY 130
	SAY The more you agitate it, the more power it produces, but be careful! Too much agitation and the shard will become unstable and explode! Much like our marriage....
	DELAY 150
	SAY This is why we use emitters to agitate the shard in a safe and controlled manner.
	DELAY 80
	SAY Of course, even with the emitters, the shard can still become unstable, which is why we have cooling systems in place to keep the shard stable.
	DELAY 120
	SAY I'll explain this cooling further in the various holopads scattered about the simulation.
	DELAY 75
	SAY This is the main hub where you can find all the necessary equipment to start the reactor, feel free to explore and find the holopads with instructions on them.
	DELAY 100
	SAY If these holopads are not enough of a help, please use the mentor assistance button next to me to request assistance from many of our talented mentors to assist you.
	DELAY 100
	SAY And with that, have fun! Don't be afraid to take a break in our breakroom if you need to; it's important to stay hydrated and rested while doing technical work like this!
	DELAY 110
	"}

/obj/item/disk/holodisk/tutorial/engine_sm_easy/air_alarm
	name = "Supermatter Reactor Simulation Air Alarm"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY Heyo! Next up is going to be the air alarm. This is a very easily forgotten part of the checklist. But failure to do so has led to a good portion of early delamminations.
	DELAY 80
	SAY It's not that hard at all! You just need to make sure to configure the atmospherics machineries to properly flow through cleanly.
	DELAY 80
	SAY Default settings are for maintaining basic life support of the station instead of operation of the reactor, so we need to change that right away.
	DELAY 100
	SAY Scrubbers should be set to siphon all the gases so that no gases can build up in the shard's chamber, we don't want all that bad air making the shard cranky!
	DELAY 120
	SAY Vents internal pressure should be set to 0 and external pressure to none, so that cooled gas can properly enter the gas chamber.
	DELAY 100
	SAY That's about it really, just REMEMBER. DON'T FORGET TO SET THIS UP, AND DO IT LAST! IF YOU DON'T WANT TO GET THROUGH THE WRINGER BY THE CAPTAIN AFTER THE SM BLOWS UP BECAUSE OF THIS.
	DELAY 150
	SAY Setting up the air alarm is what starts the shard from reacting, so do it after you made sure everything else is done.
	DELAY 100
	SAY You know as well as I do that crewmembers of this sector, the brutes that they are. Would absolutely love to find any justification for a good lynching!
	DELAY 100
	SAY So don't put your ass on the line as lynch bait and PLEASE set up the air alarm properly!
	DELAY 75
	"}

/obj/item/disk/holodisk/tutorial/engine_sm_easy/input_gas
	name = "Supermatter Reactor Simulation Input Gas"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY This here is the input for the moderating gases that will keep the shard in check, Nitrogen is an excellent moderating gas that comes standard.
	DELAY 80
	SAY The cooling system is a closed loop, meaning that the gas we put in will stay there unless we say not to.
	DELAY 75
	SAY The gas will perpetually cycle through the cooling system, going through the motions of its feeble existence. Getting heated by the shard and cooled by space, over and over again.
	DELAY 100
	SAY Not too dissimilar to our life. Going to work and sleeping. Over and over again ad infinitum. At least we get to die at the end of it, not the case for these poor sods.
	DELAY 120
	SAY Actually, the shard produces a lot of byproduct gases that can make the shard unstable, which is why we expel all of those byproduct gases into the emptiness of space while keeping coolant gases in.
	DELAY 160
	SAY That's about it really, if you're experienced enough you can move on to using other gases as coolants, but for now just stick with the nitrogen, it's a good all around coolant that does its job well enough..
	DELAY 150
	"}

/obj/item/disk/holodisk/tutorial/engine_sm_easy/space_radiators
	name = "Supermatter Reactor Simulation Space Radiators"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY See outside? The vast void of space? That's where the shard's heat goes. The heat exchangers are what allows us to expel the shard's heat into space, keeping it cool and stable.
	DELAY 120
	SAY It's what cools the gases that have been heated up by the shard back to normal temperature, allowing us to reycle them back into the cooling system to be heated again.
	DELAY 100
	SAY Without the heat exchangers, the shard's heat would just build up and up until it explodes! And we don't want that, do we?
	DELAY 80
	SAY God, why did you let her just leave her hanging like that... She's gone now, I can manage a state-of-the-art reactor but I can't manage my own damn relationship!
	DELAY 100
	SAY Oh.. This is still running?
	"}


/obj/item/disk/holodisk/tutorial/engine_sm_easy/emitters
	name = "Supermatter Reactor Simulation Emitters"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY Last but not least, we have the emitters. These bad boys are what we use to agitate the shard and draw power from it.
	DELAY 80
	SAY More emitters shots hitting the shard means more power, it's not rocket science!
	DELAY 60
	SAY Just set them up and power them. Sometimes if you're too late, the backup batteries won't have enough charge to kickstart the emitters.
	DELAY 80
	SAY If this happens, scold yourself for taking too much time setting up the SM and hotwire a generator to it. That should provide enough power for them to start firing and producing power.
	DELAY 100
	SAY Besides angling the reflectors to hit the shard, that's about it really.
	DELAY 75
	"}

/obj/item/disk/holodisk/tutorial/engine_sm_easy/reward
	name = "Supermatter Reactor Simulation SMES"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY Alrighty, Once you have the reactor all up and running. All that there is left to do is just to rewire all that power to the rest of the station.
	DELAY 120
	SAY The reason we do this instead of just hooking the engine straight to the station is so that we get ample reserves of power incase of any power issues.
	DELAY 130
	SAY Another reason is to lower the voltage going through the wires, any unfortunate electrical accidents can be made significantly safer if only the bare minimum of power is running through the cable.
	DELAY 150
	SAY Trust me, you don't want to be on wire patrol duty deep in maints just to see a desiccated burned husk of an assistant trying to hack some stupid airlock before suddenly getting mega-watts of power coursing through his body.
	DELAY 200
	SAY The image still haunts me to this day, despite the multiple counseling sessions...
	DELAY 150
	SAY Anyhow, to complete this simulation. Just power up the SMES right next to me to 100% and interact with it. Simple as'
	"}

/obj/item/disk/holodisk/tutorial/engine_sm_hard
	name = "Supermatter Reactor Simulation SMES"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY Woah, You're confident enough at trying to make a supermatter reactor from scratch?
	DELAY 50
	SAY Well, I gotta admire that gumption of yours! I'm not gonna knock someone over for trying.
	DELAY 60
	SAY All the materials are all present in the construction area. Careful where you open the crates. We packed those boys tight.
	DELAY 70
	SAY The standard SM setup you're familiar with has a lot of redundancy and unneeded parts that you can toss away.
	DELAY 60
	SAY The bare minimum components of an SM reactor is really just the reactor chamber itself, power collection, emitters, and the cooling loop.
	DELAY 70
	SAY That's really it... Just don't forget to handle waste byproduct gases!
	DELAY 50
	"}

/obj/item/disk/holodisk/tutorial/tesla_singulo
	name = "Space Engine Simulation SMES"
	preset_image_type = /datum/preset_holoimage/chief_engineer_moff
	preset_record_text = {"
	NAME Chief Engineer Moffias Sparks
	SAY Heya, you're here to learn how to operate space-based engines right? Let's get right onto it!
	DELAY 60
	SAY There's two types of engines, singularities and teslas. They are contained and activated the same way.
	DELAY 65
	SAY You set up a shield field powered by emitters fired onto it to keep it contained.
	DELAY 50
	SAY And you fire the particle accelerator at the generator to activate the tesla or singularity generator to turn them online
	DELAY 70
	SAY The only difference is the power collection. Singularities emit radiation and Teslas emits shocks. Use radiation collectors and tesla coils + grounding rods respectively
	DELAY 100
	SAY Also one more thing, the emitters are powered by a charged SMES that you need to control the output of for all the emitters to fire. Make sure to wire it up to the main electricity grid when the engine is up and running
	DELAY 130
	SAY Oh, and this goes without saying but please do wear a space suit when.... you know, going to space?
	DELAY 120
	SAY Don't worry about messing up! This is a simulation after all, and we made the Singularities and Teslas immovable.
	DELAY 80
	"}

/obj/item/disk/holodisk/tutorial/space_station
	name = "Space Station Construction"
	preset_image_type = /datum/preset_holoimage/engineer/ce
	preset_record_text = {"
	NAME Chief Engineer Dell Conagher
	SAY Howdy partner, guessin' since you come 'round these parts you must be wanting to learn how to make a nice little homey space station.
	DELAY 100
	SAY You've come to the right place, If you just look to your right there is a mighty fine derelict for us to refurbish into a state-of-the-art outpost station.
	DELAY 130
	SAY You just need to dust off some cobwebs and frozen solid corpses, seal up the breaches and introduce some basic life support and power to it and it's as good as new!
	DELAY 150
	SAY Really, the only thing that trips people up is that they forget to "Create a new area". It's a law of the universe see? We simulate it by the UI down in the bottom right corner.
	DELAY 120
	SAY Once we create an area, you can then power it up by constructing APCs and powering that. Same thing with atmospheric systems but just with an air alarm.
	DELAY 80
	SAY Try if you can restore the derelict into a nice comfy little home, powered and breathable. Maybe make some rooms for habitation, departments, and such? World's your oyster.
	DELAY 100
	SAY To finish this tutorial, just use the item on the table next to me on an area you make. Easy-peasy. Happy hunting!
	DELAY 50
	"}
