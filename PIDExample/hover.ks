// My first hovering script. This uses a PID controller as I wanted to learn more about it.
// The PID values were chosen at random but these seem to oscillate the least for me from what I've tested.
// At some point I was having trouvle with the oscillations not resolving itself but realized I needed a greater wait time before each PID update.
// I also needed to make sure the PID initialization only set up ONCE and was not put in the loop.


@lazyGlobal off.

DECLARE LOCAL logging IS FALSE.
DECLARE LOCAL targetAltitude IS 100.
DECLARE LOCAL desired_twr IS 1.3.
DECLARE LOCAL startingFuel IS 0.
DECLARE LOCAL endingFlightFuel IS 0.1.
LOCK currFuelPercentage TO 0.
LOCK vehicle_gravity TO ((kerbin:mu) / (ship:altitude + body:radius)^2).


function launch{

    
    // LOCK steering TO R(0, 0, -90) + HEADING(90, 90).
    LOCK throttle TO 1.

    STAGE.
    GEAR off.

    wait 0.1.
    DECLARE LOCAL calced_twr TO (desired_twr * vehicle_gravity * ship:mass) / ship:availableThrust.
    LOCK throttle TO calced_twr.
}



function hover{
    clearScreen.
    WAIT UNTIL SHIP:altitude > targetAltitude - 100.

    wait 1.
    LOCK currFuelPercentage TO (round(ship:liquidfuel / startingFuel, 2)).

   

    DECLARE LOCAL autoThrottle TO 0.
    LOCK THROTTLE TO autoThrottle.
    
    DECLARE LOCAL kP TO 0.2.
    DECLARE LOCAL kI TO 0.25.
    DECLARE LOCAL kD TO 0.25.
    DECLARE LOCAL pid IS PIDLOOP(kP, kI, kD, 0.01, 0.95). 
    DECLARE LOCAL startTime IS TIME:SECONDS.

    SET pid:SETPOINT TO targetAltitude.

    UNTIL currFuelPercentage < endingFlightFuel{
        
       


        SET autoThrottle TO max(0, min(1, pid:UPDATE(TIME:SECONDS, SHIP:ALTITUDE))).
        
        PRINT("curr fuel percentage " + currFuelPercentage) AT (terminal:height/2, terminal:width/2).
        PRINT("pid_loop: " + pid:OUTPUT) AT (0,1).
        PRINT(" ") AT (0,2).
        PRINT(" ") AT (0,3).
        PRINT("throttle: " + autoThrottle) AT (0,7).
        PRINT("Total Error P: " + pid:error) AT (0,8).
        PRINT("Error Sum I: " + pid:ITERM) AT (0,9).
        PRINT("D Term: " + pid:DTERM) AT (0,10).

        if logging{
            LOG (TIME:SECONDS - startTime) + "," + SHIP:ALTITUDE + "," + autoThrottle + "," + pid:ERROR TO "0:/testflight.csv".
        }
        
        WAIT 0.005. //this has to be high enough for the PID calculations to work

    }
}

//The called entry point
function main{
    
    wait 2.

    IF logging {
        LOG "Elapsed Time" + "," + "Altitude" + "," + "Throttle Output" + "," + "Altitude Error" TO "0:/testflight.csv".
    }
    
    
    WAIT 0.01.
    SET startingFuel TO ship:liquidfuel.
    print(startingFuel).
    launch().
    hover().
    CLEARSCREEN.

    PRINT("Passing Control Back to You.").
    DECLARE LOCAL V0 to GetVoice(0).
    V0:PLAY(
    LIST(
        NOTE(440, 0.1),
        NOTE(400, 0.2),
        SLIDENOTE(410, 350, 0.3)
        )
    ).

    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO THROTTLE.
}

// Entry point
main().