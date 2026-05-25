---
title: "Operationalize Lenovo Device management with Microsoft Intune"
source: "https://blog.mindcore.dk/2023/01/operationalize-lenovo-devices-in-an-intune-only-environment/"
author:
  - "[[Mattias Melkersen Kalvåg]]"
published: 2023-01-03
created: 2026-04-15
description: "Maintain Hardware life-cycle-management on Lenovo hardware in your modern device management journey and how to ensure great insights!"
tags:
  - "clippings"
---
Most environments I worked with 2-3 years back were all configuration manager. I see that picture changing constantly. When using Configuration Manager you are used to have rich data available and the data you do not have, you extend the MOF file and get your clients to upload what you need.  
It is not as easy in the cloud or is it? I will try to give you a solution to how you would operationalize e.g. Lenovo devices using only cloud based technology.  
If you are interested in having a nice way to show these data, then follow along!

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image.png)

Steps in this guide

- Download necessary bits and bytes.
- Ingest new ADMX template to Intune.
- Assign Lenovo policies to devices.
- Assign Lenovo Commercial Vantage application to devices.
- Ingest data to log analytics
- Create workbook to show data for **hardware life cycle management** and **operational state** of device.

## Download bits and bytes

Go to [Lenovo Commercial Vantage – Lenovo Support US](https://support.lenovo.com/us/en/solutions/hf003321-lenovo-vantage-for-enterprise) and download Lenovo Commercial Vantage for Windows

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-2.png)

## Lenovo policies

Go to [Devices – Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configurationProfiles)

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-3.png)

If you unpack the source downloaded from Lenovo, this is what you get and where to find the GPO files

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-4.png)

Import ADMX and ADML file found in the downloaded package from Lenovo

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-5.png)

Wait for the ingestion to happen

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-6.png)

You are good to go when this message appears

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-7.png)

Go to Configuration Profiles [Windows – Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/configProfiles)

Create profile

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-8.png)

Choose Windows 10 and later and Templates. There you will see the possibility to use the imported ADXM file.

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-9.png)

Give it a good name

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-10.png)

You see all your newly imported settings. To be able to get battery and warranty information’s we need a certain policy.

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-11.png)

Write warranty information to WMI table – enabled

Accept EULA Automatically – enabled

Write battery information to WMI table – enabled

Create the policy

**INFO:**  
Please be patient when you look for results. Intune only sync approximately every 8 hour.

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-12.png)

On your device this will result in policies applying where we usually looked for applied group policies when using on-prem solutions.

![](https://blog.mindcore.dk/wp-content/uploads/2022/10/image-13.png)

Proceed to add the commercial vantage application to Intune and assign it to your devices.

## Commercial Vantage as win32 app

Phil Jorgensen from Lenovo has provided a great blog how to do this [here](https://blog.lenovocdrt.com/#/2020/cv_intune_deploy) and therefore I will not cover this part, as I made the exact steps from his post and it just works!

Assign the package to your devices, it will automatically detect if your system is a Lenovo or not, as that was catered for in the detection of the Win32 package creation guide.

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-35.png)

## Ingest data to log analytics

Download this [script](https://github.com/mmelkersen/EndpointManager/tree/main/Lenovo%20Inventory) from my GitHub and paste it into PowerShell ISE

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-36.png)

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-37.png)

Save the script to your desktop.

Go to [Proactive Remediation](https://endpoint.microsoft.com/#view/Microsoft_Intune_Enrollment/UXAnalyticsMenu/~/proactiveRemediations) in the Intune Portal

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-38.png)

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-39.png)

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-40.png)

Depending how often you like to ingest data set the **Schedule** accordingly. Remember that it might have a cost if you ingest a lot of data to log analytics. It depends, but generally you will have 5GB data per subscription.

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-41.png)

**TIP**  
You can add a filter to your deployment to only allow the script to run on Lenovo hardware. The filter could look like this:  
*(device.manufacturer -eq “LENOVO”)*

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-43.png)

**TIP**  
Proactive Remediation scripts can easily be read on an endpoint, why having secrets or sensitive data such as **Workspace ID** and **Commercial ID** can be a bad idea. To enhance this you can utilize a much more secure way to ingest data into log analytics created by the MSEndpointMgr team [here](https://github.com/MSEndpointMgr/IntuneEnhancedInventory/blob/main/Proactive%20Remediation/Invoke-CustomInventoryAzureFunction.ps1)

Once you have verified data in your log analytics workspace you are good to go to proceed making a nice shell for data exploring.

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-44.png)

## Create a workbook

Download the workbook file from [here](https://github.com/mmelkersen/EndpointManager/tree/main/Lenovo%20Inventory)

Copy all of the workbooks content

Go to Portal.azure.com -> log analytics -> choose your log analytics workspace where your Lenovo logs are located.

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-49.png)

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-50.png)

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-51.png)

Click done editing, save it and add a propper name to your workbook.

![](https://blog.mindcore.dk/wp-content/uploads/2022/12/image-52.png)

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image-1.png)

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image-2.png)

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image-3.png)

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image-4.png)

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image-5.png)

![](https://blog.mindcore.dk/wp-content/uploads/2023/01/image-6.png)

Now you know what happens on your devices in your environment, and you can make choices on a good basis of information.  
Thanks to Lenovo, Philip Jorgensen and [Damien](https://twitter.com/syst_and_deploy) for making some good ressources to read and play around with!

Happy deployment!

## Ressources:

- [Deploying Commercial Vantage with Intune (lenovocdrt.com)](https://blog.lenovocdrt.com/#/2020/cv_intune_deploy)
- [Lenovo Commercial Vantage – Lenovo Support US](https://support.lenovo.com/us/en/solutions/hf003321-lenovo-vantage-for-enterprise)
- [Intune reporting with Log Analytics: Lenovo BIOS versions (uptodate or not) | Syst & Deploy (systanddeploy.com)](https://www.systanddeploy.com/2022/05/intune-reporting-with-log-analytics.html)