@lazyGlobal off.

function boot{

    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
    runpath("0:/PIDExample/PID_Main.ks").
    

}

wait until(SHIP:unpacked).
boot().