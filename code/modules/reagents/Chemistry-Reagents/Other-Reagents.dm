/datum/reagent/blood
	data = new/list("donor"=null,"viruses"=null,"species"="Human","blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)
	name = "Blood"
	id = "blood"
	color = "#C80000" // rgb: 200, 0, 0

/datum/reagent/blood/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(data && data["viruses"])
		for(var/datum/disease/D in data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			// We don't spread.
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

			if(method == TOUCH)
				M.contract_disease(D)
			else //injected
				M.contract_disease(D, 1, 0)
	if(data && data["virus2"] && istype(M, /mob/living/carbon))//infecting...
		var/list/vlist = data["virus2"]
		if (vlist.len)
			for (var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]

				if(method == TOUCH)
					infect_virus2(M,V.getcopy())
				else
					infect_virus2(M,V.getcopy(),1) //injected, force infection!
	if(data && data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
		var/mob/living/carbon/C = M
		C.antibodies |= data["antibodies"]

/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["blood_colour"])
			color = data["blood_colour"]
		data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning, or else we won't know who's even getting cloned, etc
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				data["viruses"] = preserve
	return 1

/datum/reagent/blood/on_update(var/atom/A)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/reaction_turf(turf/simulated/T, reac_volume)//splash the blood all over the place
	if(!istype(T))
		return
	if((reac_volume < 3))
		return
	if(!data["donor"] || istype(data["donor"], /mob/living/carbon/human))
		blood_splatter(T,src,1)

	else if(istype(data["donor"], /mob/living/carbon/monkey))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,src,1)
		if(B) B.blood_DNA["Non-Human DNA"] = "A+"

	else if(istype(data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(T,src,1)
		if(B) B.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"

	return

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	color = "#C81040" // rgb: 200, 16, 64
/datum/reagent/vaccine/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(islist(data) && method == INGEST)
		for(var/datum/disease/D in M.viruses)
			if(D.GetDiseaseID() in data)
				D.cure()
		M.resistances |= data
/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()
#define WATER_LATENT_HEAT 19000 // How much heat is removed when applied to a hot turf, in J/unit (19000 makes 120 u of water roughly equivalent to 4L)
/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
//	var/cooling_temperature = 2
/*
 *	Water reaction to turf
 */
/datum/reagent/water/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	//If the turf is hot enough, remove some heat (ZAS)
	var/datum/gas_mixture/environment = T.return_air()
	var/min_temperature = T0C + 100	//100C, the boiling point of water

	if (environment && environment.temperature > min_temperature) //abstracted as steam or something
		var/removed_heat = between(0, volume*WATER_LATENT_HEAT, -environment.get_thermal_energy_change(min_temperature))
		environment.add_thermal_energy(-removed_heat)
		if (prob(5))
			T.visible_message("\red The water sizzles as it lands on \the [T]!")
	//var/CT = cooling_temperature (LINDA)
	if(reac_volume >= 10)
		T.MakeSlippery()
	for(var/mob/living/carbon/slime/S in T)
		S.apply_water()
	/* Put out fires (LINDA)
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !istype(T, /turf/space))
		if(T.air)
			var/datum/gas_mixture/G = T.air
			G.temperature = max(min(G.temperature-(CT*1000),G.temperature/CT),0)
			G.react()
			hotspot.Kill()
	return */
	//Put out fires. (FEA)
	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot)
		qdel(hotspot)
		if(environment)
			environment.react() //react at the new temperature

/*
 *	Water reaction to an object
 */
/datum/reagent/water/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/item))
		var/obj/item/Item = O
		Item.extinguish()

	// Fire. Remove this when the change to LINDA has been made
	var/turf/T = get_turf(O)
	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	// Monkey cube
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
/*	// Dehydrated carp #TOREMOVE - not implemented yet
	else if(istype(O,/obj/item/toy/carpplushie/dehy_carp))
		var/obj/item/toy/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp
	return */
/*
 *	Water reaction to a mob
 */
/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with water can help put them out!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
/datum/reagent/water/fishwater
	name = "Fish Water"
	id = "fishwater"
	description = "Smelly water from a fish tank. Gross!"
	color = "#757547"

