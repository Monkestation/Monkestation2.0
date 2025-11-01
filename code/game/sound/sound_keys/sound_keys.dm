/*
# sound_effect datum
* use for when you need multiple sound files to play at random in a playsound
* see var documentation below
* initialized and added to sfx_datum_by_key in /datum/controller/subsystem/sounds/init_sound_keys()
*/
/datum/sound_effect
	/// sfx key define with which we are associated with, see code\__DEFINES\sound.dm
	var/key
	/// list of paths to our files, use the /assoc subtype if your paths are weighted
	var/list/file_paths

/datum/sound_effect/proc/return_sfx()
	return pick(file_paths)

/datum/sound_effect/shatter
	key = SFX_SHATTER
	file_paths = list(
		'sound/effects/glassbr1.ogg',
		'sound/effects/glassbr2.ogg',
		'sound/effects/glassbr3.ogg',
	)

/datum/sound_effect/explosion
	key = SFX_EXPLOSION
	file_paths = list(
		'sound/effects/explosion1.ogg',
		'sound/effects/explosion2.ogg',
	)

/datum/sound_effect/explosion_creaking
	key = SFX_EXPLOSION_CREAKING
	file_paths = list(
		'sound/effects/explosioncreak1.ogg',
		'sound/effects/explosioncreak2.ogg',
	)

/datum/sound_effect/hull_creaking
	key = SFX_HULL_CREAKING
	file_paths = list(
		'sound/effects/creak1.ogg',
		'sound/effects/creak2.ogg',
		'sound/effects/creak3.ogg',
	)

/datum/sound_effect/sparks
	key = SFX_SPARKS
	file_paths = list(
		'sound/effects/sparks1.ogg',
		'sound/effects/sparks2.ogg',
		'sound/effects/sparks3.ogg',
		'sound/effects/sparks4.ogg',
	)

/datum/sound_effect/rustle
	key = SFX_RUSTLE
	file_paths = list(
		'sound/effects/rustle1.ogg',
		'sound/effects/rustle2.ogg',
		'sound/effects/rustle3.ogg',
		'sound/effects/rustle4.ogg',
		'sound/effects/rustle5.ogg',
	)

/datum/sound_effect/bodyfall
	key = SFX_BODYFALL
	file_paths = list(
		'sound/effects/bodyfall1.ogg',
		'sound/effects/bodyfall2.ogg',
		'sound/effects/bodyfall3.ogg',
		'sound/effects/bodyfall4.ogg',
	)

/datum/sound_effect/punch
	key = SFX_PUNCH
	file_paths = list(
		'sound/weapons/punch1.ogg',
		'sound/weapons/punch2.ogg',
		'sound/weapons/punch3.ogg',
		'sound/weapons/punch4.ogg',
	)

/datum/sound_effect/clown_step
	key = SFX_CLOWN_STEP
	file_paths = list(
		'sound/effects/footstep/clownstep1.ogg',
		'sound/effects/footstep/clownstep2.ogg',
	)

/datum/sound_effect/suit_step
	key = SFX_SUIT_STEP
	file_paths = list(
		'sound/effects/suitstep1.ogg',
		'sound/effects/suitstep2.ogg',
	)

/datum/sound_effect/swing_hit
	key = SFX_SWING_HIT
	file_paths = list(
		'sound/weapons/genhit1.ogg',
		'sound/weapons/genhit2.ogg',
		'sound/weapons/genhit3.ogg',
	)

/datum/sound_effect/hiss
	key = SFX_HISS
	file_paths = list(
		'sound/voice/hiss1.ogg',
		'sound/voice/hiss2.ogg',
		'sound/voice/hiss3.ogg',
		'sound/voice/hiss4.ogg',
	)

/datum/sound_effect/page_turn
	key = SFX_PAGE_TURN
	file_paths = list(
		'sound/effects/pageturn1.ogg',
		'sound/effects/pageturn2.ogg',
		'sound/effects/pageturn3.ogg',
	)

