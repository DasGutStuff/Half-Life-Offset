/obj/item/weapon/melee/energy
	var/active = 0
	var/active_force
	var/active_throwforce
	var/active_w_class
	sharp = 0
	edge = 0
	flags = NOBLOODY

/obj/item/weapon/melee/energy/proc/activate(mob/living/user)
	anchored = 1
	if(active)
		return
	active = 1
	force = active_force
	throwforce = active_throwforce
	sharp = 1
	edge = 1
	w_class = active_w_class
	playsound(user, 'sound/weapons/saberon.ogg', 50, 1)

/obj/item/weapon/melee/energy/proc/deactivate(mob/living/user)
	anchored = 0
	if(!active)
		return
	playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
	active = 0
	force = initial(force)
	throwforce = initial(throwforce)
	sharp = initial(sharp)
	edge = initial(edge)
	w_class = initial(w_class)

/obj/item/weapon/melee/energy/attack_self(mob/living/user as mob)
	if (active)
		if ((CLUMSY in user.mutations) && prob(50))
			user.visible_message("<span class='danger'>[user] accidentally cuts \himself with \the [src].</span>",\
			"<span class='danger'>You accidentally cut yourself with \the [src].</span>")
			user.take_organ_damage(5,5)
		deactivate(user)
	else
		activate(user)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	if (active)
		viewers(user) << pick("<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
							"<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/is_sharp()
	return active * sharp

/*
 * Energy Axe
 */
/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	//active_force = 150 //holy...
	active_force = 60
	active_throwforce = 35
	active_w_class = 5
	//force = 40
	//throwforce = 25
	force = 20
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = 3
	flags = CONDUCT | NOSHIELD | NOBLOODY
	origin_tech = "magnets=3;combat=4"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = IS_SHARP
	edge = 1

/obj/item/weapon/melee/energy/axe/activate(mob/living/user)
	..()
	icon_state = "axe1"
	user << "\blue \The [src] is now energised."

/obj/item/weapon/melee/energy/axe/deactivate(mob/living/user)
	..()
	icon_state = initial(icon_state)
	user << "\blue \The [src] is de-energised. It's just a regular axe now."

/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</b>"
	return (BRUTELOSS|FIRELOSS)

/*
 * Energy Sword
 */
/obj/item/weapon/melee/energy/sword
	color
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	active_force = 30
	active_throwforce = 20
	active_w_class = 4
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = 2
	flags = NOSHIELD | NOBLOODY
	origin_tech = "magnets=3;syndicate=4"
	var/hacked = 0

/obj/item/weapon/melee/energy/sword/dropped(var/mob/user)
	..()
	if(!istype(loc,/mob))
		deactivate(user)

/obj/item/weapon/melee/energy/sword/New()
	item_color = pick("red","blue","green","purple")

/obj/item/weapon/melee/energy/sword/green/New()
	item_color = "green"

/obj/item/weapon/melee/energy/sword/red/New()
	item_color = "red"

/obj/item/weapon/melee/energy/sword/blue/New()
	item_color = "blue"

/obj/item/weapon/melee/energy/sword/purple/New()
	item_color = "purple"

/obj/item/weapon/melee/energy/sword/activate(mob/living/user)
	if(!active)
		user << "<span class='notice'>\The [src] is now energised.</span>"
	..()
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	icon_state = "sword[item_color]"

/obj/item/weapon/melee/energy/sword/deactivate(mob/living/user)
	if(active)
		user << "<span class='notice'>\The [src] deactivates!</span>"
	..()
	attack_verb = list()
	icon_state = initial(icon_state)

/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/sword/))
		if(W == src)
			user << "<span class='notice'>You try to attach the end of the energy sword to... itself. You're not very smart, are you?</span>"
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else
			user << "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>"
			var/obj/item/weapon/twohanded/dualsaber/newSaber = new /obj/item/weapon/twohanded/dualsaber(user.loc)
			if(src.hacked) // That's right, we'll only check the "original" esword.
				newSaber.hacked = 1
				newSaber.item_color = "rainbow"
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)
			user.put_in_hands(newSaber)
	else if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			item_color = "rainbow"
			user << "<span class='warning'>RNBW_ENGAGE</span>"
			if(active)
				icon_state = "swordrainbow"
				// Updating overlays, copied from welder code.
				// I tried calling attack_self twice, which looked cool, except it somehow didn't update the overlays!!
				if(user.r_hand == src)
					user.update_inv_r_hand(0)
				else if(user.l_hand == src)
					user.update_inv_l_hand(0)
		else
			user << "<span class='warning'>It's already fabulous!</span>"

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"

/obj/item/weapon/melee/energy/sword/pirate/activate(mob/living/user)
	..()
	icon_state = "cutlass1"

/*
 *Energy Blade
 */

//Can't be activated or deactivated, so no reason to be a subtype of energy
/obj/item/weapon/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 70.0//Normal attacks deal very high damage.
	sharp = 1
	edge = 1
	anchored = 1    // Never spawned outside of inventory, should be fine.
	throwforce = 1  //Throwing or dropping the item deletes it.
	throw_speed = 1
	throw_range = 1
	w_class = 4.0//So you can't hide it in your pocket or some such.
	flags = NOSHIELD | NOBLOODY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/mob/living/creator
	var/datum/effect/effect/system/spark_spread/spark_system

/obj/item/weapon/melee/energy/blade/New()

	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	processing_objects |= src

/obj/item/weapon/melee/energy/blade/Destroy()
	processing_objects -= src
	..()

/obj/item/weapon/melee/energy/blade/attack_self(mob/user as mob)
	user.drop_from_inventory(src)
	spawn(1) if(src) qdel(src)

/obj/item/weapon/melee/energy/blade/dropped()
	spawn(1) if(src) qdel(src)

/obj/item/weapon/melee/energy/blade/process()
	if(!creator || loc != creator || (creator.l_hand != src && creator.r_hand != src))
		// Tidy up a bit.
		if(istype(loc,/mob/living))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		spawn(1) if(src) qdel(src)
