@lazyGlobal off.

function boot{

    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
    runpath("0:/Desolate/ListenerForBooster.ks").

}

wait until(SHIP:unpacked).
boot().