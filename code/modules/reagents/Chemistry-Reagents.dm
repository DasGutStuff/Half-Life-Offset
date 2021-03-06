#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/can_synth = 1
	var/metabolization_rate = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/custom_metabolism = REAGENTS_METABOLISM
	var/overrides_metab = 0
	var/penetrates_skin = 0 //Whether or not a reagent penetrates the skin
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/overdosed = 0 // You fucked up and this is now triggering its overdose effects, purge that shit quick.

	//Old vars - #TOREMOVE
	var/scannable = 0 //shows up on health analyzers
	var/glass_center_of_mass = null


/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	if(method == VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = Clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 1)
				M.reagents.add_reagent(id, amount)

		if(method == TOUCH && penetrates_skin)
			if(isliving(M))
				var/mob/living/L = M
				var/block  = L.get_permeability_protection()
				var/amount = round(volume * (1.0 - block), 0.1)
				if(L.reagents)
					if(amount >= 1)
						L.reagents.add_reagent(id,amount)
	return 1


/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(src.id, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return

// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/M)
	return

/datum/reagent/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_update(atom/A)
	return

// Called every time reagent containers process.
/datum/reagent/proc/on_tick(data)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M)
	return

/datum/reagent/proc/overdose_start(mob/living/M)
	M << "<span class='userdanger'>You feel like you took too much of [name]!</span>"
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like some [name] right about now.</span>"
	return

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M << "<span class='notice'>You feel like you need [name]. You just can't get enough.</span>"
	return

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(prob(30))
		M << "<span class='danger'>You have an intense craving for [name].</span>"
	return

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(prob(30))
		M << "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>"
	return

