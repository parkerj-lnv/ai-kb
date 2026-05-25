# Secure Boot UEFI Certificate Update — Manual Steps

**Summary**: How to view existing UEFI Secure Boot certificates with PowerShell, manually trigger the 2023 certificate update via registry and scheduled task, and confirm the update completed.

**Sources**: `Secure Boot.md`

**Last updated**: 2026-04-13

---

## Background

The built-in `Get-SecureBootUEFI` cmdlet provides raw binary output with no readable certificate details. The community `Get-UEFICertificate` script fills this gap. With October 2025 Windows updates, Microsoft also introduced registry keys to trigger and monitor the [[secure-boot]] certificate update process. (source: Secure Boot.md)

## Viewing UEFI Certificates

Install the `Get-UEFICertificate` script from the PowerShell Gallery:

```powershell
Install-Script -Name Get-UEFICertificate -Scope CurrentUser
```

View KEK certificates:
```powershell
Get-UEFICertificate -Type KEK
```

View DB certificates:
```powershell
Get-UEFICertificate -Type DB
```

Add `-IncludeHashes` to also show hash entries (UEFI also stores hashes of specific executables in DB/DBX, not just certificates).

Script is also available at: https://github.com/richardhicks/uefi

(source: Secure Boot.md)

## Checking Update Status

```powershell
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing\ -Name UEFICA2023Status | Select-Object UEFICA2023Status
```

| Value | Meaning |
|-------|---------|
| (absent) | Updates not initiated |
| `InProgress` | Update running, reboot needed |
| `Updated` | Complete |

(source: Secure Boot.md)

## Triggering the Update Manually

**Step 1:** Set `AvailableUpdates` to `0x5944`:

```powershell
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot' -Name 'AvailableUpdates' -Value 0x5944
```

**Step 2:** Start the scheduled task:

```powershell
Start-ScheduledTask -TaskName '\Microsoft\Windows\PI\Secure-Boot-Update'
```

After this, `UEFICA2023Status` will show `InProgress`.

**Step 3:** Reboot the device, then run the scheduled task again:

```powershell
Start-ScheduledTask -TaskName '\Microsoft\Windows\PI\Secure-Boot-Update'
```

`UEFICA2023Status` should show `Updated`. A second reboot may be required. (source: Secure Boot.md)

## Confirming Updated Certificates

After the update, run `Get-UEFICertificate` again to confirm the 2023 certificates appear in KEK and DB:

- **KEK** should now include: Microsoft Corporation KEK CA 2023
- **DB** should now include: Microsoft UEFI CA 2023 and Microsoft Windows Production PCA 2023

(source: Secure Boot.md)

## Important Context

- Registry keys were introduced with the **October 2025** Windows cumulative updates
- This manual/registry method corresponds to Option 2 in the [[secure-boot-cert-expiration-2026-playbook]]
- For fleet-scale deployment, the Intune Settings Catalog method is recommended
- For monitoring status across all devices, see [[secure-boot-monitoring-with-remediations]]

## Related pages

- [[secure-boot]]
- [[secure-boot-cert-expiration-2026-playbook]]
- [[secure-boot-monitoring-with-remediations]]
