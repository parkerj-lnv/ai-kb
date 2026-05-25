---
title: "Onboarding modern with Autopilot: Magic trick revealed"
source: "https://msendpointmgr.com/2024/07/05/onboarding-modern-with-autopilot-magic-trick-revealed/?utm_source=ReviveOldPost&utm_medium=social&utm_campaign=ReviveOldPost&s=09"
author:
  - "[[Mattias Melkersen]]"
published: 2024-07-05
created: 2026-04-13
description: "This blog post is dedicated to Autopilot. As you read the opening line, you may think it’s just another piece about Microsoft’s much-discussed onboarding method. However, that’s not our angle. Our aim is to share the complete narrative. How do you begin troubleshooting when you encounter an error on the ‘preparing’ screen? Even if you’re […]"
tags:
  - "clippings"
---
This blog post is dedicated to Autopilot. As you read the opening line, you may think it’s just another piece about Microsoft’s much-discussed onboarding method. However, that’s not our angle. Our aim is to share the complete narrative. How do you begin troubleshooting when you encounter an error on the ‘preparing’ screen? Even if you’re well-versed in the subject, we believe our insights can still enlighten you. We could delve into complex details with elaborate Wireshark, Procmon, and IDA traces, but that’s not our intention. Instead, we strive to demystify the process and make it more understandable than ever before. While we know Autopilot device preparation is already out, it will take time for companies to adopt this as their primary onboarding process, so the old method of onboarding will stay for a while.

![](https://msendpointmgr.com/wp-content/uploads/2024/07/Autopilot-preparing-this-device.png)

Let’s explore the magical black box and split it into bits and pieces  
If you came so far, it means you are still curious what we are up to. Let’s begin!

## Autopilot Intro

Autopilot has been widely adopted and is used by millions, indicating its status as a necessary technology, regardless of personal opinions. As for the requirements and other specifics, it is recommended to refer to the Microsoft documentation for detailed explanations.

So, what is Autopilot really?  
Windows Autopilot is a cloud-based service that automates the deployment and configuration of new Windows 10 and 11 devices, enabling a ready-to-use state for end-users with minimal IT intervention.

  
But how?  
That is exactly the question, HOW? We will demonstrate how Autopilot works and what Autopilot really is and what it is not.

Initially, you must upload the device hash to the Autopilot database. You can collect the device hash and upload it yourself, but it is often more convenient to have a vendor handle this task, simplifying the process for you as an administrator.

Once this step is completed, and you need to distinguish between devices, you should also apply group tags. These tags facilitate the use of dynamic structures in Entra ID and automate autopilot profile assignments. Note that there may be some delay within the dynamic group, so it’s crucial to construct your rule as precisely as possible to expedite the group’s responsiveness. Another tip is to upload the hash at least a day prior to beginning the provisioning process.

Example of autopilot query that takes all autopilot registered devices:  
  
*(device.devicePhysicalIDs -any \_ -contains “\[ZTDId\]”)*

Example of autopilot query that takes autopilot registered devices with specific group tag:  
  
*(device.devicePhysicalIDs -any \_ -eq “\[OrderID\]:EntraID”)*

![](https://msendpointmgr.com/wp-content/uploads/2024/05/Autopilot-Upload-hash.gif)

This seems straight forward and yeah the process is easy enough but you need to take into consideration of the timings as this needs a bit of time to sink in and be ready to work.

## Out of box experience (OOBE)

The out-of-box experience refers to the initial setup process that a user or IT technician must complete. It should be straightforward and simple to navigate.

We know OOBE as this initial screen

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-17.png)

<video controls="" width="1920" height="1080"><source src="https://msendpointmgr.com/wp-content/uploads/2024/05/oobe.mp4"></video>

The steps will be as described here:

- Unpack the device and set it up.
- Turn on the device.
- If more than one language pack, choose which language.
- Choose region.
- Choose keyboard layout.
- If you wish to add more keyboards choose that or skip it.
- Add internet to the device.

Your friend here is a stable internet connection that you can rely on.

Once a device connects to the internet, numerous processes occur behind the scenes, even though they are not immediately visible.

<video controls="" width="undefined" height="undefined"><source src="https://msendpointmgr.com/wp-content/uploads/2024/05/Device-authentication-1.mp4"></video>

The device initiates a request to login.live.com to execute a “device add request” for device authentication. It employs a randomly generated username and password, created by a local DLL named wlidsvc.dll, also known as the Microsoft Account Sign-In Assistant service.

After the above request is made, the service returns a hardware device ID.

An rsts2.srf file is generated and sent to login.live.com to obtain the final device token required for authenticating and validating the device with the autopilot service.

Live.com returns the device token, validating the device for Autopilot services access. This token is stored locally and can be located in the registry at HKCU:\\SOFTWARE\\Microsoft\\IdentityCRL\\Immersive\\production\\Token.

The device then send a request with the device token together with the Autopilot marker to the autopilot service: ztd.dds.microsoft.com and here it will ask for the autopilot profile: device boot strap policies / Autopilot profile. This URL ztd.dds.microsoft.com is not mentioned in the [Microsoft fundamental documentation right here](https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-endpoints?tabs=north-america), so be aware that you can not use this list as a single source of truth. However it is mentioned [here](https://learn.microsoft.com/en-us/autopilot/requirements?tabs=networking).

If all processes function correctly and the device is recognized (verified to have a record in the autopilot database), it will download the autopilot profile and save it as a JSON file in C:\\Windows\\servicestate\\wmansvc on the local device.

The profile will be retrieved by the Windows management service and display company branding if it has been set up in the Intune portal. The end-user will then be presented with the login screen to enter their username and password.

Finally, this is the state you will find the device in now and here on the first screen we show you how it is **not** supposed to look like:

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-15.png)

And next a working sample:

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-16.png)

