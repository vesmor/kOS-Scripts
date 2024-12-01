@lazyGlobal off.


function main{

    declare local sideBooster to ship:partstagged("SideBooster")[0].
    declare local centralBoosterKOS to ship:partstagged("CentralBoosterKOS")[0].

    //Reset json for launch
    declare local L to lexicon().
    L:add("seperated", false).
    L:add("landed", true).
    writeJson(L, "0:/seperated.json").

    declare local sideBoosterDecoupled to sideBooster:decoupledin.
    declare local centralBoosterDecoupled to centralBoosterKOS:decoupledin.

    print("Remember to turn off Central Booster kOS power before launch.") at (terminal:height/2 , terminal:width/2).
    centralBoosterKOS:getmodule("kOSProcessor"):doevent("toggle power").
    // print(centralBoosterKOS:allmodules).
    
    declare local startingFuel to ship:liquidfuel.

    lock currFuelPercentage to (round(stage:liquidfuel / startingFuel, 2)).

    
    wait until(ship:altitude > 150).
    
    clearScreen. 
    print(currFuelPercentage).
    
    print("We've launched, letting boosters know.").
    set L["seperated"] to false.
    set L["landed"] to false.
    writeJson(L, "0:/seperated.json").


    
    wait until(stage:number <= sideBoosterDecoupled).
    
    print("Side boosters decoupled").
    set L["seperated"] to true.
    set L["landed"] to false.
    writeJson(L, "0:/seperated.json").



    //we'll turn on the kos power so it can read the json file and start landing
    wait until(stage:number <= centralBoosterDecoupled).
    // kuniverse:forceactive("Central Booster Probe").
    set centralBoosterKOS to vessel("Central Booster Probe"):partstagged("CentralBoosterKOS")[0].
    centralBoosterKOS:getmodule("kOSProcessor"):doevent("toggle power").
    
    // kuniverse:forceactive("Dres Relays").
    print("Central booster decoupled").



}

main().