# Installs common tools
# WEIGHT 90

tools_install() {
    if [ "`command -v yum`" != "" ]; then
	    TOOL="yum";
    elif [ "`command -v apt-get`" != "" ]; then
	    TOOL="apt-get";
    else
	    LOG 2 "yum and apt-get not found";
	    return 1;
    fi;
    
    TOOLS="curl wget nc nmap net-tools";
    LOGF="/tmp/$TOOL.log";
    $TOOL install -y $TOOLS 2>$LOGF >$LOGF;
    if [ "$?" = "0" ]; then
	    LOG 0 "Installed tools with $TOOL";
	    rm $LOGF
	    return 0;
    else
	    LOG 2 "Could not install tools. Check out $LOGF";
	    return 1;
    fi
}

tools() {
    LOG 1 "Installing tools";
    tools_install;
}