Autopilots work is done here. We got the json and it is up to windows and other processes to carry out the instructions from here.

## Device Preparation Phase 1 – Entra ID join

This is the phase where the device start its journey to become managed starting with Entra joining phase.

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-18.png)

<video controls="" width="undefined" height="undefined"><source src="https://msendpointmgr.com/wp-content/uploads/2024/05/entraID-Join.mp4"></video>

The initial step involves securing the hardware, which is not necessary in a user-driven autopilot scenario where this step is completed swiftly, often unnoticed. In contrast, during pre-provisioning, this step may take longer and necessitates TPM attestation.

**The device will reach out to login.microsoft.online.com and request a html based webapp**.

The user encounters the familiar login prompt previously observed in the image accompanying the autopilot JSON delivery.

The user enters their username and password to authenticate and initiate the process. This action triggers the Entra ID join flow, which is the initial step in user provisioning with Autopilot.

The web application, known as Microsoft.Windows.CloudExperienceHost\_cw5n1h2txyewy, will connect to login.microsoftonline.com/common/oauth2/token to request a token. Additionally, if the user possesses an Intune license, the application will simultaneously request the MDM token.

The application Microsoft.Windows.CloudExperienceHost\_cw5n1h2txyewy locates the EntraID join URLs using the dsreg.dll file and, with that information, connects to enterprise.registration.net/yourdomain/discover?api-version=1.7.

It will recieve a response with the DeviceJoinService URL that would be https://enterpriseregistration.windows.net/EnrollmentServer/device/ and then with a JoinResourceID urn:ms-drs:enterpriseregistration.windows.net

**With all that information the device will send a request to EntraID to ask for a certificate. It does that to the device join URL + the token it got.**

The device join service validates the ID Token and once it has been validated it will create the corresponding device object in EntraID. When the object is created it will reply to the device with the ms-organization certificate. It will also respond with SID on user and user groups that should be added to the local administrator group.

Cloud domain join info is converted and written to registry keys that then can be used during this next provisioning phase to give the device a name and know what tenant it needs to reach for:

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-41.png)

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-10.png)

The second step involves joining the device to Entra ID. During this process, the device initiates AADDiscovery, reaching out to enterpriseregistration.windows.net.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-42.png)

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-11.png)

After successfully joining Entra ID, it will receive the ms-organization-certificate and add the configured users and groups to the local administrators group:

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-14.png)

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-13.png)

The Entra ID join process is now complete, and the next step will be to enroll in MDM.

