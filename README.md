Scope: The purpose of this repo is to easily gather security information on RHEL. 
- The same DNF commands may also work on other RPM-based distributions. 
- However, other RPM-based distributions often run older kernel and package versions, 
  so the Security patch level will be different. 
- Moreover, the supplied scripts, which query the Red Hat CVE database, will be unique 
  to that RHEL version specifically, and won't likely match other RPM distributions. 
- We hope the included scripts are helpful, but they are not supported by Red Hat. 

This readme and included scripts are intended to help with the following questions: 
- How many Security Advisories (SAs) have been resolved in the 'dot' release I am using 
- How many SAs and CVEs of each severity rating are resolved? 
- What is the corresponding CVSS score for each CVE? 
- What are the affected packages? 
- Is there a way to gather all this information from a terminal? 

Let's get started: 

# RHEL_Security_Information_Commands_and_Scripts \
Red Hat Enterprise Linux - Security Information Gathering Commands and Scripts \

1) Print a summary of Security updates, Bug fixes, and Enhancements: \
$ sudo dnf updateinfo all 
// Have fun running the above command on other rpm-based distributions to compare them. \

3) Print a summary Security Advisory updates: \
$ sudo dnf updateinfo all --with-cve 

4) Print a list of Security Advisories (SAs), & corresponding CVEs: \
$ sudo dnf updateinfo list all --with-cve 

6) Print a list of CVEs: \
$ sudo dnf updateinfo list all --with-cve |egrep CVE

8) List individual CVE, and corresponding CVSS score: \
$ curl -s https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2026-23001 |grep -e "\"name\" :" -e cvss3_base_score 

9) If you want to print all the Security Advisories (SAs), associated CVEs per SA, and the corresponding CVSS score for each CVE, run the following script: \
// Thanks to Gordon Keegan at Red Hat \
$ chmod +x ./get_SA_CVEs_CVSS_scores.sh 
$ ./get_SA_CVEs_CVSS_scores.sh 

11) Print a condensed summary of the release update, including updated packages, SAs, CVEs, CVSS scores. \
// Thanks to Tim Runion at DTV \
$ chmod +x ./get_rhel_errata_score.sh 
$ ./get_rhel_errata_score.sh 


