//Script for the Reusable Space Plane 3 ascent


declare global stage_num is 2.

// declare local startingFuel to 0. //get the starting fuel amount of this stage for percentage calcs
declare local startingFuel is 0.
lock currFuelPercentage to 0.


//main ascent function
function ascent{



    countdown(). //whats a launch without a countdown?


    declare global successful is true. //checks if launch continues to be successful

    //launch time
    if (launch() = (not successful)){
        
        print "[ascent]: End of program, launch unsuccessful." .
        lock throttle to 0.
        set successful to false.
        return.
        
    }

    print ("[ascent]: liftoff successful").

    
    //once we get to 2000 we'll start calculated gravity turn
    on (ship:altitude > 2000) {

        print ("[ascent]: clear of tower starting gravity turn").
        
        set targetHeading to 90. //we want to go east on compass
   
        //this is a "line of best fit" for ascent profile up to 50km
        //90 - 0.00575x+(1.25E-7)x^2
        lock targetAngle to (90 - (0.00575 * (alt:radar))) + ((1.25E-7) * (alt:radar)^2).
        
        //go on an east heading, at calculated angle, "wings" level with horizon
        lock steering to heading(targetHeading, targetAngle, 0). 

        //start making adjustments to be at 1.4 twr constantly
        if (ship:availablethrust > 0){
            print ("[ascent]: avail thrust is more than 0").
            set gravity to ((body:mu) / (ship:altitude + body:radius)^2).
            set desired_twr to 1.4.

    
            set calced_twr to (desired_twr * gravity * ship:mass)/ship:availableThrust.
            lock throttle to calced_twr.
            print ("[ascent]: calc twr is " + calced_twr).
        }

    }

    //once we get to 10km we'll smooth it out until ~32km
    on (ship:altitude >= 10000){
        
        print("[ascent]: at 10km staying at 43 until 25000").
       
        // lock targetAngle to (48.33 - (0.00083 * alt:radar)).
        lock steering to heading(targetHeading, 43, 0).

    }

    //more linear at 25km
    on (ship:altitude >= 25000){

        print("[ascent]: at 25km switching to even more linear gravity turn").
        
        lock targetAngle to (57.5 - (0.0007 * alt:radar)).
        lock steering to heading(targetHeading, targetAngle, 0).

        //adjust thrust to 1.25
        if (ship:availablethrust > 0){
    
            set desired_twr to 1.25.
            set calced_twr to (desired_twr * gravity * ship:mass)/ship:availableThrust.
            lock throttle to calced_twr.
            print ("calc twr is " + calced_twr).
        }

    }

    on (ship:altitude >= 35000){

        print("[ascent]: at 35km linear gravity turn").
        
        lock targetAngle to ( 84.33 - ((-3.33E-9) * alt:radar^2) - (0.0014 * alt:radar)).
        lock steering to heading(targetHeading, targetAngle, 0).

    }

    on (ship:altitude >= 48000){

        print("[ascent]: at 48km going straight to 0 pitch").
        
        // lock targetAngle to ( 84.33 - ((-3.33E-9) * alt:radar^2) - (0.0014 * alt:radar)).
        lock steering to heading(targetHeading, 2, 0).

    }

    on (ship:apoapsis >= 75000) {

        // print("[ascent]:  exiting and launching other script").
        // runOncePath("0:/circ.ks").
        
        lock throttle to 0.
        print("[ascent]: apoapsis is at 75km, should stop here").
        return.

    }

    
    //keep running this script until we get to 75km or launch turns unsuccessful
    until (ship:apoapsis >= 750000){ 
    
        stageShip().

    }


}





//-----------------Helper Functions----------------------------------//

//countdown from 10 
//change countdown_start var for different needs
function countdown{

    set column to terminal:height / 2.
    set row to terminal:width / 2.

    clearScreen.

    declare local countdown_start is 5.
    print ("Countdown:") at (column, row).
    from {countdown_start.} until countdown_start = 0 step {set countdown_start to countdown_start - 1.} do {
        print ("T - " + countdown_start) at (column, row + 1).
        wait 1.
    }

    clearScreen.

}


function launch{

    lock throttle to 1.
    print "[ascent]: Liftoff!".

    
    wait .1.
    if (stage:ready) {


        stage.
        
        set startingFuel to stage:liquidfuel. //get the starting fuel amount of this stage for percentage calcs
        print("[ascent]:starting fuel is "+ startingFuel).
        lock currFuelPercentage to (stage:liquidfuel / startingFuel).
    
    }

    else{
        print "[ascent]: failed to launch".
        return false. //launch went bad
    }

    wait 2.
    lock steering to heading(90, 90).

    return true.
}



//stays on stage until
function stageShip{

    // stage:liquidfuel

    set ready_to_stage to false.

    list engines in engs.
    until ready_to_stage{

        for e in engs{
            if e:ignition{
                
                
                if (e:flameout){
                    set ready_to_stage to true.
                }

                //we only want to keep some fuel on this reusable stage
                if (stage_num = 2){
                    print("curr fuel percentage " + currFuelPercentage) at (terminal:height/2, terminal:width/2).
                    if(currFuelPercentage <= 0.12){
                        set ready_to_stage to true.
                    }
                }
            
            }
        }

        wait 0.1.

    }
        

    print ("[ascent]: dropping stage: " + stage_num).
    set stage_num to (stage_num - 1).

    stage.

    set startingFuel to stage:liquidfuel.
    lock currFuelPercentage to (startingFuel / stage:liquidfuel).

    print " ". print ("[ascent]: now on stage " + stage_num).

}