/proc/pretty_string_from_reagent_list(var/list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/result = "| "
	for (var/datum/reagent/R in reagent_list)
		result += "[R.name], [R.volume] | "

	return result

//OLD CHEM


/*
			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!istype(M, /mob/living))
					return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
				if( (overdose > 0) && (volume >= overdose))//Overdosing, wooo
					M.adjustToxLoss(overdose_dam)
				holder.remove_reagent(src.id, custom_metabolism) //By default it slowly disappears.
				return
*/
/*
		vaccine
			//data must contain virus type
			name = "Vaccine"
			id = "vaccine"
			reagent_state = LIQUID
			color = "#C81040" // rgb: 200, 16, 64

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				var/datum/reagent/vaccine/self = src
				src = null
				if(self.data&&method == INGEST)
					for(var/datum/disease/D in M.viruses)
						if(istype(D, /datum/disease/advance))
							var/datum/disease/advance/A = D
							if(A.GetDiseaseID() == self.data)
								D.cure()
						else
							if(D.type == self.data)
								D.cure()

					M.resistances += self.data
				return

		#define WATER_LATENT_HEAT 19000 // How much heat is removed when applied to a hot turf, in J/unit (19000 makes 120 u of water roughly equivalent to 4L)
		water
			name = "Water"
			id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID
			color = "#0064C8" // rgb: 0, 100, 200
			custom_metabolism = 0.01

			glass_icon_state = "glass_clear"
			glass_name = "glass of water"
			glass_desc = "The father of all refreshments."

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return

				//If the turf is hot enough, remove some heat
				var/datum/gas_mixture/environment = T.return_air()
				var/min_temperature = T0C + 100	//100C, the boiling point of water

				if (environment && environment.temperature > min_temperature) //abstracted as steam or something
					var/removed_heat = between(0, volume*WATER_LATENT_HEAT, -environment.get_thermal_energy_change(min_temperature))
					environment.add_thermal_energy(-removed_heat)
					if (prob(5))
						T.visible_message("\red The water sizzles as it lands on \the [T]!")

				else //otherwise, the turf gets wet
					if(volume >= 3)
						if(T.wet >= 1) return
						T.wet = 1
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
						T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
						T.overlays += T.wet_overlay

						src = null
						spawn(800)
							if (!istype(T)) return
							if(T.wet >= 2) return
							T.wet = 0
							if(T.wet_overlay)
								T.overlays -= T.wet_overlay
								T.wet_overlay = null

				//Put out fires.
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot)
					qdel(hotspot)
					if(environment)
						environment.react() //react at the new temperature

			reaction_obj(var/obj/O, var/volume)
				var/turf/T = get_turf(O)
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot && !istype(T, /turf/space))
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
				if(istype(O,/obj/item))
					var/obj/item/Item = O
					Item.extinguish()
				if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
					var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
					if(!cube.wrapped)
						cube.Expand()

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(-(volume / 10))
				if (istype(M, /mob/living/carbon/slime))
					var/mob/living/carbon/slime/S = M
					S.apply_water()
				..()

		water/fishwater
			name = "Fish Water"
			id = "fishwater"
			description = "Smelly water from a fish tank. Gross!"
			color = "#757547"

			glass_icon_state = "glass_clear"
			glass_name = "glass of fish water"
			glass_desc = "This smells funny. Did you get it from a fish tank?"

		water/fishwater/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
			if(!istype(M, /mob/living))
				return
			if(method == INGEST)
				if(!M.reagents.has_reagent("fishwater")) //It's not THAT big a deal, only say it once the first time it enters the mob.
					M << "Oh god, why did you drink that?"
		water/fishwater/on_mob_life(var/mob/living/M as mob)
			if(!M) M = holder.my_atom
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(prob(0.3))		// Nasty, you drank this stuff? You'll probably be okay...but there's a small chance you throw up.
					H.vomit()
				..()
				return

		water/holywater
			name = "Holy Water"
			id = "holywater"
			description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
			color = "#E0E8EF" // rgb: 224, 232, 239

			glass_icon_state = "glass_clear"
			glass_name = "glass of holy water"
			glass_desc = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."

			on_mob_life(var/mob/living/M as mob)
				if(ishuman(M))
					if((M.mind in ticker.mode.cult) && prob(10))
						M << "\blue A cooling sensation from inside you brings you an untold calmness."
						ticker.mode.remove_cultist(M.mind)
						for(var/mob/O in viewers(M, null))
							O.show_message(text("\blue []'s eyes blink and become clearer.", M), 1) // So observers know it worked.
				holder.remove_reagent(src.id, 10 * REAGENTS_METABOLISM) //high metabolism to prevent extended uncult rolls.
				return */
/*
		lube
			name = "Space Lube"
			id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
			reagent_state = LIQUID
			color = "#009CA8" // rgb: 0, 156, 168
			overdose = REAGENTS_OVERDOSE

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 1)
					if(T.wet >= 2) return
					T.wet = 2
					spawn(800)
						if (!istype(T)) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
						return

		plasticide
			name = "Plasticide"
			id = "plasticide"
			description = "Liquid plastic, do not eat."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				// Toxins are really weak, but without being treated, last very long.
				M.adjustToxLoss(0.2)
				..()
				return

		slimetoxin
			name = "Mutation Toxin"
			id = "mutationtoxin"
			description = "A corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/human = M
					if(human.species.name != "Slime")
						M << "<span class='danger'>Your flesh rapidly mutates!</span>"
						human.set_species("Slime")
				..()
				return

		aslimetoxin
			name = "Advanced Mutation Toxin"
			id = "amutationtoxin"
			description = "An advanced corruptive toxin produced by slimes."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(istype(M, /mob/living/carbon) && M.stat != DEAD)
					M << "\red Your flesh rapidly mutates!"
					if(M.monkeyizing)	return
					M.monkeyizing = 1
					M.canmove = 0
					M.icon = null
					M.overlays.Cut()
					M.invisibility = 101
					for(var/obj/item/W in M)
						if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
							qdel(W)
							continue
						W.layer = initial(W.layer)
						W.loc = M.loc
						W.dropped(M)
					var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
					new_mob.a_intent = "hurt"
					new_mob.universal_speak = 1
					if(M.mind)
						M.mind.transfer_to(new_mob)
					else
						new_mob.key = M.key
					qdel(M)
				..()
				return
*/
/*
		inaprovaline
			name = "Inaprovaline"
			id = "inaprovaline"
			description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
			reagent_state = LIQUID
			color = "#00BFFF" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE*2
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
				else
					if(M.losebreath >= 10)
						M.losebreath = max(10, M.losebreath-5)

				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				return
*/
/*
		serotrotium
			name = "Serotrotium"
			id = "serotrotium"
			description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
			reagent_state = LIQUID
			color = "#202040" // rgb: 20, 20, 40
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(ishuman(M))
					if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
					holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)
				return
*/
/*		silicate
			name = "Silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			color = "#C7FFFF" // rgb: 199, 255, 255

			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/structure/window))
					if(O:silicate <= 200)

						O:silicate += volume
						O:health += volume * 3

						if(!O:silicateIcon)
							var/icon/I = icon(O.icon,O.icon_state,O.dir)

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I
						else
							var/icon/I = O:silicateIcon

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I

				return*/
/*
		oxygen
			name = "Oxygen"
			id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustToxLoss(REAGENTS_METABOLISM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		copper
			name = "Copper"
			id = "copper"
			description = "A highly ductile metal."
			color = "#6E3B08" // rgb: 110, 59, 8

			custom_metabolism = 0.01

		nitrogen
			name = "Nitrogen"
			id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2) return
				if(alien && alien == IS_VOX)
					M.adjustOxyLoss(-2*REM)
					holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
					return
				..()

		hydrogen
			name = "Hydrogen"
			id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		potassium
			name = "Potassium"
			id = "potassium"
			description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID
			color = "#A0A0A0" // rgb: 160, 160, 160

			custom_metabolism = 0.01

		mercury
			name = "Mercury"
			id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID
			color = "#484848" // rgb: 72, 72, 72
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				M.adjustBrainLoss(2)
				..()
				return

		sulfur
			name = "Sulfur"
			id = "sulfur"
			description = "A chemical element with a pungent smell."
			reagent_state = SOLID
			color = "#BF8C00" // rgb: 191, 140, 0

			custom_metabolism = 0.01

		carbon
			name = "Carbon"
			id = "carbon"
			description = "A chemical element, the builing block of life."
			reagent_state = SOLID
			color = "#1C1300" // rgb: 30, 20, 0

			custom_metabolism = 0.01

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
					if (!dirtoverlay)
						dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
						dirtoverlay.alpha = volume*30
					else
						dirtoverlay.alpha = min(dirtoverlay.alpha+volume*30, 255)

		chlorine
			name = "Chlorine"
			id = "chlorine"
			description = "A chemical element with a characteristic odour."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.take_organ_damage(1*REM, 0)
				..()
				return

		fluorine
			name = "Fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1*REM)
				..()
				return

		sodium
			name = "Sodium"
			id = "sodium"
			description = "A chemical element, readily reacts with water."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		phosphorus
			name = "Phosphorus"
			id = "phosphorus"
			description = "A chemical element, the backbone of biological energy carriers."
			reagent_state = SOLID
			color = "#832828" // rgb: 131, 40, 40

			custom_metabolism = 0.01

		lithium
			name = "Lithium"
			id = "lithium"
			description = "A chemical element, used as antidepressant."
			reagent_state = SOLID
			color = "#808080" // rgb: 128, 128, 128
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
					step(M, pick(cardinal))
				if(prob(5)) M.emote(pick("twitch","drool","moan"))
				..()
				return
		glycerol
			name = "Glycerol"
			id = "glycerol"
			description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		nitroglycerin
			name = "Nitroglycerin"
			id = "nitroglycerin"
			description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
			reagent_state = LIQUID
			color = "#808080" // rgb: 128, 128, 128

			custom_metabolism = 0.01

		radium
			name = "Radium"
			id = "radium"
			description = "Radium is an alkaline earth metal. It is extremely radioactive."
			reagent_state = SOLID
			color = "#C7C7C7" // rgb: 199,199,199

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.apply_effect(2*REM,IRRADIATE,0)
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

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
						if(!glow)
							new /obj/effect/decal/cleanable/greenglow(T)
						return

*/
/*
		ryetalyn
			name = "Ryetalyn"
			id = "ryetalyn"
			description = "Ryetalyn can cure all genetic abnomalities via a catalytic process."
			reagent_state = SOLID
			color = "#004000" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom

				var/needs_update = M.mutations.len > 0

				M.mutations = list()
				M.disabilities = 0
				M.sdisabilities = 0

				// Might need to update appearance for hulk etc.
				if(needs_update && ishuman(M))
					var/mob/living/carbon/human/H = M
					H.update_mutations()

				..()
				return

		thermite
			name = "Thermite"
			id = "thermite"
			description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
			reagent_state = SOLID
			color = "#673910" // rgb: 103, 57, 16

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5)
					if(istype(T, /turf/simulated/wall))
						var/turf/simulated/wall/W = T
						W.thermite = 1
						W.overlays += image('icons/effects/effects.dmi',icon_state = "#673910")
				return

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustFireLoss(1)
				..()
				return

		paracetamol
			name = "Paracetamol"
			id = "paracetamol"
			description = "Most probably know this as Tylenol, but this chemical is a mild, simple painkiller."
			reagent_state = LIQUID
			color = "#C8A5DC"
			overdose = 60
			scannable = 1
			custom_metabolism = 0.025 // Lasts 10 minutes for 15 units

			on_mob_life(var/mob/living/M as mob)
				if (volume > overdose)
					M.hallucination = max(M.hallucination, 2)
				..()
				return

		tramadol
			name = "Tramadol"
			id = "tramadol"
			description = "A simple, yet effective painkiller."
			reagent_state = LIQUID
			color = "#CB68FC"
			overdose = 30
			scannable = 1
			custom_metabolism = 0.025 // Lasts 10 minutes for 15 units

			on_mob_life(var/mob/living/M as mob)
				if (volume > overdose)
					M.hallucination = max(M.hallucination, 2)
				..()
				return

		oxycodone
			name = "Oxycodone"
			id = "oxycodone"
			description = "An effective and very addictive painkiller."
			reagent_state = LIQUID
			color = "#800080"
			overdose = 20
			custom_metabolism = 0.25 // Lasts 10 minutes for 15 units

			on_mob_life(var/mob/living/M as mob)
				if (volume > overdose)
					M.druggy = max(M.druggy, 10)
					M.hallucination = max(M.hallucination, 3)
				..()
				return

*/

/*		sterilizine
			name = "Sterilizine"
			id = "sterilizine"
			description = "Sterilizes wounds in preparation for surgery."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			//makes you squeaky clean
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				if (method == TOUCH)
					M.germ_level -= min(volume*20, M.germ_level)

			reaction_obj(var/obj/O, var/volume)
				O.germ_level -= min(volume*20, O.germ_level)

			reaction_turf(var/turf/T, var/volume)
				T.germ_level -= min(volume*20, T.germ_level)

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				src = null
				if (method==TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M.health >= -100 && M.health <= 0)
							M.crit_op_stage = 0.0
				if (method==INGEST)
					usr << "Well, that was stupid."
					M.adjustToxLoss(3)
				return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
					M.radiation += 3
					..()
					return
	*/
/*		iron
			name = "Iron"
			id = "iron"
			description = "Pure iron is a metal."
			reagent_state = SOLID
			color = "#353535"
			overdose = REAGENTS_OVERDOSE

		gold
			name = "Gold"
			id = "gold"
			description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
			reagent_state = SOLID
			color = "#F7C430" // rgb: 247, 196, 48

		silver
			name = "Silver"
			id = "silver"
			description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
			reagent_state = SOLID
			color = "#D0D0D0" // rgb: 208, 208, 208

		uranium
			name ="Uranium"
			id = "uranium"
			description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
			reagent_state = SOLID
			color = "#B8B8C0" // rgb: 184, 184, 192

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.apply_effect(1,IRRADIATE,0)
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(!istype(T, /turf/space))
						var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
						if(!glow)
							new /obj/effect/decal/cleanable/greenglow(T)
						return

		aluminum
			name = "Aluminum"
			id = "aluminum"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		silicon
			name = "Silicon"
			id = "silicon"
			description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID
			color = "#A8A8A8" // rgb: 168, 168, 168

		fuel
			name = "Welding fuel"
			id = "fuel"
			description = "Required for welders. Flamable."
			reagent_state = LIQUID
			color = "#660000" // rgb: 102, 0, 0
			overdose = REAGENTS_OVERDOSE

			glass_icon_state = "dr_gibb_glass"
			glass_name = "glass of welder fuel"
			glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."

			reaction_obj(var/obj/O, var/volume)
				var/turf/the_turf = get_turf(O)
				if(!the_turf)
					return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
				new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)
			reaction_turf(var/turf/T, var/volume)
				new /obj/effect/decal/cleanable/liquid_fuel(T, volume)
				return
			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with welding fuel to make them easy to ignite!)
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					M.adjust_fire_stacks(volume / 10)
					return
			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustToxLoss(1)
				..()
				return

		space_cleaner
			name = "Space cleaner"
			id = "cleaner"
			description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
			reagent_state = LIQUID
			color = "#A5F0EE" // rgb: 165, 240, 238
			overdose = REAGENTS_OVERDOSE

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/decal/cleanable))
					qdel(O)
				else
					if(O)
						O.clean_blood()

			reaction_turf(var/turf/T, var/volume)
				if(volume >= 1)
					if(istype(T, /turf/simulated))
						var/turf/simulated/S = T
						S.dirt = 0
					T.clean_blood()
					for(var/obj/effect/decal/cleanable/C in T.contents)
						src.reaction_obj(C, volume)
						qdel(C)

					for(var/mob/living/carbon/slime/M in T)
						M.adjustToxLoss(rand(5,10))

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(C.r_hand)
						C.r_hand.clean_blood()
					if(C.l_hand)
						C.l_hand.clean_blood()
					if(C.wear_mask)
						if(C.wear_mask.clean_blood())
							C.update_inv_wear_mask(0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = C
						if(H.head)
							if(H.head.clean_blood())
								H.update_inv_head(0)
						if(H.wear_suit)
							if(H.wear_suit.clean_blood())
								H.update_inv_wear_suit(0)
						else if(H.w_uniform)
							if(H.w_uniform.clean_blood())
								H.update_inv_w_uniform(0)
						if(H.shoes)
							if(H.shoes.clean_blood())
								H.update_inv_shoes(0)
						else
							H.clean_blood(1)
							return
					M.clean_blood()
*/
/*
		leporazine
			name = "Leporazine"
			id = "leporazine"
			description = "Leporazine can be use to stabilize an individuals body temperature."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
				else if(M.bodytemperature < 311)
					M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
				..()
				return
*/
/*		cryptobiolin
			name = "Cryptobiolin"
			id = "cryptobiolin"
			description = "Cryptobiolin causes confusion and dizzyness."
			reagent_state = LIQUID
			color = "#000055" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.make_dizzy(1)
				if(!M.confused) M.confused = 1
				M.confused = max(M.confused, 20)
				holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
				..()
				return
*/
/*
		kelotane
			name = "Kelotane"
			id = "kelotane"
			description = "Kelotane is a drug used to treat burns."
			reagent_state = LIQUID
			color = "#FFA800" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				//This needs a diona check but if one is added they won't be able to heal burn damage at all.
				M.heal_organ_damage(0,2*REM)
				..()
				return

		dermaline
			name = "Dermaline"
			id = "dermaline"
			description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
			reagent_state = LIQUID
			color = "#FF8000" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE/2
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
					return
				if(!M) M = holder.my_atom
				if(!alien || alien != IS_DIONA)
					M.heal_organ_damage(0,3*REM)
				..()
				return

		dexalin
			name = "Dexalin"
			id = "dexalin"
			description = "Dexalin is used in the treatment of oxygen deprivation."
			reagent_state = LIQUID
			color = "#0080FF" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustToxLoss(2*REM)
				else if(!alien || alien != IS_DIONA)
					M.adjustOxyLoss(-2*REM)

				holder.remove_reagent("lexorin", 2*REM)
				..()
				return

		dexalinp
			name = "Dexalin Plus"
			id = "dexalinp"
			description = "Dexalin Plus is used in the treatment of oxygen deprivation. It is highly effective."
			reagent_state = LIQUID
			color = "#0040FF" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE/2
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom

				if(alien && alien == IS_VOX)
					M.adjustOxyLoss()
				else if(!alien || alien != IS_DIONA)
					M.adjustOxyLoss(-M.getOxyLoss())

				holder.remove_reagent("lexorin", 2*REM)
				..()
				return

		tricordrazine
			name = "Tricordrazine"
			id = "tricordrazine"
			description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			color = "#8040FF" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(!alien || alien != IS_DIONA)
					if(M.getOxyLoss()) M.adjustOxyLoss(-1*REM)
					if(M.getBruteLoss() && prob(80)) M.heal_organ_damage(1*REM,0)
					if(M.getFireLoss() && prob(80)) M.heal_organ_damage(0,1*REM)
					if(M.getToxLoss() && prob(80)) M.adjustToxLoss(-1*REM)
				..()
				return

		antitoxin
			name = "Dylovene"
			id = "antitoxin"
			description = "Dylovene is a broad-spectrum antitoxin."
			reagent_state = LIQUID
			color = "#00A000" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(!M) M = holder.my_atom
				if(!alien || alien != IS_DIONA)
					M.reagents.remove_all_type(/datum/reagent/toxin, 1*REM, 0, 1)
					M.drowsyness = max(M.drowsyness-2*REM, 0)
					M.hallucination = max(0, M.hallucination - 5*REM)
					M.adjustToxLoss(-2*REM)
				..()
				return

		adminordrazine //An OP chemical for admins
			name = "Adminordrazine"
			id = "adminordrazine"
			description = "It's magic. We don't have to explain it."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			glass_icon_state = "golden_cup"
			glass_name = "golden cup"
			glass_desc = "It's magic. We don't have to explain it."

			on_mob_life(var/mob/living/carbon/M as mob)
				if(!M) M = holder.my_atom ///This can even heal dead people.
				M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
				M.setCloneLoss(0)
				M.setOxyLoss(0)
				M.radiation = 0
				M.heal_organ_damage(5,5)
				M.adjustToxLoss(-5)
				M.hallucination = 0
				M.setBrainLoss(0)
				M.disabilities = 0
				M.sdisabilities = 0
				M.eye_blurry = 0
				M.eye_blind = 0
				M.SetWeakened(0)
				M.SetStunned(0)
				M.SetParalysis(0)
				M.silent = 0
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				M.sleeping = 0
				M.jitteriness = 0
				for(var/datum/disease/D in M.viruses)
					D.spread = "Remissive"
					D.stage--
					if(D.stage < 1)
						D.cure()
				..()
				return
		synaptizine

			name = "Synaptizine"
			id = "synaptizine"
			description = "Synaptizine is used to treat various diseases."
			reagent_state = LIQUID
			color = "#99CCFF" // rgb: 200, 165, 220
			custom_metabolism = 0.01
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				holder.remove_reagent("mindbreaker", 5)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))	M.adjustToxLoss(1)
				..()
				return

		impedrezene
			name = "Impedrezene"
			id = "impedrezene"
			description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-5,0)
				if(prob(80)) M.adjustBrainLoss(1*REM)
				if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
				if(prob(10)) M.emote("drool")
				..()
				return

		hyronalin
			name = "Hyronalin"
			id = "hyronalin"
			description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
			reagent_state = LIQUID
			color = "#408000" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.radiation = max(M.radiation-3*REM,0)
				..()
				return

		arithrazine
			name = "Arithrazine"
			id = "arithrazine"
			description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
			reagent_state = LIQUID
			color = "#008000" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(M.stat == 2.0)
					return  //See above, down and around. --Agouri
				if(!M) M = holder.my_atom
				M.radiation = max(M.radiation-7*REM,0)
				M.adjustToxLoss(-1*REM)
				if(prob(15))
					M.take_organ_damage(1, 0)
				..()
				return

		alkysine
			name = "Alkysine"
			id = "alkysine"
			description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
			reagent_state = LIQUID
			color = "#FFFF66" // rgb: 200, 165, 220
			custom_metabolism = 0.05
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustBrainLoss(-3*REM)
				..()
				return

		imidazoline
			name = "Imidazoline"
			id = "imidazoline"
			description = "Heals eye damage"
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.eye_blurry = max(M.eye_blurry-5 , 0)
				M.eye_blind = max(M.eye_blind-5 , 0)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
					if(E && istype(E))
						if(E.damage > 0)
							E.damage = max(E.damage - 1, 0)
				..()
				return

		peridaxon
			name = "Peridaxon"
			id = "peridaxon"
			description = "Used to encourage recovery of internal organs and nervous systems. Medicate cautiously."
			reagent_state = LIQUID
			color = "#561EC3" // rgb: 200, 165, 220
			overdose = 10
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/H = M

					//Peridaxon heals only non-robotic organs
					for(var/obj/item/organ/I in H.internal_organs)
						if((I.damage > 0) && (I.robotic != 2))
							I.damage = max(I.damage - 0.20, 0)
				..()
				return

		bicaridine
			name = "Bicaridine"
			id = "bicaridine"
			description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
			reagent_state = LIQUID
			color = "#BF0000" // rgb: 200, 165, 220
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob, var/alien)
				if(M.stat == 2.0)
					return
				if(!M) M = holder.my_atom
				if(alien != IS_DIONA)
					M.heal_organ_damage(2*REM,0)
				..()
				return

		hyperzine
			name = "Hyperzine"
			id = "hyperzine"
			description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
			reagent_state = LIQUID
			color = "#FF3300" // rgb: 200, 165, 220
			custom_metabolism = 0.03
			overdose = REAGENTS_OVERDOSE/2

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(prob(5)) M.emote(pick("twitch","blink_r","shiver"))
				..()
				return

		adrenaline
			name = "Adrenaline"
			id = "adrenaline"
			description = "Adrenaline is a hormone used as a drug to treat cardiac arrest and other cardiac dysrhythmias resulting in diminished or absent cardiac output."
			reagent_state = LIQUID
			color = "#C8A5DC" // rgb: 200, 165, 220

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.SetParalysis(0)
				M.SetWeakened(0)
				M.adjustToxLoss(rand(3))
				..()
				return

		cryoxadone
			name = "Cryoxadone"
			id = "cryoxadone"
			description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
			reagent_state = LIQUID
			color = "#8080FF" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-1)
					M.adjustOxyLoss(-1)
					M.heal_organ_damage(1,1)
					M.adjustToxLoss(-1)
				..()
				return

		clonexadone
			name = "Clonexadone"
			id = "clonexadone"
			description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' the cloning process when used in conjunction with a cryo tube."
			reagent_state = LIQUID
			color = "#80BFFF" // rgb: 200, 165, 220
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					M.adjustCloneLoss(-3)
					M.adjustOxyLoss(-3)
					M.heal_organ_damage(3,3)
					M.adjustToxLoss(-3)
				..()
				return

		rezadone
			name = "Rezadone"
			id = "rezadone"
			description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
			reagent_state = SOLID
			color = "#669900" // rgb: 102, 153, 0
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 15)
						M.adjustCloneLoss(-1)
						M.heal_organ_damage(1,1)
					if(15 to 35)
						M.adjustCloneLoss(-2)
						M.heal_organ_damage(2,1)
						M.status_flags &= ~DISFIGURED
					if(35 to INFINITY)
						M.adjustToxLoss(1)
						M.make_dizzy(5)
						M.Jitter(5)

				..()
				return

		spaceacillin
			name = "Spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antiviral agent."
			reagent_state = LIQUID
			color = "#C1C1C1" // rgb: 200, 165, 220
			custom_metabolism = 0.01
			overdose = REAGENTS_OVERDOSE
			scannable = 1

			on_mob_life(var/mob/living/M as mob)
				..()
				return
*/


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
		nanites
			name = "Nanomachines"
			id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/robotic_transformation(0),1)

		xenomicrobes
			name = "Xenomicrobes"
			id = "xenomicrobes"
			description = "Microbes with an entirely alien cellular structure."
			reagent_state = LIQUID
			color = "#535E66" // rgb: 83, 94, 102

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					M.contract_disease(new /datum/disease/xeno_transformation(0),1)

		fluorosurfactant//foam precursor
			name = "Fluorosurfactant"
			id = "fluorosurfactant"
			description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
			reagent_state = LIQUID
			color = "#9E6B38" // rgb: 158, 107, 56

		foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
			name = "Foaming agent"
			id = "foaming_agent"
			description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
			reagent_state = SOLID
			color = "#664B63" // rgb: 102, 75, 99

		ammonia
			name = "Ammonia"
			id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS
			color = "#404030" // rgb: 64, 64, 48

		ultraglue
			name = "Ultra Glue"
			id = "glue"
			description = "An extremely powerful bonding agent."
			color = "#FFFFCC" // rgb: 255, 255, 204

		diethylamine
			name = "Diethylamine"
			id = "diethylamine"
			description = "A secondary amine, mildly corrosive."
			reagent_state = LIQUID
			color = "#604030" // rgb: 96, 64, 48

		ethylredoxrazine	// FUCK YOU, ALCOHOL
			name = "Ethylredoxrazine"
			id = "ethylredoxrazine"
			description = "A powerful oxidizer that reacts with ethanol."
			reagent_state = SOLID
			color = "#605048" // rgb: 96, 80, 72
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 1*REM, 0, 1)
				..()
				return
