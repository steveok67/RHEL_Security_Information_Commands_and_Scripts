#!/bin/bash

# Author: Gordon Keegan @ Red Hat
#
# use "dnf updateinfo list all --with-cve" and pull out just the RHSA cves for current release, installed or not
#
# query RH Security API for CVE data, pull out just CVSS score
#
# profit !
# 
#  single CVE score example:
#        curl -s https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2025-43213 | grep cvss3_base_score | awk '{print $3}' | sed -e  s/\"//g -e s/,//
#

for n in `dnf updateinfo list all --with-cve | grep -E 'RHSA|CVE.*Sec' | cut -c 3-33 | sed -E "s/ //g"`; do
	rhsaname="";
	cvename="";
	rhsaname=`echo $n | sed -E "s/(RHSA.*[0-9]*)[LMIC].*/\1/"`;
	cvename=`echo $n | sed -E "s/(CVE.*[0-9]*)[LMIC].*/\1/"`;
	cveseverity=`echo $n | sed -E "s/CVE.*[0-9]*([LMIC].*)\/Sec.*/\1/"`;

	if [[ "$rhsaname" == "RHSA"* ]]; then
		echo $rhsaname;
	else
		echo -e "$cvename\t$cveseverity\tCVSS Score:  `curl -s https://access.redhat.com/hydra/rest/securitydata/cve/$cvename | grep cvss3_base_score | awk '{print $3}' | sed -e s/\\"//g -e s/,//`";
	fi	
done | sed -E  "s/(RHSA.*)CVSS Score:/\1/"

exit 0
