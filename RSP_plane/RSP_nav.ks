@lazyGlobal off.

function main{

    local reusable to true.
    local reusable_stage_num to 1. //which stage has the reusable stuff
    local tagStr to "[RSPboot]: ".

    //run the ascent part
    runoncepath("0:/RSP_plane/RSP_ascent.ks").

    //when we get to the reusable booster stage, we'll add the json saying its seperated
    on ((stage_num = reusable_stage_num) and (reusable)) {
        print(tagStr + "its seperated").

        local L to lexicon().
        
        L:add("seperated", true).
        L:add("landed", false).
        writeJson(L, "0:/seperated.json").

    }

    ascent().

    // if (successful){

    //     // local L to lexicon().
        
    //     // L:add("seperated", true).
    //     // L:add("landed", true).

    //     print (tagStr + "was successful").
    //     // deletePath("0:/seperated.json").
    // }

    // print(tagStr + "exiting and launching other script").
    // runoncePath("0:/circ.ks").
    // circ().


}
main().//entry point