![](data:image/png;base64,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klY4e/rpp23Seg2e8UFD+dSnPqqntqH7cerzev23v/0tWrNmzX0DdHQsCtE6115Wky4X+Oyzz6KHH37YLiXQZQQadKTzpxZShWrV3wdG1bcd7a9UxwUAACpXOQYNlbyFEwAAAE1HObJf2UapAwAA4MFUq0u9WbNm0SOPPGLXQKppFQAAAJWrHNmvVpc6AAAAUEp0qQMAACBVBE4AAACkisAJAACAVBE4AQAAkCoCJwAAAFJV67ZIeiLPiBEjbIj8tWvX4qUAAACoROXIfrVaOAcOHGh3mx8/fny8BAAAAJWqHNmPLnUAAACkisAJAACAVNmThvyh7dnoYe563BFl6kYZymRDGcpkQxnKZEMZymRT7jLLli2L3xXPAmefPn1q+u2rqqqiIUOGRKdPn46qq6ttmSp14cKFevv2KUOZbChDmWwoQ5lsKEOZbChT+jLZst++ffvsdSnUepa6t3aWOtkCAACg8SlH9uMaTgAAAKSqVuC8deuWNalevXo1XgIAAIBKVY7sV6tLHQAAACglutQBAACQKgInAAAAUkXgBAAAQKoInAAAAEgVgRMAAACpInACAAAgVQROAAAApIrACQAAgFQROAEAAJAqAicAAABSReAEAABAqgicAAAASBWBEwAAAKkicAIAACBVBE4AAACkisAJAACAVBE4AQAAkCoCJwAAAFJF4AQAAECqCJwAAABIFYETAAAAqSJwAgAAIFUETgAAAKSKwAkAAIBUETgBAACQKgInAAAAUkXgREV4/fXXo48++ih+l46XXnopmjFjRvyuPMpxXAAApI3A+QBYtGiRhZY9e/bESxq/UtVZIVHbCSctK8TMmTOjV155peDPNyUedPv06RMv+dr69euj7du317zOPL8+aRtOr/UZX7dy5coH4jwCAO4hcD4A+vbtG50+fTpq1apVk/mRL1WdL1y4EO3du9emjz/+OF5aGIXf48ePR59++mm8pHJt2LAh+uKLL6IpU6bES+7Rd9G7d287nyE/x+GkcyWvvvpqNHr06Oju3bu2XN9Dz549LcB36tTJygAAKhuBs8INHTrUftT3799vAWLIkCHxmsarlHU+depUtGzZMpvUslaM1atXR7NmzYquXr0aL6lcOsaDBw/auQ9bOX/4wx/aOgXSkJ/jcNq3b5+tGzBggM1nz55ty+fOnWtBds6cOQ/EuQQAEDgr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)

After that his happened the ClipRenew.exe will kick in which is a tool that will help the device acquire license. It will start its process with “C:\\WINDOWS\\system32\\ClipRenew.exe” -e but nothing further happens for now.

## Device Preparation Phase 2 – MDM enrollment

Once the device is done with entra joining, it will continue to discover the url’s needed to enroll to the MDM service.

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-19.png)

<video controls="" width="undefined" height="undefined"><source src="https://msendpointmgr.com/wp-content/uploads/2024/05/MDM-Enrollment-.mp4"></video>

While this step is running the RuntimeBroker.exe will make sure that OOBE is able to continue if the device should reboot. It does that by adding Autologon registry to HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\UserOOBE\\  
AutologonSigninName  
AutologonIsConnected  
AutologonAuthenticationBuffer  
AutologonPreserveOobeAutologonCredentials

The initial phase of mobile device enrollment indicates that inputting our username during the Entra ID Join resolves the service URI (enrollment.manage.microsoft.com), which is essential for discovering the actual enrollment URIs required for initiating the device enrollment process.

It will then contact the discovery service using the email address, which is actually utilizing your domain. It will respond with the correct enrollment URI required to carry out the enrollment.

Enrollment in the MDM service requires a security token. This token will contain information such as DeviceID, TenantID, IP Address, and the zero-touch device ID.

It contacts the MDM service to retrieve policies, utilizing the token from the previous step. The MDM service will then provide a blueprint for creating the x509 certificate required for the device to be considered trusted.

Once the device has the blueprint, it can begin to request a specific security token (using the aforementioned token). The MDM service will then provide a certificate and designate a storage location for it on the device.

The certificate is stored on the device and in the TPM. Now the enrollment is done and device + MDM (Intune) has trust.

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-22.png)

## Device Preparation Phase 3 – Preparing for MDM

In this phase the device will preparing everything needed for your device to work with Intune.

![](https://msendpointmgr.com/wp-content/uploads/2024/05/image-20.png)

It will query the device for a specific version of nodecache

HKLM\\SOFTWARE\\Microsoft\\Provisioning\\NodeCache\\CSP\\Device\\MS DM Server\\CacheVersion

OmaDMClient.exe enumerates through registry to know what policies it has available from the Windows side  
1st: HKLM\\SOFTWARE\\Microsoft\\Provisioning\\CSPs\\.\\Vendor\\MSFT and index them  
2nd: HKLM\\SOFTWARE\\Microsoft\\Provisioning\\CSPs\\.\\User\\Vendor\\MSFT  
3rd: HKLM\\SOFTWARE\\Microsoft\\Provisioning\\CSPs\\.\\Device\\Vendor\\MSFT  
4th: HKLM\\SOFTWARE\\Microsoft\\Provisioning\\CSPs\\.\\cimv2  
and this goes on and on.

OmaDMClient.exe enumerates through providers and security and index all of them.  
HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers  
HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\default\\Security  

It will alter the service **“Device Management Wireless Application Protocol”** from a startup type Manual to Automatic delayed start.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-89.png)