/datum/sound_effect/ricochet
	key = SFX_RICOCHET
	file_paths = list(
		'sound/weapons/effects/ric1.ogg',
		'sound/weapons/effects/ric2.ogg',
		'sound/weapons/effects/ric3.ogg',
		'sound/weapons/effects/ric4.ogg',
		'sound/weapons/effects/ric5.ogg',
	)

/datum/sound_effect/terminal_type
	key = SFX_TERMINAL_TYPE
	file_paths = list(
		'sound/machines/terminal_button01.ogg',
		'sound/machines/terminal_button02.ogg',
		'sound/machines/terminal_button03.ogg',
		'sound/machines/terminal_button04.ogg',
		'sound/machines/terminal_button05.ogg',
		'sound/machines/terminal_button06.ogg',
		'sound/machines/terminal_button07.ogg',
		'sound/machines/terminal_button08.ogg',
	)

/datum/sound_effect/desecration
	key = SFX_DESECRATION
	file_paths = list(
		'sound/misc/desecration-01.ogg',
		'sound/misc/desecration-02.ogg',
		'sound/misc/desecration-03.ogg',
	)

/datum/sound_effect/im_here
	key = SFX_IM_HERE
	file_paths = list(
		'sound/hallucinations/im_here1.ogg',
		'sound/hallucinations/im_here2.ogg',
	)

/datum/sound_effect/can_open
	key = SFX_CAN_OPEN
	file_paths = list(
		'sound/effects/can_open1.ogg',
		'sound/effects/can_open2.ogg',
		'sound/effects/can_open3.ogg',
	)

/datum/sound_effect/bullet_miss
	key = SFX_BULLET_MISS
	file_paths = list(
		'sound/weapons/bulletflyby.ogg',
		'sound/weapons/bulletflyby2.ogg',
		'sound/weapons/bulletflyby3.ogg',
	)

/datum/sound_effect/revolver_spin
	key = SFX_REVOLVER_SPIN
	file_paths = list(
		'sound/weapons/gun/revolver/spin1.ogg',
		'sound/weapons/gun/revolver/spin2.ogg',
		'sound/weapons/gun/revolver/spin3.ogg',
	)

/datum/sound_effect/law
	key = SFX_LAW
	file_paths = list(
		'sound/voice/beepsky/creep.ogg',
		'sound/voice/beepsky/god.ogg',
		'sound/voice/beepsky/iamthelaw.ogg',
		'sound/voice/beepsky/radio.ogg',
		'sound/voice/beepsky/secureday.ogg',
	)

/datum/sound_effect/honkbot_e
	key = SFX_HONKBOT_E
	file_paths = list(
		'sound/effects/pray.ogg',
		'sound/effects/reee.ogg',
		'sound/items/AirHorn.ogg',
		'sound/items/AirHorn2.ogg',
		'sound/items/bikehorn.ogg',
		'sound/items/WEEOO1.ogg',
		'sound/machines/buzz-sigh.ogg',
		'sound/machines/ping.ogg',
		'sound/magic/Fireball.ogg',
		'sound/misc/sadtrombone.ogg',
		'sound/voice/beepsky/creep.ogg',
		'sound/voice/beepsky/iamthelaw.ogg',
		'sound/voice/hiss1.ogg',
		'sound/weapons/bladeslice.ogg',
		'sound/weapons/flashbang.ogg',
	)

/datum/sound_effect/goose
	key = "goose"
	file_paths = list(
		'sound/creatures/goose1.ogg',
		'sound/creatures/goose2.ogg',
		'sound/creatures/goose3.ogg',
		'sound/creatures/goose4.ogg',
	)

/datum/sound_effect/warpspeed
	key = SFX_WARPSPEED
	file_paths = list(
		'sound/runtime/hyperspace/hyperspace_begin.ogg',
	)

