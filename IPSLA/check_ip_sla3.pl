#!/usr/bin/perl

use lib qw ( /usr/local/nagios/perl/lib );
use Net::SNMP;
use Getopt::Std;

$script         = "check_ip_sla";
$script_version = "0.1";

# SNMP options
$version = "2c";
$timeout = 2;

$number_of_interfaces   = 0;
$target_interface_index = 0;

$oid_sysdescr      = ".1.3.6.1.2.1.1.1.0";
$oid_ifnumber      = ".1.3.6.1.2.1.2.1.0";        # number of interfaces on device
$oid_ifdescr       = ".1.3.6.1.2.1.2.2.1.2.";     # need to append integer for specific interface
$oid_iftype        = ".1.3.6.1.2.1.2.2.1.3.";     # need to append integer for specific interface
$oid_ifmtu         = ".1.3.6.1.2.1.2.2.1.4.";     # need to append integer for specific interface
$oid_ifspeed       = ".1.3.6.1.2.1.2.2.1.5.";     # need to append integer for specific interface
$oid_ifphysaddress = ".1.3.6.1.2.1.2.2.1.6.";     # need to append integer for specific interface
$oid_ifadminstatus = ".1.3.6.1.2.1.2.2.1.7.";     # need to append integer for specific interface
$oid_ifoperstatus  = ".1.3.6.1.2.1.2.2.1.8.";     # need to append integer for specific interface
$oid_iflastchange  = ".1.3.6.1.2.1.2.2.1.9.";     # need to append integer for specific interface
$oid_ifinerrors    = ".1.3.6.1.2.1.2.2.1.14.";    # need to append integer for specific interface
$oid_ifouterrors   = ".1.3.6.1.2.1.2.2.1.20.";    # need to append integer for specific interface
$oid_ifoutqlen     = ".1.3.6.1.2.1.2.2.1.21.";    # need to append integer for specific interface

$oid_rttMonctrlOperTimeoutOccurred = ".1.3.6.1.4.1.9.9.42.1.2.9.1.5.";		# need to append integer for IP SLA instance.
$oid_rttMonLatestRttOperCompletionTime = ".1.3.6.1.4.1.9.9.42.1.2.10.1.1.";	# need to append integer for IP SLA instance

$ifdescr       = "n/a";
$iftype        = "n/a";
$ifmtu         = "n/a";
$ifspeed       = "n/a";
$ifphysaddress = "n/a";
$ifadminstatus = "n/a";
$ifoperstatus  = "n/a";
$iflastchange  = "n/a";
$ifinerrors    = "n/a";
$ifouterrors   = "n/a";
$ifoutqlen     = "n/a";

$warning  = 0;    # Warning threshold
$critical = 0;    # Critical threshold

$snmpv3_username     = "initial";    # SNMPv3 username
$snmpv3_password     = "";           # SNMPv3 password
$snmpv3_authprotocol = "md5";        # SNMPv3 hash algorithm (md5 / sha)
$snmpv3_privprotocol = "des";        # SNMPv3 encryption protocol (des / aes / aes128)
$community           = "public";     # Default community string (for SNMP v1 / v2c)

$hostname = "192.168.10.21";

#$hostname = "212.113.28.134";
$returnstring = "";

$configfilepath = "/usr/local/nagios/etc";

# Do we have enough information?
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

    # print "Hostname $opt_H\n";
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

unless ($target_interface) {
    print "Must specify an interface name", $/;
    usage();
    exit 3;
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

if ( find_match() == 0 ) {
    probe_interface();
}
else {
    $status = 2;
    print "Interface $target_interface not found on device $hostname\n";
    exit $status;
}

# Close the session
$s->close();

#if ( $status == 0 ) {
#    print "Status is OK - $returnstring\n";
#    exit $status;
#}
if ( $status == 1 ) {
    print "Status is OK - $returnstring\n";
    exit $status;
}
elsif ( $status == 2 ) {
    print "Status is CRITICAL - $returnstring\n";
    exit $status;
}
else {
    print "Plugin error! SNMP status unknown\n";
    exit $status;
}

exit 2;

#################################################
# Finds match for supplied IPSLA name
#################################################

sub find_match {

    if ( !defined( $s->get_request($oid_ifnumber) ) ) {
        if ( !defined( $s->get_request($oid_sysdescr) ) ) {
            print "Status is a Warning Level - SNMP agent not responding\n";
            exit 1;
        }
        else {
            print "Status is a Warning Level - SNMP OID does not exist\n";
            exit 1;
        }
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $number_of_interfaces = $s->var_bind_list()->{$_};
            if ( $number_of_interfaces == 0 ) {
                return 1;
            }
        }
    }

    $index = 1;
    while ( $index <= $number_of_interfaces ) {
        $oid_temp = $oid_ifdescr . $index;
        if ( !defined( $s->get_request($oid_temp) ) ) {
        }
        else {
            foreach ( $s->var_bind_names() ) {
                $temp_interface_descr = $s->var_bind_list()->{$_};
            }
            if ( lc($temp_interface_descr) eq lc($target_interface) ) {
                $target_interface_index = $index;
            }
        }
        $index++;
    }
    if ( $target_interface_index == 0 ) {
        return 1;
    }
    else {
        return 0;
    }
}