/datum/reagent/water/fishwater/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST)
		if(!M.reagents.has_reagent("fishwater")) //It's not THAT big a deal, only say it once the first time it enters the mob.
			M << "<span class='warning'>That had a fishy aftertaste...</span>"
/datum/reagent/water/fishwater/on_mob_life(var/mob/living/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(0.5))		// Nasty, you drank this stuff? You'll probably be okay...but there's a small chance you throw up.
			H.vomit()
	..()
	return
/datum/reagent/water/holywater
	name = "Holy Water"
	id = "holywater"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239
/datum/reagent/water/holywater/on_mob_life(mob/living/M)
	if(!data) data = 1
	data++
	M.jitteriness = max(M.jitteriness-5,0)
	if(data >= 30)		// 12 units, 54 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 4
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(data >= 75 && prob(33))	// 30 units, 135 seconds
		if (!M.confused) M.confused = 1
		M.confused += 3
		if(iscultist(M))
			ticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(src.id, src.volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.jitteriness = 0
			M.stuttering = 0
			M.confused = 0
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue []'s eyes blink and become clearer.", M), 1) // So observers know it worked.
	holder.remove_reagent(src.id, 0.4)	//fixed consumption to prevent balancing going out of whack
	return
/datum/reagent/water/holywater/reaction_turf(turf/simulated/T, reac_volume)
	..()
	if(!istype(T)) return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()
/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	description = "Something that shouldn't exist on this plane of existance."
/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	M.adjustBrainLoss(3)
	if(iscultist(M))
		M.status_flags |= GOTTAGOFAST
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustParalysis(-2)
		M.AdjustStunned(-2)
		M.AdjustWeakened(-2)
	else
		M.adjustToxLoss(2)
		M.adjustFireLoss(2)
		M.adjustOxyLoss(2)
		M.adjustBruteLoss(2)
	holder.remove_reagent(src.id, 1)
/datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"
/datum/reagent/hellwater/on_mob_life(mob/living/M)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1)
	M.adjustFireLoss(1)		//Hence the other damages... ain't I a bastard?
	M.adjustBrainLoss(5)
	holder.remove_reagent(src.id, 1)
/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8" // rgb: 0, 156, 168
/datum/reagent/lube/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	if(reac_volume >= 1)
		T.MakeSlippery(2)