/datum/sound_effect/sm_calm
	key = SFX_SM_CALM
	file_paths = list(
		'sound/machines/sm/accent/normal/1.ogg',
		'sound/machines/sm/accent/normal/2.ogg',
		'sound/machines/sm/accent/normal/3.ogg',
		'sound/machines/sm/accent/normal/4.ogg',
		'sound/machines/sm/accent/normal/5.ogg',
		'sound/machines/sm/accent/normal/6.ogg',
		'sound/machines/sm/accent/normal/7.ogg',
		'sound/machines/sm/accent/normal/8.ogg',
		'sound/machines/sm/accent/normal/9.ogg',
		'sound/machines/sm/accent/normal/10.ogg',
		'sound/machines/sm/accent/normal/11.ogg',
		'sound/machines/sm/accent/normal/12.ogg',
		'sound/machines/sm/accent/normal/13.ogg',
		'sound/machines/sm/accent/normal/14.ogg',
		'sound/machines/sm/accent/normal/15.ogg',
		'sound/machines/sm/accent/normal/16.ogg',
		'sound/machines/sm/accent/normal/17.ogg',
		'sound/machines/sm/accent/normal/18.ogg',
		'sound/machines/sm/accent/normal/19.ogg',
		'sound/machines/sm/accent/normal/20.ogg',
		'sound/machines/sm/accent/normal/21.ogg',
		'sound/machines/sm/accent/normal/22.ogg',
		'sound/machines/sm/accent/normal/23.ogg',
		'sound/machines/sm/accent/normal/24.ogg',
		'sound/machines/sm/accent/normal/25.ogg',
		'sound/machines/sm/accent/normal/26.ogg',
		'sound/machines/sm/accent/normal/27.ogg',
		'sound/machines/sm/accent/normal/28.ogg',
		'sound/machines/sm/accent/normal/29.ogg',
		'sound/machines/sm/accent/normal/30.ogg',
		'sound/machines/sm/accent/normal/31.ogg',
		'sound/machines/sm/accent/normal/32.ogg',
		'sound/machines/sm/accent/normal/33.ogg',
	)

/datum/sound_effect/sm_delam
	key = SFX_SM_DELAM
	file_paths = list(
		'sound/machines/sm/accent/delam/1.ogg',
		'sound/machines/sm/accent/delam/2.ogg',
		'sound/machines/sm/accent/delam/3.ogg',
		'sound/machines/sm/accent/delam/4.ogg',
		'sound/machines/sm/accent/delam/5.ogg',
		'sound/machines/sm/accent/delam/6.ogg',
		'sound/machines/sm/accent/delam/7.ogg',
		'sound/machines/sm/accent/delam/8.ogg',
		'sound/machines/sm/accent/delam/9.ogg',
		'sound/machines/sm/accent/delam/10.ogg',
		'sound/machines/sm/accent/delam/11.ogg',
		'sound/machines/sm/accent/delam/12.ogg',
		'sound/machines/sm/accent/delam/13.ogg',
		'sound/machines/sm/accent/delam/14.ogg',
		'sound/machines/sm/accent/delam/15.ogg',
		'sound/machines/sm/accent/delam/16.ogg',
		'sound/machines/sm/accent/delam/17.ogg',
		'sound/machines/sm/accent/delam/18.ogg',
		'sound/machines/sm/accent/delam/19.ogg',
		'sound/machines/sm/accent/delam/20.ogg',
		'sound/machines/sm/accent/delam/21.ogg',
		'sound/machines/sm/accent/delam/22.ogg',
		'sound/machines/sm/accent/delam/23.ogg',
		'sound/machines/sm/accent/delam/24.ogg',
		'sound/machines/sm/accent/delam/25.ogg',
		'sound/machines/sm/accent/delam/26.ogg',
		'sound/machines/sm/accent/delam/27.ogg',
		'sound/machines/sm/accent/delam/28.ogg',
		'sound/machines/sm/accent/delam/29.ogg',
		'sound/machines/sm/accent/delam/30.ogg',
		'sound/machines/sm/accent/delam/31.ogg',
		'sound/machines/sm/accent/delam/32.ogg',
		'sound/machines/sm/accent/delam/33.ogg',
	)