Then it starts to write this exact policy on the device

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\%Intune GUID%\\default\\Device\\Security\\RequireRetrieveHealthCertificateOnBoot

This is for attestation purpose. You can read more about it [here](https://learn.microsoft.com/en-us/windows/client-management/mdm/healthattestation-csp)

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-87.png)

And then to here:

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\Security\\RequireRetrieveHealthCertificateOnBoot

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-88.png)

The TPM service must initiate contact to obtain a health certificate, starting with the entry of the Intune GUID.

HKLM\\System\\CurrentControlSet\\Services\\TPM\\WMI\\HealthCert\\Store\\EnrollmentID

Secondly by adding a force key for it to reach out

HKLM\\System\\CurrentControlSet\\Services\\TPM\\WMI\\HealthCert\\Store\\has.spserv.microsoft.com\\ForceRetrieve

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-90.png)

Earlier OmaDMClient.exe queried NodeCache and configured a version, next it will create a new key underneath.

HKLM\\Software\\Microsoft\\Provisioning\\NodeCache\\CSP\\Device\\MS DM Server\\Nodes

This marks the beginning as the nodecache is written to the device, serving as a cache that reflects the device’s current state. From the initial node to the last, it typically takes about two and a half minutes to complete on a standard fast computer. On my test device, it recorded 1308 settings.

So what is NodeCache?  
The **NodeCache configuration service provider** is a tool designed to handle the **client cache**, which is a temporary storage area on the client side. This tool is intended **exclusively for use by enterprise management servers**, which are systems that oversee and control corporate networks. It offers a way to manage the list of network nodes independently of the actual storage solution used. This ensures that the client cache stays updated with the **server cache**, which is the equivalent storage on the server side. Additionally, it includes an **API (Application Programming Interface)** that allows for tracking any changes made to the cache on the devices themselves.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-44.png)

HKLM\\SOFTWARE\\Microsoft\\Provisioning\\NodeCache\\CSP\\Device\\MS DM Server\\CacheVersion

is updated with the latest information. Now NodeCache is up2date and ready to take on to the next step.

#### Intune Management Extension

Next step it construct the data to be able to deliver the Intune Management Extension (IME). That will be saved under

HKLM\\SOFTWARE\\Microsoft\\EnterpriseDesktopAppManagement\\S-0-0-00-0000000000-0000000000-000000000-000\\MSI\\%GUID%

The IME is installed, from an MSI, via the OMA-DM channel using the *Enterprise Desktop App Management* Configuration Service Provider (CSP).

This CSP is used to handle enterprise desktop application management tasks, such as querying installed enterprise applications, installing applications, or removing applications.

Using the [SyncMLViwer](https://github.com/okieselbach/SyncMLViewer) from Oliver Kieselbach, we can track track the MSI coming down in the protocol stream.

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-2.png)

You will be able to download the current production IME installation from here if you like to see what it contains. *https://euprodimedatahotfix.azureedge.net/IntuneWindowsAgent.msi*

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-47.png)

Once all the necessary data has been populated and we have the information required to understand IME, MDMAppInstaller.exe will retrieve the details from the registry path *HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Microsoft\\EnterpriseDesktopAppManagement\\  
S-0-0-00-0000000000-0000000000-000000000-000\\MSI* and begin execution.

**INFO:**  
It has been noticed from time to time that this step can fail. If so and you see error 0x800705B4, you can see more about what is happening [here](https://call4cloud.nl/2023/06/the-0x800705b4-error-in-our-stars/)

Omadmclient.exe is configured to update the tracked registry with path1, allowing the ESP to monitor it and wait for the completion of the process.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-50.png)

During installation, a session will be created to monitor the installation progress. Once the installation is complete, this session will be removed, signaling to Intune that it is prepared to proceed with the necessary instructions for IME.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-52.png)

The same CSP, EnterpriseDesktopAppManagement, is utilized for two other mechanisms you may be familiar with. When using the new Endpoint Privilege Management (EPM) feature, this CSP is employed to install the EPM client on the device. Similarly, if you utilize the co-management authority feature, the same CSP is used to download CMsetup.exe, which serves as the starting point for downloading policies from your available configuration manager management point.

#### ADMX backed policies

Next omadmclient will make the device ready to consume certain ADMX backed policies. It will do that by first download the ADMX templates and then installing ADMX for us one by one.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-53.png)

While ingesting the ADMX it will start write the policies that becomes available for intune to put on your device. You will be able to see available ingested ADMX policies here:

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\AdmxDefault\\%Intune MDM GUID%\\

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-69.png)

Once the ADMX is installed it will mark it in registry that it completed and when.

