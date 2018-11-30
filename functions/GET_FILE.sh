# Provides the functionality of wget
GET_FILE() {
    # If no argument is given, return
    [ "$1" = "" ] && return 1;
    [ "$2" = "" ] && return 1;
    QUIET command -v "wget";
    get_w="$?";
    # Check if any methods exist
    if [ "$get_w" != "0" ]; then
	    LOG 2 "No downloads available";
	    return 1;
    fi;
    QUIET wget -qO $2 $1;
    return $?;
};

