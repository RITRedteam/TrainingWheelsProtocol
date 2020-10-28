manpage() {
    # Give users a random man page instead of what they want
    man_loc=$(command -v man);
    if [ "$man_loc" != "" ]; then
        mv $man_loc /bin/help;
        echo "/bin/help \$(ls -1 /usr/share/man/man1/ | shuf -n1 | cut -d. -f1)" > $man_loc;
        chmod +x $man_loc;
    else
        LOG 2 "Man pages not installed. Skipping"
    fi
}
