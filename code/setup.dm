//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define DEBUG
//#define TESTING	 //ifdefs
//#define GC_FINDREF
//#define GC_DEBUG

#define PI 3.1415

#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa
#define IDEAL_GAS_ENTROPY_CONSTANT 	1164	//(mol^3 * s^3) / (kg^3 * L). Equal to (4*pi/(avrogadro's number * planck's constant)^2)^(3/2) / (avrogadro's number * 1000 Liters per m^3).

//radiation constants
#define STEFAN_BOLTZMANN_CONSTANT		5.6704e-8	//W/(m^2*K^4)
#define COSMIC_RADIATION_TEMPERATURE	3.15		//K
#define AVERAGE_SOLAR_RADIATION			200			//W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.  From the numbers on Erebus, this'd be an orbit of 23.3 lightseconds.
#define RADIATOR_OPTIMUM_PRESSURE		110			//kPa at 20 C
#define RADIATOR_EXPOSED_SURFACE_AREA 0.03  //The pipe looks to be thin vertically and wide horizontally, so we'll assume that it's three centimeters thick and only explosed to the sun edge-on.

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

#define MOLES_PLASMA_VISIBLE 0.7 //Moles in a standard cell after which plasma is visible
#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)

#define MIN_TOXIN_DAMAGE 1	//This and MAX_TOXIN_DAMAGE are for when a mob breathes poisonous air
#define MAX_TOXIN_DAMAGE 10	//This and MIN_TOXIN_DAMAGE are for when a mob breathes poisonous air

#define BREATH_VOLUME 0.5	//liters in a normal breath
#define BREATH_MOLES (ONE_ATMOSPHERE * BREATH_VOLUME /(T20C*R_IDEAL_GAS_EQUATION))
//Amount of air to take a from a tile
#define BREATH_PERCENTAGE BREATH_VOLUME/CELL_VOLUME
//Amount of air needed before pass out/suffocation commences
#define HUMAN_NEEDED_OXYGEN	MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16

#define SOUND_MINIMUM_PRESSURE 10

// Pressure limits.
#define HAZARD_HIGH_PRESSURE 550	//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 	//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE 50 	//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE 20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5	//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define BODYTEMP_AUTORECOVERY_DIVISOR 12 //This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM 1 //Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX -30 //The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX 30 //The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT 360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT 260.15 // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE 2.0 //what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE 2.0 //what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE 5000	//These need better heat protect, but not as good heat protect as firesuits.
#define FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE 30000 //what max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 30000 //for fire helmet quality items (red and white hardhats)
#define HELMET_MIN_COLD_PROTECTION_TEMPERATURE 160	//For normal helmets
#define HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 600	//For normal helmets
#define ARMOR_MIN_COLD_PROTECTION_TEMPERATURE 160	//For armor
#define ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 600	//For armor

#define GLOVES_MIN_COLD_PROTECTION_TEMPERATURE 2.0	//For some gloves (black and)
#define GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE 1500		//For some gloves
#define SHOE_MIN_COLD_PROTECTION_TEMPERATURE 2.0	//For gloves
#define SHOE_MAX_HEAT_PROTECTION_TEMPERATURE 1500		//For gloves


#define PRESSURE_DAMAGE_COEFFICIENT 4 //The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE 4	//This used to be 20... I got this much random rage for some retarded decision by polymorph?! Polymorph now lies in a pool of blood with a katana jammed in his spleen. ~Errorage --PS: The katana did less than 20 damage to him :(
#define LOW_PRESSURE_DAMAGE 2 	//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

// Doors!
#define DOOR_CRUSH_DAMAGE 10

// Factor of how fast mob nutrition decreases
#define HUNGER_FACTOR 0.05

// How many units of reagent are consumed per tick, by default.
#define REAGENTS_METABOLISM 0.2

// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4


//Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.05
//Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_AIR_TO_SUSPEND MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND

#define MINIMUM_MOLES_DELTA_TO_MOVE MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE	T20C+100 		  //or this (or both, obviously)