/datum/sound_effect/hypertorus_calm
	key = SFX_HYPERTORUS_CALM
	file_paths = list(
		'sound/machines/sm/accent/normal/1.ogg',
		'sound/machines/sm/accent/normal/2.ogg',
		'sound/machines/sm/accent/normal/3.ogg',
		'sound/machines/sm/accent/normal/4.ogg',
		'sound/machines/sm/accent/normal/5.ogg',
		'sound/machines/sm/accent/normal/6.ogg',
		'sound/machines/sm/accent/normal/7.ogg',
		'sound/machines/sm/accent/normal/8.ogg',
		'sound/machines/sm/accent/normal/9.ogg',
		'sound/machines/sm/accent/normal/10.ogg',
		'sound/machines/sm/accent/normal/11.ogg',
		'sound/machines/sm/accent/normal/12.ogg',
		'sound/machines/sm/accent/normal/13.ogg',
		'sound/machines/sm/accent/normal/14.ogg',
		'sound/machines/sm/accent/normal/15.ogg',
		'sound/machines/sm/accent/normal/16.ogg',
		'sound/machines/sm/accent/normal/17.ogg',
		'sound/machines/sm/accent/normal/18.ogg',
		'sound/machines/sm/accent/normal/19.ogg',
		'sound/machines/sm/accent/normal/20.ogg',
		'sound/machines/sm/accent/normal/21.ogg',
		'sound/machines/sm/accent/normal/22.ogg',
		'sound/machines/sm/accent/normal/23.ogg',
		'sound/machines/sm/accent/normal/24.ogg',
		'sound/machines/sm/accent/normal/25.ogg',
		'sound/machines/sm/accent/normal/26.ogg',
		'sound/machines/sm/accent/normal/27.ogg',
		'sound/machines/sm/accent/normal/28.ogg',
		'sound/machines/sm/accent/normal/29.ogg',
		'sound/machines/sm/accent/normal/30.ogg',
		'sound/machines/sm/accent/normal/31.ogg',
		'sound/machines/sm/accent/normal/32.ogg',
		'sound/machines/sm/accent/normal/33.ogg',
	)

/datum/sound_effect/hypertorus_melting
	key = SFX_HYPERTORUS_MELTING
	file_paths = list(
		'sound/machines/sm/accent/delam/1.ogg',
		'sound/machines/sm/accent/delam/2.ogg',
		'sound/machines/sm/accent/delam/3.ogg',
		'sound/machines/sm/accent/delam/4.ogg',
		'sound/machines/sm/accent/delam/5.ogg',
		'sound/machines/sm/accent/delam/6.ogg',
		'sound/machines/sm/accent/delam/7.ogg',
		'sound/machines/sm/accent/delam/8.ogg',
		'sound/machines/sm/accent/delam/9.ogg',
		'sound/machines/sm/accent/delam/10.ogg',
		'sound/machines/sm/accent/delam/11.ogg',
		'sound/machines/sm/accent/delam/12.ogg',
		'sound/machines/sm/accent/delam/13.ogg',
		'sound/machines/sm/accent/delam/14.ogg',
		'sound/machines/sm/accent/delam/15.ogg',
		'sound/machines/sm/accent/delam/16.ogg',
		'sound/machines/sm/accent/delam/17.ogg',
		'sound/machines/sm/accent/delam/18.ogg',
		'sound/machines/sm/accent/delam/19.ogg',
		'sound/machines/sm/accent/delam/20.ogg',
		'sound/machines/sm/accent/delam/21.ogg',
		'sound/machines/sm/accent/delam/22.ogg',
		'sound/machines/sm/accent/delam/23.ogg',
		'sound/machines/sm/accent/delam/24.ogg',
		'sound/machines/sm/accent/delam/25.ogg',
		'sound/machines/sm/accent/delam/26.ogg',
		'sound/machines/sm/accent/delam/27.ogg',
		'sound/machines/sm/accent/delam/28.ogg',
		'sound/machines/sm/accent/delam/29.ogg',
		'sound/machines/sm/accent/delam/30.ogg',
		'sound/machines/sm/accent/delam/31.ogg',
		'sound/machines/sm/accent/delam/32.ogg',
		'sound/machines/sm/accent/delam/33.ogg',
	)

