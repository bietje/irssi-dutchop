#
# irssi dutchop commands
#

use strict;
use warnings;
use 5.018;
use vars qw($VERSION %IRSSI);
use Irssi;

$VERSION = '0.1.0';
%IRSSI = (
    authors     => 'Michel (bietje) Megens',
    contact     => 'dev@bietje.net',
    name        => 'irssi-dutchop',
    description => 'Manage channels during the JOTI with irssi-dutchop. ',
    license     => 'GPLv3',
);

# Channel warnings
my $cflood = 'Wil je niet teveel (onzin) achter elkaar typen? Als je de aandacht wil, zorg dan dat je origineel bent en praat lekker mee of spreek iemand aan.';
my $ctaal = 'Zou je alsjeblieft op je taalgebruik willen letten. Ik zou het jammer vinden als ik iemand uit dit chatkanaal zou moeten verwijderen om zoiets kinderachtigs.';
my $cprive = 'Je kan beter geen privégegevens doorgeven. Dit kan later vervelende gevolgen hebben zoals bijvoorbeeld stalkers. Besluit je toch om gegevens door te geven, doe dat dan in een privebericht.';
my $ccaps = 'Alleen maar hoofdletters gebruiken wordt gezien als schreeuwen en is erg onvriendelijk. Hiervoor mag ik je verwijderen uit dit chatkanaal. Dit wil ik graag voorkomen met deze waarschuwing.';

# kick messages
my $kick_taal = 'Jouw taalgebruik is niet wenselijk';
my $kick_flood = 'Onzin typen is storend. Helaas is je enthousiasme niet te temmen.';
my $kick_nick = 'Jouw nickname is niet wenselijk, verander hem met /nick';

sub warn_msg
{
	my ($message, $data, $server, $witem) = @_;
	if (!$server || !$server->{connected}) {
		Irssi::print("Not connected to server");
	      return;
	}

	if ($data) {
	      $server->command("MSG ".$witem->{name}." $data, ".lcfirst($message));
	} elsif ($witem && ($witem->{type} eq "CHANNEL" ||
				$witem->{type} eq "QUERY")) {
		# there's query/channel active in window
		$witem->command("MSG ".$witem->{name}." $message");
	} else {
		Irssi::print("Nick not given, and no active channel/query in window");
	}
}

sub kick_msg
{
	my ($message, $data, $server, $witem) = @_;

	Irssi::print("No target nick given") unless $data;

	if($witem && $witem->{type} ne "CHANNEL") {
		Irsii::print("Can only kick when the active window is a channel");
	} else {
		$witem->command("KICK ".$witem->{name}." ".$data." $message");
	}
}

sub timeout_msg
{
	my ($message, $data, $server, $witem) = @_;

	Irssi::print("No target nick given") unless $data;

	if($witem && $witem->{type} ne "CHANNEL") {
		Irsii::print("Can only kick when the active window is a channel");
	} else {
		$witem->command("KNOCKOUT 120 ".$data." $message");
	}
}

sub do_action
{
	my ($msg, $data, $server, $witem) = @_;

	if($data) {
		my ($action, $target) = split /\s*:\s*/, $data, 2;

		Irsii::print("action: $action - target: $target");
		$target = $action unless $target;

		given ($action) {
			kick_msg($msg, $target, $server, $witem) when ['k', 'kick'];
			default { warn_msg($msg, $target, $server, $witem) }
		}
	} else {
		# Nothing is up, just a playing channel warning.
		warn_msg($msg, $data, $server, $witem);
	}
}

# Channel/nick warnings
sub cmd_cflood
{
	my ($data, $server, $witem) = @_;

	Irsii::print("Hello");
	#do_action($cflood, $data, $server, $witem);
}

sub cmd_ccaps
{
	my ($data, $server, $witem) = @_;
	
	warn_msg($ccaps, $data, $server, $witem);
}

sub cmd_cprive
{
	my ($data, $server, $witem) = @_;

	warn_msg($cprive, $data, $server, $witem);
}

sub cmd_ctaal
{
	my ($data, $server, $witem) = @_;

	warn_msg($ctaal, $data, $server, $witem);
}

# Kicks
sub cmd_kflood
{
	my ($data, $server, $witem) = @_;
	
	kick_msg($cflood, $data, $server, $witem);
}

sub cmd_kcaps
{
	my ($data, $server, $witem) = @_;
	
	kick_msg($ccaps, $data, $server, $witem);
}

sub cmd_kprive
{
	my ($data, $server, $witem) = @_;

	kick_msg($cprive, $data, $server, $witem);
}

sub cmd_ktaal
{
	my ($data, $server, $witem) = @_;

	kick_msg($ctaal, $data, $server, $witem);
}

Irssi::command_bind('flood', 'cmd_cflood');
Irssi::command_bind('taal', 'cmd_ctaal');
Irssi::command_bind('prive', 'cmd_cprive');
Irssi::command_bind('caps', 'cmd_ccaps');

Irssi::command_bind('kflood', 'cmd_kflood');
Irssi::command_bind('ktaal', 'cmd_ktaal');
Irssi::command_bind('kprive', 'cmd_kprive');
Irssi::command_bind('kcaps', 'cmd_kcaps');