*/
//////////////////////////Poison stuff///////////////////////
/*
		toxin
			name = "Toxin"
			id = "toxin"
			description = "A toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
		//	var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
			custom_metabolism = 0.1

			on_mob_life(var/mob/living/M as mob,var/alien)
				if(!M) M = holder.my_atom
				if(toxpwr)
					M.adjustToxLoss(toxpwr*REM)
				if(alien) ..() // Kind of a catch-all for aliens without the liver. Because this does not metabolize 'naturally', only removed by the liver.
				return

		toxin/amatoxin
			name = "Amatoxin"
			id = "amatoxin"
			description = "A powerful poison derived from certain species of mushroom."
			reagent_state = LIQUID
			color = "#792300" // rgb: 121, 35, 0
			toxpwr = 1

		toxin/mutagen
			name = "Unstable mutagen"
			id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			color = "#13BC5E" // rgb: 19, 188, 94
			toxpwr = 0

			reaction_mob(var/mob/living/carbon/M, var/method=TOUCH, var/volume)
				if(!..())	return
				if(!istype(M) || !M.dna)	return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
				src = null
				if((method==TOUCH && prob(33)) || method==INGEST)
					randmuti(M)
					if(prob(98))	randmutb(M)
					else			randmutg(M)
					domutcheck(M, null)
					M.UpdateAppearance()
				return
			on_mob_life(var/mob/living/carbon/M)
				if(!istype(M))	return
				if(!M) M = holder.my_atom
				M.apply_effect(10,IRRADIATE,0)
				..()
				return


/*
		toxin/cyanide //Fast and Lethal
			name = "Cyanide"
			id = "cyanide"
			description = "A highly toxic chemical."
			reagent_state = LIQUID
			color = "#CF3600" // rgb: 207, 54, 0
			toxpwr = 4
			custom_metabolism = 0.4

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.adjustOxyLoss(4*REM)
				M.sleeping += 1
				..()
				return
*/
*/
/*
		//Reagents used for plant fertilizers.
		toxin/fertilizer
			name = "fertilizer"
			id = "fertilizer"
			description = "A chemical mix good for growing plants with."
			reagent_state = LIQUID
			toxpwr = 0.2 //It's not THAT poisonous.
			color = "#664330" // rgb: 102, 67, 48

		toxin/fertilizer/eznutrient
			name = "EZ Nutrient"
			id = "eznutrient"

		toxin/fertilizer/left4zed
			name = "Left-4-Zed"
			id = "left4zed"

		toxin/fertilizer/robustharvest
			name = "Robust Harvest"
			id = "robustharvest"

		toxin/plantbgone
			name = "Plant-B-Gone"
			id = "plantbgone"
			description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
			reagent_state = LIQUID
			color = "#49002E" // rgb: 73, 0, 46
			toxpwr = 1

			// Clear off wallrot fungi
			reaction_turf(var/turf/T, var/volume)
				if(istype(T, /turf/simulated/wall))
					var/turf/simulated/wall/W = T
					if(W.rotting)
						W.rotting = 0
						for(var/obj/effect/E in W) if(E.name == "Wallrot") qdel(E)

						for(var/mob/O in viewers(W, null))
							O.show_message(text("\blue The fungi are completely dissolved by the solution!"), 1)

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/effect/alien/weeds/))
					var/obj/effect/alien/weeds/alien_weeds = O
					alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
					alien_weeds.healthcheck()
				else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
					qdel(O)
				else if(istype(O,/obj/effect/plantsegment))
					if(prob(50)) qdel(O) //Kills kudzu too.
				else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
					var/obj/machinery/portable_atmospherics/hydroponics/tray = O

					if(tray.seed)
						tray.health -= rand(30,50)
						if(tray.pestlevel > 0)
							tray.pestlevel -= 2
						if(tray.weedlevel > 0)
							tray.weedlevel -= 3
						tray.toxins += 4
						tray.check_level_sanity()
						tray.update_icon()

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
				src = null
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(!C.wear_mask) // If not wearing a mask
						C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.dna)
							if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
								H.adjustToxLoss(50)
*/
/*
		toxin/stoxin
			name = "Soporific"
			id = "stoxin"
			description = "An effective hypnotic used to treat insomnia."
			reagent_state = LIQUID
			color = "#009CA8" // rgb: 232, 149, 204
			toxpwr = 0
			custom_metabolism = 0.1
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 12)
						if(prob(5))	M.emote("yawn")
					if(12 to 15)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(15 to 49)
						if(prob(50))
							M.Weaken(2)
						M.drowsyness = max(M.drowsyness, 20)
					if(50 to INFINITY)
						M.sleeping = max(M.sleeping, 20)
						M.drowsyness = max(M.drowsyness, 60)
				data++
				..()
				return
*/
/*
		toxin/potassium_chloride
			name = "Potassium Chloride"
			id = "potassium_chloride"
			description = "A delicious salt that stops the heart when injected into cardiac muscle."
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255,255,255
			toxpwr = 0
			overdose = 30

			on_mob_life(var/mob/living/carbon/M as mob)
				var/mob/living/carbon/human/H = M
				if(H.stat != 1)
					if (volume >= overdose)
						if(H.losebreath >= 10)
							H.losebreath = max(10, H.losebreath-10)
						H.adjustOxyLoss(2)
						H.Weaken(10)
				..()
				return

		toxin/potassium_chlorophoride
			name = "Potassium Chlorophoride"
			id = "potassium_chlorophoride"
			description = "A specific chemical based on Potassium Chloride to stop the heart for surgery. Not safe to eat!"
			reagent_state = SOLID
			color = "#FFFFFF" // rgb: 255,255,255
			toxpwr = 2
			overdose = 20

			on_mob_life(var/mob/living/carbon/M as mob)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.stat != 1)
						if(H.losebreath >= 10)
							H.losebreath = max(10, M.losebreath-10)
						H.adjustOxyLoss(2)
						H.Weaken(10)
				..()
				return

		toxin/beer2	//disguised as normal beer for use by emagged brobots
			name = "Beer"
			id = "beer2"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water. The fermentation appears to be incomplete." //If the players manage to analyze this, they deserve to know something is wrong.
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			custom_metabolism = 0.15 // Sleep toxins should always be consumed pretty fast
			overdose = REAGENTS_OVERDOSE/2

			glass_icon_state = "beerglass"
			glass_name = "glass of beer"
			glass_desc = "A freezing pint of beer"
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1)
						M.confused += 2
						M.drowsyness += 2
					if(2 to 50)
						M.sleeping += 1
					if(51 to INFINITY)
						M.sleeping += 1
						M.adjustToxLoss((data - 50)*REM)
				data++
				..()
				return

		toxin/acid
			name = "Sulphuric acid"
			id = "sacid"
			description = "A very corrosive mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			color = "#DB5008" // rgb: 219, 80, 8
			toxpwr = 1
			var/meltprob = 10

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.take_organ_damage(0, 1*REM)
				..()
				return

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//magic numbers everywhere
				if(!istype(M, /mob/living))
					return
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M

						if(H.head)
							if(prob(meltprob) && !H.head.unacidable)
								H << "<span class='danger'>Your headgear melts away but protects you from the acid!</span>"
								qdel(H.head)
								H.update_inv_head(0)
								H.update_hair(0)
							else
								H << "<span class='warning'>Your headgear protects you from the acid.</span>"
							return

						if(H.wear_mask)
							if(prob(meltprob) && !H.wear_mask.unacidable)
								H << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
								qdel(H.wear_mask)
								H.update_inv_wear_mask(0)
								H.update_hair(0)
							else
								H << "<span class='warning'>Your mask protects you from the acid.</span>"
							return

						if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
							if(prob(meltprob) && !H.glasses.unacidable)
								H << "<span class='danger'>Your glasses melts away!</span>"
								qdel(H.glasses)
								H.update_inv_glasses(0)

					else if(ismonkey(M))
						var/mob/living/carbon/monkey/MK = M
						if(MK.wear_mask)
							if(!MK.wear_mask.unacidable)
								MK << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
								qdel(MK.wear_mask)
								MK.update_inv_wear_mask(0)
							else
								MK << "<span class='warning'>Your mask protects you from the acid.</span>"
							return

					if(!M.unacidable)
						if(istype(M, /mob/living/carbon/human) && volume >= 10)
							var/mob/living/carbon/human/H = M
							var/obj/item/organ/external/affecting = H.get_organ("head")
							if(affecting)
								if(affecting.take_damage(4*toxpwr, 2*toxpwr))
									H.UpdateDamageIcon()
								if(prob(meltprob)) //Applies disfigurement
									if (!(H.species && (H.species.flags & NO_PAIN)))
										H.emote("scream")
									H.status_flags |= DISFIGURED
						else
							M.take_organ_damage(min(6*toxpwr, volume * toxpwr)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
				else
					if(!M.unacidable)
						M.take_organ_damage(min(6*toxpwr, volume * toxpwr))

			reaction_obj(var/obj/O, var/volume)
				if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(meltprob * 3))
					if(!O.unacidable)
						var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
						I.desc = "Looks like this was \an [O] some time ago."
						for(var/mob/M in viewers(5, O))
							M << "\red \the [O] melts."
						qdel(O)

		toxin/acid/polyacid
			name = "Polytrinic acid"
			id = "pacid"
			description = "Polytrinic acid is a an extremely corrosive chemical substance."
			reagent_state = LIQUID
			color = "#8E18A9" // rgb: 142, 24, 169
			toxpwr = 2
			meltprob = 30
*/
/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
/*		nutriment
			name = "Nutriment"
			id = "nutriment"
			description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
			reagent_state = SOLID
			nutriment_factor = 15 * REAGENTS_METABOLISM
			color = "#664330" // rgb: 102, 67, 48

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
		//	if(!(M.mind in ticker.mode.vampires)) #TOREMOVE - we don't have them yet
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species && H.species.dietflags)	//Make sure the species has it's dietflag set, and that it is not a herbivore
						H.nutrition += nutriment_factor	// For hunger and fatness
						if(prob(50)) M.heal_organ_damage(1,0)
				if(istype(M,/mob/living/simple_animal))		//Any nutrients can heal simple animals
					if(prob(50)) M.heal_organ_damage(1,0)
				..()
				return
/*
				// If overeaten - vomit and fall down
				// Makes you feel bad but removes reagents and some effect
				// from your body
				if (M.nutrition > 650)
					M.nutrition = rand (250, 400)
					M.weakened += rand(2, 10)
					M.jitteriness += rand(0, 5)
					M.dizziness = max (0, (M.dizziness - rand(0, 15)))
					M.druggy = max (0, (M.druggy - rand(0, 15)))
					M.adjustToxLoss(rand(-15, -5)))
					M.updatehealth()
*/
*/

