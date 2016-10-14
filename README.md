# irssi-dutchop

The irssi-dutchop script provides channel operator commands for channel ops
during the JOTI/JOTA. Please note that game commands are not included in this
script (e.g. the control of Pimpampet).

## Installation

The script can be installed by running the following command:

```bash
wget -nv -O- https://git.bietje.net/bietje/irssi-dutchop/raw/master/irssi-dutchop.pl > ~/.irssi/scripts/irssi-dutchop.pl
```
This will download the script to irssi's default script location. Once
installed, the script can be loaded by running the 'script load' command
in irssi:

```
/script load irssi-dutchop.pl
```

## Usage

Using the script is fairly simple. There are several base commands:

```
/flood
/caps
/nk
/lang
/prive
```

These 5 commands can be used to warn, kick or kick ban users with a preset
reason:

```
/command [[w|warn] | [k|kick] [kb|tb]] [user]
```

To generate a channel wide warning, use the plain command without any
arguments.
