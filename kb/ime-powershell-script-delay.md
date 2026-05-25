# IME PowerShell Script Delay — What Really Causes It

**Summary**: Why Intune PowerShell platform scripts don't run immediately after deployment, and exactly what triggers the IME to evaluate and execute them.

**Sources**: `Intune PowerShell Script Delay Here Is What Really Causes It.md`

**Last updated**: 2026-04-13

---

## The Problem

A new PowerShell platform script is assigned in Intune to a device group. The device is online, the IME service is running, and nothing is happening — even hours later. The script finally runs when a user logs in.

This behavior is **not random** — it is the designed, predictable behavior of the [[intune-management-extension]].

## Root Cause

The IME does **not** maintain a live connection to Intune. It does not poll continuously. It reacts only to specific internal triggers. The PowerShell scriptplugin timer is hardcoded at **28,800,000 ms (8 hours)**. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## Triggers That Fire the PowerShell Workload

| Trigger | How It Works |
|---------|-------------|
| **User session logon** | IME's `OnSessionChange()` detects `SessionLogon` and immediately calls the PS workload |
| **8-hour timer** | The scriptplugin timer elapses |
| **IME service restart** | Resets the timer and evaluates immediately |
| **Company Portal sync** | Triggers the workload |

## What Does NOT Trigger It

- **Intune Remote Sync** (from the portal)
- **Sync from Windows Settings** (Work or School account sync)
- **WNS push notifications**

These actions only communicate with the **OMA-DM/MDM stack** — a completely separate component from the IME. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## Session Change Bonus: App Installs Too

When a user logs in, the IME also calls `ProcessAppsOnSession` — this triggers a required app evaluation immediately, bypassing the 60-minute app check-in interval. Both app activity and script activity appear in IME logs after sign-in for this reason.

## The Scenario That Explained It

A script was deployed while a device sat at the Windows logon screen (no user session). The OMA-DM client was healthy, the script existed in Intune — but no session existed, so no logon event fired, and the 8-hour timer had not elapsed. The moment the employee signed in, the IME detected `SessionLogon` and ran the script within seconds. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## User Context vs. Device Context

- **Device-scoped scripts** can run in SYSTEM context without a user session
- **User-scoped scripts** require a user session — no session means no user token to attach to

The Microsoft docs say "users are not required to sign in" — this only means the IME doesn't require manual launch, not that user-context scripts run without a session. (source: Intune PowerShell Script Delay Here Is What Really Causes It.md)

## Practical Takeaways

1. If you need a script to run "now" on a device at the logon screen, have the user log in (or log off and back in).
2. The Sync button is useless for PowerShell scripts — use Company Portal sync instead.
3. For immediate testing, restart the IME service or wait for a session change.
4. The 8-hour IME timer is separate from the 8-hour MDM maintenance/safety-net timer.

## Related pages

- [[intune-management-extension]]
- [[windows-autopilot]]
