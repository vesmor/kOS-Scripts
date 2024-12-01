@lazyGlobal off.

//for reusable boosters to land back on kerbin

local tagStr to "[reusable_booster]: ".

function main{

    waitForSep().
    print (tagStr + "new 1 time to hoverslam (with parachutes)!").

    //stopping distance
    //  v^2 / 2a
    
    local fallingHeading to heading_of_vector(retrograde:vector).
    print (tagStr + "locking to " + heading(fallingHeading, -5, 0)).
    sas off.
    rcs on.
    brakes on.
    lock steering to heading(fallingHeading, -5, 0).

    //need to add point where booster does an entry burn to slow down so that we can safely deploy parachutes
    // maybe we can solve for how long to burn with
    // t = ((mass_booster) * (targetSpeed - currentSpeed)) / availableThrust
    on (alt:radar <= 30000){


        //get how long we need to burn to get down to roughly 300m/s 

        AG1 on.
        print (tagStr + "turning 2 engines on").

        declare local targetSpeed to 800.
        declare local delta_speed to (targetSpeed - ship:airspeed). 

        declare local burn_time to (ship:mass) * (delta_speed / ship:availablethrustat(ship:altitude)).
        set burn_time to round(abs(burn_time)).

        print (tagStr + "at 30km going to burn for " + burn_time + "to slow down to " + targetSpeed).

        // start_time = time:seconds
        //when burn_time == (time:seconds - start_time)
        //leave loop

        lock steering to srfPrograde.
        lock throttle to 1. //go full burn.
        declare local start_time to time:seconds.
        print (tagStr + "start time is "+ start_time).

        wait until (ship:airspeed <= targetSpeed). //keep throttle locked

        
        print (tagStr + "burn finished").
        lock throttle to 0.

    
    }

    on (ship:altitude <= 5000){

        declare local target_speed to 300.

        print (tagStr + "locking to srfretro and firing").
        lock steering to srfRetrograde.

        AG1 on.
        print (tagStr + "switching to 2 engines").

        lock throttle to 1.
        wait until (ship:airspeed <= target_speed).
        print (tagStr + "firing done").
        
        chutes on.
        print (tagStr + "deploying chutes").

        lock throttle to .3.
        print (tagStr + "throttle 30%").

        wait 1.

        lock throttle to 0.
        print (tagStr + "done").

    }

    on (alt:radar <= 2000){

        print (tagStr + "at 2000").

        lock throttle to 1.
        wait until (ship:airspeed <= 20).

        lock throttle to 0.

    }

    on (alt:radar <= 150){
        print (tagStr + "gear coming down").
        gear on.

        lock throttle to .5.

        wait until (ship:verticalspeed >= 0).

        lock throttle to 0.
    }

  


    wait until (alt:radar <= 0). //stop the script when we get on the ground
    print("End of reusable landing process.").
    

    //let process know we are done and reset
    local L to lexicon().
    L:add("seperated", false).
    L:add("landed", true).
    writeJson(L, "0:/seperated.json").

}


//entry point
main().



//-------Helper Functions------/

//hanging program here until booster seperation
function waitForSep{

    if(not exists("0:/seperated.json")){

        print (tagStr + "seperated.json not found.").
        print (tagStr + "shutting down.").

        shutdown.
    }


    declare local s to readJson("0:/seperated.json").
    local seperated to s["seperated"].
    local landed to s["landed"].

    until (seperated and (not landed)){
            
        if ((seperated = false) and (landed = true)) { 
            print (tagStr + "We probably havent launched yet"). 
        }

        else if((seperated = false) and (landed = false)){
            print (tagStr + "Not yet seperated").
        }
        
        else if((seperated = true) and (landed = true)){
            print (tagStr + "We should have finished landed by now").
            
            //reset state at this point
            set seperated to s["seperated"].
            set landed to s["landed"].
            writeJson(s, "0:/seperated.json").
        }


        set s to readJson("0:/seperated.json").
        set seperated to s["seperated"].
        set landed to s["landed"].

        wait 2.

    }
}


//function gotten from reddit (https://www.reddit.com/r/Kos/comments/aytesl/kos_get_bearing_of_prograde_and_not_of/)
//calculates the heading a vector is on using vector math and trig
FUNCTION heading_of_vector { // heading_of_vector returns the heading of the vector (number range 0 to 360)
	PARAMETER vecT.

	LOCAL east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).

	LOCAL trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
	LOCAL trig_y IS VDOT(east, vecT).

	LOCAL result IS ARCTAN2(trig_y, trig_x).

	IF result < 0 {RETURN 360 + result.} ELSE {RETURN result.}
}

