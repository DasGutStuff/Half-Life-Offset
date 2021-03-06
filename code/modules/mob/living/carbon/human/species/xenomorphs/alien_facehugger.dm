//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

var/const/MIN_IMPREGNATION_TIME = 100 //time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 150

var/const/MIN_ACTIVE_TIME = 200 //time between being dropped and going idle
var/const/MAX_ACTIVE_TIME = 400

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | AIRTIGHT
	body_parts_covered = FACE|EYES
	throw_range = 5
	tint = 3
	layer = MOB_LAYER

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/strength = 5
	var/attached = 0

/obj/item/clothing/mask/facehugger/attack_hand(user as mob)
	if((stat == CONSCIOUS && !sterile))
		if(Attach(user))
			return
	..()

/obj/item/clothing/mask/facehugger/attack(mob/living/M as mob, mob/user as mob)
	..()
	user.unEquip(src)
	Attach(M)

/obj/item/clothing/mask/facehugger/New()
	if(config.aliens_allowed)
		..()
	else
		qdel(src)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..(user)
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			user << "<span class='boldannounce'>[src] is not moving.</span>"
		if(CONSCIOUS)
			user << "<span class='boldannounce'>[src] seems to be active!</span>"
	if (sterile)
		user << "<span class='boldannounce'>It looks like the proboscis has been removed.</span>"

/obj/item/clothing/mask/facehugger/attackby(obj/item/O,mob/M, params)
	if(O.force)
		Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act(obj/item/projectile/P)
	if(P.damage)
		Die()
	return

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	Attach(M)

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	HasProximity(target)
	return

/obj/item/clothing/mask/facehugger/on_found(mob/finder as mob)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return 0

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM as mob|obj)
	if(CanHug(AM))
		return Attach(AM)
	return 0

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	if(!..())
		return
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		throwing = 0
	GoIdle(30,100) //stunned for a few seconds - allows throwing them to be useful for positioning but not as an offensive action (unless you're setting up a trap)

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/M)

	if(!isliving(M))
		return 0
	if((!iscorgi(M) && !iscarbon(M)) || isalien(M))
		return 0
	if(attached)
		return 0
	else
		attached++
		spawn(MAX_IMPREGNATION_TIME)
			attached = 0

	var/mob/living/carbon/C = M
	if(istype(C) && locate(/obj/item/organ/xenos/hivenode) in C.internal_organs)
		return 0

	if(loc == M)
		return 0
	if(stat != CONSCIOUS)
		return 0

	if(!sterile) M.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage
	M.visible_message("<span class='danger'>[src] leaps at [M]'s face!</span>", \
						"<span class='userdanger'>[src] leaps at [M]'s face!</span>")

	/* Tentatively removed since huggers can't be thrown anymore
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.is_mouth_covered(head_only = 1))
			H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
								"<span class='userdanger'>[src] smashes against [H]'s [H.head]!</span>")
			Die()
			return 0
	*/

	if(iscarbon(M))
		var/mob/living/carbon/target = M
		if(target.wear_mask)
			if(prob(20))
				return 0
			var/obj/item/clothing/W = target.wear_mask
			if(!W.canremove)
				return 0
			target.unEquip(W)

			target.visible_message("<span class='danger'>[src] tears [W] off of [target]'s face!</span>", \
						"<span class='userdanger'>[src] tears [W] off of [target]'s face!</span>")

		src.loc = target
		target.equip_to_slot(src, slot_wear_mask,,0)
		target.contents += src // Monkey sanity check - Snapshot
		if(!sterile)
			M.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings
	else if (iscorgi(M))
		var/mob/living/simple_animal/corgi/D = M
		loc = D
		D.facehugger = src
		D.regenerate_icons()

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		Impregnate(M)

	return 1

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.stat == DEAD) //was taken off or something
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.wear_mask != src)
			return


	if(!sterile)
		//target.contract_disease(new /datum/disease/alien_embryo(0)) //so infection chance is same as virus infection chance
		new /obj/item/alien_embryo(target)
		target.status_flags |= XENO_HOST

		target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>", \
								"<span class='userdanger'>[src] falls limp after violating [target]'s face!</span>")
		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("<span class='danger'>[src] violates [target]'s face!</span>", \
								"<span class='userdanger'>[src] violates [target]'s face!</span>")

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/proc/GoIdle(var/min_time=MIN_ACTIVE_TIME, var/max_time=MAX_ACTIVE_TIME)
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	item_state = "facehugger_inactive"
	stat = DEAD

	visible_message("<span class='danger'>[src] curls up into a ball!</span>")

	if(ismob(loc))
		var/mob/living/carbon/C = loc
		C.update_inv_l_hand()
		C.update_inv_r_hand()
		C.visible_message("<span class='danger'>[src] curls up into a ball!</span>") //#TOREMOVE if the facehugger is in a mob's hand or inventory, the message is considered not visible
																				   //maybe there is a neater way of handling this but for now this'll do

/proc/CanHug(var/mob/M)

	if(!istype(M))
		return 0
	if(M.stat == DEAD)
		return 0

	var/mob/living/carbon/C = M
	if(istype(C) && locate(/obj/item/organ/xenos/hivenode) in C.internal_organs)
		return 0

	if(iscorgi(M) || ismonkey(M))
		return 1

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.head && H.head.flags & HEADCOVERSMOUTH)
			return 0
		return 1
	return 0
