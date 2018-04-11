#!/usr/bin/perl
use IO::Socket;
use LWP::UserAgent;

$PUSHOVERTOKEN="";
$PUSHOVERUSER="";

my $command_output = `/sbin/zpool status -x`;
if ($command_output eq "all pools are healthy\n") {
	if (-e "/tmp/resilvering.status") {
		system ("rm -f /tmp/resilvering.status");
		my $statusinfo = `/sbin/zpool status -v | grep -1 "^status:" | grep -v "state:"`;
		chomp($statusinfo);              # remove the newline from $line.
        	$statusinfo =~ s/^status: //g;
        	$statusinfo =~ s/[\n\r]//g;
	        LWP::UserAgent->new()->post(
                 "https://api.pushover.net/1/messages.json", [
                 "token" => "$PUSHOVERTOKEN",
                 "user" => "$PUSHOVERUSER",
                 "title" => "ZPool Optimal",
           	 "message" => "$statusinfo",
                 "priority" => "0",
                 "retry" => "60",
                 "expire" => "3600",
                 "sound" => "mechanical",
        	]);
		exit;
	}
	#print "all pools are healthy\n";
	exit;
} elsif ($command_output =~/No known data errors/) {
	if ($command_output =~/One or more devices is currently being resilvered/) {
		if (-e "/tmp/resilvering.status") {
			exit;
		} else {
			system ("touch /tmp/resilvering.status");
			my $statusinfo = `/sbin/zpool status -v | grep -1 "^status:" | grep -v "state:"`;
			chomp($statusinfo);              # remove the newline from $line.
        		$statusinfo =~ s/^status: //g;
        		$statusinfo =~ s/[\n\r]//g;
			LWP::UserAgent->new()->post(
                 		"https://api.pushover.net/1/messages.json", [
                 		"token" => "$PUSHOVERTOKEN",
                 		"user" => "$PUSHOVERUSER",
                 		"title" => "ZPool Resilvering",
                 		"message" => "$statusinfo",
                 		"priority" => "0",
                 		"retry" => "60",
                 		"expire" => "3600",
                 		"sound" => "mechanical",
        		]);
        		exit;
		}
		
	}
	#print "Pools look healthy, but may have a warning.\n";
	my $statusinfo = `/sbin/zpool status -v | grep -1 "^status:" | grep -v "state:"`;
	chomp($statusinfo);              # remove the newline from $line.
        $statusinfo =~ s/^status: //g;
        $statusinfo =~ s/[\n\r]//g;
	LWP::UserAgent->new()->post(
                 "https://api.pushover.net/1/messages.json", [
                 "token" => "$PUSHOVERTOKEN",
                 "user" => "$PUSHOVERUSER",
                 "title" => "ZFS Status",
                 "message" => "$statusinfo",
                 "priority" => "0",
                 "retry" => "60",
                 "expire" => "3600",
                 "sound" => "mechanical",
        ]);
	exit;
} else {
	#print "zpool not healthy\n";
	my $verbose_command_output = `/sbin/zpool status -v`;
	#$command_output = substr($command_output, 0, 9000);
	#system ("/root/bin//nma.pl -apikeyfile=/root/bin/nma.key -application='Home NAS' -event='ZFS Alert' -notification='$verbose_command_output' -priority=2");
        my $stateinfo = `/sbin/zpool status -v | grep "state: "`;
        chomp($stateinfo);              # remove the newline from $line.
        $stateinfo =~ s/state: //g;
        $stateinfo =~ s/[\s\n\r]//g;
	LWP::UserAgent->new()->post(
                 "https://api.pushover.net/1/messages.json", [
                 "token" => "$PUSHOVERTOKEN",
                 "user" => "$PUSHOVERUSER",
                 "title" => "ZFS Alert",
                 "message" => "$stateinfo",
                 "priority" => "1",
                 "retry" => "60",
                 "expire" => "3600",
                 "sound" => "mechanical",
        ]);
}
