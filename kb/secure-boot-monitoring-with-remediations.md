# Secure Boot Certificate Monitoring with Intune Remediations

**Summary**: Step-by-step guide to deploying a detection-only Intune Remediation that collects Secure Boot certificate status from every managed Windows device and reports it centrally — no changes made to devices.

**Sources**: `Monitoring Secure Boot certificate status with Microsoft Intune remediations.md`

**Last updated**: 2026-04-13

---

## Purpose

This approach gives IT admins a fleet-wide, exportable view of [[secure-boot]] certificate update progress across Intune-enrolled Windows devices. It is **monitoring only** — no device changes are made.

Designed for organizations preparing for the June 2026 [[secure-boot]] certificate expiration deadline.

## What the Script Collects

The detection script outputs a JSON string per device pulling from three sources: (source: Monitoring Secure Boot certificate status with Microsoft Intune remediations.md)

| Source | Data Collected |
|--------|---------------|
| **Registry** (`HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot` and subkeys) | Certificate update status, servicing keys, device attributes, opt-in/opt-out settings |
| **WMI/CIM** | OS version, last boot time, baseboard hardware info |
| **Event Log (System)** | Event IDs 1801 and 1808 (Secure Boot update events), bucket IDs, confidence levels |

## Step 1: Get the Script

1. Navigate to KB5072718 (Sample Secure Boot inventory data collection script)
2. Copy the full script content
3. Save as `Detect-SecureBootCertUpdateStatus.ps1`

## Step 2: Create the Remediation in Intune

**Basics tab:**

| Setting | Value |
|---------|-------|
| Name | Secure Boot Certificate Status Monitor |
| Description | Monitors Secure Boot certificate update status across the fleet. Detection only — no remediation action is taken. |
| Publisher | Your organization name |

**Settings tab:**

| Setting | Value | Notes |
|---------|-------|-------|
| Detection script file | Upload `Detect-SecureBootCertificateStatus.ps1` | |
| Remediation script file | (leave empty) | No remediation needed |
| Run using logged-on credentials | **No** | Runs as SYSTEM for registry/UEFI access |
| Enforce script signature check | No (or Yes if org requires signed scripts) | |
| Run script in 64-bit PowerShell | **Yes** | Required for `Confirm-SecureBootUEFI` and accurate registry reads |

**Assignments tab:**

| Setting | Value |
|---------|-------|
| Target | All devices (fleet-wide) or specific device groups |
| Schedule | **Daily** during active rollout; **Weekly** for ongoing monitoring |

> Note: First run may take up to 24 hours after assignment depending on device check-in cycle.

(source: Monitoring Secure Boot certificate status with Microsoft Intune remediations.md)

## Viewing Results

**Devices > Remediations > Secure Boot Certificate Status Monitor > Monitor > Device status**

Click **Columns** and add **Pre-remediation detection output** to see the JSON per device.

| Column | Description |
|--------|-------------|
| Device name | Device identifier |
| Username | Primary user |
| Detection status | **Without issue** (certs updated) or **With issue** (certs not updated) |
| Pre-remediation detection output | Full JSON from the script |
| Last modified | When the script last ran |

**Export to CSV** from the Device status page. Open in Excel and use TEXTJOIN or JSON functions to parse JSON into separate columns. (source: Monitoring Secure Boot certificate status with Microsoft Intune remediations.md)

## Interpreting Results

| Detection Status | Meaning |
|-----------------|---------|
| **Without issue** | `UEFICA2023Status` = `Updated`; device has 2023 certificates and new boot manager |
| **With issue** | 2023 certs not yet applied — could be not started, in progress, Secure Boot disabled, or non-UEFI device |
| **UEFICA2023Status = NoValue** | `HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing` key doesn't exist; updates not initiated |

(source: Monitoring Secure Boot certificate status with Microsoft Intune remediations.md)

## License Requirement

Remediations require Windows 10/11 Enterprise E3/E5, Education A3/A5, or F3. Not available with Business Premium or Pro. See [[intune-remediations]].

## Related pages

- [[secure-boot]]
- [[secure-boot-cert-expiration-2026-playbook]]
- [[intune-remediations]]