/*
/datum/reagent/spraytan
	name = "Spray Tan"
	id = "spraytan"
	description = "A substance applied to the skin to darken the skin."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
/datum/reagent/spraytan/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(istype(M, /mob/living/carbon/human))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/N = M
			if(N.dna.species.id == "human")
				switch(N.skin_tone)
					if("african1")
						N.skin_tone = "african2"
					if("indian")
						N.skin_tone = "african1"
					if("arab")
						N.skin_tone = "indian"
					if("asian2")
						N.skin_tone = "arab"
					if("asian1")
						N.skin_tone = "asian2"
					if("mediterranean")
						N.skin_tone = "african1"
					if("latino")
						N.skin_tone = "mediterranean"
					if("caucasian3")
						N.skin_tone = "mediterranean"
					if("caucasian2")
						N.skin_tone = pick("caucasian3", "latino")
					if("caucasian1")
						N.skin_tone = "caucasian2"
					if ("albino")
						N.skin_tone = "caucasian1"
			if(MUTCOLORS in N.dna.species.specflags) //take current alien color and darken it slightly
				var/newcolor = ""
				var/len = length(N.dna.features["mcolor"])
				for(var/i=1, i<=len, i+=1)
					var/ascii = text2ascii(N.dna.features["mcolor"],i)
					switch(ascii)
						if(48)		newcolor += "0"
						if(49 to 57)	newcolor += ascii2text(ascii-1)	//numbers 1 to 9
						if(97)		newcolor += "9"
						if(98 to 102)	newcolor += ascii2text(ascii-1)	//letters b to f lowercase
						if(65)		newcolor +="9"
						if(66 to 70)	newcolor += ascii2text(ascii+31)	//letters B to F - translates to lowercase
						else
							break
				N.dna.features["mcolor"] = newcolor
				N.regenerate_icons()
			N.update_body()
		if(method == INGEST)
			if(show_message)
				M << "<span class='notice'>That tasted horrible.</span>"
			M.AdjustStunned(2)
			M.AdjustWeakened(2)
	..()
/datum/reagent/spraytan/overdose_process(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/N = M
		if(N.dna.species.id == "human") // If they're human, turn em to the "orange" race, and give em spiky black hair
			N.skin_tone = "orange"
			N.h_style = "Spiky"
			N.h_color = "000"
			N.update_hair()
		if(MUTCOLORS in N.dna.species.specflags) //Aliens with custom colors simply get turned orange
			N.dna.features["mcolor"] = "f80"
			N.regenerate_icons()
		N.update_body()
		if(prob(7))
			if(N.w_uniform)
				M.visible_message(pick("<b>[M]</b>'s collar pops up without warning.</span>", "<b>[M]</b> flexes their arms."))
			else
				M.visible_message("<b>[M]</b> flexes their arms.")
	if(prob(10))
		M.say(pick("Check these sweet biceps bro!", "Deal with it.", "CHUG! CHUG! CHUG! CHUG!", "Winning!", "NERDS!", "My name is John and I hate every single one of you."))
	..()
	return
*/
/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
/datum/reagent/slimetoxin/on_mob_life(var/mob/living/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/human = M
		if(human.species.name != "Slime")
			M << "<span class='danger'>Your flesh rapidly mutates!</span>"
			human.set_species("Slime")
	..()
	return
/datum/reagent/unstableslimetoxin
	name = "Unstable Mutation Toxin"
	id = "unstablemutationtoxin"
	description = "An unstable and unpredictable corruptive toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY //So it instantly removes all of itself
	/* #TOREMOVE - not implemented yet
/datum/reagent/unstableslimetoxin/on_mob_life(mob/living/carbon/human/H)
	..()
	H << "<span class='warning'><b>You crumple in agony as your flesh wildly morphs into new forms!</b></span>"
	H.visible_message("<b>[H]</b> falls to the ground and screams as their skin bubbles and froths!") //'froths' sounds painful when used with SKIN.
	H.Weaken(3)
	sleep(30)
	var/list/blacklisted_species = list(/datum/species/zombie, /datum/species/skeleton, /datum/species/human, /datum/species/golem, /datum/species/golem/adamantine, /datum/species/shadow, /datum/species/shadow/ling, /datum/species/plasmaman, /datum/species)
	var/list/possible_morphs = typesof(/datum/species/) - blacklisted_species
	var/datum/species/mutation = pick(possible_morphs)
	if(prob(90) && mutation && H.dna.species != /datum/species/golem && H.dna.species != /datum/species/golem/adamantine)
		H << "<span class='danger'>The pain subsides. You feel... different.</span>"
		hardset_dna(H, null, null, null, null, mutation)
		H.regenerate_icons()
		if(mutation == /datum/species/slime)
			H.faction |= "slime"
		else
			H.faction -= "slime"
	else
		H << "<span class='danger'>The pain vanishes suddenly. You feel no different.</span>"
	return 1 */
/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
/datum/reagent/aslimetoxin/reaction_mob(mob/M, method=TOUCH, reac_volume)
	//if(method != TOUCH)
	//	M.ForceContractDisease(new /datum/disease/transformation/slime(0))
/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
/datum/reagent/serotrotium/on_mob_life(mob/living/M)
	if(ishuman(M))
		if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
	..()
	return
/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/oxygen/on_mob_life(mob/living/M, alien)
	if(M.stat == DEAD) return
	if(alien && alien == IS_VOX)
		M.adjustToxLoss(REAGENTS_METABOLISM)
		holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
		return
	..()
/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8
/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/nitrogen/on_mob_life(mob/living/M, alien)
	if(M.stat == DEAD) return
	if(alien && alien == IS_VOX)
		M.adjustOxyLoss(-2*REM)
		holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
		return
	..()
/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	color = "#484848" // rgb: 72, 72, 72
/datum/reagent/mercury/on_mob_life(mob/living/M)
	if(M.canmove && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)
	..()
	return
/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
/datum/reagent/carbon/reaction_turf(turf/T, reac_volume)
	if(!istype(T, /turf/space))
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
		if (!dirtoverlay)
			dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
			dirtoverlay.alpha = volume*30
		else
			dirtoverlay.alpha = min(dirtoverlay.alpha+volume*30, 255)
		dirtoverlay.reagents.add_reagent("carbon", reac_volume)
/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element with a characteristic odour."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/chlorine/on_mob_life(mob/living/M)
	M.take_organ_damage(1*REM, 0)
	..()
	return
/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/fluorine/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM)
	..()
	return
