#!/usr/bin/perl

use lib qw ( /usr/local/nagios/perl/lib );
use Net::SNMP;
use Getopt::Std;

$script         = "check_snmp_ifstatus";
$script_version = "3.0";

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

getopts("hH:C:U:P:a:e:i:w:v:");
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

if ( $status == 0 ) {
    print "Status is OK - $returnstring\n";
    exit $status;
}
elsif ( $status == 1 ) {
    print "Status is a Warning Level - $returnstring\n";
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
# Finds match for supplied interface name
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
    $iana[3]   = "hdh1822";
    $iana[4]   = "ddnX25";
    $iana[5]   = "rfc877x25";
    $iana[6]   = "ethernet";
    $iana[7]   = "";
    $iana[8]   = "TokenBus";
    $iana[9]   = "TokenRing";
    $iana[10]  = "iso88026Man";
    $iana[11]  = "starLan";
    $iana[12]  = "proteon10Mbit";
    $iana[13]  = "proteon80Mbit";
    $iana[14]  = "hyperchannel";
    $iana[15]  = "fddi";
    $iana[16]  = "lapb";
    $iana[17]  = "sdlc";
    $iana[18]  = "DSL";
    $iana[19]  = "E1";
    $iana[20]  = "basicISDN";
    $iana[21]  = "primaryISDN";
    $iana[22]  = "propritory PointToPointSerial";
    $iana[23]  = "PPP";
    $iana[24]  = "softwareLoopback";
    $iana[25]  = "CLNP over IP ";
    $iana[26]  = "ethernet3Mbit";
    $iana[27]  = "XNS over IP";
    $iana[28]  = "SLIP";
    $iana[29]  = "ultra";
    $iana[30]  = "DS3";
    $iana[31]  = "SMDS";
    $iana[32]  = "frameRelay DTE";
    $iana[33]  = "RS232";
    $iana[34]  = "Parallel port";
    $iana[35]  = "arcnet";
    $iana[36]  = "arcnetPlus";
    $iana[37]  = "ATM";
    $iana[38]  = "miox25";
    $iana[39]  = "SONET / SDH ";
    $iana[40]  = "X25PLE";
    $iana[41]  = "iso88022llc";
    $iana[42]  = "localTalk";
    $iana[43]  = "SMDSDxi";
    $iana[44]  = "frameRelayService";
    $iana[45]  = "v35";
    $iana[46]  = "hssi";
    $iana[47]  = "hippi";
    $iana[48]  = "Generic MODEM";
    $iana[49]  = "";
    $iana[50]  = "sonetPath";
    $iana[51]  = "sonetVT";
    $iana[52]  = "SMDSIcip";
    $iana[53]  = "propVirtual";
    $iana[54]  = "propMultiplexor";
    $iana[55]  = "ieee80212 100BaseVG";
    $iana[56]  = "fibreChannel";
    $iana[57]  = "HIPPI interface";
    $iana[58]  = "";
    $iana[59]  = "ATM Emulated LAN for 802.3";
    $iana[60]  = "ATM Emulated LAN for 802.5";
    $iana[61]  = "ATM Emulated circuit          ";
    $iana[62]  = "";
    $iana[63]  = "ISDN / X.25           ";
    $iana[64]  = "CCITT V.11/X.21             ";
    $iana[65]  = "CCITT V.36                  ";
    $iana[66]  = "CCITT G703 at 64Kbps";
    $iana[67]  = "G703 at 2Mb";
    $iana[68]  = "SNA QLLC ";
    $iana[69]  = "";
    $iana[70]  = "channel  ";
    $iana[71]  = "ieee80211 radio spread spectrum       ";
    $iana[72]  = "IBM System 360/370 OEMI Channel";
    $iana[73]  = "IBM Enterprise Systems Connection";
    $iana[74]  = "Data Link Switching";
    $iana[75]  = "ISDN S/T interface";
    $iana[76]  = "ISDN U interface";
    $iana[77]  = "Link Access Protocol D";
    $iana[78]  = "IP Switching Objects";
    $iana[79]  = "Remote Source Route Bridging";
    $iana[80]  = "ATM Logical Port";
    $iana[81]  = "Digital Signal Level 0";
    $iana[82]  = "ds0 Bundle (group of ds0s on the same ds1)";
    $iana[83]  = "Bisynchronous Protocol";
    $iana[84]  = "Asynchronous Protocol";
    $iana[85]  = "Combat Net Radio";
    $iana[86]  = "ISO 802.5r DTR";
    $iana[87]  = "Ext Pos Loc Report Sys";
    $iana[88]  = "Appletalk Remote Access Protocol";
    $iana[89]  = "Proprietary Connectionless Protocol";
    $iana[90]  = "CCITT-ITU X.29 PAD Protocol";
    $iana[91]  = "CCITT-ITU X.3 PAD Facility";
    $iana[92]  = "frameRelay MPI";
    $iana[93]  = "CCITT-ITU X213";
    $iana[94]  = "ADSL";
    $iana[95]  = "Rate-Adapt. DSL";
    $iana[96]  = "SDSL";
    $iana[97]  = "Very High-Speed DSL";
    $iana[98]  = "ISO 802.5 CRFP";
    $iana[99]  = "Myricom Myrinet";
    $iana[100] = "voiceEM voice recEive and transMit";
    $iana[101] = "voiceFXO voice Foreign Exchange Office";
    $iana[102] = "voiceFXS voice Foreign Exchange Station";
    $iana[103] = "voiceEncap voice encapsulation";
    $iana[104] = "VoIP";
    $iana[105] = "ATM DXI";
    $iana[106] = "ATM FUNI";
    $iana[107] = "ATM IMA";
    $iana[108] = "PPP Multilink Bundle";
    $iana[109] = "IBM ipOverCdlc";
    $iana[110] = "IBM Common Link Access to Workstn";
    $iana[111] = "IBM stackToStack";
    $iana[112] = "IBM VIPA";
    $iana[113] = "IBM multi-protocol channel support";
    $iana[114] = "IBM IP over ATM";
    $iana[115] = "ISO 802.5j Fiber Token Ring";
    $iana[116] = "IBM twinaxial data link control";
    $iana[117] = "";
    $iana[118] = "HDLC";
    $iana[119] = "LAP F";
    $iana[120] = "V.37";
    $iana[121] = "X25 Multi-Link Protocol";
    $iana[122] = "X25 Hunt Group";
    $iana[123] = "Transp HDLC";
    $iana[124] = "Interleave channel";
    $iana[125] = "Fast channel";
    $iana[126] = "IP (for APPN HPR in IP networks)";
    $iana[127] = "CATV Mac Layer";
    $iana[128] = "CATV Downstream interface";
    $iana[129] = "CATV Upstream interface";
    $iana[130] = "Avalon Parallel Processor";
    $iana[131] = "Encapsulation interface";
    $iana[132] = "Coffee pot (no, really)";
    $iana[133] = "Circuit Emulation Service";
    $iana[134] = "ATM Sub Interface";
    $iana[135] = "Layer 2 Virtual LAN using 802.1Q";
    $iana[136] = "Layer 3 Virtual LAN using IP";
    $iana[137] = "Layer 3 Virtual LAN using IPX";
    $iana[138] = "IP over Power Lines";
    $iana[139] = "Multimedia Mail over IP";
    $iana[140] = "Dynamic Synchronous Transfer Mode";
    $iana[141] = "Data Communications Network";
    $iana[142] = "IP Forwarding Interface";
    $iana[143] = "Multi-rate Symmetric DSL";
    $iana[144] = "IEEE1394 High Performance Serial Bus";
    $iana[145] = "HIPPI-6400 ";
    $iana[146] = "DVB-RCC MAC Layer";
    $iana[147] = "DVB-RCC Downstream Channel";
    $iana[148] = "DVB-RCC Upstream Channel";
    $iana[149] = "ATM Virtual Interface";
    $iana[150] = "MPLS Tunnel Virtual Interface";
    $iana[151] = "Spatial Reuse Protocol";
    $iana[152] = "Voice Over ATM";
    $iana[153] = "Voice Over Frame Relay ";
    $iana[154] = "Digital Subscriber Loop over ISDN";
    $iana[155] = "Avici Composite Link Interface";
    $iana[156] = "SS7 Signaling Link ";
    $iana[157] = "Prop. P2P wireless interface";
    $iana[158] = "Frame Forward Interface";
    $iana[159] = "Multiprotocol over ATM AAL5";
    $iana[160] = "USB Interface";
    $iana[161] = "IEEE 802.3ad Link Aggregate";
    $iana[162] = "BGP Policy Accounting";
    $iana[163] = "FRF .16 Multilink Frame Relay ";
    $iana[164] = "H323 Gatekeeper";
    $iana[165] = "H323 Voice and Video Proxy";
    $iana[166] = "MPLS";
    $iana[167] = "Multi-frequency signaling link";
    $iana[168] = "High Bit-Rate DSL - 2nd generation";
    $iana[169] = "Multirate HDSL2";
    $iana[170] = "Facility Data Link 4Kbps on a DS1";
    $iana[171] = "Packet over SONET/SDH Interface";
    $iana[172] = "DVB-ASI Input";
    $iana[173] = "DVB-ASI Output ";
    $iana[174] = "Power Line Communtications";
    $iana[175] = "Non Facility Associated Signaling";
    $iana[176] = "TR008";
    $iana[177] = "Remote Digital Terminal";
    $iana[178] = "Integrated Digital Terminal";
    $iana[179] = "ISUP";
    $iana[180] = "Cisco proprietary MAC layer";
    $iana[181] = "Cisco proprietary Downstream";
    $iana[182] = "Cisco proprietary Upstream";
    $iana[183] = "HIPERLAN Type 2 Radio Interface";
    $iana[184] = "PropBroadbandWirelessAccesspt2multipt";
    $iana[185] = "SONET Overhead Channel";
    $iana[186] = "Digital Wrapper";
    $iana[187] = "ATM adaptation layer 2";
    $iana[188] = "MAC layer over radio links";
    $iana[189] = "ATM over radio links   ";
    $iana[190] = "Inter Machine Trunks";
    $iana[191] = "Multiple Virtual Lines DSL";
    $iana[192] = "Long Reach DSL";
    $iana[193] = "Frame Relay DLCI End Point";
    $iana[194] = "ATM VCI End Point";
    $iana[195] = "Optical Channel";
    $iana[196] = "Optical Transport";
    $iana[197] = "Proprietary ATM       ";
    $iana[198] = "Voice Over Cable Interface";
    $iana[199] = "Infiniband";
    $iana[200] = "TE Link";
    $iana[201] = "Q.2931";
    $iana[202] = "Virtual Trunk Group";
    $iana[203] = "SIP Trunk Group";
    $iana[204] = "SIP Signaling   ";
    $iana[205] = "CATV Upstream Channel";
    $iana[206] = "Acorn Econet";
    $iana[207] = "FSAN 155Mb Symetrical PON interface";
    $iana[208] = "FSAN622Mb Symetrical PON interface";
    $iana[209] = "Transparent bridge interface";
    $iana[210] = "Interface common to multiple lines";
    $iana[211] = "voice E&M Feature Group D";
    $iana[212] = "voice FGD Exchange Access North American";
    $iana[213] = "voice Direct Inward Dialing";
    $iana[214] = "MPEG transport interface";
    $iana[215] = "6to4 interface";
    $iana[216] = "GTP (GPRS Tunneling Protocol)";
    $iana[217] = "Paradyne EtherLoop 1";
    $iana[218] = "Paradyne EtherLoop 2";
    $iana[219] = "Optical Channel Group";
    $iana[220] = "HomePNA ITU-T G.989";
    $iana[221] = "Generic Framing Procedure (GFP)";
    $iana[222] = "Layer 2 Virtual LAN using Cisco ISL";
    $iana[223] = "Acteleis proprietary MetaLOOP High Speed Link ";
    $iana[224] = "FCIP Link ";
    $iana[225] = "Resilient Packet Ring Interface Type";
    $iana[226] = "RF Qam Interface";
    $iana[227] = "Link Management Protocol";

    if ( $iftype_int > 227 ) {
        $returnstring = "$iftype_int";
    }
    else {
        $returnstring = $iana[$iftype_int];
    }

    return ($returnstring);

}
