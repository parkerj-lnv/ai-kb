---
title: "Secure Boot"
source: "https://directaccess.richardhicks.com/category/secure-boot/"
author:
  - "[[Richard M. Hicks]]"
published:
created: 2026-04-13
description: "Posts about Secure Boot written by Richard M. Hicks"
tags:
  - "clippings"
---
![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/04/hourglass2.png?w=1024&ssl=1)

For IT administrators responsible for managing Windows devices, a crucial certificate update milestone is coming in June 2026 that could result in degraded security for systems that are not updated. Specifically, the Microsoft certificates that manage UEFI [Secure Boot](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot) trust will expire, potentially allowing untrusted or malicious software to load on affected machines during system boot.

Windows Secure Boot is a UEFI firmware security feature that ensures a computer boots only with trusted, digitally signed operating system loaders and drivers, preventing malicious code (such as rootkits or compromised bootloaders) from loading during startup. Introduced with Windows 8, it verifies the cryptographic signatures of boot components against a database of authorized keys, blocking unauthorized or tampered software to protect system integrity from the earliest stages of boot.

## Chain of Trust

The UEFI Platform Key (PK) is the ultimate root of trust in Secure Boot. It is a single public key owned by the device manufacturer and stored in firmware. The PK certificate signs the Key Exchange Key (KEK) and grants authority to modify the other Secure Boot databases, such as the allowed database (DB) and the disallowed database (DBX). The DB and DBX contain certificates and signatures for authorized and unauthorized software, respectively.

## Microsoft Secure Boot Certificate Expiration

Two crucial Microsoft Secure Boot certificates are set to expire in June 2026. They are:

- Microsoft Corporation KEK CA 2011 (stored in KEK)
- Microsoft UEFI CA 2011 (stored in DB)

In addition, another critical Microsoft Secure Boot certificate expires in October 2026.

- Microsoft Windows Production PCA 2011 (stored in DB)

When these certificates expire, devices may fail to recognize trusted bootloaders, and future Secure Boot policies may not be applied. Updating the certificates ensures continued protection against malicious rootkits and ensures Windows firmware compliance

## View Certificate Information

Ideally, administrators could use PowerShell to view these UEFI Secure Boot certificates. Sadly, the output of the [Get-SecureBootUEFI](https://learn.microsoft.com/en-us/powershell/module/secureboot/get-securebootuefi) PowerShell command is not particularly helpful and does not display any pertinent certificate details.

*Get-SecureBootUEFI -Name KEK*

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-1.jpg?w=936&ssl=1)

## PowerShell Script

To address this limitation, I’ve created a PowerShell script that allows administrators to view all UEFI certificates, including PK, KEK, and DB certificates, and optionally save them as base64-encoded files. The script is available on [GitHub](https://github.com/richardhicks/uefi) and in the [PowerShell gallery](https://www.powershellgallery.com/packages/Get-UEFICertificate/).

*Install-Script -Name Get-UEFICertificate -Scope CurrentUser*

## View UEFI Certificates

After downloading the Get-UEFICertificate PowerShell script, run the following command to view the KEK database.

*Get-UEFICertificate -Type KEK*

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-4.jpg?w=936&ssl=1)

In this example, the only KEK certificate is the expiring Microsoft Corporation KEK CA 2011 certificate. Running the command and specifying the DB type shows only the expiring Microsoft Windows Product PCA 2011 certificate.

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-2.jpg?w=936&ssl=1)

*Note: UEFI also includes hashes of specific executables in the DB and DBX databases. By default, this script focuses on UEFI certificates and omits hash calculations for brevity. Use the -IncludeHashes switch to view this information.*

## Updating Microsoft UEFI Certificates

With the October 2025 updates, Microsoft introduced [new registry key](https://support.microsoft.com/en-us/topic/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates-a7be69c9-4634-42e1-9ca1-df06f43f360d) s to enable and monitor the update status of these UEFI Secure Boot certificates.

### Status

To begin, administrators can check the status of the update process by reading the value of the **UEFICA2023Status** registry key.

*Get-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot\\Servicing\\ -Name UEFICA2023Status | Select-Object UEFICA2023Status*

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image.jpg?w=936&ssl=1)

### Update

To initiate the update process, set the value of **AvailableUpdates** to **0x5944**.

*Set-ItemProperty -Path ‘HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot’ -Name ‘AvailableUpdates’ -Value 0x5944*

Next, start the **Secure-Boot-Update** scheduled task.

*Start-ScheduledTask -TaskName ‘\\Microsoft\\Windows\\PI\\Secure-Boot-Update’*

Once complete, the **UEFICA2023Status** indicates **InProgress**.

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-3.jpg?w=937&ssl=1)

After a reboot, start the **Secure-Boot-Update** scheduled task once more. The **UEFICA2023Status** should indicate that it has been updated (may require one more reboot!).

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-6.jpg?w=936&ssl=1)

## Updated Certificates

After the update process completes, run the Get-UEFICertificate PowerShell script to confirm that new certificates have been added to UEFI Secure Boot.

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-5.jpg?w=936&ssl=1)

*Updated Microsoft KEK Certificates*

![](https://i0.wp.com/directaccess.richardhicks.com/wp-content/uploads/2025/12/image-7.jpg?w=936&ssl=1)

*Updated Microsoft DB Certificates*

## Summary

With multiple Microsoft Secure Boot CA certificates expiring in 2026, organizations need to ensure devices are updated to maintain a valid UEFI trust chain. This guide shows how to view existing firmware certificates, apply Microsoft’s Secure Boot CA 2023 updates, and confirm that new KEK and DB certificates have been installed. Completing this process now will ensure devices remain protected from tampered or malicious boot components as the 2026 expiration dates approach.

#### Additional Information

[Windows Secure Boot certificate expiration and CA updates](https://support.microsoft.com/en-us/topic/windows-secure-boot-certificate-expiration-and-ca-updates-7ff40d33-95dc-4c3c-8725-a9b95457578e)

[Registry key updates for Secure Boot: Windows devices with IT-managed updates](https://support.microsoft.com/en-us/topic/registry-key-updates-for-secure-boot-windows-devices-with-it-managed-updates-a7be69c9-4634-42e1-9ca1-df06f43f360d)

[Get-UEFICertificate PowerShell Script on GitHub](https://github.com/richardhicks/uefi)

[Get-UEFICertificate PowerShell Script in the PowerShell Gallery](https://www.powershellgallery.com/packages/Get-UEFICertificate/)