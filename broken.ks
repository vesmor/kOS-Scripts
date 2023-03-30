print "hello".
wait 1.

lock throttle to 1.
print("throttle to 1").
wait 2.

// lock targetPitch to 88.963-1.03287 * alt:radar^0.409511.
// set targetDirection to 90.
// lock steering to heading(targetDirection, targetPitch).


// lock targetDirection to 90.

//start slight grav turn
when ship:altitude > 5000 then{
    print "alt 5000".
    SAS off.
    lock steering to heading(90, 15, 1).
    
}

//does not well understoof gracity turn
when ship:altitude > 10000 then{
    print "10000 i guess".
    lock targetPitch to 88.963-1.03287 * alt:radar^0.409511.
    lock targetDirection to 90.
    lock steering to heading(targetDirection, targetPitch, 1).
}

//makes sure that we stop firing when we get into orbit
when ship:periapsis >= 75000 then{
    lock throttle to 0.
    print ("in orbit hopefully").
}

//when the apoaopsis gets to 75km we'll switch over to a circulization burn
when ship:apoapsis >= 75000 then{

    lock throttle to 0.
    print("ap is at 75km switching to circ script").
    runPath("0:/circ.ks").


}


when ship:altitude > 74000 then {

    print("ship is at 74km").
    lock steering to heading(90, 0).
    lock throttle to .7.

}

stage. print "Liftoff stage".
until STAGE:LIQUIDFUEL < 0.1{
    printDirection().
    // clearScreen.
}

//6
stage. print "stage 6".
until STAGE:LIQUIDFUEL < 0.1{
    printDirection().
    // clearScreen.
}

//5
stage. print "stage 5".
until STAGE:LIQUIDFUEL < 0.1{
    printDirection().
    lock steering to heading(90, 1, 0).
    // clearScreen.
}

//4
stage. print "stage 4".
until (STAGE:LIQUIDFUEL < 0.1){
    printDirection().
    lock throttle to 0.
    // clearScreen.
}



when ship:verticalspeed < 25 and ship:periapsis < 70000 then{
    AG1 on.
}

when ship:altitude < 10000 then{
    AG3 on.
}





//Functions
function printDirection{

    print ("Direction :") at (18, 9).
    print (ship:direction()) at (18, 10).
    wait .001
    .

}