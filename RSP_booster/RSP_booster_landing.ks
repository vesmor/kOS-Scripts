//for reusable boosters to land back on kerbin

function main{

    waitForSep().
    print ("[reusable_booster]: new 1 time to hoverslam (with parachutes)!").

    //stopping distance
    //  v^2 / 2a
    
    print ("[reusable_booster]: locking to " + heading(270, -5, 0)).
    rcs on.
    brakes on.
    lock steering to heading(270, -5, 0).


    on (ship:altitude <= 5000){

        set target_speed to 300.

        print ("[reusable_booster]: locking to srfretro and firing").
        lock steering to srfRetrograde.

        AG1 on.
        print ("[reusable_booster]: switching to 2 engines").

        lock throttle to 1.
        wait until (ship:airspeed <= target_speed).
        print ("[reusable_booster]: firing done").
        
        chutes on.
        print ("[reusable_booster]: deploying chutes").

        lock throttle to .3.
        print ("[reusable_booster]: throttle 30%").

        wait 1.

        lock throttle to 0.
        print ("[reusable_booster]: done").

    }

    on (alt:radar <= 2000){

        print ("[reusable_booster]: at 2000").

        lock throttle to 1.
        wait until (ship:airspeed <= 20).

        lock throttle to 0.

    }

    on (alt:radar <= 150){
        print ("[reusable_booster]: gear coming down").
        gear on.

        lock throttle to .3.

        wait until (ship:verticalspeed >= 0).

        lock throttle to 0.
    }

    //need to add point where booster does an entry burn to slow down so that we can safely deploy parachutes
    // maybe we can solve for how long to burn with
    // t = ((mass_booster) * (targetSpeed - currentSpeed)) / availableThrust
    on (alt:radar <= 30000){


        //get how long we need to burn to get down to roughly 300m/s 

        AG1 on.
        print ("[reusable_booster]: turning 2 engines on").

        set targetSpeed to 800.
        set delta_speed to (targetSpeed - ship:airspeed). 

        set burn_time to (ship:mass) * (delta_speed / ship:availablethrustat(ship:altitude)).
        set burn_time to round(abs(burn_time)).

        print ("[reusable_booster]: at 30km going to burn for " + burn_time + "to slow down to "+targetSpeed).

        // start_time = time:seconds
        //when burn_time == (time:seconds - start_time)
        //leave loop

        lock steering to srfPrograde.
        lock throttle to 1. //go full burn.
        set start_time to time:seconds.
        print ("[reusable_booster]: start time is "+ start_time).

        wait until (ship:airspeed <= targetSpeed). //keep throttle locked

        
        print ("[reusable_booster]: burn finished").
        lock throttle to 0.

    
    }


    wait until (alt:radar <= 0). //stop the script when we get on the ground
    print("End of reusable landing process.").

}
//entry point
main().



//-------Helper Functions------/

//hanging program here until booster seperation
function waitForSep{
    set seperated to false.

    until (seperated){
            
        if(not exists("0:/seperated.json")){

            print ("[reusable_booster]: seperated.json not found.").

        }

        else{
            set s to readJson("0:/seperated.json").
            print ("[reusable_booster]: seperated is " + s["seperated"]).
            
            set seperated to s["seperated"].
            
            if (seperated = false) { 
                print ("[reusable_booster]: seperated was false in json shutting down"). 
                shutdown.
            }
        }

        wait 2.

    }
}

