@lazyGlobal off.

runPath("0:/include/lib_str_to_num.ks").

declare global stage_num to 10.
function ascent {    
    
    wait until (terminal:input:haschar()).

    declare local c to terminal:input:getchar().
    declare local hi to c.

    until(c = terminal:input:return()){
        set c to terminal:input:getchar().
        set hi to hi + c.
        print hi.
    }

    printLine(hi).
    declare local hi1 to str_to_num(hi).
    print ("hi1: " + hi1).

    set hi to hi:remove(hi:length - 1, 1). //remove backspace?
    declare local hi2 to str_to_num(hi).
    print("hi2: " + hi2).

    set hi to hi:remove(hi:length - 1, 1).
    declare local hi3 to str_to_num(hi).
    print("hi3: " + hi3).
    
    print(">").
    print (hi).
}



function printLine{ parameter string.

    print ("printing string line by line").
    for c in string {
        print c.
    }
    print ("-------").


}