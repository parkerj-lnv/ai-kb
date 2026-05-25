# Secure Boot Certificate Expiration 2026 — Deployment Playbook

**Summary**: Microsoft's official 5-step playbook for proactively updating Secure Boot certificates before the June 2026 expiration of the 2011 CAs, covering inventory, monitoring, OEM firmware, deployment methods, and troubleshooting.

**Sources**: `Secure Boot playbook for certificates expiring in 2026.md`

**Last updated**: 2026-04-13

---

## Background

Two Microsoft [[secure-boot]] certificates expire in **June 2026** and one in **October 2026**. All Windows devices with Secure Boot enabled must be updated to the 2023 CAs to continue receiving Secure Boot-related security protections. This is also tied to the BlackLotus vulnerability (CVE-2023-24932). (source: Secure Boot playbook for certificates expiring in 2026.md)

Microsoft auto-updates "high-confidence" devices via Windows Update unless opted out. For the rest, admins must act.

Bookmark `https://aka.ms/GetSecureBoot` for the latest resources.

---

## Step 1: Inventory and Prepare

**Inventory:**
- Verify Secure Boot is enabled (most devices manufactured since 2012 have it enabled, but verify)
- Check `UEFICA2023Status` registry key — should ultimately read `Updated`
- Use sample inventory PowerShell commands or the Intune Remediations approach (see [[secure-boot-monitoring-with-remediations]])
- Windows Autopatch users: use the **Secure Boot status report** under Reports > Windows quality updates

**Build a pilot group:**
Focus on less common device models where high-confidence auto-update is not guaranteed.

**Decide on high-confidence behavior:**
- To **opt out** of automatic updates via Windows monthly updates: set `HighConfidenceOptOut` = `1`, or enable the **Automatic Certificate Deployment via Updates** GPO
- To **opt in** to Microsoft-managed Controlled Feature Rollout: set `MicrosoftUpdateManagedOptIn` = `1` (requires diagnostic data sharing), or configure the **Certificate Deployment via Controlled Feature Rollout** GPO

All registry keys live under:
```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing
```

(source: Secure Boot playbook for certificates expiring in 2026.md)

---

## Step 2: Monitor Devices

Check `UEFICA2023Status` for deployment progress:
- **Not started** → key is absent or shows no value
- **InProgress** → update running, reboot needed
- **Updated** → complete

Monitor Event IDs in **Windows Logs > System**:
- **Event ID 1808** — success
- **Event ID 1801** — error; certificates not applied
- **Event ID 1795** — firmware handoff error; contact OEM

Check `UEFICA2023Error` registry key — if it exists with a non-zero value, an error is pending.

(source: Secure Boot playbook for certificates expiring in 2026.md)

---

## Step 3: Apply OEM Firmware Updates First

Apply the latest BIOS/UEFI update from the OEM **before** applying Secure Boot certificate updates. OEM firmware updates may include updated certificate stores and fixes that ensure new Windows certificates are accepted. (source: Secure Boot playbook for certificates expiring in 2026.md)

Check the [Microsoft OEM pages for Secure Boot](https://support.microsoft.com/topic/original-equipment-manufacturer-oem-pages-for-secure-boot-9ecc3ba4-fb50-4bd3-9e9b-f16b35b8fb68) for device-specific guidance.

---

## Step 4: Deploy Certificates — Choose One Method

> **Important:** Do not mix deployment methods on the same device.

Allow approximately **48 hours and one or more restarts** after changing configuration for updates to fully apply.

### Option 1 (Recommended): Microsoft Intune

Three Settings Catalog settings under the **Secure Boot** category (all disabled by default):

| Setting | Purpose |
|---------|---------|
| Enable SecureBoot Certificate Updates | Initiates the certificate deployment process |
| Configure Microsoft Update Managed Opt In | Joins Microsoft-managed Controlled Feature Rollout |
| Configure High Confidence Opt-Out | Prevents automatic updates via Windows Update |

See [Microsoft Intune method of Secure Boot](https://support.microsoft.com/en-us/topic/microsoft-intune-method-of-secure-boot-for-windows-devices-with-it-managed-updates-1c4cf9a3-8983-40c8-924f-44d9c959889d) for detailed settings configuration.

### Option 2: Registry Keys

```
HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\AvailableUpdates = 0x5944
```

This deploys all needed certificates and updates to the Windows UEFI CA 2023 signed boot manager. See [[secure-boot-uefi-cert-update]] for manual registry + scheduled task steps.

### Option 3: WinCS CLI (Windows 11 23H2+ domain-joined)

- Feature name: `Feature_AllKeysAndBootMgrByWinCS`
- WinCS key value: `F33E0C8E002`
- State: **Enabled**

Available on Windows 11 versions 25H2, 24H2, and 23H2 for domain-joined clients.

### Option 4: Group Policy

`Computer Configuration > Administrative Templates > Windows Components > Secure Boot`  
Enable: **Enable Secure Boot certificate deployment**

Requires latest .admx files for [Windows 11](https://www.microsoft.com/download/details.aspx?id=108394) and [Windows Server](https://www.microsoft.com/download/details.aspx?id=108430).

(source: Secure Boot playbook for certificates expiring in 2026.md)

---

## Step 5: Troubleshoot Common Issues

| Symptom | Cause / Action |
|---------|---------------|
| `UEFICA2023Error` key exists with non-zero value | Deployment error — trace via Secure Boot DB/DBX variable update events |
| `AvailableUpdates` stuck at `0x4104` after multiple restarts | Device can't clear the KEK bit — contact OEM; device may not follow [Windows Secure Boot Key Creation and Management Guidance](https://learn.microsoft.com/windows-hardware/manufacture/desktop/windows-secure-boot-key-creation-and-management-guidance) |
| Event ID 1795 in System log | Firmware handoff error — get OEM firmware update |

(source: Secure Boot playbook for certificates expiring in 2026.md)

---

## Related pages

- [[secure-boot]]
- [[secure-boot-monitoring-with-remediations]]
- [[secure-boot-uefi-cert-update]]
- [[intune-remediations]]