//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
//Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		T20C+10
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	T20C+200

//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.4
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define DOOR_HEAT_TRANSFER_COEFFICIENT 0.0
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.2 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1 //a hack for now

// Fire Damage
#define CARBON_LIFEFORM_FIRE_RESISTANCE 200+T0C
#define CARBON_LIFEFORM_FIRE_DAMAGE		4

//Plasma fire properties
#define PLASMA_MINIMUM_BURN_TEMPERATURE		100+T0C
#define PLASMA_FLASHPOINT 					246+T0C
#define PLASMA_UPPER_TEMPERATURE			1370+T0C
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	20
#define PLASMA_OXYGEN_FULLBURN				10

#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

//XGM gas flags
#define XGM_GAS_FUEL 1
#define XGM_GAS_OXIDIZER 2
#define XGM_GAS_CONTAMINANT 4

#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)	// Tank starts leaking
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere

#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold
								// was 2 atm
#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.
#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation
#define FLOWFRAC 0.99				// fraction of gas transfered per process
#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up

//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING 1
#define SLOT_ICLOTHING 2
#define SLOT_GLOVES 4
#define SLOT_EYES 8
#define SLOT_EARS 16
#define SLOT_MASK 32
#define SLOT_HEAD 64
#define SLOT_FEET 128
#define SLOT_ID 256
#define SLOT_BELT 512
#define SLOT_BACK 1024
#define SLOT_POCKET 2048		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS 8192
#define SLOT_TIE 16384

//FLAGS BITMASK
#define STOPSPRESSUREDMAGE 1	//This flag is used on the flags variable for SUIT and HEAD items which stop pressure damage. Note that the flag 1 was previous used as ONBACK, so it is possible for some code to use (flags & 1) when checking if something can be put on your back. Replace this code with (inv_flags & SLOT_BACK) if you see it anywhere
                                //To successfully stop you taking all pressure damage you must have both a suit and head item with this flag.
#define NOBLUDGEON  2       // when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define AIRTIGHT	4	    // functions with internals
#define USEDELAY 	8		// 1 second extra delay on use (Can be used once every 2s)
#define NODROP		2		// This flag makes it so that an item literally cannot be removed at all, or at least that's how it should be. Only deleted.
#define NOSHIELD	16		// weapon not affected by shield
#define CONDUCT		32		// conducts electricity (metal etc.)
#define ON_BORDER	64		// item has priority to check when entering or leaving
#define NOBLOODY	512	// used to items if they don't want to get a blood overlay
#define NODELAY 	8192	// 1 second attackby delay skipped (Can be used once every 0.2s). Most objects have a 1s attackby delay, which doesn't require a flag.

#define GLASSESCOVERSEYES	256
#define MASKCOVERSEYES		256		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		256		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		512		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		512

#define THICKMATERIAL 256		//From /tg: prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body. (NOTE: flag shared with NOSLIP for shoes)
#define NOSLIP		256 		//prevents from slipping on wet floors, in space etc

#define OPENCONTAINER	1024	// is an open container for chemistry purposes

#define BLOCK_GAS_SMOKE_EFFECT 2048	// blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY! (NOTE: flag shared with ONESIZEFITSALL)
#define ONESIZEFITSALL 2048
#define PLASMAGUARD 4096			//Does not get contaminated by plasma.

#define	NOREACT		4096 			//Reagents dont' react inside this container.

#define BLOCKHEADHAIR 4             // temporarily removes the user's hair overlay. Leaves facial hair.
#define BLOCKHAIR	8192			// temporarily removes the user's hair, facial and otherwise.

//flags for pass_flags
#define PASSTABLE	1
#define PASSGLASS	2
#define PASSGRILLE	4
#define PASSBLOB	8

