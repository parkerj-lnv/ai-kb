# Microsoft Store Access Configuration

**Summary**: How to block or control access to the Microsoft Store app on Windows devices using Intune, CSP, or Group Policy — and what the important caveats are.

**Sources**: `Configure Access To The Microsoft Store App For Windows Devices.md`

**Last updated**: 2026-04-13

---

## Overview

Some organizations block the Microsoft Store to prevent users from installing unsanctioned apps. Access can be controlled via Intune Settings Catalog, CSP, or Group Policy.

> Note: The CSP-based configuration (and therefore Intune) is only available on **Windows Enterprise and Education** editions. (source: Configure Access To The Microsoft Store App For Windows Devices.md)

## Blocking the Store via Intune (Recommended)

Create a **Settings Catalog** policy with:

| Category | Setting | Value |
|----------|---------|-------|
| Administrative Templates > Windows Components > Store | Turn off the Store application | **Enabled** |

Assign to a device or user group. (source: Configure Access To The Microsoft Store App For Windows Devices.md)

## User Experience When Blocked

Users who open the Microsoft Store app will see a blocked access message. The Store app launches but immediately presents the restriction notice.

## Key Caveats

1. **Store apps still auto-update** by default even when the Store UI is blocked — app update behavior is not governed by this policy alone.

2. **Winget still works** — users may still be able to install applications via Windows Package Manager (`winget`) or other mechanisms that don't require acquiring a package from the Store UI.

3. **Intune can still push Store apps** — even with the Store app blocked, Microsoft Intune can deploy applications sourced from the Microsoft Store (via the **Add Microsoft Store apps to Microsoft Intune** workflow). Blocking the Store UI does not block Intune-managed Store app deployments.

(source: Configure Access To The Microsoft Store App For Windows Devices.md)

## Related pages

- [[windows-autopilot]]
- [[intune-management-extension]]
