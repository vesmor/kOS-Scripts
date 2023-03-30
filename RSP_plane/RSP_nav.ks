function main{

    set reusable to true.
    set reusable_stage_num to 1. //which stage has the reusable stuff

    //run the ascent part
    runoncepath("0:/RSP_plane/RSP_ascent.ks").

    on ((stage_num = reusable_stage_num) and (reusable)) {
        print("[RSP_boot]: its seperated").

        set L to lexicon().
        
        L:add("seperated", true).
        writeJson(L, "0:/seperated.json").

    }

    ascent().

    if (successful){
        print ("[RSPboot]: Now deleting seperated json").
        deletePath("0:/seperated.json").
    }

    print("[RSPboot]: exiting and launching other script").
    runoncePath("0:/circ.ks").
    circ().



}
main().//entry point