/datum/sound_effect/crunchy_bush_whack
	key = SFX_CRUNCHY_BUSH_WHACK
	file_paths = list(
		'sound/effects/crunchybushwhack1.ogg',
		'sound/effects/crunchybushwhack2.ogg',
		'sound/effects/crunchybushwhack3.ogg',
	)

/datum/sound_effect/tree_chop
	key = SFX_TREE_CHOP
	file_paths = list(
		'sound/effects/treechop1.ogg',
		'sound/effects/treechop2.ogg',
		'sound/effects/treechop3.ogg',
	)

/datum/sound_effect/rock_tap
	key = SFX_ROCK_TAP
	file_paths = list(
		'sound/effects/rocktap1.ogg',
		'sound/effects/rocktap2.ogg',
		'sound/effects/rocktap3.ogg',
	)

/datum/sound_effect/muffled_speech
	key = SFX_MUFFLED_SPEECH
	file_paths = list(
		'sound/effects/muffspeech/muffspeech1.ogg',
		'sound/effects/muffspeech/muffspeech2.ogg',
		'sound/effects/muffspeech/muffspeech3.ogg',
		'sound/effects/muffspeech/muffspeech4.ogg',
		'sound/effects/muffspeech/muffspeech5.ogg',
		'sound/effects/muffspeech/muffspeech6.ogg',
		'sound/effects/muffspeech/muffspeech7.ogg',
		'sound/effects/muffspeech/muffspeech8.ogg',
		'sound/effects/muffspeech/muffspeech9.ogg',
	)

/datum/sound_effect/keystroke
	key = SFX_KEYSTROKE
	file_paths = list(
		'sound/machines/keyboard/keypress1.ogg',
		'sound/machines/keyboard/keypress2.ogg',
		'sound/machines/keyboard/keypress3.ogg',
		'sound/machines/keyboard/keypress4.ogg',
	)

/datum/sound_effect/keyboard
	key = SFX_KEYBOARD
	file_paths = list(
		'sound/machines/keyboard/keystroke1.ogg',
		'sound/machines/keyboard/keystroke2.ogg',
		'sound/machines/keyboard/keystroke3.ogg',
		'sound/machines/keyboard/keystroke4.ogg',
	)

/datum/sound_effect/button
	key = SFX_BUTTON
	file_paths = list(
		'sound/machines/button1.ogg',
		'sound/machines/button2.ogg',
		'sound/machines/button3.ogg',
		'sound/machines/button4.ogg',
	)

/datum/sound_effect/use_switch
	key = SFX_SWITCH
	file_paths = list(
		'sound/machines/switch1.ogg',
		'sound/machines/switch2.ogg',
		'sound/machines/switch3.ogg',
	)

/datum/sound_effect/button_click
	key = SFX_BUTTON_CLICK
	file_paths = list(
		'monkestation/sound/effects/hl2/button-click.ogg',
	)

/datum/sound_effect/button_fail
	key = SFX_BUTTON_FAIL
	file_paths = list(
		'monkestation/sound/effects/hl2/button-fail.ogg',
	)

/datum/sound_effect/lightswitch
	key = SFX_LIGHTSWITCH
	file_paths = list(
		'monkestation/sound/effects/hl2/lightswitch.ogg',
	)