HKLM\\Software\\Microsoft\\PolicyManager\\AdmxDefault\\%Intune MDM GUID%

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-51.png)

The device has completed the preparing for MDM management.

## Device Setup Phase 1 – Security policies, certificates and network connections

During this phase, the device will implement security policies, certificates, and network connections. The specifics of this chapter hinge on the policies you have assigned to groups containing devices or to “all devices.”

**Important notice**  
It is very important to notice here, that your policies can differ from ours. But most of the configuration shown here will most likely apply to your environment too, we are sure.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image.png)

#### 1st Certificates (ESP Tracked)

First policy to come down is written as a REG\_BINARY key called Blob. Inside this key it hold information how to retrieve certificates that has been assigned from Intune.

HKLM\\SOFTWARE\\Microsoft\\SystemCertificates\\ROOT\\Certificates\\AB3FD6E553CCFF3E34C164623B70F30CE1937A74\\Blob

It will then proceed to write the preferred certificate tracking policy or policies, which will be applied as swiftly as possible. Additionally, the count will increment by one for each path it adds to the tracked policies.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-70.png)

#### 2nd DeviceHealthMonitoring (Not Tracked)

One might assume that the firewall CSP or other security-related policies would be the first to apply to a device, but in reality, the initial policy to be enforced is the DeviceHealthMonitoring, assuming it has been assigned—and it’s advisable to do so.

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\%Intune GUID%\\default\\Device\\DeviceHealthMonitoring

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-71.png)

and right after this it will write DeviceHealthMonitoring keys to

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\DeviceHealthMonitoring

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-73.png)

Read more on the device health CSP and what it means to enable it right [here](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-devicehealthmonitoring)

#### 3rd Defender (Not Tracked)

Next policy to come down is 3 specific defender updates. More specifically the signature, engine and platform ring. I didn’t configure those, but anyhow they get configured on my devices.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-74.png)

#### 4th Windows Updates (Not Tracked)

As the fourth policy is implemented, it’s crucial to configure Windows updates if you haven’t already. You’ll definitely want to manage this aspect. In particular, the AllowAutoUpdate policy should be the first one to consider.

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\%Intune GUID%\\default\\Device\\Update\\AllowAutoUpdate

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-75.png)

And last ends up in

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\Update

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-77.png)

If you utilize the update ring policy, a preview build policy will also be among the configured policies. This particular policy is not stored in the same hive as the update registry but is located in the System instead.

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\%Intune GUID%\\default\\Device\\System

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-78.png)

And lastly added here

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\System\\AllowBuildPreview

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-80.png)

#### 5th Defender tagging (Not Tracked)

Because I scope my devices to groups in MDE I have added a policy to add that group ID to the device. This policy is applied as the 5th policy in the chain of policies coming down.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-81.png)

#### 6th Microsoft Defender onboarding (Not Tracked)

It comes as no surprise that we need the onboarding of the device to happen as fast as possible. I wonder though why this is prioritized as the 6th policy and not the first, if a device has been targeted to onboard to this service.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-82.png)

Then the service Windows Defender Advanced Threat Protection (MsSense.exe) is kicking in to get the fresh policy and to get the process started. It uses the same registry entries to look up the tenant ID as in the process where it join the device to Entra.

Windows Defender Advanced Threat Protection service will go from Manual to Automatic and disable from tampering with the service.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-91.png)

#### 7th Delivery Optimization (Not Tracked)

Operating the cloud where all bits and bytes comes from internet we of course should have our DO configured. This is the 6th policy that comes down to the device

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\%Intune GUID%\\default\\Device\\DeliveryOptimization more specifically the download mode.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-83.png)

and last in to

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\DeliveryOptimization

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-85.png)

If you like to know more about Delivery Optimization we have other [posts](https://msendpointmgr.com/2024/06/20/delivery-optimization-troubleshooting-reporting/) that can help you build some nice reports.

#### 8th Firewall – (ESP Tracked)

Firewall is a policy that ESP will be able to track. First thing that the OmaDMClient will do is to ask the registry path beneath what it can track from the firewall CSP node. Tracking policies will be Global, DomainProfile, PublicProfile, PrivateProfile and FirewallRules.

HKLM\\SOFTWARE\\Microsoft\\Windows\\EnterpriseResourceManager\\AllowedNodePaths\\CSP\\Firewall

First one will be the rules that needs to be applied. If you didn’t assign any, you would of course not see them.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-86.png)

#### 9th Microsoft Edge Channel – (Not Tracked)

Either if you use autopatch or just manage Edge yourself, this is something that will come down fast to the device as well.

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\BD9C1553-50EF-432B-A9EC-925DE282894B\\default\\Device\\updatev95~Policy~Cat\_EdgeUpdate~Cat\_Applications~Cat\_MicrosoftEdge\\Pol\_TargetChannelMicrosoftEdge

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-92.png)