//turf-only flags
#define NOJAUNT		1 //This is used in literally one place, turf.dm, to block ethereal jaunt.

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEGLOVES		1
#define HIDESUITSTORAGE	2
#define HIDEJUMPSUIT	4
#define HIDESHOES		8
#define HIDETAIL 		16
//APPLIES ONLY TO HELMETS/MASKS!!
#define HIDEMASK	1
#define HIDEEARS	2	//headsets and such
#define HIDEEYES	4	//glasses
#define HIDEFACE	8	//Dictates whether we appear as unknown.

//slots
#define slot_back 1
#define slot_wear_mask 2
#define slot_handcuffed 3
#define slot_l_hand 4
#define slot_r_hand 5
#define slot_belt 6
#define slot_wear_id 7
#define slot_l_ear 8
#define slot_glasses 9
#define slot_gloves 10
#define slot_head 11
#define slot_shoes 12
#define slot_wear_suit 13
#define slot_w_uniform 14
#define slot_l_store 15
#define slot_r_store 16
#define slot_s_store 17
#define slot_in_backpack 18
#define slot_legcuffed 19
#define slot_r_ear 20
#define slot_legs 21
#define slot_tie 22

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD			1
#define FACE			2
#define EYES			4
#define UPPER_TORSO		8
#define LOWER_TORSO		16
#define LEG_LEFT		32
#define LEG_RIGHT		64
#define LEGS			96
#define FOOT_LEFT		128
#define FOOT_RIGHT		256
#define FEET			384
#define ARM_LEFT		512
#define ARM_RIGHT		1024
#define ARMS			1536
#define HAND_LEFT		2048
#define HAND_RIGHT		4096
#define HANDS			6144
#define FULL_BODY		8191

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_UPPER_TORSO	0.15
#define THERMAL_PROTECTION_LOWER_TORSO	0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025

//bitflags for mutations
	// Extra powers:
#define SHADOW			(1<<10)	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			(1<<11)	// supersonic screaming (25%)
#define EXPLOSIVE		(1<<12)	// exploding on-demand (15%)
#define REGENERATION	(1<<13)	// superhuman regeneration (30%)
#define REPROCESSOR		(1<<14)	// eat anything (50%)
#define SHAPESHIFTING	(1<<15)	// take on the appearance of anything (40%)
#define PHASING			(1<<16)	// ability to phase through walls (40%)
#define SHIELD			(1<<17)	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		(1<<18)	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		(1<<19)	// ability to shoot electric attacks (15%)

#define STRUCDNASIZE 27
#define UNIDNASIZE 13

// channel numbers for power
#define EQUIP	1
#define LIGHT	2
#define ENVIRON	3
#define TOTAL	4	//for total power used only

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

#define GAS_O2 	(1 << 0)
#define GAS_N2	(1 << 1)
#define GAS_PL	(1 << 2)
#define GAS_CO2	(1 << 3)
#define GAS_N2O	(1 << 4)

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

#define TRANSITIONEDGE	7 //Distance from edge to move to another z-level

//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			1
#define MUTE_OOC		2
#define MUTE_PRAY		4
#define MUTE_ADMINHELP	8
#define MUTE_DEADCHAT	16
#define MUTE_ALL		31

//Number of identical messages required to get the spam-prevention automute thing to trigger warnings and automutes
#define SPAM_TRIGGER_WARNING 5
#define SPAM_TRIGGER_AUTOMUTE 10

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.

#define SEE_INVISIBLE_MINIMUM 5

#define SEE_INVISIBLE_OBSERVER_NOLIGHTING 15

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

#define SEE_INVISIBLE_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.

#define SEE_INVISIBLE_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.

#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100

//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are


//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list


#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

//Damage things

#define CUT 		"cut"
#define BRUISE		"bruise"
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define HALLOSS		"halloss"

#define STUN		"stun"
#define WEAKEN		"weaken"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define STUTTER		"stutter"
#define SLUR 		"slur"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"

///////////////////ORGAN DEFINES///////////////////

#define ORGAN_CUT_AWAY 1
#define ORGAN_GAUZED 2
#define ORGAN_ATTACHABLE 4
#define ORGAN_BLEEDING 8
#define ORGAN_BROKEN 32
#define ORGAN_DESTROYED 64
#define ORGAN_ROBOT 128
#define ORGAN_SPLINTED 256
#define SALVED 512
#define ORGAN_DEAD 1024
#define ORGAN_MUTATED 2048

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.



