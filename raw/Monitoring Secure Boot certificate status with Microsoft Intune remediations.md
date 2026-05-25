---
title: "Monitoring Secure Boot certificate status with Microsoft Intune remediations"
source: "https://support.microsoft.com/en-us/topic/monitoring-secure-boot-certificate-status-with-microsoft-intune-remediations-6696a27b-fa09-4570-b112-124965adc87f"
author:
published:
created: 2026-04-13
description:
tags:
  - "clippings"
---
**This article has guidance for:**

- IT administrators who need visibility into Secure Boot certificate update status from their Intune enrolled Windows devices
- Organizations preparing for the June 2026 Secure Boot certificate expiration deadline
- Teams that want to monitor certificate rollout progress across their Intune enrolled Windows devices

## Introduction

Microsoft Secure Boot certificates (2011 CAs) are expiring starting June 2026. All Windows devices with Secure Boot enabled must be updated to the 2023 certificates before expiration to ensure continued security update support.

This guide provides a **monitoring-only** approach using Microsoft Intune Remediations (Proactive Remediations). The detection script collects Secure Boot and certificate status from each device and reports it back to the Intune portal — **no remediation action is taken on devices**. This gives administrators a centralized, exportable view of certificate update progress across their Intune enrolled Windows devices.

**Why use this approach?**

| **Benefit** | **Description** |
| --- | --- |
| **Device-wide visibility** | See every Intune enrolled Windows device’s certificate status in one place |
| **Exportable** | Export results to CSV directly from the Intune portal |
| **Raw registry values** | See actual registry data, not just pass/fail |
| **Device context** | Includes manufacturer, model, BIOS version, and firmware type |
| **Event log telemetry** | Captures Secure Boot event IDs (1801/1808), bucket IDs, and confidence levels |
| **Zero touch** | Runs silently as SYSTEM — no user interaction required |