And moved on to

HKLM\\SOFTWARE\\Policies\\Microsoft\\EdgeUpdate\\TargetChannel{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-93.png)

#### 10th Bitlocker – (Not Tracked)

I believe that everyone with a windows device also run with some sort of encryption. If you run with the native bitlocker this is the 10th policy that will hit the device.

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\providers\\BD9C1553-50EF-432B-A9EC-925DE282894B\\default\\Device\\BitLocker

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-94.png)

and next here

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\BitLocker

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-95.png)

But this policy is not only applying to the MDM stack. It also had to put a certain setting in the old hive of policies.

HKLM\\SOFTWARE\\Policies\\Microsoft\\FVE\\OSEncryptionType  
HKLM\\SOFTWARE\\Policies\\Microsoft\\FVE\\EncryptionMethodWithXtsOs  
HKLM\\SOFTWARE\\Policies\\Microsoft\\FVE\\EncryptionMethodWithXtsFdv  
HKLM\\SOFTWARE\\Policies\\Microsoft\\FVE\\EncryptionMethodWithXtsRdv

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-122.png)

#### 11th Knobs – (Not Tracked)

Knobs, what can we say about knobs? This is registry added by omadmclient that says something about power schemes. It seems to add a hole lot but at the same time a standard device has the same settings applied already. So why are Intune adding those to the registry portion of a windows device, is a really good question! We think this is not for a regular windows device but maybe for lighter versions that need certain settings to perform best possible while Intune manages the device.

First ~400 settings will get added to this path

HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\knobs

#### 12th LAPS – (Not Tracked)

Then it is time for LAPS to apply. Of course again if you applied it, but why wouldn’t you. LAPS configuration can be found here:

HKLM\\SOFTWARE\\Microsoft\\Policies\\LAPS\\

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-123.png)

#### 13th Firewall settings – (ESP Tracked)

Then it will be time for some generel firewall configuration.

HKLM\\SOFTWARE\\Microsoft\\Windows\\EnterpriseResourceManager\\AllowedNodePaths\\CSP\\Firewall

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-124.png)

#### 14th OneDrive – (Not Tracked)

Time for some OneDrive. Same applies this time, if you haven’t configured it, it might not be something you see, but why wouldn’t you right?!

First i goes to

HKLM\\Software\\Microsoft\\PolicyManager\\providers\\%Intune GUID%\\default\\Device\\  
OneDriveNGSCv2~Policy~OneDriveNGSC  
OneDriveNGSCv4~Policy~OneDriveNGSC  
OneDriveNGSCv5~Policy~OneDriveNGSC

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-147.png)

and then to the known path

HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\current\\device\\  
OneDriveNGSCv2~Policy~OneDriveNGSC  
OneDriveNGSCv4~Policy~OneDriveNGSC  
OneDriveNGSCv5~Policy~OneDriveNGSC

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-148.png)

#### 15th Windows Hello for Business – (ESP Tracked)

Last but not least the last tracked policy in our environment. As stated in the beginning, there can be plenty more. One of my customer has 127 tracking policies as we speak. Especially firewall rules if you have a lot of those, will be filling up the tracked policy space.

If you enable this policy setting, Windows Hello for Business will use a Microsoft Entra Kerberos ticket to authenticate to on-premises resources. The Microsoft Entra Kerberos ticket is returned to the client after a successful authentication to Microsoft Entra ID if Microsoft Entra Kerberos is enabled for the tenant and domain.

You can see more about the CSP right [here](https://learn.microsoft.com/en-us/windows/client-management/mdm/passportforwork-csp#devicetenantidpoliciesusecloudtrustforonpremauth)

HKLM\\SOFTWARE\\Microsoft\\EnterpriseResourceManager\\Tracked\\BD9C1553-50EF-432B-A9EC-925DE282894B\\device\\default\\Path12

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-149.png)

This will result in a policy that will located here:

HKLM\\SOFTWARE\\Microsoft\\Policies\\PassportForWork\\%tenant GUID%\\Device\\Policies\\UseCloudTrustForOnPremAuth

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-150.png)

That concludes it for now on the tracked policies. It doesn’t mean if it is tracked that it will be prioritized before everything else, just that ESP will track it to make sure it applies.

## Device Setup Phase 2 – Apps

The device has now reached the stage where it begins to search for and install applications.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-1.png)

First thing that will happen is that IME is instructed to configure 2 registries

HKLM\\SOFTWARE\\Microsoft\\IntuneManagementExtension\\Notification\\  
  