/*
		lipozine
			name = "Lipozine" // The anti-nutriment.
			id = "lipozine"
			description = "A chemical compound that causes a powerful fat-burning reaction."
			reagent_state = LIQUID
			nutriment_factor = 10 * REAGENTS_METABOLISM
			color = "#BBEDA4" // rgb: 187, 237, 164
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.nutrition = max(M.nutrition - nutriment_factor, 0)
				M.overeatduration = 0
				if(M.nutrition < 0)//Prevent from going into negatives.
					M.nutrition = 0
				..()
				return
*/
/*
		capsaicin
			name = "Capsaicin Oil"
			id = "capsaicin"
			description = "This is what makes chilis hot."
			reagent_state = LIQUID
			color = "#B31008" // rgb: 179, 16, 8

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				if(!data)
					data = 1
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species && !(H.species.flags & (NO_PAIN | IS_SYNTHETIC)) )
						switch(data)
							if(1 to 2)
								H << "\red <b>Your insides feel uncomfortably hot !</b>"
							if(2 to 20)
								if(prob(5))
									H << "\red <b>Your insides feel uncomfortably hot !</b>"
							if(20 to INFINITY)
								H.apply_effect(2,AGONY,0)
								if(prob(5))
									H.visible_message("<span class='warning'>[H] [pick("dry heaves!","coughs!","splutters!")]</span>")
									H << "\red <b>You feel like your insides are burning !</b>"
				else if(istype(M, /mob/living/carbon/slime))
					M.bodytemperature += rand(10,25)
				holder.remove_reagent("frostoil", 5)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				data++
				..()
				return

			on_mob_life(var/mob/living/M as mob)
				if(!M)
					M = holder.my_atom
				if(!data)
					data = 1
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species && !(H.species.flags & (NO_PAIN | IS_SYNTHETIC)) )
						switch(data)
							if(1)
								H << "\red <b>You feel like your insides are burning !</b>"
							if(2 to INFINITY)
								H.apply_effect(4,AGONY,0)
								if(prob(5))
									H.visible_message("<span class='warning'>[H] [pick("dry heaves!","coughs!","splutters!")]</span>")
									H << "\red <b>You feel like your insides are burning !</b>"
				else if(istype(M, /mob/living/carbon/slime))
					M.bodytemperature += rand(15,30)
				holder.remove_reagent("frostoil", 5)
				holder.remove_reagent(src.id, FOOD_METABOLISM)
				data++
				..()
				return

		psilocybin
			name = "Psilocybin"
			id = "psilocybin"
			description = "A strong psycotropic derived from certain species of mushroom."
			color = "#E700E7" // rgb: 231, 0, 231
			overdose = REAGENTS_OVERDOSE

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 30)
				if(!data) data = 1
				switch(data)
					if(1 to 5)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(5)
						if(prob(10)) M.emote(pick("twitch","giggle"))
					if(5 to 10)
						if (!M.stuttering) M.stuttering = 1
						M.Jitter(10)
						M.make_dizzy(10)
						M.druggy = max(M.druggy, 35)
						if(prob(20)) M.emote(pick("twitch","giggle"))
					if (10 to INFINITY)
						if (!M.stuttering) M.stuttering = 1
						M.Jitter(20)
						M.make_dizzy(20)
						M.druggy = max(M.druggy, 40)
						if(prob(30)) M.emote(pick("twitch","giggle"))
				holder.remove_reagent(src.id, 0.2)
				data++
				..()
				return
*/
/*	//removed because of meta bullshit. this is why we can't have nice things.
		syndicream
			name = "Cream filling"
			id = "syndicream"
			description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#AB7878" // rgb: 171, 120, 120

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				if(istype(M, /mob/living/carbon/human) && M.mind)
					if(M.mind.special_role)
						if(!M) M = holder.my_atom
						M.heal_organ_damage(1,1)
						M.nutrition += nutriment_factor
						..()
						return
				..()
*/
/*
		cornoil
			name = "Corn Oil"
			id = "cornoil"
			description = "An oil derived from various types of corn."
			reagent_state = LIQUID
			nutriment_factor = 20 * REAGENTS_METABOLISM
			color = "#302000" // rgb: 48, 32, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return
			reaction_turf(var/turf/simulated/T, var/volume)
				if (!istype(T)) return
				src = null
				if(volume >= 3)
					if(T.wet >= 1) return
					T.wet = 1
					if(T.wet_overlay)
						T.overlays -= T.wet_overlay
						T.wet_overlay = null
					T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
					T.overlays += T.wet_overlay

					spawn(800)
						if (!istype(T)) return
						if(T.wet >= 2) return
						T.wet = 0
						if(T.wet_overlay)
							T.overlays -= T.wet_overlay
							T.wet_overlay = null
				var/hotspot = (locate(/obj/fire) in T)
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					qdel(hotspot)
*/
/* We're back to flour bags
		flour
			name = "flour"
			id = "flour"
			description = "This is what you rub all over yourself to pretend to be a ghost."
			reagent_state = SOLID
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFFFF" // rgb: 0, 0, 0

			on_mob_life(var/mob/living/M as mob)
				M.nutrition += nutriment_factor
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/effect/decal/cleanable/flour(T)
*/