For complete background information on the certificate updates, see [Secure Boot certificate updates: Guidance for IT professionals and organizations](https://support.microsoft.com/topic/e2b43f9f-b424-42df-bc6a-8476db65ab2f).

## Prerequisites

Before deploying the detection script, ensure your environment meets the necessary requirements.

This solution leverages Remediations in Microsoft Intune. For a full list of prerequisites, see [Use Remediations to detect and fix support issues - Microsoft Intune.](https://learn.microsoft.com/intune/intune-service/fundamentals/remediations)

## Detection scripts

The detection script is a PowerShell script that collects comprehensive Secure Boot inventory data from each device and outputs it as a JSON string. The script reads from the following sources:

**Registry** — Secure Boot certificate update status, servicing keys, device attributes, and opt-in/opt-out settings from HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot and its subkeys

**WMI/CIM** — OS version, last boot time, and baseboard hardware info

**Event logs** — System event log entries for Event IDs 1801 and 1808 (Secure Boot update events)

The JSON output appears in the Intune portal under **Remediations > Monitor > Device status > “Pre-remediation detection output** ” and can be exported to CSV for analysis.

**Important:** This is a detection-only script. No changes are made to the device. No remediation script is needed.

### Creating the Script File

- Navigate to the [Sample Secure Boot inventory data collection script](https://support.microsoft.com/topic/sample-secure-boot-inventory-data-collection-script-d02971d2-d4b5-42c9-b58a-8527f0ffa30b) (KB5072718)
- Copy the full script content from the page
- Open a text editor (e.g., Notepad, VS Code) and paste the script
- Save the file as Detect-SecureBootCertUpdateStatus.ps1

## Create the Remediation in Intune

Follow these steps to deploy the detection script as a Remediation (script package) in Microsoft Intune.

**Step 1: Create the Script Package**

- Sign in to the [Microsoft Intune admin center](https://intune.microsoft.com/)
- Navigate to **Devices > Remediations**
- Click **\+ Create script package**

**Step 2: Basics**

- Configure the following settings on the **Basics** tab:

| **Setting** | **Value** |
| --- | --- |
| **Name** | Secure Boot Certificate Status Monitor |
| **Description** | Monitors Secure Boot certificate update status across the fleet. Detection only — no remediation action is taken. |
| **Publisher** | (your organization name) |

- Click **Next**

**Step 3: Settings**

- Configure the following settings on the **Settings** tab:

| **Setting** | **Value** | **Notes** |
| --- | --- | --- |
| **Detection script file** | Upload Detect-SecureBootCertificateStatus.ps1 | The script from the previous section |
| **Remediation script file** | (leave empty) | No remediation is needed — this is monitoring only |
| **Run this script using the logged-on credentials** | **No** | Runs as SYSTEM to ensure access to Confirm-SecureBootUEFI and registry |
| **Enforce script signature check** | **No** | Set to **Yes** if your organization requires signed scripts |
| **Run script in 64-bit PowerShell** | **Yes** | Required for Confirm-SecureBootUEFI cmdlet and accurate registry reads |

- Click **Next**

**Step 4: Scope Tags**

- Add any scope tags required by your organization, or leave as default
- Click **Next**

**Step 5: Assignments**

| **Setting** | **Value** | **Notes** |
| --- | --- | --- |
| **Assignments** | Select the device groups to monitor | Use All devices for fleet-wide monitoring, or specific groups for targeted monitoring |
| **Schedule** | Configure to your monitoring needs | Recommended: **Once every day** for active rollout tracking, or **once every week** for ongoing monitoring |

**Note**: Remediations run on the device’s configured schedule. The first run may take up to 24 hours after assignment depending on the device’s check-in cycle.

Click **Next**

**Step 6: Review + Create**

- Review all settings
- Click **Create**

## Viewing and Exporting Results

**View results in the portal**

- Navigate to **Devices > Remediations**
- Click on **Secure Boot Certificate Status Monitor** (or the name you chose)
- Select the **Monitor** tab
- Click **Device status**
- Click **Columns** and add **Pre-remediation detection output**

![Status monitor](https://support.microsoft.com/images/en-us/2fed7d37-3786-40c7-a914-3bd3d96074e2?format=avif&w=800)

You will see a table with the following columns:

| **Column** | **Description** |
| --- | --- |
| **Device name** | The name of the device |
| **Username** | The primary user of the device |
| **Detection status** | **Without issue** (certs updated) or **with issue** (certs not updated) |
| **Pre-remediation detection output** | The full JSON output from the script |
| **Last modified** | When the script last ran on the device |

**Export to CSV**

- On the **Device status page**, click the **Export** button at the top of the table
- The CSV file will download all columns including the full JSON detection output for every device
- Open in Excel to filter, sort, and analyze by any field

**Tip**: In Excel, you can use the TEXTJOIN or JSON functions to parse the detection output JSON into separate columns for easier analysis.

**Overview tab**

![Intune Overview](https://support.microsoft.com/images/en-us/7b125b67-11bc-40ba-84ee-786793166a43?format=avif&w=800)

The **Overview** tab on the Remediation provides a summary dashboard:

| Metric | Meaning |
| --- | --- |
| **Devices with issues** | Devices where certificates are not yet updated |
| **Devices without issues** | Devices where certificates are up to date |
| **Devices with failed detection** | Devices where the script encountered an error |

## Frequently Asked Questions

### Does this change anything on my devices?

No. This is a detection-only script. No registry values are modified, no updates are triggered, and no remediation action is taken. The script only reads values and reports them.

### What does “With issue” mean?

“With issue” means the device does not yet have the 2023 Secure Boot certificates applied and the 2023-signed boot manager in place. This could be because: - The certificate update hasn’t been initiated - The update is in progress and may require a reboot to complete - Secure Boot is not enabled on the device - The device is not UEFI-based or is waiting for a reboot to apply the boot manager.

### What does “Without issue” mean?

“Without issue” means the device has Secure Boot enabled and the UEFICA2023Status registry value is Updated, indicating the 2023 certificates have been successfully applied.

### How often does the script run?

The script runs on the schedule you configure in the assignment. For active monitoring during a rollout, daily is recommended. For ongoing monitoring, weekly is sufficient.

### What if the Servicing registry key doesn’t exist?

If the HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot\\Servicing key does not exist on a device, the UEFICA2023Status field will show NoValue. This typically means certificate updates have not been initiated on the device.

### What licenses are required?

Remediations require Windows 10/11 Enterprise E3/E5, Education A3/A5, or F3 licenses. If your devices have Business Premium or Pro licenses only, Remediations will not be available. See [Prerequisites for Remediations](https://learn.microsoft.com/mem/intune/fundamentals/remediations#prerequisites).

## Resources

[Secure Boot Certificate Update Playbook](https://aka.ms/securebootplaybook)

[Secure Boot Certificate Updates: Guidance for IT Professionals](https://support.microsoft.com/topic/e2b43f9f-b424-42df-bc6a-8476db65ab2f)

[Registry Key Updates for Secure Boot](https://support.microsoft.com/topic/a7be69c9-4634-42e1-9ca1-df06f43f360d)

[Secure Boot DB and DBX Variable Update Events](https://support.microsoft.com/topic/37e47cf8-608b-4a87-8175-bdead630eb69)

[Remediations in Microsoft Intune](https://learn.microsoft.com/mem/intune/fundamentals/remediations)

[Prerequisites for Remediations](https://learn.microsoft.com/mem/intune/fundamentals/remediations#prerequisites)