####################################################################
# Gathers data about target interface                              #
####################################################################

sub probe_interface {
    $oid_temp = $oid_ifdescr . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifdescr = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_iftype . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $iftype = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifmtu . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifmtu = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifspeed . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifspeed = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifadminstatus . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifadminstatus = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifoperstatus . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifoperstatus = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_iflastchange . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $iflastchange = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifinerrors . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifinerrors = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifouterrors . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifouterrors = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $oid_temp = $oid_ifoutqlen . $target_interface_index;
    if ( !defined( $s->get_request($oid_temp) ) ) {
    }
    else {
        foreach ( $s->var_bind_names() ) {
            $ifoutqlen = $s->var_bind_list()->{$_};
        }
    }
    ############################

    $errorstring = "";

    if ( $ifadminstatus eq "1" ) {
    }
    else {
        $status      = 1;
        $errorstring = "INTERFACE ADMINISTRATIVELY DOWN:";
    }

    if ( $ifoperstatus eq "1" ) {
    }
    else {
        $status      = 2;
        $errorstring = "INTERFACE DOWN:";
    }

    # Mangles interface speed

    my $mbps = $ifspeed / 1000000;
    if ( $mbps < 1 ) {
        $ifspeed = $ifspeed / 1000;
        $ifspeed = "$ifspeed Kbps";
    }
    else {
        $ifspeed = "$mbps Mbps";
    }

    # Returns string relating to interface media
    my $iftype_string = return_interfacetype($iftype);

    if ( $status == 0 ) {
        $temp = sprintf "$ifdescr ($iftype_string) - Speed: $ifspeed, MTU: $ifmtu, Last change: $iflastchange, STATS:(in errors: $ifinerrors, out errors: $ifouterrors, queue length: $ifoutqlen)";
        append($temp);
        $temp = sprintf "|queue=$ifoutqlen";
        append($temp);
    }
    else {
        $temp = sprintf "$errorstring $ifdescr ($iftype_string) - Speed: $ifspeed, MTU: $ifmtu, Last change: $iflastchange, STATS:(in errors: $ifinerrors, out errors: $ifouterrors, queue length: $ifoutqlen)";
        append($temp);
        $temp = sprintf "|queue=$ifoutqlen";
        append($temp);
    }
}

####################################################################
# help and usage information                                       #
####################################################################

sub usage {
    print << "USAGE";
--------------------------------------------------------------------
$script v$script_version

Monitors status of specific Ethernet interface. 

Usage: $script -H <hostname> -C <community> -i <interface name> [...]

Options: -H 	Hostname or IP address
         -C 	Community (default is public)
         -U 		SNMPv3 username 
         -P 		SNMPv3 password 
         -a 		SNMPv3 hashing algorithm (default is MD5)
         -e 		SNMPv3 encryption protocol (default is DES)
         -v 		SNMP version (1, 2c or 3 supported)
         -i			Target IPSLA tag name 
					Eg: IPSLA1, IPSLA2
		

--------------------------------------------------------------------	 
Copyright (C) 2003-2009 Opsera Limited. All rights reserved	 
	 
This program is free software; you can redistribute it or modify
it under the terms of the GNU General Public License
--------------------------------------------------------------------		
		
USAGE
    exit 1;
}

####################################################################
# Appends string to existing $returnstring                         #
####################################################################

sub append {
    my $appendstring = @_[0];
    $returnstring = "$returnstring$appendstring";
}

####################################################################
# Returns the interface type for given IANA metric                 #
####################################################################

sub return_interfacetype {
    my $iftype_int   = @_[0];
    my @iana         = ();
    my $returnstring = $iftype_int;
    $iana[0]   = "";
    $iana[1]   = "other";
    $iana[2]   = "regular1822";


    if ( $iftype_int > 227 ) {
        $returnstring = "$iftype_int";
    }
#    else {
 #       $returnstring = $iana[$iftype_int];
#    }

    return ($returnstring);

}