/*boozepwr chart
1-2 = non-toxic alcohol
3 = medium-toxic
4 = the hard stuff
5 = potent mixes
<6 = deadly toxic
*/
/*
		ethanol
			name = "Ethanol" //Parent class for all alcoholic reagents.
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			nutriment_factor = 0 //So alcohol can fill you up! If they want to.
			color = "#404030" // rgb: 64, 64, 48
			var/boozepwr = 5 //higher numbers mean the booze will have an effect faster.
			var/dizzy_adj = 3
			var/adj_drowsy = 0
			var/adj_sleepy = 0
			var/slurr_adj = 3
			var/confused_adj = 2
			var/slur_start = 90			//amount absorbed after which mob starts slurring
			var/confused_start = 150	//amount absorbed after which mob starts confusing directions
			var/blur_start = 300	//amount absorbed after which mob starts getting blurred vision
			var/pass_out = 400	//amount absorbed after which mob starts passing out

			glass_icon_state = "glass_clear"
			glass_name = "glass of ethanol"
			glass_desc = "A well-known alcohol with a variety of applications."

			on_mob_life(var/mob/living/M as mob, var/alien)
				M:nutrition += nutriment_factor
				holder.remove_reagent(src.id, (alien ? FOOD_METABOLISM : ALCOHOL_METABOLISM)) // Catch-all for creatures without livers.

				if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
				if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)

				if(!src.data || (!isnum(src.data)  && src.data.len)) data = 1   //if it doesn't exist we set it.  if it's a list we're going to set it to 1 as well.  This is to
				src.data += boozepwr						//avoid a runtime error associated with drinking blood mixed in drinks (demon's blood).

				var/d = data

				// make all the beverages work together
				for(var/datum/reagent/ethanol/A in holder.reagent_list)
					if(A != src && isnum(A.data)) d += A.data

				if(alien && alien == IS_SKRELL) //Skrell get very drunk very quickly.
					d*=5

				M.dizziness += dizzy_adj.
				if(d >= slur_start && d < pass_out)
					if (!M:slurring) M:slurring = 1
					M:slurring += slurr_adj
				if(d >= confused_start && prob(33))
					if (!M:confused) M:confused = 1
					M.confused = max(M:confused+confused_adj,0)
				if(d >= blur_start)
					M.eye_blurry = max(M.eye_blurry, 10)
					M:drowsyness  = max(M:drowsyness, 0)
				if(d >= pass_out)
					M:paralysis = max(M:paralysis, 20)
					M:drowsyness  = max(M:drowsyness, 30)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/obj/item/organ/liver/L = H.internal_organs_by_name["liver"]
						if (!L)
							H.adjustToxLoss(5)
						else if(istype(L))
							L.take_damage(0.1, 1)
						H.adjustToxLoss(0.1)
				..()
				return

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/weapon/paper))
					var/obj/item/weapon/paper/paperaffected = O
					paperaffected.clearpaper()
					usr << "The solution dissolves the ink on the paper."
				if(istype(O,/obj/item/weapon/book))
					if(istype(O,/obj/item/weapon/book/tome))
						usr << "The solution does nothing. Whatever this is, it isn't normal ink."
						return
					if(volume >= 5)
						var/obj/item/weapon/book/affectedbook = O
						affectedbook.dat = null
						usr << "The solution dissolves the ink on the book."
					else
						usr << "It wasn't enough..."
				return

		ethanol/beer
			name = "Beer"
			id = "beer"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "beerglass"
			glass_name = "glass of beer"
			glass_desc = "A freezing pint of beer"
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				M:jitteriness = max(M:jitteriness-3,0)
				..()
				return

		ethanol/kahlua
			name = "Kahlua"
			id = "kahlua"
			description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5
			dizzy_adj = -5
			adj_drowsy = -3
			adj_sleepy = -2

			glass_icon_state = "kahluaglass"
			glass_name = "glass of RR coffee liquor"
			glass_desc = "DAMN, THIS THING LOOKS ROBUST"
			glass_center_of_mass = list("x"=15, "y"=7)

			on_mob_life(var/mob/living/M as mob)
				M.Jitter(5)
				..()
				return

		ethanol/whiskey
			name = "Whiskey"
			id = "whiskey"
			description = "A superb and well-aged single-malt whiskey. Damn."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2
			dizzy_adj = 4

			glass_icon_state = "whiskeyglass"
			glass_name = "glass of whiskey"
			glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/specialwhiskey
			name = "Special Blend Whiskey"
			id = "specialwhiskey"
			description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2
			dizzy_adj = 4
			slur_start = 30		//amount absorbed after which mob starts slurring

			glass_icon_state = "whiskeyglass"
			glass_name = "glass of special blend whiskey"
			glass_desc = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/thirteenloko
			name = "Thirteen Loko"
			id = "thirteenloko"
			description = "A potent mixture of caffeine and alcohol."
			color = "#102000" // rgb: 16, 32, 0
			boozepwr = 2
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "thirteen_loko_glass"
			glass_name = "glass of Thirteen Loko"
			glass_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."

			on_mob_life(var/mob/living/M as mob)
				M:drowsyness = max(0,M:drowsyness-7)
				if (M.bodytemperature > 310)
					M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
				M.Jitter(5)
				..()
				return

		ethanol/vodka
			name = "Vodka"
			id = "vodka"
			description = "Number one drink AND fueling choice for Russians worldwide."
			color = "#0064C8" // rgb: 0, 100, 200
			boozepwr = 2

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of vodka"
			glass_desc = "The glass contain wodka. Xynta."
			glass_center_of_mass = list("x"=16, "y"=12)

			on_mob_life(var/mob/living/M as mob)
				M.radiation = max(M.radiation-1,0)
				..()
				return

		ethanol/bilk
			name = "Bilk"
			id = "bilk"
			description = "This appears to be beer mixed with milk. Disgusting."
			color = "#895C4C" // rgb: 137, 92, 76
			boozepwr = 1
			nutriment_factor = 2 * FOOD_METABOLISM

			glass_icon_state = "glass_brown"
			glass_name = "glass of bilk"
			glass_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."

		ethanol/threemileisland
			name = "Three Mile Island Iced Tea"
			id = "threemileisland"
			description = "Made for a woman, strong enough for a man."
			color = "#666340" // rgb: 102, 99, 64
			boozepwr = 5

			glass_icon_state = "threemileislandglass"
			glass_name = "glass of Three Mile Island iced tea"
			glass_desc = "A glass of this is sure to prevent a meltdown."
			glass_center_of_mass = list("x"=16, "y"=2)

			on_mob_life(var/mob/living/M as mob)
				M.druggy = max(M.druggy, 50)
				..()
				return

		ethanol/gin
			name = "Gin"
			id = "gin"
			description = "It's gin. In space. I say, good sir."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1
			dizzy_adj = 3

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of gin"
			glass_desc = "A crystal clear glass of Griffeater gin."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/tequilla
			name = "Tequila"
			id = "tequilla"
			description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
			color = "#FFFF91" // rgb: 255, 255, 145
			boozepwr = 2

			glass_icon_state = "tequillaglass"
			glass_name = "glass of Tequilla"
			glass_desc = "Now all that's missing is the weird colored shades!"
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/vermouth
			name = "Vermouth"
			id = "vermouth"
			description = "You suddenly feel a craving for a martini..."
			color = "#91FF91" // rgb: 145, 255, 145
			boozepwr = 1.5

			glass_icon_state = "vermouthglass"
			glass_name = "glass of vermouth"
			glass_desc = "You wonder why you're even drinking this straight."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/wine
			name = "Wine"
			id = "wine"
			description = "An premium alchoholic beverage made from distilled grape juice."
			color = "#7E4043" // rgb: 126, 64, 67
			boozepwr = 1.5
			dizzy_adj = 2
			slur_start = 65			//amount absorbed after which mob starts slurring
			confused_start = 145	//amount absorbed after which mob starts confusing directions

			glass_icon_state = "wineglass"
			glass_name = "glass of wine"
			glass_desc = "A very classy looking drink."
			glass_center_of_mass = list("x"=15, "y"=7)

		ethanol/cognac
			name = "Cognac"
			id = "cognac"
			description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
			color = "#AB3C05" // rgb: 171, 60, 5
			boozepwr = 1.5
			dizzy_adj = 4
			confused_start = 115	//amount absorbed after which mob starts confusing directions

			glass_icon_state = "cognacglass"
			glass_name = "glass of cognac"
			glass_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
			glass_center_of_mass = list("x"=16, "y"=6)

		ethanol/hooch
			name = "Hooch"
			id = "hooch"
			description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2
			dizzy_adj = 6
			slurr_adj = 5
			slur_start = 35			//amount absorbed after which mob starts slurring
			confused_start = 90	//amount absorbed after which mob starts confusing directions

			glass_icon_state = "glass_brown2"
			glass_name = "glass of Hooch"
			glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

		ethanol/ale
			name = "Ale"
			id = "ale"
			description = "A dark alchoholic beverage made by malted barley and yeast."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "aleglass"
			glass_name = "glass of ale"
			glass_desc = "A freezing pint of delicious ale"
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/absinthe
			name = "Absinthe"
			id = "absinthe"
			description = "Watch out that the Green Fairy doesn't come for you!"
			color = "#33EE00" // rgb: 51, 238, 0
			boozepwr = 4
			dizzy_adj = 5
			slur_start = 15
			confused_start = 30

			glass_icon_state = "absintheglass"
			glass_name = "glass of absinthe"
			glass_desc = "Wormwood, anise, oh my."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/pwine
			name = "Poison Wine"
			id = "pwine"
			description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
			color = "#000000" // rgb: 0, 0, 0 SHOCKER
			boozepwr = 1
			dizzy_adj = 1
			slur_start = 1
			confused_start = 1

			glass_icon_state = "pwineglass"
			glass_name = "glass of ???"
			glass_desc = "A black ichor with an oily purple sheer on top. Are you sure you should drink this?"
			glass_center_of_mass = list("x"=16, "y"=5)

			on_mob_life(var/mob/living/M as mob)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 50)
				if(!data) data = 1
				data++
				switch(data)
					if(1 to 25)
						if (!M.stuttering) M.stuttering = 1
						M.make_dizzy(1)
						M.hallucination = max(M.hallucination, 3)
						if(prob(1)) M.emote(pick("twitch","giggle"))
					if(25 to 75)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 10)
						M.Jitter(2)
						M.make_dizzy(2)
						M.druggy = max(M.druggy, 45)
						if(prob(5)) M.emote(pick("twitch","giggle"))
					if (75 to 150)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 60)
						M.Jitter(4)
						M.make_dizzy(4)
						M.druggy = max(M.druggy, 60)
						if(prob(10)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
					if (150 to 300)
						if (!M.stuttering) M.stuttering = 1
						M.hallucination = max(M.hallucination, 60)
						M.Jitter(4)
						M.make_dizzy(4)
						M.druggy = max(M.druggy, 60)
						if(prob(10)) M.emote(pick("twitch","giggle"))
						if(prob(30)) M.adjustToxLoss(2)
						if(prob(5)) if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/obj/item/organ/heart/L = H.internal_organs_by_name["heart"]
							if (L && istype(L))
								L.take_damage(5, 0)
					if (300 to INFINITY)
						if(ishuman(M))
							var/mob/living/carbon/human/H = M
							var/obj/item/organ/heart/L = H.internal_organs_by_name["heart"]
							if (L && istype(L))
								L.take_damage(100, 0)
				holder.remove_reagent(src.id, FOOD_METABOLISM)

		ethanol/rum
			name = "Rum"
			id = "rum"
			description = "Yohoho and all that."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5

			glass_icon_state = "rumglass"
			glass_name = "glass of rum"
			glass_desc = "Now you want to Pray for a pirate suit, don't you?"
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/deadrum
			name = "Deadrum"
			id = "rum" // duplicate ids?
			description = "Popular with the sailors. Not very popular with everyone else."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "rumglass"
			glass_name = "glass of rum"
			glass_desc = "Now you want to Pray for a pirate suit, don't you?"
			glass_center_of_mass = list("x"=16, "y"=12)

			on_mob_life(var/mob/living/M as mob)
				..()
				M.dizziness +=5
				return

		ethanol/sake
			name = "Sake"
			id = "sake"
			description = "Anime's favorite drink."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of sake"
			glass_desc = "A glass of sake."
			glass_center_of_mass = list("x"=16, "y"=12)

/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////


		ethanol/goldschlager
			name = "Goldschlager"
			id = "goldschlager"
			description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "ginvodkaglass"
			glass_name = "glass of Goldschlager"
			glass_desc = "100 proof that teen girls will drink anything with gold in it."
			glass_center_of_mass = list("x"=16, "y"=12)

		ethanol/patron
			name = "Patron"
			id = "patron"
			description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
			color = "#585840" // rgb: 88, 88, 64
			boozepwr = 1.5

			glass_icon_state = "patronglass"
			glass_name = "glass of Patron"
			glass_desc = "Drinking patron in the bar, with all the subpar ladies."
			glass_center_of_mass = list("x"=7, "y"=8)

		ethanol/gintonic
			name = "Gin and Tonic"
			id = "gintonic"
			description = "An all time classic, mild cocktail."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "gintonicglass"
			glass_name = "glass of gin and tonic"
			glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/cuba_libre
			name = "Cuba Libre"
			id = "cubalibre"
			description = "Rum, mixed with cola. Viva la revolucion."
			color = "#3E1B00" // rgb: 62, 27, 0
			boozepwr = 1.5

			glass_icon_state = "cubalibreglass"
			glass_name = "glass of Cuba Libre"
			glass_desc = "A classic mix of rum and cola."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/whiskey_cola
			name = "Whiskey Cola"
			id = "whiskeycola"
			description = "Whiskey, mixed with cola. Surprisingly refreshing."
			color = "#3E1B00" // rgb: 62, 27, 0
			boozepwr = 2

			glass_icon_state = "whiskeycolaglass"
			glass_name = "glass of whiskey cola"
			glass_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/martini
			name = "Classic Martini"
			id = "martini"
			description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "martiniglass"
			glass_name = "glass of classic martini"
			glass_desc = "Damn, the bartender even stirred it, not shook it."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/vodkamartini
			name = "Vodka Martini"
			id = "vodkamartini"
			description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "martiniglass"
			glass_name = "glass of vodka martini"
			glass_desc ="A bastardisation of the classic martini. Still great."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/white_russian
			name = "White Russian"
			id = "whiterussian"
			description = "That's just, like, your opinion, man..."
			color = "#A68340" // rgb: 166, 131, 64
			boozepwr = 3

			glass_icon_state = "whiterussianglass"
			glass_name = "glass of White Russian"
			glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/screwdrivercocktail
			name = "Screwdriver"
			id = "screwdrivercocktail"
			description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
			color = "#A68310" // rgb: 166, 131, 16
			boozepwr = 3

			glass_icon_state = "screwdriverglass"
			glass_name = "glass of Screwdriver"
			glass_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."
			glass_center_of_mass = list("x"=15, "y"=10)

		ethanol/booger
			name = "Booger"
			id = "booger"
			description = "Ewww..."
			color = "#8CFF8C" // rgb: 140, 255, 140
			boozepwr = 1.5

			glass_icon_state = "booger"
			glass_name = "glass of Booger"
			glass_desc = "Ewww..."

		ethanol/bloody_mary
			name = "Bloody Mary"
			id = "bloodymary"
			description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "bloodymaryglass"
			glass_name = "glass of Bloody Mary"
			glass_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."

		ethanol/brave_bull
			name = "Brave Bull"
			id = "bravebull"
			description = "It's just as effective as Dutch-Courage!"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "bravebullglass"
			glass_name = "glass of Brave Bull"
			glass_desc = "Tequilla and coffee liquor, brought together in a mouthwatering mixture. Drink up."
			glass_center_of_mass = list("x"=15, "y"=8)

		ethanol/tequilla_sunrise
			name = "Tequila Sunrise"
			id = "tequillasunrise"
			description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
			color = "#FFE48C" // rgb: 255, 228, 140
			boozepwr = 2

			glass_icon_state = "tequillasunriseglass"
			glass_name = "glass of Tequilla Sunrise"
			glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."

		ethanol/toxins_special
			name = "Toxins Special"
			id = "plasmaspecial"
			description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 5

			glass_icon_state = "toxinsspecialglass"
			glass_name = "glass of Toxins Special"
			glass_desc = "Whoah, this thing is on FIRE"

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 330)
					M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/beepsky_smash
			name = "Beepsky Smash"
			id = "beepskysmash"
			description = "Deny drinking this and prepare for THE LAW."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "beepskysmashglass"
			glass_name = "Beepsky Smash"
			glass_desc = "Heavy, hot and strong. Just like the Iron fist of the LAW."
			glass_center_of_mass = list("x"=18, "y"=10)

			on_mob_life(var/mob/living/M as mob)
				M.Stun(2)
				..()
				return

		ethanol/irish_cream
			name = "Irish Cream"
			id = "irishcream"
			description = "Whiskey-imbued cream, what else would you expect from the Irish."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "irishcreamglass"
			glass_name = "glass of Irish cream"
			glass_desc = "It's cream, mixed with whiskey. What else would you expect from the Irish?"
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/manly_dorf
			name = "The Manly Dorf"
			id = "manlydorf"
			description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "manlydorfglass"
			glass_name = "glass of The Manly Dorf"
			glass_desc = "A manly concotion made from Ale and Beer. Intended for true men only."

		ethanol/longislandicedtea
			name = "Long Island Iced Tea"
			id = "longislandicedtea"
			description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "longislandicedteaglass"
			glass_name = "glass of Long Island iced tea"
			glass_desc = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/moonshine
			name = "Moonshine"
			id = "moonshine"
			description = "You've really hit rock bottom now... your liver packed its bags and left last night."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "glass_clear"
			glass_name = "glass of moonshine"
			glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

		ethanol/b52
			name = "B-52"
			id = "b52"
			description = "Coffee, Irish Cream, and cognac. You will get bombed."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "b52glass"
			glass_name = "glass of B-52"
			glass_desc = "Kahlua, Irish cream, and congac. You will get bombed."

		ethanol/irishcoffee
			name = "Irish Coffee"
			id = "irishcoffee"
			description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "irishcoffeeglass"
			glass_name = "glass of Irish coffee"
			glass_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
			glass_center_of_mass = list("x"=15, "y"=10)

		ethanol/margarita
			name = "Margarita"
			id = "margarita"
			description = "On the rocks with salt on the rim. Arriba~!"
			color = "#8CFF8C" // rgb: 140, 255, 140
			boozepwr = 3

			glass_icon_state = "margaritaglass"
			glass_name = "glass of margarita"
			glass_desc = "On the rocks with salt on the rim. Arriba~!"
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/black_russian
			name = "Black Russian"
			id = "blackrussian"
			description = "For the lactose-intolerant. Still as classy as a White Russian."
			color = "#360000" // rgb: 54, 0, 0
			boozepwr = 3

			glass_icon_state = "blackrussianglass"
			glass_name = "glass of Black Russian"
			glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/manhattan
			name = "Manhattan"
			id = "manhattan"
			description = "The Detective's undercover drink of choice. He never could stomach gin..."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "manhattanglass"
			glass_name = "glass of Manhattan"
			glass_desc = "The Detective's undercover drink of choice. He never could stomach gin..."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/manhattan_proj
			name = "Manhattan Project"
			id = "manhattan_proj"
			description = "A scientist's drink of choice, for pondering ways to blow up the station."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 5

			glass_icon_state = "proj_manhattanglass"
			glass_name = "glass of Manhattan Project"
			glass_desc = "A scienitst drink of choice, for thinking how to blow up the station."
			glass_center_of_mass = list("x"=17, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				M.druggy = max(M.druggy, 30)
				..()
				return

		ethanol/whiskeysoda
			name = "Whiskey Soda"
			id = "whiskeysoda"
			description = "For the more refined griffon."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "whiskeysodaglass2"
			glass_name = "glass of whiskey soda"
			glass_desc = "Ultimate refreshment."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/antifreeze
			name = "Anti-freeze"
			id = "antifreeze"
			description = "Ultimate refreshment."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "antifreeze"
			glass_name = "glass of Anti-freeze"
			glass_desc = "The ultimate refreshment."
			glass_center_of_mass = list("x"=16, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 330)
					M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/barefoot
			name = "Barefoot"
			id = "barefoot"
			description = "Barefoot and pregnant"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5

			glass_icon_state = "b&p"
			glass_name = "glass of Barefoot"
			glass_desc = "Barefoot and pregnant"
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/snowwhite
			name = "Snow White"
			id = "snowwhite"
			description = "A cold refreshment"
			color = "#FFFFFF" // rgb: 255, 255, 255
			boozepwr = 1.5

			glass_icon_state = "snowwhite"
			glass_name = "glass of Snow White"
			glass_desc = "A cold refreshment."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/melonliquor
			name = "Melon Liquor"
			id = "melonliquor"
			description = "A relatively sweet and fruity 46 proof liquor."
			color = "#138808" // rgb: 19, 136, 8
			boozepwr = 1

			glass_icon_state = "emeraldglass"
			glass_name = "glass of melon liquor"
			glass_desc = "A relatively sweet and fruity 46 proof liquor."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/bluecuracao
			name = "Blue Curacao"
			id = "bluecuracao"
			description = "Exotically blue, fruity drink, distilled from oranges."
			color = "#0000CD" // rgb: 0, 0, 205
			boozepwr = 1.5

			glass_icon_state = "curacaoglass"
			glass_name = "glass of blue curacao"
			glass_desc = "Exotically blue, fruity drink, distilled from oranges."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/suidream
			name = "Sui Dream"
			id = "suidream"
			description = "Comprised of: White soda, blue curacao, melon liquor."
			color = "#00A86B" // rgb: 0, 168, 107
			boozepwr = 0.5

			glass_icon_state = "sdreamglass"
			glass_name = "glass of Sui Dream"
			glass_desc = "A froofy, fruity, and sweet mixed drink. Understanding the name only brings shame."
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/demonsblood
			name = "Demons Blood"
			id = "demonsblood"
			description = "AHHHH!!!!"
			color = "#820000" // rgb: 130, 0, 0
			boozepwr = 3

			glass_icon_state = "demonsblood"
			glass_name = "glass of Demons' Blood"
			glass_desc = "Just looking at this thing makes the hair at the back of your neck stand up."
			glass_center_of_mass = list("x"=16, "y"=2)

		ethanol/vodkatonic
			name = "Vodka and Tonic"
			id = "vodkatonic"
			description = "For when a gin and tonic isn't russian enough."
			color = "#0064C8" // rgb: 0, 100, 200
			boozepwr = 3
			dizzy_adj = 4
			slurr_adj = 3

			glass_icon_state = "vodkatonicglass"
			glass_name = "glass of vodka and tonic"
			glass_desc = "For when a gin and tonic isn't Russian enough."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/ginfizz
			name = "Gin Fizz"
			id = "ginfizz"
			description = "Refreshingly lemony, deliciously dry."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5
			dizzy_adj = 4
			slurr_adj = 3

			glass_icon_state = "ginfizzglass"
			glass_name = "glass of gin fizz"
			glass_desc = "Refreshingly lemony, deliciously dry."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/bahama_mama
			name = "Bahama mama"
			id = "bahama_mama"
			description = "Tropical cocktail."
			color = "#FF7F3B" // rgb: 255, 127, 59
			boozepwr = 2

			glass_icon_state = "bahama_mama"
			glass_name = "glass of Bahama Mama"
			glass_desc = "Tropical cocktail"
			glass_center_of_mass = list("x"=16, "y"=5)

		ethanol/singulo
			name = "Singulo"
			id = "singulo"
			description = "A blue-space beverage!"
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 5
			dizzy_adj = 15
			slurr_adj = 15

			glass_icon_state = "singulo"
			glass_name = "glass of Singulo"
			glass_desc = "A blue-space beverage."
			glass_center_of_mass = list("x"=17, "y"=4)

		ethanol/sbiten
			name = "Sbiten"
			id = "sbiten"
			description = "A spicy Vodka! Might be a little hot for the little guys!"
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "sbitenglass"
			glass_name = "glass of Sbiten"
			glass_desc = "A spicy mix of Vodka and Spice. Very hot."
			glass_center_of_mass = list("x"=17, "y"=8)

			on_mob_life(var/mob/living/M as mob)
				if (M.bodytemperature < 360)
					M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/devilskiss
			name = "Devils Kiss"
			id = "devilskiss"
			description = "Creepy time!"
			color = "#A68310" // rgb: 166, 131, 16
			boozepwr = 3

			glass_icon_state = "devilskiss"
			glass_name = "glass of Devil's Kiss"
			glass_desc = "Creepy time!"
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/red_mead
			name = "Red Mead"
			id = "red_mead"
			description = "The true Viking's drink! Even though it has a strange red color."
			color = "#C73C00" // rgb: 199, 60, 0
			boozepwr = 1.5

			glass_icon_state = "red_meadglass"
			glass_name = "glass of red mead"
			glass_desc = "A true Viking's beverage, though its color is strange."
			glass_center_of_mass = list("x"=17, "y"=10)

		ethanol/mead
			name = "Mead"
			id = "mead"
			description = "A Viking's drink, though a cheap one."
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1.5
			nutriment_factor = 1 * FOOD_METABOLISM

			glass_icon_state = "meadglass"
			glass_name = "glass of mead"
			glass_desc = "A Viking's beverage, though a cheap one."
			glass_center_of_mass = list("x"=17, "y"=10)

		ethanol/iced_beer
			name = "Iced Beer"
			id = "iced_beer"
			description = "A beer which is so cold the air around it freezes."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 1

			glass_icon_state = "iced_beerglass"
			glass_name = "glass of iced beer"
			glass_desc = "A beer so frosty, the air around it freezes."
			glass_center_of_mass = list("x"=16, "y"=7)

			on_mob_life(var/mob/living/M as mob)
				if(M.bodytemperature > 270)
					M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
				..()
				return

		ethanol/grog
			name = "Grog"
			id = "grog"
			description = "Watered down rum, NanoTrasen approves!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 0.5

			glass_icon_state = "grogglass"
			glass_name = "glass of grog"
			glass_desc = "A fine and cepa drink for Space."

		ethanol/aloe
			name = "Aloe"
			id = "aloe"
			description = "So very, very, very good."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "aloe"
			glass_name = "glass of Aloe"
			glass_desc = "Very, very, very good."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/andalusia
			name = "Andalusia"
			id = "andalusia"
			description = "A nice, strangely named drink."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 3

			glass_icon_state = "andalusia"
			glass_name = "glass of Andalusia"
			glass_desc = "A nice, strange named drink."
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/alliescocktail
			name = "Allies Cocktail"
			id = "alliescocktail"
			description = "A drink made from your allies, not as sweet as when made from your enemies."
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "alliescocktail"
			glass_name = "glass of Allies cocktail"
			glass_desc = "A drink made from your allies."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/acid_spit
			name = "Acid Spit"
			id = "acidspit"
			description = "A drink for the daring, can be deadly if incorrectly prepared!"
			reagent_state = LIQUID
			color = "#365000" // rgb: 54, 80, 0
			boozepwr = 1.5

			glass_icon_state = "acidspitglass"
			glass_name = "glass of Acid Spit"
			glass_desc = "A drink from Nanotrasen. Made from live aliens."
			glass_center_of_mass = list("x"=16, "y"=7)

		ethanol/amasec
			name = "Amasec"
			id = "amasec"
			description = "Official drink of the NanoTrasen Gun-Club!"
			reagent_state = LIQUID
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 2

			glass_icon_state = "amasecglass"
			glass_name = "glass of Amasec"
			glass_desc = "Always handy before COMBAT!!!"
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/changelingsting
			name = "Changeling Sting"
			id = "changelingsting"
			description = "You take a tiny sip and feel a burning sensation..."
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 5

			glass_icon_state = "changelingsting"
			glass_name = "glass of Changeling Sting"
			glass_desc = "A stingy drink."

		ethanol/irishcarbomb
			name = "Irish Car Bomb"
			id = "irishcarbomb"
			description = "Mmm, tastes like chocolate cake..."
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 3
			dizzy_adj = 5

			glass_icon_state = "irishcarbomb"
			glass_name = "glass of Irish Car Bomb"
			glass_desc = "An irish car bomb."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/syndicatebomb
			name = "Syndicate Bomb"
			id = "syndicatebomb"
			description = "Tastes like terrorism!"
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 5

			glass_icon_state = "syndicatebomb"
			glass_name = "glass of Syndicate Bomb"
			glass_desc = "Tastes like terrorism!"
			glass_center_of_mass = list("x"=16, "y"=4)

		ethanol/erikasurprise
			name = "Erika Surprise"
			id = "erikasurprise"
			description = "The surprise is it's green!"
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 3

			glass_icon_state = "erikasurprise"
			glass_name = "glass of Erika Surprise"
			glass_desc = "The surprise is, it's green!"
			glass_center_of_mass = list("x"=16, "y"=9)

		ethanol/driestmartini
			name = "Driest Martini"
			id = "driestmartini"
			description = "Only for the experienced. You think you see sand floating in the glass."
			nutriment_factor = 1 * FOOD_METABOLISM
			color = "#2E6671" // rgb: 46, 102, 113
			boozepwr = 4

			glass_icon_state = "driestmartiniglass"
			glass_name = "glass of Driest Martini"
			glass_desc = "Only for the experienced. You think you see sand floating in the glass."
			glass_center_of_mass = list("x"=17, "y"=8)

		ethanol/bananahonk
			name = "Banana Mama"
			id = "bananahonk"
			description = "A drink from Clown Heaven."
			nutriment_factor = 1 * REAGENTS_METABOLISM
			color = "#FFFF91" // rgb: 255, 255, 140
			boozepwr = 4

			glass_icon_state = "bananahonkglass"
			glass_name = "glass of Banana Honk"
			glass_desc = "A drink from Banana Heaven."
			glass_center_of_mass = list("x"=16, "y"=8)

		ethanol/silencer
			name = "Silencer"
			id = "silencer"
			description = "A drink from Mime Heaven."
			nutriment_factor = 1 * FOOD_METABOLISM
			color = "#664300" // rgb: 102, 67, 0
			boozepwr = 4

			glass_icon_state = "silencerglass"
			glass_name = "glass of Silencer"
			glass_desc = "A drink from mime Heaven."
			glass_center_of_mass = list("x"=16, "y"=9)

			on_mob_life(var/mob/living/M as mob)
				if(!data) data = 1
				data++
				M.dizziness +=10
				if(data >= 55 && data <115)
					if (!M.stuttering) M.stuttering = 1
					M.stuttering += 10
				else if(data >= 115 && prob(33))
					M.confused = max(M.confused+15,15)
				..()
				return
*/