//introduction lines stolen from one of the mods, I don't even remember, they all have them.
if (!("Entities" in this)) return;
if ("throwLiteralShit" in this) return;
IncludeScript("ppmod3");

local auto = Entities.CreateByClassname("logic_auto");
ppmod.addscript(auto, "OnMapTransition", "throwLiteralShit.setup()");
ppmod.addscript(auto, "OnNewGame", "throwLiteralShit.setup()");


//TODO make poop throw further

::throwLiteralShit <- {
	triggered = null,//keeps track of what we already triggered
    setup = function() {
		//something important, I guess.
        ppmod.player.enable();
		
		//f key pressing capture. stolen from SMO mod.
        SendToConsole("alias +mouse_menu \"script throwLiteralShit.throwShit()\"");
		
		//precaching model. Stolen from Maxwell mod.
		ppmod.create("prop_dynamic_create poo/poo.mdl",function (cache) {
			this.cache <- cache
			ppmod.fire(cache,"disablemotion")
			ppmod.wait(function () {
				ppmod.fire(cache,"kill")
			},0.1)
		})
		//poo model stolen from Garry's mod addon 304354340
		
		ppmod.interval (function() {
			if(!throwLiteralShit.last) return;
			//Can we use triggers or something??? I never coded for Portal 2.
			
			//TODO check that shit is not fizzled or smth
			
			//trying to find a floor button nearby
			local button = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_floor_button", 50);
			if(button) {
				local buttonName = button.GetName();
				if(throwLiteralShit.triggered == buttonName) return;//Do not activate button if already activated
				printl("found button!")
				ppmod.fire(button, "pressin")
				//Next line (and concept it implements) stolen from ecopchtal's mapspawn.nut
				ppmod.addoutput(button, "OnUnpressed", "!self", "pressin", "", 1);
				throwLiteralShit.triggered = buttonName//keep track what we activated
			}
			
			//trying to find cube button
			local cubeButton = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_floor_cube_button", 50);
			if(cubeButton) {
				local buttonName = cubeButton.GetName();
				if(throwLiteralShit.triggered == buttonName) return;//Do not activate button if already activated
				printl("found cubeButton!")
				//ppmod.fire(cubeButton, "pressin")//this crashes my game for some reason
				SendToConsole("ent_fire " + buttonName + " pressin")//this do not
				throwLiteralShit.triggered = buttonName//keep track what we activated
			}
			
			//trying to find sphere button
			local ballButton = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_floor_ball_button", 50);
			if(ballButton) {
				local buttonName = ballButton.GetName();
				if(throwLiteralShit.triggered == buttonName) return;//Do not activate button if already activated
				printl("found ballButton!")
				//ppmod.fire(ballButton, "pressin")//Never tryed this for sphere button, but for cube this crashes my game for some reason
				SendToConsole("ent_fire " + buttonName + " pressin")//this do not
				throwLiteralShit.triggered = buttonName//keep track what we activated
			}
			
			//trying to find pedestal button
			local pedestalButton = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_button", 50);
			if(pedestalButton) {
				local buttonName = pedestalButton.GetName();
				if(throwLiteralShit.triggered == buttonName) return;//Do not activate button if already activated
				printl("found pedestalButton!")
				ppmod.fire(pedestalButton, "press")
				throwLiteralShit.triggered = buttonName//keep track what we activated
			}
			
			//trying to find laser receptacle nearby
			local laserCatcher = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_laser_catcher", 50);
			if(laserCatcher) {
				local receptacleName = laserCatcher.GetName();
				if(throwLiteralShit.triggered == receptacleName) return;
				printl("found laserCatcher!")
				//ppmod.fire(laserCatcher, "")//This is not how it works
				
				//stolen from epochtal's splits.nut
				ppmod.create("env_portal_laser", function (emitter):(laserCatcher) {
					emitter.SetOrigin(laserCatcher.GetOrigin() - laserCatcher.GetForwardVector() * 64);
					emitter.SetForwardVector(laserCatcher.GetForwardVector());
					ppmod.fire(emitter, "TurnOn");
					
					//Next line is not stolen
					ppmod.fire(emitter, "DisableDraw")
				});
				throwLiteralShit.triggered = receptacleName
			}
			
			//trying to find laser relay nearby
			local laserRelay = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_laser_relay", 50);
			if(laserRelay) {
				local receptacleName = laserRelay.GetName();
				if(throwLiteralShit.triggered == receptacleName) return;
				printl("found laserRelay!")
				//ppmod.fire(laserRelay, "")//This is not how it works
				
				//stolen (but then modified) from epochtal's splits.nut
				ppmod.create("env_portal_laser", function (emitter):(laserRelay) {
					emitter.SetForwardVector(laserRelay.GetUpVector());
					emitter.SetOrigin(laserRelay.GetOrigin() - laserRelay.GetUpVector() * 56 + emitter.GetUpVector()*8);
					ppmod.fire(emitter, "TurnOn");
					
					//Next line is not stolen
					ppmod.fire(emitter, "DisableDraw")
				});
				throwLiteralShit.triggered = receptacleName
			}
			
			//trying to find door nearby
			local door = ppmod.get(throwLiteralShit.last.GetOrigin(), "prop_testchamber_door", 50);
			if(door) {
				//TODO do not activate activated door.
				local doorName = door.GetName();//name of a door
				local doorNameWithoutShit = doorName.slice(0, doorName.find("-"));//name of a door without that part which is not is
				printl("found door!")
				printl(doorName)
				printl(doorNameWithoutShit)
				ppmod.fire(door, "open")//open door
				//door has clipbrushes, Let's find them
				local door_physics_clip = ppmod.get(doorNameWithoutShit+"-door_physics_clip")
				local door_player_clip = ppmod.get(doorNameWithoutShit+"-door_player_clip")
				printl(door_physics_clip)
				printl(door_player_clip)
				//and remove them if found
				if(door_physics_clip)
					ppmod.fire(door_physics_clip, "Disable")
				if(door_player_clip)
					ppmod.fire(door_player_clip, "Disable")
			}
			
			//TODO put map specific stuff outside this interval
			//Specific maps have some weird shit.
			if(GetMapName() == "sp_a1_intro7") {
				//door Whealtey opens
				local poo = throwLiteralShit.last.GetOrigin()//our shit is here
				//Calculate distance by hand
				local distance = pow(pow(-992-poo.x, 2)+pow(-528-poo.y, 2)+pow(1256-poo.z, 2), 0.5)
				printl(distance)
				//if poop close enough activate stuff
				if(distance < 60 && throwLiteralShit.triggered != "Mysheus-sp_a1_intro7-door1") {
					ppmod.fire(ppmod.get("bts_panel_door-LR_heavydoor_open"), "trigger")
					throwLiteralShit.triggered = "Mysheus-sp_a1_intro7-door1"
				}
				
				//and for another door as well
				local distance2 = pow(pow(-1418-poo.x, 2)+pow(-413-poo.y, 2)+pow(1208-poo.z, 2), 0.5)
				printl(distance2)
				if(distance2 < 60 && throwLiteralShit.triggered != "Mysheus-sp_a1_intro7-door2") {
					ppmod.fire(ppmod.get("airlock_door-open_door"), "trigger")
					throwLiteralShit.triggered = "Mysheus-sp_a1_intro7-door2"
				}
			}
			
			if(GetMapName() == "sp_a2_bridge_the_gap") {
				local poo = throwLiteralShit.last.GetOrigin()//our shit is here
				//Calculate distance by hand
				local distance = pow(pow(-639-poo.x, 2)+pow(-638-poo.y, 2)+pow(1152-poo.z, 2), 0.5)
				if(distance < 60 && throwLiteralShit.triggered != "Mysheus-sp_a2_bridge_the_gap") {
					ppmod.fire(ppmod.get("trick_door_open_relay"), "trigger")
					throwLiteralShit.triggered = "Mysheus-sp_a2_bridge_the_gap"
				}
			}
			
			//TODO color affected stuff with poop color.
			
			//for sp_a2_bts1
			//ent_fire jailbreak_chamber_lit-power_loss_teleport Enable;ent_fire @jailbreak_begin_logic Trigger;ent_fire @jailbreak_1st_wall_1_2_open_logic Trigger;ent_fire @jailbreak_1st_wall_2_2_open_logic Trigger; ent_fire 
			
			
		}, 0.25)
	},
	last = null,//last shit we threw

    throwShit = function() {
		//TODO check if shit is precached. Cause some times when you die or maybe load save game craches
        printl("throwing literal shit...");
		//reset some shit
		throwLiteralShit.last = null
		throwLiteralShit.triggered = null;
		ppmod.create("prop_physics_create props/food_can/food_can_open.mdl", function(poop) {
			if(!poop) {
				printl("poop creation failed for no reason!");
				throwLiteralShit.throwShit();
				return;
			}
			ppmod.create("ent_create_portal_weighted_cube", function(cube):(poop) {
				//cube here is for propulsion purposes. Shit needs to be thrown, not just fall on the floor. SetVelocity does nothing, so this is the way I found.
				throwLiteralShit.last = poop//This is for... I forgor.
				ppmod.fire(cube, "DisableDraw")//Make propulsion cube invisible
				local angles = ppmod.player.eyes.GetAngles()
				local eyes_vec = ppmod.player.eyes_vec()
				local position = ppmod.player.eyes.GetOrigin()
				ppmod.keyval(poop, "CollisionGroup", 23)//make cube and poop not collide with player
				ppmod.keyval(cube, "CollisionGroup", 23)
				poop.SetAngles( angles.x, angles.y, angles.z);//make them aligned with player orientation
				cube.SetAngles( angles.x, angles.y, angles.z);
				poop.SetOrigin( position);//position them
				cube.SetOrigin( position-eyes_vec*15);
				ppmod.wait (function():(cube, poop){
					ppmod.keyval(poop, "CollisionGroup", 24)//poop is now thrown away, restoring collision with player
					cube.Destroy()//we don't need propulsion cube anymore. His job is done.
				}, 0.25)

				//TODO make shit bigger

				poop.SetModel("models/poo/poo.mdl")
			});
		});
	}
}


//http://src-ents.shoutwiki.com/wiki/CBaseEntity
//https://developer.valvesoftware.com/wiki/List_of_Portal_2_Script_Functions