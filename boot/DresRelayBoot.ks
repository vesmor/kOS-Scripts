@lazyGlobal off.


function boot{

    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
    runpath("0:/DresRelay/RelayLaunchEventListener.ks").

}

wait until (ship:unpacked).
boot().