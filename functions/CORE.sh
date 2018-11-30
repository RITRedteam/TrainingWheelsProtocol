# CORE functions that TitanFall depends on
# Suppress the output of a command and return the result
QUIET (){
    eval $@ 2>/dev/null >/dev/null
    return $?
}

# Destroys a file and returns the status
DESTROY() {
    [ "$1" = "" ] && return 1
    OPENFILE $1 
    # Try to shred the file
    QUIET command -v shred
    [ $? = 0 ] && shred $1
    # Try to remove the file
    rm -f $1
    if [ "$?" != 0 ]; then
	# If you cant remove it, overwrite it
	head -n 100 /dev/urandom > $1
    fi
    res=$?
}

INIT() {    
    LOG 1 "Standbye for TitanFall"
    TRAP
}

FINISH() {
    LOG warn "Deleting self..."
    QUIET shred $0;
    rm -fr $0 && exit;
}