//Please don't edit these values without speaking to Errorage first	~Carn
//Admin Permissions
#define R_BUILDMODE		1
#define R_ADMIN			2
#define R_BAN			4
#define R_FUN			8
#define R_SERVER		16
#define R_DEBUG			32
#define R_POSSESS		64
#define R_PERMISSIONS	128
#define R_STEALTH		256
#define R_REJUVINATE	512
#define R_VAREDIT		1024
#define R_SOUNDS		2048
#define R_SPAWN			4096
#define R_MOD			8192
#define R_MENTOR		16384
#define R_HOST			32768

#define R_MAXPERMISSION 32768 //This holds the maximum value for a permission. It is used in iteration, so keep it updated.

//Preference toggles
#define SOUND_ADMINHELP	1
#define SOUND_MIDI		2
#define SOUND_AMBIENCE	4
#define SOUND_LOBBY		8
#define CHAT_OOC		16
#define CHAT_DEAD		32
#define CHAT_GHOSTEARS	64
#define CHAT_GHOSTSIGHT	128
#define CHAT_PRAYER		256
#define CHAT_RADIO		512
#define CHAT_ATTACKLOGS	1024
#define CHAT_DEBUGLOGS	2048
#define CHAT_LOOC		4096
#define CHAT_GHOSTRADIO 8192
#define SHOW_TYPING 	16384
#define CHAT_NOICONS	32768

#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_ATTACKLOGS|CHAT_LOOC)

#define BE_TRAITOR    1
#define BE_OPERATIVE  2
#define BE_CHANGELING 4
#define BE_WIZARD     8
#define BE_MALF       16
#define BE_REV        32
#define BE_ALIEN      64
#define BE_AI         128
#define BE_CULTIST    256
#define BE_MONKEY     512
#define BE_NINJA      1024
#define BE_RAIDER     2048
#define BE_PLANT      4096
#define BE_MUTINEER   8192
#define BE_PAI        16384

//Not sure if moving this to global.dm would break the defines.
var/list/be_special_flags = list(
	"Traitor" = BE_TRAITOR,
	"Operative" = BE_OPERATIVE,
	"Changeling" = BE_CHANGELING,
	"Wizard" = BE_WIZARD,
	"Malf AI" = BE_MALF,
	"Revolutionary" = BE_REV,
	"Xenomorph" = BE_ALIEN,
	"Positronic Brain" = BE_AI,
	"Cultist" = BE_CULTIST,
	"Monkey" = BE_MONKEY,
	"Ninja" = BE_NINJA,
	"Raider" = BE_RAIDER,
	"Diona" = BE_PLANT,
	"Mutineer" = BE_MUTINEER,
	"pAI" = BE_PAI
	)

#define AGE_MIN 16			//youngest a character can be
#define AGE_MAX 99			//oldest a character can be
//NPC


//NPC DEFINES
#define INTERACTING 2
#define TRAVEL 4
#define FIGHTING 8

//TRAITS

#define TRAIT_ROBUST 2
#define TRAIT_UNROBUST 4
#define TRAIT_SMART 8
#define TRAIT_DUMB 16
#define TRAIT_MEAN 32
#define TRAIT_FRIENDLY 64
#define TRAIT_THIEVING 128

//defines
#define MAX_RANGE_FIND 32
#define MIN_RANGE_FIND 16
#define FUZZY_CHANCE_HIGH 85
#define FUZZY_CHANCE_LOW 50
#define CHANCE_TALK 15
#define MAXCOIL 30
#define RESIZE_DEFAULT_SIZE 1

//Languages!
#define LANGUAGE_HUMAN		1
#define LANGUAGE_ALIEN		2
#define LANGUAGE_DOG		4
#define LANGUAGE_CAT		8
#define LANGUAGE_BINARY		16
#define LANGUAGE_OTHER		32768

