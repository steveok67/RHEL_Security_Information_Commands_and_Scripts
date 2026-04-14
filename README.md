# RHEL_Security_Information_Commands_and_Scripts
Red Hat Enterprise Linux - Security Information Gathering Commands and Scripts

1) Print a summary of Security updates, Bug fixes, and Enhancements: \
$ sudo dnf updateinfo all \
// Have fun running the above command on other rpm-based distributions to compare them.

3) Print a summary Security Advisory updates: \
$ sudo dnf updateinfo all --with-cve

4) Print a list of Security Advisories (SAs), & corresponding CVEs: \
$ sudo dnf updateinfo list all --with-cve

6) Print a list of CVEs: \
$ sudo dnf updateinfo list all --with-cve |egrep CVE

8) List individual CVE, and corresponding CVSS score: \
$ curl -s https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2026-23001 |grep -e "\"name\" :" -e cvss3_base_score

9) If you want to print all the Security Advisories (SAs), associated CVEs per SA, and the corresponding CVSS score for each CVE, run the following script: \
$ chmod +x ./get_SA_CVEs_CVSS_scores.sh \
$ ./get_SA_CVEs_CVSS_scores.sh

10) If want all the information from the above script, and also the affected package run the following script: \
$ chmod +x ./get_rhel_errata_score.sh \
$ ./get_rhel_errata_score.sh