EnableChannelUriFeature = True  
EnableDeviceActionFeature = True

These keys are related to a new feature we know as device query. If you are using or have used device query you maybe know by know that it uses the IME engine to grab the information queried from the Intune portal on the device and send it back again. If you like to deep dive the subject, you can do so [here](https://call4cloud.nl/2024/02/device-query-a-mad-max-feature/).

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-151.png)

Here are some intriguing observations. Initially, we have the ChannelAddress, which indicates the WNS push address utilized by the device for receiving specific information via IME when necessary.

Another noteworthy detail is the FullSyncFrequencyInHours set at 168. Dividing this by 24 hours yields 7, signifying that the device performs a complete synchronization every seven days.

#### PowerShell scripts

Before apps are installed, IME will start executing PowerShell scripts, also called “platform scripts” in the Intune console. AgentExecuter will be responsible for carring out this task and it can be viewed in the log “C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs\\AgentExecutor.log” what happens.

Within our setup, there are four scripts designated for the device. Consequently, the process will initiate by executing these scripts. The agentExecutor log provides a straightforward way to monitor the script’s status and the outcome of its execution.

Scripts are download to here:

C:\\Program Files (x86)\\Microsoft Intune Management Extension\\Policies\\Scripts  
  
and will create 4 files for every script it executes (the GUID will represent your script from Intune.)  
  
4cce5d56-a9c4-42d9-b822-0e99acdcba91.ps1  
4cce5d56-a9c4-42d9-b822-0e99acdcba91.error  
4cce5d56-a9c4-42d9-b822-0e99acdcba91.output  
4cce5d56-a9c4-42d9-b822-0e99acdcba91.timeout

And if we have a look at the AgentExecuter.log

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-154.png)

**Note:** It is common to see the following error if you have an All-Signed PowerShell policy in place and the script being processed is not digitally signed.

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-6.png)

#### IME Policies

Now is the time to get policies down from Intune so the device knows what it needs to apply.

It will start by populating the system part to the registry here:

HKLM\\SOFTWARE\\Microsoft\\IntuneManagementExtension\\Policies\\00000000-0000-0000-0000-000000000000

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-152.png)

It is also worth mentioning that everytime IME does add a registry key or value it is reflecting the status in the IME log

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-153.png)

The log “C:\\ProgramData\\Microsoft\\IntuneManagementExtension\\Logs\\AppActionProcessor.log” is created and starts to process all the logic that needs to happen with Win32 apps like

- Are the app required
- Is there any uninstall before the installation
- Is the app detected
- Is is applicable
![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-155.png)

#### ESP tracking app

IME agent continues to write to the registry and the first thing that that comes down is the EspTrackingWin32App.

HKLM\\SOFTWARE\\Microsoft\\IntuneManagementExtension\\EspTrackingWin32Apps\\00000000-0000-0000-0000-000000000000

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-156.png)

If you are interested in knowing what these apps that the device added to the tracking list, you can easily do that by grabbing the GUID, navigate to a random win32 app in Intune and then paste the GUID into the address bar.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-157.png)

#### Win32 apps

You cannot specify the application installation order, even when Win32 apps are tracked. The exact order in which the IME will process each Win32 app policy is:-

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-3.png)

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-4.png)

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-5.png)

Next up the IME agent will start adding reporting information to the registry. This will be some sort of help to track the process.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-158.png)

And then it moved onto AppAuthority where it publish all apps that has a assignment for the device

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-159.png)

While everything starts coming together it continues to write into the SideCarPolicies space. SideCar? Where did that come from?

It’s a component that facilitates the installation and management of Win32 apps and PowerShell scripts on Windows devices. During the Enrollment Status Page (ESP) process, Sidecar tracks the installation state of Win32 apps (but not PowerShell scripts). The installation state can have the following values:

- **1 (NotInstalled)**
- **2 (NotRequired)**
- **3 (Completed)**
- **4 (Error)**

During the process the status here in the next picture will start saying: Installing…

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-160.png)

It then goes back to reporting *HKLM\\SOFTWARE\\Microsoft\\IntuneManagementExtension\\Win32Apps\\Reporting\\00000000-0000-0000-0000-000000000000\\* to make sure it is updated with latest status.

Next up its Compliance State Reporting. A compliance report is generated and sent back to the Intune service. These reports are saved as a JSON body in a key under *\\Win32apps\\<deviceGUID\\UserGUID>\\<AppId>\\ComplianceStateMessage*

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-7.png)

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-9.png)

The IME can be decompiled to reveal what the numerical values represent. Here are some of the common state message values you might come across.

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-10.png)