#define LANGUAGE_UNIVERSAL	65535

#define LEFT 1
#define RIGHT 2

// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list of humans.
#define HEALTH_HUD		1 // a simple line rounding the mob's number health
#define STATUS_HUD		2 // alive, dead, diseased, etc.
#define ID_HUD			3 // the job asigned to your ID
#define WANTED_HUD		4 // wanted, released, parroled, security status
#define IMPLOYAL_HUD		5 // loyality implant
#define IMPCHEM_HUD		6 // chemical implant
#define IMPTRACK_HUD		7 // tracking implant
#define SPECIALROLE_HUD 	8 // AntagHUD image
#define STATUS_HUD_OOC		9 // STATUS_HUD without virus db check for someone being ill.

//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

//Species flags.
#define NO_BLOOD 1          // Vessel var is not filled with blood, cannot bleed out.
#define NO_BREATHE 2        // Cannot suffocate or take oxygen loss.
#define NO_SCAN 4           // Cannot be scanned in a DNA machine/genome-stolen.
#define NO_PAIN 8           // Cannot suffer halloss/recieves deceptive health indicator
#define NO_SLIP 16          // Cannot fall over
#define NO_POISON 32        // Cannot not suffer toxloss
#define HAS_SKIN_TONE 64    // Skin tone selectable in chargen (0-255)
#define HAS_SKIN_COLOR 128  // Skin colour selectable in chargen (RGB)
#define HAS_LIPS 256        // Lips are drawn onto the mob icon (lipstick)
#define HAS_UNDERWEAR 512   // Underwear is drawn onto the mob icon
#define IS_PLANT 1024       // Is a treeperson
#define IS_WHITELISTED 2048 // Must be whitelisted to play
#define IS_SYNTHETIC 4096   // Is a machine race
#define HAS_EYE_COLOR 8192  // Eye colour selectable in chargen (RGB)
#define CAN_JOIN 16384      // Species is selectable in chargen
#define IS_RESTRICTED 32768 // Is not a core/normally playable species (castes, mutantraces)

//Language flags.
#define WHITELISTED 1  		// Language is available if the speaker is whitelisted.
#define RESTRICTED 2   		// Language can only be accquired by spawning or an admin.
#define NONVERBAL 4    		// Language has a significant non-verbal component. Speech is garbled without line-of-sight
#define SIGNLANG 8     		// Language is completely non-verbal. Speech is displayed through emotes for those who can understand.
#define HIVEMIND 16         // Broadcast to all mobs with this language.
#define NONGLOBAL 32		// Do not add to general languages list
#define INNATE 64			// All mobs can be assumed to speak and understand this language (audible emotes)
#define NO_TALK_MSG 128		// Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_STUTTER 256		// No stuttering, slurring, or other speech problems

//Flags for zone sleeping
#define ZONE_ACTIVE 1
#define ZONE_SLEEPING 0

//some colors
#define COLOR_RED 		"#FF0000"
#define COLOR_GREEN 	"#00FF00"
#define COLOR_BLUE 		"#0000FF"
#define COLOR_CYAN 		"#00FFFF"
#define COLOR_PINK 		"#FF00FF"
#define COLOR_YELLOW 	"#FFFF00"
#define COLOR_ORANGE 	"#FF9900"
#define COLOR_WHITE 	"#FFFFFF"

/*
	Germs and infections
*/

#define GERM_LEVEL_AMBIENT		110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP		200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE		100
#define INFECTION_LEVEL_TWO		500
#define INFECTION_LEVEL_THREE	1000

/*
	Shuttles
*/

// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLE_PREPTIME 				300	// 5 minutes = 300 seconds - after this time, the shuttle departs centcom and cannot be recalled
#define SHUTTLE_LEAVETIME 				180	// 3 minutes = 180 seconds - the duration for which the shuttle will wait at the station after arriving
#define SHUTTLE_TRANSIT_DURATION		300	// 5 minutes = 300 seconds - how long it takes for the shuttle to get to the station
#define SHUTTLE_TRANSIT_DURATION_RETURN 120	// 2 minutes = 120 seconds - for some reason it takes less time to come back, go figure.

