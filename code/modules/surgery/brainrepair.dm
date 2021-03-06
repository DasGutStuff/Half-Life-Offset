//////////////////////////////////////////////////////////////////
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/bone_chips
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 		\
	/obj/item/weapon/wirecutters = 75, 		\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	priority = 3
	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected) return
		var/obj/item/organ/brain/sponge = target.internal_organs_by_name["brain"]
		return (sponge && sponge.damage > 0 && sponge.damage <= 20) && affected.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts taking bone chips out of [target]'s brain with \the [tool].", \
		"You start taking bone chips out of [target]'s brain with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='notice'>[user] takes out all the bone chips in [target]'s brain with \the [tool].</span>",	\
		"<span class='notice'>You take out all the bone chips in [target]'s brain with \the [tool].</span>")
		var/obj/item/organ/brain/sponge = target.internal_organs_by_name["brain"]
		if (sponge)
			sponge.damage = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='danger'>[user]'s hand slips, jabbing \the [tool] in [target]'s brain!</span>", \
		"<span class='danger'>Your hand slips, jabbing \the [tool] in [target]'s brain!</span>")
		target.apply_damage(30, BRUTE, "head", 1, sharp=1)

/datum/surgery_step/brain/hematoma
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)

	priority = 3
	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected) return
		var/obj/item/organ/brain/sponge = target.internal_organs_by_name["brain"]
		return (sponge && sponge.damage > 20) && affected.open == 3

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts mending hematoma in [target]'s brain with \the [tool].", \
		"You start mending hematoma in [target]'s brain with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='notice'>[user] mends hematoma in [target]'s brain with \the [tool].</span>",	\
		"<span class='notice'>You mend hematoma in [target]'s brain with \the [tool].</span>")
		var/obj/item/organ/brain/sponge = target.internal_organs_by_name["brain"]
		if (sponge)
			sponge.damage = 20

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='danger'>[user]'s hand slips, bruising [target]'s brain with \the [tool]!</span>", \
		"<span class='danger'>Your hand slips, bruising [target]'s brain with \the [tool]!</span>")
		target.apply_damage(20, BRUTE, "head", 1, sharp=1)