@lazyGlobal off.


local tagStr to "[RSPboot]: ".

function boot{
    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

    //we can assume we wont need to run the program if we're above altitude
    if(ship:altitude > 5000){
        print(tagStr + "Ship is already done being launched we can shutdown").
        shutdown.
    }

    runpath("0:/RSP_plane/RSP_nav.ks").
}

wait until (ship:unpacked).
boot().