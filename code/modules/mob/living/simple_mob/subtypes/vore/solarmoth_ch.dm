/datum/category_item/catalogue/fauna/solarmoth		//TODO: VIRGO_LORE_WRITING_WIP
	name = "Solarmoth"
	desc = "An adult variation of a solargrub, these winged critters are very deadly. They seem to heat up everything nearby, \
	turning ordinary rooms into infernos, and causing malfunctions across the station. They are so hot that laser weaponry is like throwing an ice cube at them. \
	Bullets will melt in the face of them and only cause minor damage from the melted matter. \
	Melee seems to be thier weakness as long as the user has appropriate heat protection or if you're quick enough to respond before needing protection. Approach with caution."
	value = CATALOGUER_REWARD_MEDIUM

/mob/living/simple_mob/vore/solarmoth
	name = "solarmoth"
	desc = "A majestic sparkling solarmoth. Also a slight engineering hazard known to heat rooms equal to temperatures of a white dwarf."
	catalogue_data = list(/datum/category_item/catalogue/fauna/solarmoth)
	icon = 'icons/mob/solarmoth.dmi' //all of these are placeholders
	icon_state = "solarmoth"
	icon_living = "solarmoth"
	icon_dead = "solarmoth-dead"

	var/mycolour = COLOR_BLUE //Variable Lighting colours
	var/original_temp = null //Value to remember temp
	var/set_temperature = T0C + 450	//Sets the target point of 450 degrees celsius
	var/heating_power = 100000	//This controls the strength at which it heats the environment. // The number seems ridiculous but this is actually pretty reasonable - Lunar

	faction = "grubs"
	maxHealth = 75 // Tanky fuckers.
	health = 75 // Tanky fuckers.

	melee_damage_lower = 5
	melee_damage_upper = 10

	movement_cooldown = 5

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/grubmeat

	response_help = "pokes"
	response_disarm = "pushes"
	response_harm = "roughly pushes"

	ai_holder_type = /datum/ai_holder/simple_mob/retaliate
	say_list_type = /datum/say_list/solarmoth

	var/poison_per_bite = 5 //grubs cause a shock when they bite someone
	var/poison_type = "shockchem"
	var/poison_chance = 50
	var/shock_chance = 20 // Beware synths

	// solar moths are not affected by atmos
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	heat_damage_per_tick = 0 //Even if the atmos stuff doesn't work, at least it won't take any damage.

	armor = list(
				"melee" = 0,
				"bullet" = 0,
				"laser" = 0,
				"energy" = 0,
				"bomb" = 0,
				"bio" = 0,
				"rad" = 0)

/datum/say_list/solarmoth
	emote_see = list("flutters")

/mob/living/simple_mob/vore/solarmoth/apply_melee_effects(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(prob(shock_chance))
			A.emp_act(4) //The weakest strength of EMP
			playsound(src, 'sound/weapons/Egloves.ogg', 75, 1)
			L.Weaken(4)
			L.Stun(4)
			L.stuttering = max(L.stuttering, 4)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, L)
			s.start()
			visible_message("<span class='danger'>The moth releases a powerful shock!</span>")
		else
			if(L.reagents)
				var/target_zone = pick(BP_TORSO,BP_TORSO,BP_TORSO,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_HEAD)
				if(L.can_inject(src, null, target_zone))
					inject_poison(L, target_zone)

// Does actual poison injection, after all checks passed.
/mob/living/simple_mob/vore/solarmoth/proc/inject_poison(mob/living/L, target_zone)
	if(prob(poison_chance))
		to_chat(L, "<span class='warning'>You feel a small shock rushing through your veins.</span>")
		L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_mob/vore/solarmoth/Life()
	. = ..()
	if(icon_state != icon_dead) //I mean on death() Life() should disable but i guess doesnt hurt to make sure -shark
		var/datum/gas_mixture/env = loc.return_air() //Gets all the information on the local air.
		var/transfer_moles = 0.25 * env.total_moles //The bigger the room, the harder it is to heat the room.
		var/datum/gas_mixture/removed = env.remove(transfer_moles)
		var/heat_transfer = removed.get_thermal_energy_change(set_temperature)
		if(heat_transfer > 0 && env.temperature < T0C + 200)	//This should start heating the room at a moderate pace up to 200 degrees celsius.
			heat_transfer = min(heat_transfer , heating_power) //limit by the power rating of the heater
			removed.add_thermal_energy(heat_transfer)

		else if(heat_transfer > 0 && env.temperature < set_temperature) //Set temperature is 450 degrees celsius. Heating rate should increase between 200 and 450 C.
			heating_power = original_temp*100
			heat_transfer = min(heat_transfer , heating_power) //limit by the power rating of the heater. Except it's hot, so yeah.
			removed.add_thermal_energy(heat_transfer)

		else
			return

		env.merge(removed)



	//Since I'm changing hyper mode to be variable we need to store old power
	original_temp = heating_power //We remember our old goal, for use in non perpetual heating level increase



/mob/living/simple_mob/vore/solarmoth/handle_light()
	. = ..()
	if(. == 0 && !is_dead())
		set_light(9.5, 1, mycolour) //9.5 makes the brightness range super huge.
		return 1


/mob/living/simple_mob/vore/solarmoth //active noms
	vore_bump_chance = 50
	vore_bump_emote = "applies minimal effort to try and slurp up"
	vore_active = 1
	vore_capacity = 1
	vore_pounce_chance = 0 //moths only eat incapacitated targets. It's too lazy burning you to a crisp to try to pounce you
	vore_default_mode = DM_DIGEST

/mob/living/simple_mob/vore/solarmoth/lunarmoth
	name = "lunarmoth"
	desc = "A majestic sparkling lunarmoth. Also a slight engineering hazard."
	cold_damage_per_tick = 0
	//ATMOS
	set_temperature = T0C - 450
	heating_power = -100000
	//light
	mycolour = COLOR_WHITE


