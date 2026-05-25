# Autopilot Onboarding Deep Dive — Magic Trick Revealed

**Summary**: A protocol-level walkthrough of every phase of Windows Autopilot enrollment — from OOBE device authentication through Entra ID join, MDM enrollment, IME installation, ADMX ingestion, and policy delivery order.

**Sources**: `Onboarding modern with Autopilot Magic trick revealed.md`

**Last updated**: 2026-04-13

---

## Purpose

This article by Mattias Melkersen (msendpointmgr.com, 2024-07-05) demystifies the Autopilot "black box" — explaining the exact network calls, registry writes, and service interactions at each phase. Useful for troubleshooting enrollment failures and understanding why certain things happen in a specific order.

The high-level summary of each phase is in [[windows-autopilot]]. This page captures the detail and troubleshooting context.

## Key Insight: Where Autopilot's Job Ends

Autopilot's responsibility ends the moment the JSON profile is downloaded and the device shows the branded login screen. Everything after the user signs in — Entra ID join, MDM enrollment, IME install, policy delivery — is handled by Windows, OMA-DM, and the [[intune-management-extension]]. (source: Onboarding modern with Autopilot Magic trick revealed.md)

## OOBE Authentication Flow

The device authenticates to Microsoft services using `wlidsvc.dll` (Microsoft Account Sign-In Assistant), which generates a random username/password. This results in a device token stored at:

```
HKCU:\SOFTWARE\Microsoft\IdentityCRL\Immersive\production\Token
```

The Autopilot service endpoint is `ztd.dds.microsoft.com` — this URL is **not** in the standard Intune endpoints list; it's only in the Autopilot-specific requirements doc.

The Autopilot profile JSON is saved to: `C:\Windows\servicestate\wmansvc`

## Timing Considerations

- Upload device hash **at least one day** before provisioning (dynamic group membership sync delay)
- Dynamic groups must resolve before the Autopilot profile assignment is active
- `ztd.dds.microsoft.com` must be reachable at OOBE time — proxy/firewall issues here cause "device not recognized" failures

## Entra ID Join — Technical Details

The join process uses `Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy` (the Cloud Experience Host webapp). Key URL chain:

1. `login.microsoftonline.com/common/oauth2/token` — Entra + MDM tokens
2. `enterprise.registration.net/yourdomain/discover?api-version=1.7` — discovers Device Join Service URL
3. `enterpriseregistration.windows.net/EnrollmentServer/device/` — actual Entra ID join request

The join service creates the Entra device object and returns the ms-organization certificate, plus SIDs for local Administrators group population.

## MDM Enrollment — Certificate in TPM

The enrollment x509 certificate is stored both on the device and **in the TPM**. This is the trust anchor between the device and Intune. The security token used during enrollment contains: DeviceID, TenantID, IP Address, ZTD device ID.

## NodeCache

NodeCache (`HKLM\SOFTWARE\Microsoft\Provisioning\NodeCache\CSP\Device\MS DM Server`) is the client-side cache that mirrors the MDM server's view of device state. It is written during Phase 3 (Preparing for MDM):
- ~1308 settings on a typical fast device
- Takes approximately 2.5 minutes to complete
- Allows the MDM server to detect what has changed rather than re-sending all policies

## Policy Delivery Order (Observed)

During Device Setup Phase 1, policies arrive in this order on a typical device:

1. **Certificates** (ESP tracked) — binary Blob in SystemCertificates registry
2. **DeviceHealthMonitoring** (not tracked) — written to providers and current policy hives
3. **Defender** (not tracked) — signature/engine/platform ring updates, even without explicit configuration
4. **Windows Updates** (not tracked) — `AllowAutoUpdate` and update ring; preview build policy stored in System hive

Actual order may vary based on assigned policies.

## Troubleshooting Reference

| Symptom | Area to Investigate |
|---------|-------------------|
| Device not recognized at OOBE | Hash not in Autopilot database; or `ztd.dds.microsoft.com` unreachable |
| Company branding not shown | Autopilot profile not retrieved; dynamic group not resolved |
| Stuck at Preparing screen | Check IME installation (Phase 3); 0x800705B4 = IME MSI delivery failure |
| Scripts not running post-enrollment | See [[ime-powershell-script-delay]] and [[intune-management-extension]] |

**Useful tools:**
- [SyncMLViewer](https://github.com/okieselbach/SyncMLViewer) — trace OMA-DM protocol stream live during enrollment
- IME log files — track script workload and session change events

(source: Onboarding modern with Autopilot Magic trick revealed.md)

## Related pages

- [[windows-autopilot]]
- [[intune-management-extension]]
- [[ime-powershell-script-delay]]
