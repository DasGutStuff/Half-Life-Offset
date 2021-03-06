// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	burn_state = 0 //Burnable
	var/plantname
	var/potency = 1

/obj/item/weapon/grown/New()

	..()

	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src

	//Handle some post-spawn var stuff.
	spawn(1)
		// Fill the object up with the appropriate reagents.
		if(!isnull(plantname))
			var/datum/seed/S = seed_types[plantname]
			if(!S || !S.chems)
				return

			potency = S.potency

			for(var/rid in S.chems)
				var/list/reagent_data = S.chems[rid]
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				reagents.add_reagent(rid,max(1,rtotal))

/obj/item/weapon/grown/log
	name = "towercap"
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/harvest.dmi'
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || (istype(W, /obj/item/weapon/twohanded/fireaxe) && W:wielded) || istype(W, /obj/item/weapon/melee/energy))
			user.show_message("<span class='notice'>You make planks out of \the [src]!</span>", 1)
			for(var/i=0,i<2,i++)
				var/obj/item/stack/sheet/wood/NG = new (user.loc)
				for (var/obj/item/stack/sheet/wood/G in user.loc)
					if(G==NG)
						continue
					if(G.amount>=G.max_amount)
						continue
					G.attackby(NG, user)
					usr << "You add the newly-formed wood to the stack. It now contains [NG.amount] planks."
			qdel(src)
			return

/obj/item/weapon/grown/sunflower // FLOWER POWER!
	plantname = "sunflowers"
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	throwforce = 1
	w_class = 1.0
	throw_speed = 1
	throw_range = 3

/obj/item/weapon/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	M << "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>"
	user << "<font color='green'> Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>"

/obj/item/weapon/grown/nettle // -- Skie
	plantname = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	name = "nettle"
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	throwforce = 1
	w_class = 2.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "combat=1"
	attack_verb = list("stung")
	hitsound = ""

	var/potency_divisior = 5

/obj/item/weapon/grown/nettle/New()
	..()
	spawn(5)
		force = round((5+potency/potency_divisior), 1)

/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(istype(user) && !user.gloves)
		user << "\red The nettle burns your bare hand!"
		if(istype(user, /mob/living/carbon/human))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/obj/item/organ/external/affecting = user.get_organ(organ)
			if(affecting.take_damage(0,force))
				user.UpdateDamageIcon()
		else
			user.take_organ_damage(0,force)
		return 1
	return 0

/obj/item/weapon/grown/nettle/proc/lose_leaves(var/mob/user)
	if(force > 0)
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	sleep(1)

	if(force <= 0)
		if(user)
			user << "All the leaves have fallen off \the [src] from violent whacking."
			user.drop_from_inventory(src)
		qdel(src)

/obj/item/weapon/grown/nettle/death // -- Skie
	plantname = "deathnettle"
	desc = "The \red glowing \black nettle incites \red<B>rage</B>\black in you just from looking at it!"
	name = "deathnettle"
	icon_state = "deathnettle"
	origin_tech = "combat=3"
	potency_divisior = 2.5

/obj/item/weapon/grown/nettle/death/pickup(mob/living/carbon/human/user as mob)

	if(..() && prob(50))
		user.Paralyse(5)
		user << "\red You are stunned by the deathnettle when you try picking it up!"

/obj/item/weapon/grown/nettle/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!..()) return

	lose_leaves(user)

/obj/item/weapon/grown/nettle/death/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!..()) return

	if(istype(M, /mob/living))
		M << "\red You are stunned by the powerful acid of the deathnettle!"

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had the [src.name] used on them by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] on [M.name] ([M.ckey])</font>")
		msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force/6)
			M.Weaken(force/15)
		M.drop_item()


/obj/item/weapon/grown/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/grown/bananapeel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is deliberately slipping on the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/grown/bananapeel/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		var/stun = Clamp(potency / 10, 1, 10)
		var/weaken = Clamp(potency / 20, 0.5, 5)
		M.slip(stun, weaken, src)
		return 1

/obj/item/weapon/grown/bananapeel/specialpeel     //used by /obj/item/clothing/shoes/clown_shoes/bananashoes.dm
	name = "synthesized banana peel"
	desc = "A synthetic banana peel."

/obj/item/weapon/grown/bananapeel/specialpeel/Crossed(AM)
	if(..())	qdel(src)

/obj/item/weapon/grown/bananapeel/mimanapeel
	name = "mimana peel"
	desc = "A mimana peel."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "mimana_peel"

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/trash.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 1
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/weapon/corncob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife) || istype(W, /obj/item/weapon/kitchenknife) || istype(W, /obj/item/weapon/kitchenknife/ritual))
		user << "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>"
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		user.unEquip(src)
		qdel(src)
		return
