---
title: "Secure Boot playbook for certificates expiring in 2026"
source: "https://techcommunity.microsoft.com/blog/windows-itpro-blog/secure-boot-playbook-for-certificates-expiring-in-2026/4469235"
author:
  - "[[Ashis_Chatterjee]]"
published: 2025-11-13
created: 2026-04-13
description: "Explore tools and step-by-step guidance to help you proactively update your Secure Boot certificates."
tags:
  - "clippings"
---
**Next up: [April 23 - Ask Microsoft Anything (AMA) about Secure Boot](https://techcommunity.microsoft.com/event/windowsevents/ask-microsoft-anything-secure-boot---april-2026/4501308)**

The first set of tools and steps are now available to help you proactively update your Secure Boot certificates before they start expiring in June of 2026.

Secure Boot is more mature and robust today than it was some years ago. Coupled with the Unified Extensible Firmware Interface (UEFI) firmware signing process, Secure Boot uses cryptographic keys, known as certificate authorities (CAs), to validate that firmware modules come from a trusted source. This helps prevent malware from running early in the startup sequence of a Windows device.

Secure Boot certificates have always had expiration dates. New certificates help ensure that your devices stay up to date with the latest security protections.<sup><a href="#community-4469235-_note1">[1]</a></sup> That is why your organization will need to install the 2023 CAs before the 2011 CAs start expiring in June of 2026.

Many Windows PCs manufactured since 2024 already have the updated 2023 certificates. For the remaining devices, Microsoft is delivering new Secure Boot certificates through Windows monthly updates, with partner original equipment manufacturers (OEMs) making firmware updates available to help ensure compatibility.  
  

## Get started today

If you wish to proactively update your Secure Boot certificates, this playbook outlines the initial steps you can take and tools you can use. At a minimum, we encourage you to monitor the progress of your device fleet from the start.

- [Step 1: Inventory and prepare your environment](#community-4469235-_step1)
- [Step 2: Monitor and check your devices for Secure Boot status](#community-4469235-_step2)
- [Step 3: Apply OEM firmware updates before Microsoft updates](#community-4469235-_step3)
- [Step 4: Plan and pilot Secure Boot certificate deployments](#community-4469235-_step4)
	- Option 1 (recommended): [Deploy certificates using Microsoft Intune](#community-4469235-_option1)
		- Option 2: [Deploy certificates with registry keys](#community-4469235-_option2)
		- Option 3: [Deploy certificates via WinCS](#community-4469235-_option3)
		- Option 4: [Deploy certificates using Group Policy](#community-4469235-_option4)
- [Step 5: Troubleshoot and remediate common issues](#community-4469235-_step5)

> **Note:** The steps on this page are focused on Secure Boot certificate updates for Windows client devices. For additional guidance, see:
> 
> - [Secure Boot playbook for Windows Server](https://aka.ms/SecureBootForServer)
> - [Secure Boot Certificate Updates for Windows 365](https://support.microsoft.com/en-us/topic/secure-boot-certificate-updates-for-windows-365-71839dd8-2832-44ed-9c60-57c04f99a645)
> - [Secure Boot Certificate Updates for Azure Virtual Desktop](https://support.microsoft.com/en-us/topic/secure-boot-certificate-updates-for-azure-virtual-desktop-06a8a1bc-2510-4ead-9bea-3698e1d6b1db)

## Step 1: Inventory and prepare your environment

For most devices in your organization, Microsoft will automatically update [high-confidence devices](https://support.microsoft.com/topic/a-closer-look-at-the-high-confidence-database-32382469-4505-4ed4-915b-982eff09b5d2) via Windows Update. However, you can validate and actively roll out these updates, in which case, you would start by conducting an inventory.

### Inventory

Most devices manufactured since 2012 have Secure Boot enabled, but you should always [verify that](https://support.microsoft.com/topic/secure-boot-certificate-updates-guidance-for-it-professionals-and-organizations-e2b43f9f-b424-42df-bc6a-8476db65ab2f#bkmk_is_secure_boot_enabled). You should also check the status of the Secure Boot certificates with [sample inventory PowerShell commands](https://support.microsoft.com/topic/windows-devices-with-it-managed-updates-e2b43f9f-b424-42df-bc6a-8476db65ab2f) or by checking the value of the **UEFICA2023Status** registry key (it should ultimately be "updated").  
  

> **Note:** A new [Secure Boot status report](https://learn.microsoft.com/windows/deployment/windows-autopatch/monitor/secure-boot-status-report) is now available in Windows Autopatch. Use it to identify devices that have Secure Boot enabled, those fully up to date, and those that need updated certificates.

  
Out of the devices that show up as not updated, build a small, representative sample. We recommend that you focus on the less common devices, for which high confidence determination isn't automatic. Then follow the rest of the steps outlined in this post to pilot the certificate updates and help ensure that deployment is successful.

### Prepare select devices

To prepare devices for Secure Boot certificate deployment, consider how you'll manage it. There are several approaches to managing Secure Boot certificate updates. Today, you can use registry keys <sup><a href="#community-4469235-_note2">[2]</a></sup>, Group Policy, or a Configuration Service Provider (CSP) for mobile device management (MDM), such as Microsoft Intune. Bookmark [https://aka.ms/GetSecureBoot](https://aka.ms/GetSecureBoot) for the latest updates.

The primary method is to deploy the certificates to devices that have been validated as ready for the update. See Step 4 when you're ready to deploy these updates.

For the more common device configurations in your environment, you can utilize two "assists" to manage your deployment:

- Get new certificates through monthly Windows updates for high-confidence devices. - This option is enabled by default for devices that are ready for new certificates. Microsoft will update these devices for you unless you opt out. To opt out, set the **HighConfidenceOptOut** registry key <sup><a href="#community-4469235-_note2">[2]</a></sup> value to **1** (or any non-zero value) or set the **Automatic Certificate Deployment via Updates** Group Policy to **Enabled**.
- Opt devices in to Microsoft-managed controlled feature rollout. - With registry keys, set the value of **MicrosoftUpdateManagedOptIn** to **1** to opt in to Microsoft-managed controlled feature rollout. The value of 0 or non-existent key means that you're opted out. With Group Policy, configure the **Certificate Deployment via Controlled Feature Rollout** policy to **Enabled**. Note: To opt in, please [configure devices to share required diagnostic data with Microsoft](https://learn.microsoft.com/windows/privacy/configure-windows-diagnostic-data-in-your-organization).

> **Important:** All Secure Boot registry keys are located under these two paths:  
> HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot  
> HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot\\Servicing
> 
> See [Registry key updates for Secure Boot: Windows devices with IT-managed updates](https://support.microsoft.com/topic/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates-a7be69c9-4634-42e1-9ca1-df06f43f360d) for more details.
> 
> Group Policy settings are available by navigating to: **Computer Configuration > Administrative Templates > Windows Components > Secure Boot**. To get the updates that include the Group Policy for deploying Secure Boot certificate updates, download the latest Administrative Templates (.admx) for [Windows 11](https://www.microsoft.com/download/details.aspx?id=108394) and [Windows Server](https://www.microsoft.com/download/details.aspx?id=108430).

## Step 2: Monitor and check your devices for Secure Boot status

Check the Secure Boot status of your devices before and after deployment. In Windows Autopatch, you can do this by using the new [Secure Boot status report](https://learn.microsoft.com/windows/deployment/windows-autopatch/monitor/secure-boot-status-report). You can also use registry keys <sup><a href="#community-4469235-_note2">[2]</a></sup> or Windows Event Log events to identify which devices already have new certificates and which ones need attention.

### Deployment progress

The text value of the **UEFICA2023Status** registry key will indicate if your certificate deployment status is not started, in progress, or updated. The value will change progressively until all new certificates and the new boot manager have been deployed successfully.

### Successful deployment

- To check the status using Windows Autopatch, from the Microsoft Intune admin center, go to **Reports** > **Windows quality updates**, and select **Secure Boot status** in the **Reports** tab. Successful deployments are marked up to date in the "Certificate status" column.
- Audit the Windows System Event Log events for **Event ID 1808**.<sup><a href="#community-4469235-_note3">[3]</a></sup> This informational event indicates that the device has the required new Secure Boot certificates applied to the device's firmware.
- Audit the **UEFICA2023Error** registry key for issues. This key should not exist unless an error is pending.
- Check that the text value of the **UEFICA2023Status** registry key reads as "Updated."

### Errors during deployment

- If you use Windows Autopatch, watch the "Certificate status column" of the Secure Boot status report for devices marked as not up to date. Select any cell in this column to see which certificates are missing for these devices.
- Audit the Windows System Event Log for **Event ID 1801**.<sup><a href="#community-4469235-_note3">[3]</a> </sup> This error event indicates that the updated certificates have not been applied to the device. Analyze details specific to the device, including device attributes, that will help you in correlating which devices still need updating.
- Check if the **UEFICA2023Error** registry key exists. If so, it indicates an error in certificate deployment. The error itself won't appear in the Event Log. Trace related issues through [Secure Boot DB and DBX variable update events](https://support.microsoft.com/topic/37e47cf8-608b-4a87-8175-bdead630eb69).

## Step 3: Apply OEM firmware updates before Microsoft updates

Updated firmware can help prevent compatibility problems and ensure new Secure Boot certificates are accepted. If your organization has identified Secure Boot update issues or your OEM recommends a firmware update, apply the latest BIOS/UEFI update before installing Secure Boot–related Windows updates.

[Some OEMs](https://support.microsoft.com/topic/original-equipment-manufacturer-oem-pages-for-secure-boot-9ecc3ba4-fb50-4bd3-9e9b-f16b35b8fb68) provide firmware updates that include important fixes and updated certificate stores. These updates help Secure Boot function correctly with new Windows certificates. Microsoft works closely with OEM partners to ensure these updates integrate smoothly with Windows.

## Step 4: Plan and pilot Secure Boot certificate deployments

As you've seen in Step 1, Microsoft can assist with your Secure Boot updates if you enable diagnostic data. You can also deploy new Secure Boot certificates yourself for devices that don't already have them. Choose a way to do this with Microsoft Intune, registry keys,<sup><a href="#community-4469235-_note2">[2]</a></sup> via Windows Configuration System (WinCS) command-line interface (CLI), or using Group Policy today. Pilot your desired method first on a representative set of devices to gain confidence.

In a typical enterprise deployment, whatever option you choose, allow approximately 48 hours and one or more restarts after changing configuration for updates to fully apply. See [How updates are deployed](https://support.microsoft.com/topic/secure-boot-certificate-updates-guidance-for-it-professionals-and-organizations-e2b43f9f-b424-42df-bc6a-8476db65ab2f#bkmk_how_updates_are_deployed) for more details. For testing scenarios, you can accelerate the experience by following the steps outlined in [Device Testing Using Registry Keys](https://support.microsoft.com/kb/5068202#bkmk_device_testing).

> **Important:** Avoid mixing deployment methods on the same device. For additional technical recommendations to help you plan and deploy your Secure Boot updates, see [Deployment strategies](https://support.microsoft.com/topic/secure-boot-certificate-updates-guidance-for-it-professionals-and-organizations-e2b43f9f-b424-42df-bc6a-8476db65ab2f#bkmk_deployment_strategies).

### Option 1 (recommended): Deploy certificates using Microsoft Intune

You can deploy, manage, and monitor Secure Boot certificate updates in Microsoft Intune. Three settings are available, and disabled by default, in the Secure Boot category located in the settings picker:

- Enable SecureBoot Certificate Updates - This policy controls whether Windows initiates the Secure Boot certificate deployment process on devices.
- Configure Microsoft Update Managed Opt In - This policy allows your organization to participate in a [Controlled Feature Rollout](https://techcommunity.microsoft.com/blog/windows-itpro-blog/commercial-control-for-continuous-innovation/3737575) of Secure Boot certificate update managed by Microsoft.
- Configure High Confidence Opt-Out - This policy controls whether Secure Boot certificate updates are applied automatically through Windows monthly security and non-security updates.

For more detailed information on each of these settings, and how to configure them in Intune, see [Microsoft Intune method of Secure Boot for Windows devices with IT-managed updates](https://support.microsoft.com/en-us/topic/microsoft-intune-method-of-secure-boot-for-windows-devices-with-it-managed-updates-1c4cf9a3-8983-40c8-924f-44d9c959889d).

### Option 2: Deploy certificates with registry keys

Find the **AvailableUpdates** registry key located under this registry path: HKEY\_LOCAL\_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot.

Set its value to **0x5944** to deploy all needed certificates and update to the **Windows UEFI CA 2023** signed boot manager. This key corresponds to the Group Policy setting **Enable Secure Boot certificate deployment**. For details, see [Registry key updates for Secure Boot: Windows devices with IT-managed updates](https://support.microsoft.com/topic/a7be69c9-4634-42e1-9ca1-df06f43f360d).

### Option 3: Deploy certificates via Windows Configuration System (WinCS)

New command-line tools are now available for domain-joined clients on Windows 11, versions 25H2, 24H2, and 23H2.

These include both a traditional executable and a PowerShell module to query and apply Secure Boot configurations locally to a device. For step-by-step guidance, see [Windows Configuration System (WinCS) APIs for Secure Boot](https://support.microsoft.com/topic/d3e64aa0-6095-4f8a-b8e4-fbfda254a8fe).

Deploy the Secure Boot updates via WinCS:

- Feature name: **Feature\_AllKeysAndBootMgrByWinCS**
- WinCS key value: **F33E0C8E002**
- Secure Boot configuration state: **Enabled**

### Option 4: Deploy certificates using Group Policy

Group Policy settings are available by navigating to:  
**Computer Configuration** > **Administrative Templates** > **Windows Components** > **Secure Boot**.

To apply Secure Boot updates to devices using Group Policy, set the **Enable Secure Boot certificate deployment** policy to **Enabled**. This lets Windows automatically begin the certificate deployment process. This setting corresponds to the registry key **AvailableUpdates**.

Be sure to get the latest version of the.admx for [Windows 11](https://www.microsoft.com/download/details.aspx?id=108394) and [Windows Server](https://www.microsoft.com/download/details.aspx?id=108430). For more details, see [Group Policy Objects (GPO) method of Secure Boot for Windows devices with IT-managed updates](http://support.microsoft.com/kb/5068198).

## Step 5. Troubleshoot and remediate common issues

You can also use registry keys and Windows Event Log events to identify and resolve common issues:

- The **UEFICA2023Error** registry key doesn't exist if there are no errors. If it exists with a value other than 0, check your remediation recommendations in [Secure Boot DB and DBX variable update events](https://support.microsoft.com/topic/37e47cf8-608b-4a87-8175-bdead630eb69).
- The **AvailableUpdates** registry key on a device is set to **0x4104**. If it doesn't clear the **0x0004** bit even after multiple restarts, the device doesn't progress past deploying the new Key Exchange Key (KEK) certificate. If you encounter this error, check with your OEM to confirm they have followed the steps outlined in [Windows Secure Boot Key Creation and Management Guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/windows-secure-boot-key-creation-and-management-guidance?view=windows-11).
- If Event Viewer Windows Logs for System registers an **Event ID 1795**,<sup><a href="#community-4469235-_note2">ii</a></sup> it means that there was an error when Windows attempted to hand off the certificates to firmware. Check with the OEM to see if there is a firmware update available for the device to resolve this issue.

## Learn more

You can start preparing, monitoring, deploying, and troubleshooting Secure Boot certificates today, in advance of the June 2026 expiration date. Tools for additional scenarios are in development.

For the latest information, bookmark [https://aka.ms/GetSecureBoot](https://aka.ms/GetSecureBoot) as your landing page for resources to help you with Windows Secure Boot certificate updates. There you will find:

- [Guidance for IT professionals and organizations](https://support.microsoft.com/topic/windows-devices-with-it-managed-updates-e2b43f9f-b424-42df-bc6a-8476db65ab2f)
- [Secure Boot frequently asked questions (FAQ)](https://support.microsoft.com/topic/frequently-asked-questions-about-the-secure-boot-update-process-b34bf675-b03a-4d34-b689-98ec117c7818)
- [What happens when Secure Boot certificates expire on Windows devices](https://support.microsoft.com/topic/when-secure-boot-certificates-expire-on-windows-devices-c83b6afd-a2b6-43c6-938e-57046c80c1c2)
- [How to use Microsoft Intune to update certificates for Windows devices with IT-managed updates](https://support.microsoft.com/topic/microsoft-intune-method-of-secure-boot-for-windows-devices-with-it-managed-updates-1c4cf9a3-8983-40c8-924f-44d9c959889d)
- [How to perform registry key updates for Windows devices with IT-managed updates](https://support.microsoft.com/topic/a7be69c9-4634-42e1-9ca1-df06f43f360d)
- [How to use GPO method for Windows devices with IT-managed updates](https://support.microsoft.com/topic/65f716aa-2109-4c78-8b1f-036198dd5ce7)
- [Windows Configuration System (WinCS) APIs for Secure Boot](https://support.microsoft.com/topic/d3e64aa0-6095-4f8a-b8e4-fbfda254a8fe)
- [Key creation and management guidance for OEMs](https://support.microsoft.com/topic/windows-secure-boot-key-creation-and-management-guidance-c4ce3153-9d90-4671-a0ee-bbeec894eaaa)

---

Continue the conversation. Find best practices. Bookmark the [Windows Tech Community](http://aka.ms/community/Windows), then follow us [@MSWindowsITPro](https://x.com/mswindowsitpro) on X and on [LinkedIn](https://www.linkedin.com/company/windows-it-pro). Looking for support? Visit [Windows on Microsoft Q&A](https://docs.microsoft.com/answers/products/windows#windows-client-for-it-pros).

<sup>[1]</sup> Updated certificates are the latest security measure to address the BlackLotus UEFI bootkit vulnerability tracked by [CVE-2023-24932](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2023-24932).  
<sup>[2]</sup> Registry key support is available to Windows 10, version 22H2 and newer versions (including 21H2 LTSC), all supported versions of Windows 11, as well as Windows Server 2022 and later. Any other versions of Windows still in support will get these registry keys soon.  
<sup>[3]</sup> For all events, go to Event Viewer > Windows Logs > **System**. Please see complete details under [Secure Boot DB and DBX variable update events](https://support.microsoft.com/topic/secure-boot-db-and-dbx-variable-update-events-37e47cf8-608b-4a87-8175-bdead630eb69).

Version 20.0