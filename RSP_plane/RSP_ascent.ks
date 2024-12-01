@lazyGlobal off.
runPath("0:/include/lib_str_to_num.ks").

//Script for the Reusable Space Plane 3 ascent


declare global stage_num is 2.

// declare local startingFuel to 0. //get the starting fuel amount of this stage for percentage calcs
declare local startingFuel is 0.
lock currFuelPercentage to 0.

local tagStr to "[ascent]: ".

declare local targetHeading to 90. //heading we want to launch at, default to east


//main ascent function
function ascent{

    //let the boosters know we're on the ground but not seperated
    local L to lexicon().
    L:add("seperated", false).
    L:add("landed", true).
    writeJson(L, "0:/seperated.json").


    //Get user input of what heading we want to launch to
    declare local confirm to "0".
    until(confirm = "1"){ 

        set targetHeading to readInput().
        print("Press 1 to confirm you want to launch to heading of " + targetHeading + "?").

        set confirm to terminal:input:getchar().

    }

    countdown(). //whats a launch without a countdown?

    //let boosters know we launched
    set L["seperated"] to false.
    set L["landed"] to false.
    writeJson(L, "0:/seperated.json").

    declare global successful is true. //checks if launch continues to be successful

    //launch time
    if (launch() = (not successful)){
        
        print (tagStr + "End of program, launch unsuccessful.") .
        lock throttle to 0.
        set successful to false.
        return.
        
    }

    print (tagStr + "liftoff successful").

    //roll program
    on (ship:altitude > 1000){
        print(tagStr + "Roll program to heading: " + targetHeading).
        lock steering to heading(targetHeading, 90).
    }
    
    //once we get to 2000 we'll start calculated gravity turn
    on (ship:altitude > 2000) {

        print (tagStr + "clear of tower starting gravity turn").
        
   
        //this is a "line of best fit" for ascent profile up to 50km
        //90 - 0.00575x+(1.25E-7)x^2
        lock targetAngle to (90 - (0.00575 * (alt:radar))) + ((1.25E-7) * (alt:radar)^2).
        
        //go on an east heading, at calculated angle, "wings" level with horizon
        lock steering to heading(targetHeading, targetAngle, 0). 

        //start making adjustments to be at 1.4 twr constantly
        if (ship:availablethrust > 0){
            print (tagStr + "avail thrust is more than 0").
            declare local gravity to ((body:mu) / (ship:altitude + body:radius)^2).
            declare local desired_twr to 1.4.

    
            declare local calced_twr to (desired_twr * gravity * ship:mass)/ship:availableThrust.
            lock throttle to calced_twr.
            print (tagStr + "calc thrust is " + calced_twr).
        }

    }

    //once we get to 10km we'll smooth it out until ~32km
    on (ship:altitude >= 10000){
        
        print(tagStr + "at 10km staying at 43 until 25000").
       
        // lock targetAngle to (48.33 - (0.00083 * alt:radar)).
        lock steering to heading(targetHeading, 43, 0).

    }

    //more linear at 25km
    on (ship:altitude >= 25000){

        print(tagStr + "at 25km switching to even more linear gravity turn").
        
        lock targetAngle to (57.5 - (0.0007 * alt:radar)).
        lock steering to heading(targetHeading, targetAngle, 0).

        //adjust thrust to 1.25
        if (ship:availablethrust > 0){

            declare local gravity to ((body:mu) / (ship:altitude + body:radius)^2).
    
            declare local desired_twr to 1.5.
            declare local calced_twr to (desired_twr * gravity * ship:mass)/ship:availableThrust.
            lock throttle to calced_twr.
            print ("calc thrust is " + calced_twr).
        }

    }

    on (ship:altitude >= 35000){

        print(tagStr + "at 35km linear gravity turn").
        
        lock targetAngle to ( 84.33 - ((-3.33E-9) * alt:radar^2) - (0.0014 * alt:radar)).
        lock steering to heading(targetHeading, targetAngle, 0).

    }

    on (ship:altitude >= 43000){

        print(tagStr + "at 43km going straight to 0 pitch").
        
        // lock targetAngle to ( 84.33 - ((-3.33E-9) * alt:radar^2) - (0.0014 * alt:radar)).
        lock steering to heading(targetHeading, 2, 0).

        declare local gravity to ((body:mu) / (ship:altitude + body:radius)^2).
        declare local desired_twr to 2.0.
        declare local calced_twr to (desired_twr * gravity * ship:mass)/ship:availableThrust.
        lock throttle to calced_twr.
        print ("calc thrust is " + calced_twr).

    }

    on (ship:apoapsis >= 75000) {

        // print(tagStr + " exiting and launching other script").
        // runOncePath("0:/circ.ks").
        
        lock throttle to 0.
        print(tagStr + "apoapsis is at 75km, should stop here").
        
        //double checking that our reusable boosters are seperated now and sending the signal that they are seperated
        declare local j to readJson("0:/seperated.json").
        declare local seperated to j["seperated"].
        if(seperated = false){
            stageShip().
            L:add("seperated", true).
            L:add("landed", false).
            writeJson(L, "0:/seperated.json").
        }

        kuniverse:pause().
        return.

    }

    
    //keep running this script until we get to 75km or launch turns unsuccessful
    until (ship:apoapsis >= 750000){ 
    
        stageShip().

    }


}