/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, sometimes used a mood stabilizer."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/lithium/on_mob_life(mob/living/M)
	if(M.canmove && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128
/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
/datum/reagent/radium/on_mob_life(mob/living/M)
	M.apply_effect(2*REM/M.metabolism_efficiency,IRRADIATE,0)
	// radium may increase your chances to cure a disease
	if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
		var/mob/living/carbon/C = M
		if(C.virus2.len)
			for (var/ID in C.virus2)
				var/datum/disease2/disease/V = C.virus2[ID]
				if(prob(5))
					M:antibodies |= V.antigen
					if(prob(50))
						M.radiation += 50 // curing it that way may kill you instead
						var/absorbed = 0
						if(istype(C,/mob/living/carbon))
							var/mob/living/carbon/H = C
							var/obj/item/organ/diona/nutrients/rad_organ = locate() in H.internal_organs
							if(rad_organ && !rad_organ.is_broken())
								absorbed = 1
							if(!absorbed)
								M.adjustToxLoss(100)
	..()
	return
/datum/reagent/radium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				glow = new/obj/effect/decal/cleanable/greenglow(T)
			glow.reagents.add_reagent("radium", reac_volume)
/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC" // rgb: 200, 165, 220

//makes you squeaky clean
/datum/reagent/sterilizine/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if (method == TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/sterilizine/reaction_obj(var/obj/O, var/volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/sterilizine/reaction_turf(var/turf/T, var/volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/sterilizine/on_mob_life(var/mob/living/M as mob)
	M.radiation += 3
	..()
/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
/datum/reagent/uranium/on_mob_life(mob/living/M)
	M.apply_effect(1/M.metabolism_efficiency,IRRADIATE,0)
	..()
/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
			if(!glow)
				glow = new/obj/effect/decal/cleanable/greenglow(T)
			glow.reagents.add_reagent("radium", reac_volume)
/datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
/datum/reagent/fuel
	name = "Welding fuel"
	id = "welding_fuel"
	description = "Required for welders. Flammable."
	color = "#660000" // rgb: 102, 0, 0
/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return
	..()
/datum/reagent/fuel/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	..()
/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	color = "#A5F0EE" // rgb: 165, 240, 238
/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.clean_blood()
/datum/reagent/space_cleaner/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 1)
		if(istype(T, /turf/simulated))
			var/turf/simulated/S = T
			S.dirt = 0
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5,10))
/datum/reagent/space_cleaner/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(method == TOUCH || VAPOR)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.lip_style)
					H.lip_style = null
					H.update_body()
			if(C.r_hand)
				C.r_hand.clean_blood()
			if(C.l_hand)
				C.l_hand.clean_blood()
			if(C.wear_mask)
				if(C.wear_mask.clean_blood())
					C.update_inv_wear_mask()
			if(ishuman(M))
				var/mob/living/carbon/human/H = C
				if(H.head)
					if(H.head.clean_blood())
						H.update_inv_head()
				if(H.wear_suit)
					if(H.wear_suit.clean_blood())
						H.update_inv_wear_suit()
				else if(H.w_uniform)
					if(H.w_uniform.clean_blood())
						H.update_inv_w_uniform()
				if(H.shoes)
					if(H.shoes.clean_blood())
						H.update_inv_shoes()
				else
					H.clean_blood(1)
					return
			M.clean_blood()
/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizzyness."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
/datum/reagent/cryptobiolin/on_mob_life(mob/living/M)
	M.Dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)
	..()
	return
