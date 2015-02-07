#!/usr/bin/perl

use lib qw ( /usr/local/nagios/perl/lib );
use Net::SNMP;
use Getopt::Std;

$script         = "check_ip_sla";
$script_version = "0.1";

# SNMP options
$version = "2c";
$timeout = 2;

$number_of_ipslas   = 0;

$oid_rttMonctrlOperTimeoutOccurred = ".1.3.6.1.4.1.9.9.42.1.2.9.1.5.";		# need to append integer for IP SLA instance.
$oid_rttMonLatestRttOperCompletionTime = ".1.3.6.1.4.1.9.9.42.1.2.10.1.1.";	# need to append integer for IP SLA instance.

$warning  = 0;    # Warning threshold
$critical = 0;    # Critical threshold

$snmpv3_username     = "initial";    # SNMPv3 username
$snmpv3_password     = "";           # SNMPv3 password
$snmpv3_authprotocol = "md5";        # SNMPv3 hash algorithm (md5 / sha)
$snmpv3_privprotocol = "des";        # SNMPv3 encryption protocol (des / aes / aes128)
$community           = "public";     # Default community string (for SNMP v1 / v2c)

$hostname = "192.168.10.21";
$returnstring = "";
$configfilepath = "/usr/local/nagios/etc";

if ( @ARGV < 1 ) {
    print "Too few arguments\n";
    usage();
}

getopts("hH:C:U:P:a:e:s:w:v:");
if ($opt_h) {
    usage();
    exit(0);
}
if ($opt_H) {
    $hostname = $opt_H;
	
print "Hostname $opt_H\n";
}
else {
    print "No hostname specified\n";
    usage();
    exit(0);
}
if ($opt_C) {
    $community = $opt_C;
}
if ($opt_i) {
    $target_interface = $opt_i;
}
if ($opt_s) {
    $target_ipsla = $opt_s;
}
if ($opt_U) {
    $snmpv3_username = $opt_U;
}
if ($opt_P) {
    $snmpv3_password = $opt_P;
}
if ($opt_a) {
    $snmpv3_authprotocol = $opt_a;
}
if ($opt_e) {
    $snmpv3_privprotocol = $opt_e;
}
if ($opt_v) {
    $version = $opt_v;
}


unless ($target_ipsla) {
    print "Must specify an IP SLA tag", $/;
    usage();
    exit 3;
}

# Create the SNMP session

$oid_sysDescr = ".1.3.6.1.2.1.1.1.0";    # Used to check whether SNMP is actually responding

# Checks whether requested SNMP version is supported
if ( $version !~ /^[13]|[2c]$/ ) {
    print "SNMP v$version not supported by this plugin\n";
    exit(1);
}

# Create the SNMP session
if ( $version == "3" ) {
    ( $s, $e ) = Net::SNMP->session(
        -username     => $snmpv3_username,
        -authpassword => $snmpv3_password,
        -authprotocol => $snmpv3_authprotocol,
        -privprotocol => $snmpv3_privprotocol,
        -hostname     => $hostname,
        -version      => $version,
        -timeout      => $timeout,
    );
    if ($s) {
    }
    else {
        print "Agent not responding, tried SNMP v3 ($e)\n";
        exit(1);
    }
}

my $triedv2c = 0;    # Track whether we've attempted SNMPv2c connection
if ( $version == "2c" ) {
    ( $s, $e ) = Net::SNMP->session(
        -community => $community,
        -hostname  => $hostname,
        -version   => $version,
        -timeout   => $timeout,
    );
    if ( !defined( $s->get_request($oid_sysDescr) ) ) {

        # try SNMP v1 if v2c doesn't work
        $triedv2c = 1;
        $version  = 1;
    }
}

if ( $version == "1" ) {
    ( $s, $e ) = Net::SNMP->session(
        -community => $community,
        -hostname  => $hostname,
        -version   => $version,
        -timeout   => $timeout,
    );
    if ( !defined( $s->get_request($oid_sysDescr) ) ) {
        if ( $triedv2c == 1 ) {
            print "Agent not responding, tried SNMP v1 and v2c\n";
        }
        else {
            print "Agent not responding, tried SNMP v1\n";
        }
        exit(1);
    }
}






