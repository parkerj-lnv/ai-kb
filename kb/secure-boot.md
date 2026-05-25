# Secure Boot

**Summary**: Overview of Windows Secure Boot — what it is, the UEFI chain of trust, which Microsoft certificates are expiring in 2026, and how to view and update them.

**Sources**: `Secure Boot.md`, `Secure Boot playbook for certificates expiring in 2026.md`, `Monitoring Secure Boot certificate status with Microsoft Intune remediations.md`

**Last updated**: 2026-04-13

---

## What Is Secure Boot

Secure Boot is a UEFI firmware security feature that ensures a device boots only with trusted, digitally signed OS loaders and drivers. Introduced with Windows 8, it prevents malicious code (rootkits, compromised bootloaders) from loading during startup by verifying cryptographic signatures against a database of authorized keys. (source: Secure Boot.md)

## Chain of Trust

The UEFI trust chain flows from the top down:

| Component | Role |
|-----------|------|
| **Platform Key (PK)** | Ultimate root of trust. Single public key owned by the device OEM, stored in firmware. Signs the KEK. |
| **Key Exchange Key (KEK)** | Grants authority to modify the DB and DBX databases. |
| **DB (Allowed database)** | Contains certificates and signatures for authorized boot software. |
| **DBX (Disallowed database)** | Contains revoked certificates and signatures. |

(source: Secure Boot.md)

## 2026 Certificate Expirations

Three critical Microsoft Secure Boot certificates are expiring:

| Certificate | Database | Expiration |
|-------------|----------|------------|
| Microsoft Corporation KEK CA 2011 | KEK | June 2026 |
| Microsoft UEFI CA 2011 | DB | June 2026 |
| Microsoft Windows Production PCA 2011 | DB | October 2026 |

When these expire, devices may fail to recognize trusted bootloaders, and future Secure Boot policies may not be applied. The replacement certificates are the **2023 CAs** (Microsoft Corporation KEK CA 2023 and Microsoft UEFI CA 2023). (source: Secure Boot.md, Secure Boot playbook for certificates expiring in 2026.md)

Many Windows PCs manufactured since 2024 already have the 2023 certificates. For others, Microsoft delivers them via Windows monthly updates for high-confidence devices. (source: Secure Boot playbook for certificates expiring in 2026.md)

The June 2026 deadline is also linked to addressing the BlackLotus UEFI bootkit vulnerability tracked as CVE-2023-24932. (source: Secure Boot playbook for certificates expiring in 2026.md)

## Checking Certificate Status

### Registry Key

The primary status indicator is the `UEFICA2023Status` registry key:

```
HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing\UEFICA2023Status
```

| Value | Meaning |
|-------|---------|
| (key does not exist / `NoValue`) | Updates not initiated |
| `InProgress` | Update underway, reboot needed |
| `Updated` | 2023 certificates successfully applied |

```powershell
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing\ -Name UEFICA2023Status | Select-Object UEFICA2023Status
```

(source: Secure Boot.md)

### Error Key

If `UEFICA2023Error` exists with a non-zero value, a certificate deployment error has occurred. Trace further using Secure Boot DB/DBX variable update events (Event IDs in Windows System log). (source: Secure Boot playbook for certificates expiring in 2026.md)

### Event IDs

Check **Windows Logs > System** in Event Viewer:

| Event ID | Meaning |
|----------|---------|
| **1808** | Certificates successfully applied |
| **1801** | Error — updated certificates not applied |
| **1795** | Error during handoff of certificates to firmware (contact OEM for firmware update) |

(source: Secure Boot playbook for certificates expiring in 2026.md)

### Viewing UEFI Certificates with PowerShell

The built-in `Get-SecureBootUEFI` cmdlet output is not helpful. Use the community `Get-UEFICertificate` script instead:

```powershell
Install-Script -Name Get-UEFICertificate -Scope CurrentUser
Get-UEFICertificate -Type KEK
Get-UEFICertificate -Type DB
```

Available on [GitHub](https://github.com/richardhicks/uefi) and the PowerShell Gallery. Use `-IncludeHashes` to also view hash entries in DB/DBX. (source: Secure Boot.md)

## Updating Certificates

### Registry Method (Manual / Scripted)

Set `AvailableUpdates` to `0x5944` to deploy all needed certificates and update to the Windows UEFI CA 2023 signed boot manager:

```powershell
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot' -Name 'AvailableUpdates' -Value 0x5944
Start-ScheduledTask -TaskName '\Microsoft\Windows\PI\Secure-Boot-Update'
```

After reboot, run the scheduled task again. `UEFICA2023Status` should reach `Updated` (may require a second reboot). (source: Secure Boot.md)

All Secure Boot registry keys live under:
- `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot`
- `HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing`

### Intune Method (Recommended)

Three Settings Catalog settings under the **Secure Boot** category (disabled by default):
- **Enable SecureBoot Certificate Updates** — initiates deployment
- **Configure Microsoft Update Managed Opt In** — joins Microsoft-managed Controlled Feature Rollout
- **Configure High Confidence Opt-Out** — prevents automatic updates via Windows monthly updates

See [[secure-boot-cert-expiration-2026-playbook]] for the full deployment decision tree.

### Group Policy Method

`Computer Configuration > Administrative Templates > Windows Components > Secure Boot`  
Enable: **Enable Secure Boot certificate deployment** (corresponds to `AvailableUpdates` registry key).  
Requires latest .admx files for Windows 11/Server.

### WinCS Method (Windows 11 23H2+)

Available on Windows 11 versions 25H2, 24H2, and 23H2 for domain-joined clients:
- Feature name: `Feature_AllKeysAndBootMgrByWinCS`
- WinCS key value: `F33E0C8E002`

### High-Confidence Devices

Microsoft automatically updates "high-confidence" devices via Windows Update unless opted out. To opt out, set `HighConfidenceOptOut` to `1` or enable the **Automatic Certificate Deployment via Updates** Group Policy.

## Monitoring at Scale

Use [[intune-remediations]] with the detection script from KB5072718 to collect per-device certificate status across your fleet. See [[secure-boot-monitoring-with-remediations]] for setup steps.

Windows Autopatch users can also use the built-in **Secure Boot status report** under Reports > Windows quality updates.

## OEM Firmware Consideration

Apply the latest BIOS/UEFI firmware update from the OEM *before* applying Secure Boot certificate updates. Some OEMs include updated certificate stores in firmware updates. If `AvailableUpdates` stays at `0x4104` and never clears the `0x0004` bit after multiple restarts, the device is stuck at deploying the KEK — check with the OEM. (source: Secure Boot playbook for certificates expiring in 2026.md)

## Important: Do Not Mix Deployment Methods

Avoid applying multiple deployment methods (e.g., Intune + registry) to the same device simultaneously. (source: Secure Boot playbook for certificates expiring in 2026.md)

## Related pages

- [[secure-boot-cert-expiration-2026-playbook]]
- [[secure-boot-monitoring-with-remediations]]
- [[secure-boot-uefi-cert-update]]
- [[intune-remediations]]
