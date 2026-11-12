# Security

Please report a vulnerability privately through
[GitHub's private vulnerability reporting](https://github.com/Pacabase/taka/security/advisories/new),
not in a public issue. You'll get a reply within a week.

Taka stores no secrets. It runs the system's `ssh` through
[`system_ssh`](https://github.com/Pacabase/system_ssh), so keys, passwords
and `~/.ssh/config` stay entirely with OpenSSH and its agent. A new server's
host key goes into `known_hosts` only once you click Trust: the line is the
one ssh itself produced for that key, added unchanged. Its tunnels file holds only names, hosts and ports. The app and its agent talk
over a Unix socket in the user's own application support folder.