/datum/reagent/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#C8A5DC" // rgb: 200, 165, 220
/datum/reagent/impedrezene/on_mob_life(mob/living/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80)) M.adjustBrainLoss(1*REM)
	if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
	if(prob(10)) M.emote("drool")
	..()
	return
/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102
/datum/reagent/nanites/reaction_mob(mob/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
//		M.ForceContractDisease(new /datum/disease/transformation/robot(0)) #TOREMOVE
		M.contract_disease(new /datum/disease/robotic_transformation(0),1)
/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
/datum/reagent/xenomicrobes/reaction_mob(mob/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
//		M.ContractDisease(new /datum/disease/transformation/xeno(0)) #TOREMOVE
		M.contract_disease(new /datum/disease/xeno_transformation(0),1)
/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38" // rgb: 158, 107, 56
/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
/datum/reagent/ultraglue
	name = "Ultra Glue"
	id = "glue"
	description = "An extremely powerful bonding agent."
	color = "#FFFFCC" // rgb: 255, 255, 204
/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030" // rgb: 96, 64, 48
/datum/reagent/ethylredoxrazine	// FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72
/datum/reagent/ethylredoxrazine/on_mob_life(var/mob/living/M as mob)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 1*REM, 0, 1)
	..()
	return
/////////////////////////Coloured Crayon Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents
/datum/reagent/crayonpowder
	name = "Crayon Powder"
	id = "crayon powder"
	var/colorname = "none"
	description = "A powder made by grinding down crayons, good for colouring chemical reagents."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0
/datum/reagent/crayonpowder/New()
	description = "\an [colorname] powder made by grinding down crayons, good for colouring chemical reagents."
/datum/reagent/crayonpowder/red
	name = "Red Crayon Powder"
	id = "redcrayonpowder"
	colorname = "red"
/datum/reagent/crayonpowder/orange
	name = "Orange Crayon Powder"
	id = "orangecrayonpowder"
	colorname = "orange"
	color = "#FF9300" // orange
/datum/reagent/crayonpowder/yellow
	name = "Yellow Crayon Powder"
	id = "yellowcrayonpowder"
	colorname = "yellow"
	color = "#FFF200" // yellow
/datum/reagent/crayonpowder/green
	name = "Green Crayon Powder"
	id = "greencrayonpowder"
	colorname = "green"
	color = "#A8E61D" // green
/datum/reagent/crayonpowder/blue
	name = "Blue Crayon Powder"
	id = "bluecrayonpowder"
	colorname = "blue"
	color = "#00B7EF" // blue
/datum/reagent/crayonpowder/purple
	name = "Purple Crayon Powder"
	id = "purplecrayonpowder"
	colorname = "purple"
	color = "#DA00FF" // purple
/datum/reagent/crayonpowder/invisible
	name = "Invisible Crayon Powder"
	id = "invisiblecrayonpowder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
//////////////////////////////////Hydroponics stuff///////////////////////////////
/datum/reagent/plantnutriment
	name = "Generic nutriment"
	id = "plantnutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
/datum/reagent/plantnutriment/on_mob_life(mob/living/M)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REM)
	..()
	return
/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	id = "eznutriment"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10
/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	id = "left4zednutriment"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 25
/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	id = "robustharvestnutriment"
	description = "Very potent nutriment that prevents plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15
// GOON OTHERS
/datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	color = "#C8A5DC"
	/*
/datum/reagent/stable_plasma
	name = "Stable Plasma"
	id = "stable_plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/stable_plasma/on_mob_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(10)
	..()
	return
	*/
/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/carpet/reaction_turf(turf/simulated/T, reac_volume)
	if(istype(T, /turf/simulated/floor/plating))
		var/turf/simulated/floor/F = T
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()
	return
/datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "Used for certain medical recipes."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Basic ingredient in a couple of recipes."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "Common ingredient in other recipes."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()
	return
/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()
/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.color = pick(random_color_list)
	..()
/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.color = pick(random_color_list)
	..()
