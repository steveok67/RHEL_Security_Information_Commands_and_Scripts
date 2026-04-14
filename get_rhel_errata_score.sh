#!/bin/bash
#set -x - uncomment to turn on debug mode
# Get latest advisory/package entry only, then enrich with CVE CVSS score.
# Displays package errata about the local system
# Output:
# package name- errata type - advisory - cve - cvss
## Script created by Gordon Keegan @RedHat and updated by timothy.runion@directv.com 4/8/2026

set -u

RH_CVE_TEST_URL="https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2025-43213.json"

# ANSI colors
COLOR_WARN='\033[0;33m'
COLOR_RESET='\033[0m'

get_kernel_install_date() {
    local kernel install_date
    kernel=$(uname -r)

    install_date=$(rpm -q --qf '%{INSTALLTIME:date}\n' "kernel-core-$kernel" 2>/dev/null || true)

    if [[ -z "$install_date" ]]; then
        install_date=$(rpm -q --qf '%{INSTALLTIME:date}\n' "kernel-$kernel" 2>/dev/null || true)
    fi

    if [[ -z "$install_date" ]]; then
        install_date="Unknown"
    fi

    echo "$install_date"
}

check_redhat_connectivity() {
    curl -fsS --connect-timeout 8 --max-time 15 "$RH_CVE_TEST_URL" >/dev/null 2>&1
}

print_summary() {
    local advisory_count="$1"
    local unique_pkg_count="$2"
    local result_count="$3"
    local high_cvss_advisory_count="$4"
    local kernel install_date report_date

    kernel=$(uname -r)
    install_date=$(get_kernel_install_date)
    report_date=$(date)

    echo
    echo "----------------------------------------"
    echo "Number of advisory entries found: $advisory_count"
    echo "Number of unique packages with updates: $unique_pkg_count"
    echo "Number of package/CVE entries shown: $result_count"
    printf "${COLOR_WARN}Number of advisories with CVSS > 8: %s${COLOR_RESET}\n" "$high_cvss_advisory_count"
    echo "Running Kernel: $kernel"
    echo "Kernel Installed: $install_date"
    echo "Report Generated: $report_date"
    echo "----------------------------------------"
}

tmp_results=$(mktemp)
trap 'rm -f "$tmp_results"' EXIT

echo "Checking connectivity to Red Hat errata API..."

if ! check_redhat_connectivity; then
    echo "ERROR: Unable to reach Red Hat errata API."
    echo "Check outbound internet access, proxy settings, DNS, or firewall rules."
    exit 1
fi

echo "Connectivity check passed."
echo

advisory_count=$(dnf -q updateinfo list available | grep -Ec '^(RHSA|RHBA|RHEA)' || true)

if [[ "$advisory_count" -eq 0 ]]; then
    echo "No updates found. Your system is up-to-date."
    print_summary 0 0 0 0
    exit 0
fi

echo "Updates found. Gathering advisory, CVE, and CVSS details..."
echo

dnf -q updateinfo list available --with-cve | \
grep -v '^classification ' | \
sort -s -k3,3V | \
awk '
{
    item=$1
    severity=$2
    package=$3

    base=package
    sub(/-[0-9].*$/, "", base)

    rows[base,package] = rows[base,package] $0 "\n"
    latest[base] = package
}
END {
    for (b in latest) {
        pkg = latest[b]
        printf "%s", rows[b,pkg]
    }
}' | \
while read -r item severity package; do
    [[ -z "${item:-}" ]] && continue

    if [[ "$item" == RHSA-* || "$item" == RHBA-* || "$item" == RHEA-* ]]; then
        current_advisory="$item"
        current_severity="$severity"
        current_package="$package"
    elif [[ "$item" == CVE-* ]]; then
        if [[ -z "${current_package:-}" || -z "${current_advisory:-}" || -z "${current_severity:-}" ]]; then
            continue
        fi

        cve="$item"
        cvss=$(curl -fsS --connect-timeout 8 --max-time 15 \
          "https://access.redhat.com/hydra/rest/securitydata/cve/${cve}.json" 2>/dev/null \
          | grep 'cvss3_base_score' | awk -F'"' '{print $4}')

        [[ -z "${cvss:-}" ]] && cvss="N/A"

        echo "$current_package - $current_severity - $current_advisory - $cve - CVSS $cvss"
    fi
done | sort | tee "$tmp_results"

result_count=$(wc -l < "$tmp_results")
unique_pkg_count=$(awk -F' - ' '{print $1}' "$tmp_results" | sort -u | wc -l)

high_cvss_advisory_count=$(awk -F' - ' '
{
    advisory=$3
    cvss=$5
    sub(/^CVSS /, "", cvss)

    if (cvss != "N/A" && cvss+0 > 8) {
        seen[advisory]=1
    }
}
END {
    count=0
    for (a in seen) {
        count++
    }
    print count
}' "$tmp_results")

print_summary "$advisory_count" "$unique_pkg_count" "$result_count" "$high_cvss_advisory_count"
