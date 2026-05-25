# Intune Remediations (Proactive Remediations)

**Summary**: Intune Remediations (formerly Proactive Remediations) are script packages — a detection script plus an optional remediation script — that run on a schedule and report device state back to the Intune portal.

**Sources**: `Monitoring Secure Boot certificate status with Microsoft Intune remediations.md`

**Last updated**: 2026-04-13

---

## What Are Remediations

Remediations are script packages consisting of:
- A **detection script** — runs on devices, outputs a string (shown in the portal), and exits with code 0 (no issue) or 1 (issue found)
- An optional **remediation script** — runs automatically on devices where detection reports an issue

Results are collected centrally in the Intune portal with exportable CSV output. Scripts run as SYSTEM by default (no user interaction required). (source: Monitoring Secure Boot certificate status with Microsoft Intune remediations.md)

## License Requirements

Remediations require one of:
- Windows 10/11 **Enterprise E3/E5**
- Education **A3/A5**
- **F3** licenses

Business Premium or Pro licenses do not include Remediations. (source: Monitoring Secure Boot certificate status with Microsoft Intune remediations.md)

## Key Settings When Creating a Remediation

| Setting | Recommended Value | Notes |
|---------|------------------|-------|
| Run using logged-on credentials | **No** | Runs as SYSTEM; required for registry/WMI/UEFI access |
| Run script in 64-bit PowerShell | **Yes** | Required for `Confirm-SecureBootUEFI` and accurate registry reads |
| Enforce script signature check | Organization preference | Set Yes if org requires signed scripts |
| Schedule | Daily (active rollout) or Weekly (maintenance) | First run may take up to 24h after assignment |

## Viewing Results

In the Intune portal: **Devices > Remediations > [Script Package] > Monitor > Device status**

Add the **Pre-remediation detection output** column to see script output per device. Export to CSV for bulk analysis.

The Overview tab provides a summary dashboard:
- **Devices with issues** — detection exited with code 1
- **Devices without issues** — detection exited with code 0
- **Devices with failed detection** — script error

## Use Case: Secure Boot Certificate Monitoring

A detection-only Remediation can collect [[secure-boot]] certificate status across the entire fleet without making any changes to devices. See [[secure-boot-monitoring-with-remediations]] for full setup steps.

## Related pages

- [[secure-boot-monitoring-with-remediations]]
- [[secure-boot]]
- [[intune-management-extension]]