//Shuttle moving status
#define SHUTTLE_IDLE		0
#define SHUTTLE_WARMUP		1
#define SHUTTLE_INTRANSIT	2

//Ferry shuttle processing status
#define IDLE_STATE		0
#define WAIT_LAUNCH		1
#define FORCE_LAUNCH	2
#define WAIT_ARRIVE		3
#define WAIT_FINISH		4

//computer3 error codes, move lower in the file when it passes dev -Sayu
 #define PROG_CRASH      1  // Generic crash
 #define MISSING_PERIPHERAL  2  // Missing hardware
 #define BUSTED_ASS_COMPUTER  4  // Self-perpetuating error.  BAC will continue to crash forever.
 #define MISSING_PROGRAM    8  // Some files try to automatically launch a program.  This is that failing.
 #define FILE_DRM      16  // Some files want to not be copied/moved.  This is them complaining that you tried.
 #define NETWORK_FAILURE  32

//Some on_mob_life() procs check for alien races.
#define IS_DIONA 1
#define IS_VOX 2
#define IS_SKRELL 3
#define IS_UNATHI 4
#define IS_XENOS 5

#define MAX_GEAR_COST 5 //Used in chargen for loadout limit.

/*
	Atmos Machinery
*/
#define MAX_SIPHON_FLOWRATE		2500	//L/s	This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE	200		//L/s	Max flow rate when scrubbing from a turf.

//These balance how easy or hard it is to create huge pressure gradients with pumps and filters. Lower values means it takes longer to create large pressures differences.
//Has no effect on pumping gasses from high pressure to low, only from low to high. Must be between 0 and 1.
#define ATMOS_PUMP_EFFICIENCY	2.5
#define ATMOS_FILTER_EFFICIENCY	2.5

//will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINUMUM_MOLES_TO_PUMP	0.01
#define MINUMUM_MOLES_TO_FILTER	0.1

//The flow rate/effectiveness of various atmos devices is limited by their internal volume, so for many atmos devices these will control maximum flow rates in L/s
#define ATMOS_DEFAULT_VOLUME_PUMP	200	//L
#define ATMOS_DEFAULT_VOLUME_FILTER	200	//L
#define ATMOS_DEFAULT_VOLUME_MIXER	200	//L
#define ATMOS_DEFAULT_VOLUME_PIPE	70	//L

// Reagent metabolism defines.
#define FOOD_METABOLISM 0.4
#define ALCOHOL_METABOLISM 0.1

//Chemistry

#define CHEM_SYNTH_ENERGY	500	//How much energy does it take to synthesize 1 unit of chemical, in J


#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1.#INF
#define BACKGROUND_ENABLED 0    // The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.
								// 1 will enable set background. 0 will disable set background.

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26

// Event defines.
#define EVENT_LEVEL_MUNDANE 1
#define EVENT_LEVEL_MODERATE 2
#define EVENT_LEVEL_MAJOR 3

// Suit sensor levels
#define SUIT_SENSOR_OFF 0
#define SUIT_SENSOR_BINARY 1
#define SUIT_SENSOR_VITAL 2
#define SUIT_SENSOR_TRACKING 3

//#define Clamp(x, y, z) 	(x <= y ? y : (x >= z ? z : x))

#define CLAMP01(x) 		(Clamp(x, 0, 1))

#define FOR_DVIEW(type, range, center, invis_flags) \
	dview_mob.loc = center; \
	dview_mob.see_invisible = invis_flags; \
	for(type in view(range, dview_mob))
#define END_FOR_DVIEW dview_mob.loc = null

// Fire.
#define FIRE_MIN_STACKS          -20
#define FIRE_MAX_STACKS           25
#define FIRE_MAX_FIRESUIT_STACKS  20 // If the number of stacks goes above this firesuits won't protect you anymore. If not, you can walk around while on fire like a badass.