//-----------------Helper Functions----------------------------------//

// reading user input from terminal and sanitize it for what we need
function readInput{

    //stolen from lib_str_to_num, to check if input is a number while its still string
    declare local num_lex   is lexicon(). //sev changed to global so we can use as

    num_lex:add("0", 0).
    num_lex:add("1", 1).
    num_lex:add("2", 2).
    num_lex:add("3", 3).
    num_lex:add("4", 4).
    num_lex:add("5", 5).
    num_lex:add("6", 6).
    num_lex:add("7", 7).
    num_lex:add("8", 8).
    num_lex:add("9", 9).

    declare local targetH to "null".

    clearScreen.
    print("Enter a heading between 0 and 359: ").
    print("input: ").

    wait until (terminal:input:haschar()). //block terminal until we detect a char


    declare local ch to terminal:input:getchar().
    declare local input to ch:trim().

    clearScreen.
    print("Enter a heading between 0 and 359: ").
    print("input: ").
    print(input).


    until(ch = terminal:input:return){

        set ch to terminal:input:getchar().
        
        
        if(ch = terminal:input:backspace){ //take care of backspace
        
            if(input:length > 0){
                set input to input:remove(input:trim:length - 1, 1). //because of weird string stuff u can only delete one character
            }
        }

        else if(not num_lex:haskey(ch)){
            print("Not valid key"). 
        }
        else{
            set input to (input + ch):trim().
        }


        clearScreen.
        print("Enter a heading between 0 and 359: ").
        print("input: ").
        print(input).
    }


    set targetH to str_to_num(input).
    print(tagStr + "targetHeading before input check is " + targetH).
    set targetH to mod(targetH, 360).


    return targetH.
}





//countdown from 10 
//change countdown_start var for different needs
function countdown{

    declare local column to terminal:height / 2.
    declare local row to terminal:width / 2.

    clearScreen.


    declare local beep to getVoice(0). //countdown beep
    declare local countdown_start is 10.
    from {countdown_start.} until countdown_start = 0 step {set countdown_start to countdown_start - 1.} do {
        
        if(terminal:input:haschar){
            break.
        }
        
        print("Press any key to skip countdown.").
        print ("Countdown:") at (column, row).
        print ("T - " + countdown_start) at (column, row + 1).
        
        beep:play(note(360, 0)).
        
        wait 1.
        
        clearScreen.
    }

    beep:play(note(540, 0.5)).
    clearScreen.

}


function launch{

    lock throttle to 1.
    print (tagStr + "Liftoff!").
    print (tagStr + "Target heading is: " + targetHeading).

    
    wait .1.
    if (stage:ready) {


        stage.
        
        set startingFuel to stage:liquidfuel. //get the starting fuel amount of this stage for percentage calcs
        print(tagStr + "starting fuel is "+ startingFuel).
        lock currFuelPercentage to (round(stage:liquidfuel / startingFuel, 2)).
    
    }

    else{
        print tagStr + "failed to launch".
        return false. //launch went bad
    }

    wait 2.
    lock steering to heading(90, 90).

    return true.
}



//stays on stage until
function stageShip{

    // stage:liquidfuel

    declare local ready_to_stage to false.

    local engs is list().
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
        

    print (tagStr + "dropping stage: " + stage_num).
    set stage_num to (stage_num - 1).

    stage.

    set startingFuel to stage:liquidfuel.
    lock currFuelPercentage to (startingFuel / stage:liquidfuel).

    print (" "). print (tagStr + "now on stage " + stage_num).

}