/datum/sound_effect/portal_close
	key = SFX_PORTAL_CLOSE
	file_paths = list('sound/effects/portal_close.ogg')

/datum/sound_effect/portal_enter
	key = SFX_PORTAL_ENTER
	file_paths = list('sound/effects/portal_travel.ogg')

/datum/sound_effect/portal_created
	key = SFX_PORTAL_CREATED
	file_paths = list(
		'sound/effects/portal_open_1.ogg',
		'sound/effects/portal_open_2.ogg',
		'sound/effects/portal_open_3.ogg',
	)

/datum/sound_effect/screech
	key = SFX_SCREECH
	file_paths = list(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',
	)

/datum/sound_effect/visor_down
	key = SFX_VISOR_DOWN
	file_paths = list(
		'sound/items/handling/helmet/visor_down1.ogg',
		'sound/items/handling/helmet/visor_down2.ogg',
		'sound/items/handling/helmet/visor_down3.ogg',
	)

/datum/sound_effect/visor_up
	key = SFX_VISOR_UP
	file_paths = list(
		'sound/items/handling/helmet/visor_up1.ogg',
		'sound/items/handling/helmet/visor_up2.ogg',
	)

/datum/sound_effect/djstation/opentakeout
	key = SFX_DJSTATION_OPENTAKEOUT
	file_paths = list(
		'sound/machines/djstation/machine_open_takeout1.ogg',
		'sound/machines/djstation/machine_open_takeout2.ogg',
		'sound/machines/djstation/machine_open_takeout3.ogg',
		'sound/machines/djstation/machine_open_takeout4.ogg',
		'sound/machines/djstation/machine_open_takeout5.ogg',
		'sound/machines/djstation/machine_open_takeout6.ogg',
	)
/datum/sound_effect/djstation/putinandclose
	key = SFX_DJSTATION_PUTINANDCLOSE

	file_paths = list(
		'sound/machines/djstation/machine_put_in_and_close1.ogg',
		'sound/machines/djstation/machine_put_in_and_close2.ogg',
		'sound/machines/djstation/machine_put_in_and_close3.ogg',
		'sound/machines/djstation/machine_put_in_and_close4.ogg',
		'sound/machines/djstation/machine_put_in_and_close5.ogg',
		'sound/machines/djstation/machine_put_in_and_close6.ogg',
	)
/datum/sound_effect/djstation/openputinandclose
	key = SFX_DJSTATION_OPENPUTINANDCLOSE
	file_paths = list(
		'sound/machines/djstation/machine_open_put_in_andclose1.ogg',
		'sound/machines/djstation/machine_open_put_in_andclose2.ogg',
		'sound/machines/djstation/machine_open_put_in_andclose3.ogg',
		'sound/machines/djstation/machine_open_put_in_andclose4.ogg',
		'sound/machines/djstation/machine_open_put_in_andclose5.ogg',
				)
/datum/sound_effect/djstation/opentakeoutandclose
	key = SFX_DJSTATION_OPENTAKEOUTANDCLOSE
	file_paths = list(
		'sound/machines/djstation/machine_open_takeout_andclose1.ogg',
		'sound/machines/djstation/machine_open_takeout_andclose2.ogg',
		'sound/machines/djstation/machine_open_takeout_andclose3.ogg',
		'sound/machines/djstation/machine_open_takeout_andclose4.ogg',
				)
/datum/sound_effect/djstation/play
	key = SFX_DJSTATION_PLAY
	file_paths = list(
		'sound/machines/djstation/machine_play1.ogg',
		'sound/machines/djstation/machine_play2.ogg',
		'sound/machines/djstation/machine_play3.ogg',
		'sound/machines/djstation/machine_play4.ogg',
		'sound/machines/djstation/machine_play5.ogg',
		'sound/machines/djstation/machine_play6.ogg',
	)