/*
/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0") // fucking hair code
/datum/reagent/hair_dye/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_color = pick(potential_colors)
			H.facial_hair_color = pick(potential_colors)
			H.update_hair()
/datum/reagent/barbers_aid
	name = "Barber's Aid"
	id = "barbers_aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/sprite_accessory/hair/picked_hair = pick(hair_styles_list)
			var/datum/sprite_accessory/facial_hair/picked_beard = pick(facial_hair_styles_list)
			H.hair_style = picked_hair
			H.facial_hair_style = picked_beard
			H.update_hair()
/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	id = "concentrated_barbers_aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
/datum/reagent/concentrated_barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Very Long Hair"
			H.facial_hair_style = "Very Long Beard"
			H.update_hair()
*/
/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	description = "Volatile."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
/datum/reagent/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	description = "Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
/datum/reagent/drying_agent/reaction_turf(turf/simulated/T, reac_volume)
	if(istype(T) && T.wet)
		T.MakeDry(TURF_WET_WATER)
/datum/reagent/drying_agent/reaction_obj(obj/O, reac_volume)
	if(O.type == /obj/item/clothing/shoes/galoshes)
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)


datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "It's pure liquid colors. That's a thing now."
	reagent_state = LIQUID
	color = "#FFFFFF"

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1)
	result_amount = 6
	mix_message = "The substance flashes multiple colors and emits the smell of a pocket protector."

datum/reagent/colorful_reagent/reaction_mob(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
    if(M && istype(M))
        M.color = pick(random_color_list)
    ..()
    return

datum/reagent/colorful_reagent/reaction_obj(var/obj/O, var/volume)
	if(O)
		O.color = pick(random_color_list)
	..()
	return
datum/reagent/colorful_reagent/reaction_turf(var/turf/T, var/volume)
	if(T)
		T.color = pick(random_color_list)
	..()
	return

datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "A rather tubular and gnarly way of coloring totally bodacious hair. Duuuudddeee."
	reagent_state = LIQUID
	color = "#960096"

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "hairgrownium" = 1)
	result_amount = 2

datum/reagent/hair_dye/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.r_facial = rand(0,255)
		H.g_facial = rand(0,255)
		H.b_facial = rand(0,255)
		H.r_hair = rand(0,255)
		H.g_hair = rand(0,255)
		H.b_hair = rand(0,255)
		H.update_hair()
	..()
	return

datum/reagent/hairgrownium
	name = "Hairgrownium"
	id = "hairgrownium"
	description = "A mysterious chemical purported to help grow hair. Often found on late-night TV infomercials."
	reagent_state = LIQUID
	color = "#5DDA5D"
	penetrates_skin = 1

/datum/chemical_reaction/hairgrownium
	name = "hairgrownium"
	id = "hairgrownium"
	result = "hairgrownium"
	required_reagents = list("synthflesh" = 1, "ephedrine" = 1)
	result_amount = 3
	mix_message = "The liquid becomes slightly hairy."

datum/reagent/hairgrownium/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.h_style = random_hair_style(H.gender, H.species)
		H.f_style = random_facial_hair_style(H.gender, H.species)
		H.update_hair()
	..()
	return

datum/reagent/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	description = "A mysterious and powerful chemical purported to cause rapid hair growth."
	reagent_state = LIQUID
	color = "#5DD95D"
	penetrates_skin = 1


/datum/chemical_reaction/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	result = "super_hairgrownium"
	required_reagents = list("iron" = 1, "methamphetamine" = 1, "hairgrownium" = 1)
	result_amount = 3
	mix_message = "The liquid becomes amazingly furry and smells peculiar."

datum/reagent/super_hairgrownium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.h_style = "Very Long Hair"
		H.f_style = "Very Long Beard"
		H.update_hair()
		if(!H.wear_mask || H.wear_mask && !istype(H.wear_mask, /obj/item/clothing/mask/fakemoustache))
			if(H.wear_mask)
				H.unEquip(H.wear_mask)
			var/obj/item/clothing/mask/fakemoustache = new /obj/item/clothing/mask/fakemoustache
			H.equip_to_slot(fakemoustache, slot_wear_mask)
			H << "<span class = 'notice'>Hair bursts forth from your every follicle!"
	..()
	return