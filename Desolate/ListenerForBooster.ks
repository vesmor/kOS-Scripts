@lazyGlobal off.

declare local tagStr to "ListenerForBooster: ".

function main{

    //let boosters know we havent done launched yet
    declare local L to lexicon().
    L:add("seperated", false).
    L:add("landed", true).
    writeJson(L, "0:/seperated.json").

    print(tagStr + "Script is up and running, letting boosters know we're on the ground").

    declare local myEng to ship:partstagged("TransferStageEngine")[0].
    if(ship:partstagged("TransferStageEngine"):length = 0){
        print("TransferStageEngine not found. Rebooting").
        wait 2.
        reboot.
    }


    //get the engine status so we know when the booster is seperated. (had to find by listing all the modules)
    declare local myEngModule to myEng:getmodule("ModuleEnginesFX").

    // print(myEngModule:allfields).

    declare local engineStatus to myEngModule:getfield("Status"). 
    // declare local engineStatus to myEng:getmodule("ModuleEnginesFX"):getfield("Status"). //get the status of engine
    print(engineStatus).
    print("Engine status Nominal?: " + engineStatus = "Nominal").
    
    
    wait until ( myEng:getmodule("ModuleEnginesFX"):getfield("Status") = "Nominal").{ //have to repeatedely get the field cuz var doesnt change

        print ("when then triggered.").

        //let the boosters know they can start their process
        set L["seperated"] to true.
        set L["landed"] to false.

        writeJson(L, "0:/seperated.json").

        print(tagStr + "Should have seperated with booster.").
        
        wait 1.


    }
    // when( engineStatus = "Nominal") then{

    //     print ("when then triggered.").

    //     //let the boosters know they can start their process
    //     declare local M to lexicon().
    //     set M["seperated"] to true.
    //     set M["landed"] to false.

    //     writeJson(M, "0:/seperated.json").

    //     print(tagStr + "Should have seperated with booster.").
        
    //     wait 1.


    // }

}

main().