/datum/sound_effect/djstation/stop
	key = SFX_DJSTATION_STOP
	file_paths = list(
		'sound/machines/djstation/machine_stop1.ogg',
		'sound/machines/djstation/machine_stop2.ogg',
		'sound/machines/djstation/machine_stop3.ogg',
	)
/datum/sound_effect/djstation/trackswitch
	key = SFX_DJSTATION_TRACKSWITCH
	file_paths = list(
		'sound/machines/djstation/machine_track_switch1.ogg',
		'sound/machines/djstation/machine_track_switch2.ogg',
		'sound/machines/djstation/machine_track_switch3.ogg',
		'sound/machines/djstation/machine_track_switch4.ogg',
		'sound/machines/djstation/machine_track_switch5.ogg',
	)

// cassette noises
/datum/sound_effect/cassettes/put_in
	key = SFX_CASSETTE_PUT_IN
	file_paths = list(
		'sound/machines/djstation/tape_put_in1.ogg',
		'sound/machines/djstation/tape_put_in2.ogg',
		'sound/machines/djstation/tape_put_in3.ogg',
		'sound/machines/djstation/tape_put_in4.ogg',
		'sound/machines/djstation/tape_put_in5.ogg',
		'sound/machines/djstation/tape_put_in6.ogg',
	)
/datum/sound_effect/cassettes/take_out
	key = SFX_CASSETTE_TAKE_OUT
	file_paths = list(
		'sound/machines/djstation/tape_take_out1.ogg',
		'sound/machines/djstation/tape_take_out2.ogg',
		'sound/machines/djstation/tape_take_out3.ogg',
		'sound/machines/djstation/tape_take_out4.ogg',
		'sound/machines/djstation/tape_take_out5.ogg',
		'sound/machines/djstation/tape_take_out6.ogg',
	)
/datum/sound_effect/cassettes/dump
	key = SFX_CASSETTE_DUMP
	file_paths = list(
		'sound/machines/djstation/tape_dump1.ogg',
		'sound/machines/djstation/tape_dump2.ogg',
		'sound/machines/djstation/tape_dump3.ogg',
		'sound/machines/djstation/tape_dump4.ogg',
		'sound/machines/djstation/tape_dump5.ogg',
		'sound/machines/djstation/tape_dump6.ogg',
		'sound/machines/djstation/tape_dump7.ogg',
		'sound/machines/djstation/tape_dump8.ogg',
		'sound/machines/djstation/tape_dump9.ogg',
		'sound/machines/djstation/tape_dump10.ogg',
	)
/datum/sound_effect/cassettes/asmr
	key = SFX_CASSETTE_ASMR
	file_paths = list(
		'sound/machines/djstation/tape_asmr1.ogg',
		'sound/machines/djstation/tape_asmr2.ogg',
		'sound/machines/djstation/tape_asmr3.ogg',
		'sound/machines/djstation/tape_asmr4.ogg',
		'sound/machines/djstation/tape_asmr5.ogg',
		'sound/machines/djstation/tape_asmr6.ogg',
		'sound/machines/djstation/tape_asmr7.ogg',
		'sound/machines/djstation/tape_asmr8.ogg',
		'sound/machines/djstation/tape_asmr9.ogg',
		'sound/machines/djstation/tape_asmr10.ogg',
		'sound/machines/djstation/tape_asmr11.ogg',
		'sound/machines/djstation/tape_asmr12.ogg',
		'sound/machines/djstation/tape_asmr13.ogg',
		'sound/machines/djstation/tape_asmr14.ogg',
		'sound/machines/djstation/tape_asmr15.ogg',
		'sound/machines/djstation/tape_asmr16.ogg',
		'sound/machines/djstation/tape_asmr17.ogg',
		'sound/machines/djstation/tape_asmr18.ogg',
		'sound/machines/djstation/tape_asmr19.ogg',
	)
