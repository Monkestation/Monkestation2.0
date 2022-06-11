//Bark defines
#define BARK_DEFAULT_MINPITCH 0.6
#define BARK_DEFAULT_MAXPITCH 1.4
#define BARK_DEFAULT_MINVARY 0.1
#define BARK_DEFAULT_MAXVARY 0.4
#define BARK_DEFAULT_MINSPEED 2
#define BARK_DEFAULT_MAXSPEED 8

///Used to calculate delay between barks, any bark speeds below this feature higher bark density, any speeds above feature lower bark density. Keeps barking length consistent
#define BARK_SPEED_BASELINE 4

#define BARK_MAX_BARKS 128
#define BARK_MAX_TIME (10 SECONDS) // More or less the amount of time the above takes to process through with a bark speed of 2.

///Macro for determining random pitch based off gender
#define BARK_PITCH_RAND(gend) ((gend == MALE ? rand(60, 120) : (gend == FEMALE ? rand(80, 140) : rand(60,140))) / 100)
///Macro for randomizing bark variance to reduce the amount of copy-pasta necessary for that
#define BARK_VARIANCE_RAND (rand(BARK_DEFAULT_MINVARY * 100, BARK_DEFAULT_MAXVARY * 100) / 100)

#define BARK_DO_VARY(pitch, variance) (rand(((pitch * 100) - (variance*50)), ((pitch*100) + (variance*50))) / 100)

///At lower ranges, we want the exponent to be below 1 so that whispers don't sound too awkward. At higher ranges, we want the exponent fairly high to make yelling less obnoxious
#define BARK_SOUND_FALLOFF_EXPONENT(distance) (distance/7)
