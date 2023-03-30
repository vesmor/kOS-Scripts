
function boot{
    core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
    runpath("0:/RSP_plane/RSP_nav.ks").
}

boot().