---
title: "Configure Access To The Microsoft Store App For Windows Devices"
source: "https://learn.microsoft.com/en-us/windows/configuration/store/?tabs=intune"
author:
  - "[[officedocspr5]]"
published:
created: 2026-04-13
description: "Learn how to configure access to the Microsoft Store app."
tags:
  - "clippings"
---
## Configure access to the Microsoft Store app

Microsoft Store is a digital distribution platform that provides a way for users to install applications on Windows devices. For some organizations, business policies require blocking access to Microsoft Store.

This article describes how to configure access to the Microsoft Store app in your organization.

## Prevent access to the Microsoft Store app

You can use configuration service provider (CSP) or group policy (GPO) settings to configure access to the Microsoft Store app. The CSP configuration is available to Windows Enterprise and Education editions only.

The following instructions provide details about how to configure your devices. Select the option that best suits your needs.

- [**Intune**](#tabpanel_1_intune)
- [**CSP**](#tabpanel_1_csp-11)
- [**GPO**](#tabpanel_1_gpo)

To configure devices with Microsoft Intune, [create a Settings catalog policy](https://learn.microsoft.com/en-us/mem/intune/configuration/settings-catalog) and use the following settings:

| Category | Setting name | Value |
| --- | --- | --- |
| **Administrative Templates > Windows Components > Store** | Turn off the Store application | **Enabled** |

Assign the policy to a group that contains as members the devices or users that you want to configure.

## User experience

When you turn off the Microsoft Store application, users get the following message when they open it:

![Screenshot of the Microsoft Store app blocked access.](https://learn.microsoft.com/en-us/windows/configuration/store/images/store-blocked.png)

## Considerations

Here are some considerations when you prevent access to the Microsoft Store app:

- Microsoft Store applications keep updating automatically, by default
- Users might still be able to install applications using Windows Package Manager (winget), or other methods, if they don't need to acquire the package from Microsoft Store
- Devices managed by Microsoft Intune can still install applications sourced from Microsoft Store, even if you block access to the Microsoft Store app. To learn more, see [Add Microsoft Store apps to Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/apps/store-apps-microsoft)

---

## Additional resources

Training

Module

[Manage Universal Windows Platform apps - Training](https://learn.microsoft.com/en-us/training/modules/manage-universal-windows-platform-apps/?source=recommendations)

This module explores using Microsoft Store to manage Universal Windows Platform apps.

Certification

[Microsoft 365 Certified: Endpoint Administrator Associate - Certifications](https://learn.microsoft.com/en-us/credentials/certifications/modern-desktop/?source=recommendations)

Plan and execute an endpoint deployment strategy, using essential elements of modern management, co-management approaches, and Microsoft Intune integration.