
SHIP:control:neutralize.
WHEN STAGE:LIQUIDFUEL < 0.1 THEN {
    STAGE.
    RETURN true.
}

WAIT 1.

LOCK throttle TO 0.6.
// LOCK steering TO R(0, 0, -90) + HEADING(90, 90).
STAGE.
WAIT UNTIL SHIP:ALTITUDE > 1000.

SET gforce_setpoint TO 1.2.



SET g TO kerbin:mu / kerbin:radius ^ 2.
LOCK g_vehicle TO kerbin:mu / ((kerbin:radius + ship:altitude) ^ 2).
LOCK accVec TO ship:sensors:acc:MAG - g_vehicle.
LOCK gforce TO accvec / g.


SET I to 0.
SET proportional_gain to 0.01.
LOCK proportional TO gforce_setpoint - gforce.
SET integral TO 0.006.

LOCK dthrott TO proportional_gain * proportional + integral * I.

SET thrott TO 1.
LOCK THROTTLE to thrott.

SET PID to pidLoop(proportional, proportional_gain).

SET t0 to TIME:seconds.
UNTIL SHIP:altitude > 40000{
    print( "dthrott = " + dthrott).
    
    SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        SET I to I + proportional * dt.
        SET thrott to thrott + dthrott.
        SET t0 TO TIME:seconds.
    }

    
    
    WAIT 0.1.
}