We deep dive into Compliance State Messages at [Win32 app State Messages Demystified – PowerShell FTW (msendpointmgr.com)](https://msendpointmgr.com/2023/08/28/win32-app-state-messages-demystified/)

Next **GRS** get’s written, one record at a time. I needs to go through above flow for each app. **GRS** stands for ==**Global ReEvaluation**== **Scheduler** and is a mechanism within IME that comes into play when a Win32 app deployment fails. After 3 consecutive failed attempts to install an app, the GRS prevents the IME from trying to install the app again for the next 24 hours.

The IME will only retry the app 3 times if the return code is known

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-11.png)

Great preventative action not having a device repeatedly attempting to install an app that has known issues, which will allow admins to troubleshoot and resolve the problem before the system reattempts.

In this example the app has 2 things it needs to keep tack of.  
If you like to troubleshoot this area, you can see more [here.](https://call4cloud.nl/2021/05/imecache-attack-of-the-cleaner/)

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-161.png)

Let us explain. The first GUID is CDBurnerXP, which has a supersedence to another app. Can you guess which? Correct the other GUID mentioned above. That is why we will see 2 GUIDs under this GRS data. If you had only 1 installation without any relationship, there would be one GUID.

![](https://msendpointmgr.com/wp-content/uploads/2024/06/image-162.png)

This process then happens over and over again until there are no more apps that needs to be installed during ESP.

An overview of how GRS handles policy retries can be found below:-

1. Policy is evaluated and installation begins.
2. If installer fails, does the exit code indicate “Retry”? If so, retry 3 more times every 5 minutes.
3. If installer is failed (still), add the app to the GRS.
4. Evaluate a sub graph every 8 hours to check when 24 hours have passed since the app was added to GRS.
5. After 24 hours, retry the installation.
6. Repeat forever.

Because the sub-graph is evaluated every 8 hours, and depending if the machine has been off during a scheduled re-evaluation, it can take anywhere between 24 and 32 hours to re-evaluate a policy

#### Remediation

Next, we have remediation scripts. These scripts are typically located in C:\\Windows\\IMECache\\HealthScripts\\ and are associated with a GUID that can be resolved in the Intune console to identify what is executing on the device.

First, we encounter the detection script, followed by the remediation script. Occasionally, not both scripts are added to your remediation package, yet both will still be downloaded. The script without any code will remain at 0kb.

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image.png)

The AgentExecutor.log file reveals the process flow for remediation.

![](https://msendpointmgr.com/wp-content/uploads/2024/07/image-1.png)

This procedure is repeated for each remediation script assigned to the device or user.

The process writes to ClientHealth.log to verify the device’s IME health, MDM certificate, download location, and the sending of sidecar requests back to Intune. It also checks the Intune Management Extension service and sends back a health report.

## Account Setup

Account setup is very similar to Device setup. If you’ve adopted a strategy of assigning most of your policies to user groups, it’s advisable to maintain this approach in your provisioning strategy. Additionally, if you utilize pre-provisioning, the account setup stage becomes a valuable asset, ensuring the latest configuration / apps is applied before users access their devices.

Should the above not apply, we recommend disabling this phase. It tends to decelerate the provisioning process and offers little benefit if your policies and app stack are already assigned to groups containing your devices.

## Summary

We have reached the conclusion. The device provisioning flow has been thoroughly documented, providing you with comprehensive knowledge of the process from start to finish.

Autopilot plays a minor role in provisioning, supplying a JSON with initial data, which triggers the entire sequence from enterprise joining, through MDM enrollment, to device preparation for management, including configuration settings, app installations, and scripts.

Despite the apparent simplicity, the process is complex. We sincerely hope that this insight into the world of modern provisioning will be advantageous to you in the future.

#### Mattias Melkersen

Mattias Melkersen is a community driven and passionate modern workplace consultant with 18 years’ experience in automating software, driving adoption and technology change within the Enterprise. He lives in Denmark and works at Mindcore.

He is an Enterprise Mobility MVP, Official Contributor in a LinkedIn group with 20.000 members and Microsoft 365 Enterprise Administrator Expert.

Mattias blogs, gives interview and creates a YouTube content on the channel "MEM Tips and Tricks" where he creates helpful content in the MEM area and interview MVP’s who showcase certain technology or topic.

#### Rudy Ooms

Rudy is well-known for his expertise in Microsoft Intune, Windows Autopilot, and Endpoint Privilege Management (EPM).  
As a Microsoft MVP, Rudy has helped many in the tech community with his deep dives into DLL files to solve tricky issues. He’s known for his practical advice and often adds a bit of humor to his work.  
When he's not tackling tech problems, Rudy enjoys a good beer and sharing funny stories from his adventures in IT. His blog, Call4Cloud, is a favorite among those looking for clear and helpful guidance on modern device management.