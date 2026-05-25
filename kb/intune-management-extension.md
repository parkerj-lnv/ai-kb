# Intune Management Extension (IME)

**Summary**: The Intune Management Extension (IME) is a Windows agent installed during Autopilot enrollment that handles PowerShell scripts, Win32 apps, and other workloads outside the core OMA-DM channel — with its own trigger and timer logic.

**Sources**: `Intune PowerShell Script Delay Here Is What Really Causes It.md`, `Onboarding modern with Autopilot Magic trick revealed.md`

**Last updated**: 2026-04-13

---

## What Is the IME

The IME is a Windows service installed on Intune-managed devices. It handles workloads that the core MDM/OMA-DM client does not: PowerShell platform scripts, Win32 app installs, and related features like [[intune-remediations]].

It is installed during [[windows-autopilot]] enrollment via the `EnterpriseDesktopAppManagement` CSP as an MSI delivered over the OMA-DM channel. (source: Onboarding modern with Autopilot Magic trick revealed.md)

The IME and the OMA-DM client are **separate components** running in separate "traffic lanes." Actions that trigger one do not necessarily trigger the other.

## IME Triggers for PowerShell Scripts

The IME does **not** maintain a live connection to Intune. It does **not** continuously poll for changes. It reacts to a fixed set of triggers: (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

| Trigger | Notes |
|---------|-------|
| **Session logon** | Most reliable for on-demand execution |
| **8-hour timer expiration** | Hardcoded at 28,800,000 ms in the scriptplugin |
| **IME service restart** | Also resets the timer |
| **Company Portal sync** | Triggers the PowerShell workload |

**What does NOT trigger the PowerShell workload:**
- Remote Sync from Intune portal
- Sync from Windows Settings > Accounts > Work or School
- WNS (Windows Notification Service) push notifications

These sync actions only communicate with the OMA-DM client, not the IME. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## The 8-Hour Timer

The PowerShell scriptplugin sets its workload timer to `28800000` milliseconds (8 hours) when PowerShell scripts are present. This is distinct from the 8-hour MDM maintenance/safety net timer. If a new script assignment is created and no trigger fires, the device waits up to 8 hours before evaluating it. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## Session Change Handling

The IME service implements `OnSessionChange(SessionChangeDescription)`. When the session change reason is `SessionLogon`, the IME immediately:

1. Calls the PS script workload (same path as the timer-driven evaluation)
2. Calls `ProcessAppsOnSession` — also triggers required app evaluation, bypassing the separate 60-minute app check-in interval

This is why both app and script activity appear in IME logs right after a user signs in. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## PowerShell Script Workload Flow

When the scriptplugin fires (via any trigger):

1. IME builds a `PolicyRequest` and sends it to the Intune service
2. Intune returns serialized `EmsPolicy` objects (assigned scripts)
3. Policies are filtered via `FilterPolicies()` — only scripts applicable to the current session/context remain
4. Policies are processed via `ProcessPolicies()` — the schedule manager checks execution history, retry count, and run-once flags
5. If execution is warranted, the script runs and results are reported back to Intune

(source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## User Context vs. Device Context Scripts

- **Device-scoped scripts** run in the SYSTEM context and can execute without a user session
- **User-scoped scripts** require an active user session — a user token must exist

The Microsoft documentation says "users are not required to sign in" — this means the IME itself does not require a manual launch, not that user-context scripts can run sessionless. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## IME Installation During Autopilot

During Autopilot enrollment the IME is installed as follows:

1. OMA-DM delivers IME install data to: `HKLM\SOFTWARE\Microsoft\EnterpriseDesktopAppManagement\S-0-0-00-...\MSI\%GUID%`
2. `MDMAppInstaller.exe` reads the registry path and begins execution
3. An installation session is created and monitored; once complete, it is removed, signaling Intune to proceed
4. ESP tracks the install via a tracked registry path

Error `0x800705B4` during IME installation has been documented in the community. (source: Onboarding modern with Autopilot Magic trick revealed.md)

## Log Location

IME activity is written to its local log files. Session change events and script workload trigger entries appear here — useful for diagnosing why a script did or did not run.

## Related pages

- [[ime-powershell-script-delay]]
- [[windows-autopilot]]
- [[intune-remediations]]
