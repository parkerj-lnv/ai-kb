# Knowledge Base Index

**Last updated**: 2026-04-13

---

## Concept Pages

| Page | Description |
|------|-------------|
| [[secure-boot]] | Secure Boot fundamentals: UEFI chain of trust, 2026 certificate expirations, how to check and update certificates |
| [[intune-management-extension]] | The IME service: what it does, trigger logic for PowerShell scripts and app installs, installation during Autopilot |
| [[windows-autopilot]] | Autopilot overview and protocol-level walkthrough of all enrollment phases from OOBE to policy delivery |
| [[intune-remediations]] | Intune Remediations (Proactive Remediations): how they work, license requirements, key settings |

## Summary Pages

| Page | Source | Description |
|------|--------|-------------|
| [[ime-powershell-script-delay]] | Intune PowerShell Script Delay Here Is What Really Causes It.md | Why scripts don't run immediately and what actually triggers the IME PowerShell workload |
| [[secure-boot-monitoring-with-remediations]] | Monitoring Secure Boot certificate status with Microsoft Intune remediations.md | Step-by-step setup for a detection-only Remediation that reports Secure Boot cert status per device |
| [[secure-boot-cert-expiration-2026-playbook]] | Secure Boot playbook for certificates expiring in 2026.md | Microsoft's 5-step playbook: inventory, monitor, OEM firmware, deploy (4 methods), troubleshoot |
| [[secure-boot-uefi-cert-update]] | Secure Boot.md | How to view UEFI certificates with Get-UEFICertificate and manually trigger the 2023 cert update |
| [[microsoft-store-access-configuration]] | Configure Access To The Microsoft Store App For Windows Devices.md | How to block the Store app via Intune Settings Catalog and important caveats (winget, app updates, Intune deployments still work) |
| [[autopilot-onboarding-deep-dive]] | Onboarding modern with Autopilot Magic trick revealed.md | Protocol-level Autopilot deep dive with troubleshooting reference and NodeCache/policy delivery order detail |
| [[lenovo-warranty-powershell]] | Get Lenovo device warranty info (expired or active) with PowerShell.md | Query Lenovo warranty status via REST API and web scraping — no Vantage or modules required |
