#
# irssi dutchop commands
#

use strict;
use warnings;
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

my %flood_msg = (
	'warn' => 'Wil je niet teveel (onzin) achter elkaar typen? Als je de ' .
		  'aandacht wil, zorg dan dat je origineel bent en praat '.
		  'lekker mee of spreek iemand aan.',
	'kick' => 'Teveel (onzin) typen is storend. Helaas is je enthousiasme ' .
		  'niet te temmen.',
	'ban'  => 'Teveel (onzin) typen is storend. Helaas is je enthousiasme ' .
		  'niet te temmen.',
);

my %lang_msg = (
	'warn' => 'Zou je alsjeblieft op je taalgebruik willen letten? Ik zou ' .
		  'het jammer vinden als ik iemand uit dit chatkanaal zou moeten verwijderen.',
	'kick' => 'Je taalgebruik is niet wenselijk.',
	'ban'  => 'Je taalgebruik is niet wenselijk.',
);

my %nick_msg = (
	'warn' => 'Je schuilnaam is niet gepast en ik wil graag dat je deze ' .
		  'veranderd. Je kan je schuilnaam veranderen met het ' .
		  'commando /nick NieuweNaam.',
	'kick' => 'Je schuilnaam is niet toegestaan. Je kan je naam veranderen met /nick nieuwenaam.',
	'ban'  => 'Je schuilnaam is niet toegestaan. Je kan je naam veranderen met /nick nieuwenaam.',
);

my %caps_msg = (
	'warn' => 'Alleen maar hoofdletters gebruiken wordt gezien als ' .
		  'schreeuwen en is erg onvriendelijk. Ik wil graag dat je daar mee stopt!',
	'kick' => 'Helaas schrijf je alles in hoofdletters. Dat is niet wenselijk.',
	'ban'  => 'Helaas schrijf je alles in hoofdletters. Dat is niet wenselijk.',
);

my %prive_msg = (
	'warn' => 'Je kan beter geen privégegevens doorgeven. Dit kan later ' .
		  'vervelende gevolgen hebben. Besluit je toch om gegevens door ' .
		  'te geven, doe dat dan in een privébericht.',
	'kick' => 'Geef prive gegevens door in privé, niet in het kanaal!',
	'ban'  => 'Geef prive gegevens door in privé, niet in het kanaal!',
);

my %warning_msgs = (
	'flood' => \%flood_msg,
	'lang' => \%lang_msg,
	'nick' => \%nick_msg,
	'caps' => \%caps_msg,
	'prive' => \%prive_msg,
);

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
	my ($type, $data, $server, $witem) = @_;

	if($data) {
		my ($action, $target) = split / /, $data, 2;

		if($action eq 'k' or $action eq 'kick') {
			kick_msg($warning_msgs{$type}->{kick}, $target,
				$server, $witem);
		} elsif($action eq 'kb' or $action eq 'tb') {
			timeout_msg($warning_msgs{$type}->{ban}, $target,
				$server, $witem);
		} else {
			$target = $action unless $target;
			warn_msg($warning_msgs{$type}->{warn}, $target,
				$server, $witem);

		}
	} else {
		# Channel warning
		warn_msg($warning_msgs{$type}->{warn}, $data, $server, $witem);
	}
}

sub do_request
{
	my ($data, $server, $witem) = @_;

	Irssi::print("Not enough parameters given") unless $data;
	return unless $data;

	my ($action, $args) = split / /, $data, 2;

	Irssi::print("Not enough parameters given") unless $args;
	return unless $args;

	my ($user, $reason) = split / /, $args, 2;

	unless($user and $reason) {
		Irssi::print("Not enough parameters given");
		return;
	}


	if($action eq 'gline') {
		$witem->command("MSG #dutchops /gline $user 2m :$reason " .
			"Korte ban, mail voor meer info naar jcc\@jota-joti.nl");
	} elsif($action eq 'kill') {
		$witem->command("MSG #dutchops /kill $user $reason");
	} elsif($action eq 'nick') {
		$witem->command("MSG #dutchops Nickchange: /sanick $user $reason");
	}
}

sub do_ppp
{
	my ($data, $server, $witem) = @_;

	Irssi::print("Not enough parameters given") unless $data;
	return unless $data;

	my ($action, $args) = split / /, $data, 2;

	if($action eq "start") {
		$witem->command("MSG Pimmetje !startppp");
	} elsif($action eq "stop") {
		$witem->command("MSG Pimmetje !stopppp");
	} elsif($action eq "punt") {
		$witem->command("MSG Pimmetje !punterbij $args");
	} elsif($action eq "strafpunt") {
		$witem->command("MSG Pimmetje !strafpunt $args");
	} elsif($action eq "hiscore") {
		$witem->command("MSG Pimmetje !hiscore");
	}
}

# Channel/nick warnings
sub cmd_flood
{
	my ($data, $server, $witem) = @_;

	do_action('flood', $data, $server, $witem);
}

sub cmd_caps
{
	my ($data, $server, $witem) = @_;
	
	do_action('caps', $data, $server, $witem);
}

sub cmd_prive
{
	my ($data, $server, $witem) = @_;

	do_action('prive', $data, $server, $witem);
}

sub cmd_lang
{
	my ($data, $server, $witem) = @_;

	do_action('lang', $data, $server, $witem);
}

sub cmd_nick
{
	my ($data, $server, $witem) = @_;

	do_action('nick', $data, $server, $witem);
}

sub cmd_request
{
	my ($data, $server, $witem) = @_;

	do_request($data, $server, $witem);
}

sub cmd_pimmetje
{
	my ($data, $server, $witem) = @_;

	do_ppp($data, $server, $witem);
}

Irssi::command_bind('flood', 'cmd_flood');
Irssi::command_bind('lang', 'cmd_lang');
Irssi::command_bind('prive', 'cmd_prive');
Irssi::command_bind('caps', 'cmd_caps');
Irssi::command_bind('nk', 'cmd_nick');

Irssi::command_bind('rq', 'cmd_request');
Irssi::command_bind('request', 'cmd_request');

Irssi::command_bind('pimmetje', 'cmd_request');
