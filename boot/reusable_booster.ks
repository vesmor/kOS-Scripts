@lazyGlobal off.

function boot{

    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
    runpath("0:/RSP_booster/RSP_booster_landing.ks").

}

wait until (ship:unpacked).
boot().
