---
title: "Get Lenovo device warranty info (expired or active) with PowerShell"
source: "https://www.systanddeploy.com/2024/08/using-powershell-to-know-if-lenovo.html"
author:
  - "[[Damien Van Robaeys]]"
published: 2024-09-02
created: 2026-04-13
description: "In this post I will show you how to use only PowerShell to know if a Lenovo device warranty is expired or active using only the serial numbe..."
tags:
  - "clippings"
---
[![](https://blogger.googleusercontent.com/img/a/AVvXsEgfGJtIO1f8Qfa62JN-XJ_DQ3Vu-jF7-xYv4D-kh8g7gr0f8-pAEJ8zp46CpdlzcZxSYCeb6d6gOyQpMv6dNu-iByAIYJrq7rjzHfmZywHniYjKztmw3U0UqnJAeQK5nAT1C1JiPjLUNwx-oqeXZqTtX_Ljmuc66AN3kXeS76KDKXkNi2YUgYjU-yHxRXQx=w421-h263)](https://blogger.googleusercontent.com/img/a/AVvXsEgfGJtIO1f8Qfa62JN-XJ_DQ3Vu-jF7-xYv4D-kh8g7gr0f8-pAEJ8zp46CpdlzcZxSYCeb6d6gOyQpMv6dNu-iByAIYJrq7rjzHfmZywHniYjKztmw3U0UqnJAeQK5nAT1C1JiPjLUNwx-oqeXZqTtX_Ljmuc66AN3kXeS76KDKXkNi2YUgYjU-yHxRXQx)

  

In this post I will show you how to use only PowerShell to know if a Lenovo device warranty is expired or active using only the serial number.

**The solution**

The script uses only PowerShell and some web scrapping method to get the warranty information. Here we don't use any module or 3rd party app like Vantage.

You just need to specify a serial number to identity the device.

Of course it should be the serial number of the device for which you want to check the warranty.

When you go on the Lenovo website to check the warranty, you have to specify the serial number as below:

![](https://blogger.googleusercontent.com/img/a/AVvXsEgNY_wrxeqOHKeeLXNRG5Y4gIaRrEOUrMp1OfKgEpOsdDm1Hyz9BgeW5quS3o7e5Dwe9kNk9NTLnIjqOpzVOjdPnYgaUNDtjC4rZb25D0M3Sk7hwLdMnIG6l0DxpiXel_2auZ0SevYXYUD3e1kbNEgc8XbC_yD_wQjEMv9GNiWBFshqq6ioAKwJ-ZnElFmG)  

Then it will show you the warranty status:

![](https://blogger.googleusercontent.com/img/a/AVvXsEgnx2z38liBYrFJznxZqMW1pYz3XyyU0Kpl24b55yN7Y2jzWKt08Mu_EQDjTaKRC5SRSNruuSlC0vkXU-kNtHWA8MOohLvB-r1ovDKAO3iwHt-VMisYhubiIKKBA-hdcGIm6GIO5KpBi4YlBoUOUs5R00fEudqEgpIEqZo2Dwkj24ThYwB7pJp7-YSh6n9u)  

Now you just need to use the F12 developer mode to know what is done behind.

The script here works for any device and you don't need to be on the device to get the warranty information.

**Proceed with PowerShell**

Now let's check the warranty status of a device and see how to do the same with PowerShell.

The first step is to specify a serial number as we have done before:

![](https://blogger.googleusercontent.com/img/a/AVvXsEil0ThsjCbNbZc21FAjWqN5GrjzZQpWnPvusfpGUajuORziwFm4l3-IreQWIfNZx_A1fSzmzYOJdRpsY_RraGR3bUjMVt2bpYln8avP0WZJXpHJvMIqazQSG8eGIMGyzRVYlJHdQ8BoPyvOG-oT4FD9mZMfWT2s_IZQkuE8BQFGx7C8YxRQBCu8z-I6VoSk)  

See below the PowerShell way:

```powershell
$Device_Info= invoke-restmethod"https://pcsupport.lenovo.com/us/en/api/v4/mse/getproducts?productId=$serialNumber"
```

Here the result we get:

![](https://blogger.googleusercontent.com/img/a/AVvXsEhzIb-FXH4nNks34JciPgjQgcr0NGk5qiJNpnJrJuciBAHKCi6LC3FWaB7-ufyQRBbZyYJBSIl9CdM1LZlGL2rysKUZN0NW6GwxTSPfMcXx_kzR45C7VYp1qwoS4hUaZYYqFbbK7z-TNMBSVodd9txpT6SoEsUsLCva4H6V22IAm_xykRYzJR8_U_bXgQLF=w446-h124)  

We need the to get the ID to get the full URL for the next step:

```powershell
$Device_ID= $Device_Info.id
```

  

Then the warranty URL for this device will be the following one:

```powershell
$Warranty_url= "https://pcsupport.lenovo.com/us/en/products/$Device_ID/warranty"
```

https://pcsupport.lenovo.com/us/en/products/LAPTOPS-AND-NETBOOKS/THINKPAD-T-SERIES-LAPTOPS/THINKPAD-T14S-GEN-2-TYPE-20WM-20WN/20WN/20WNS7M800/PC2JLMMR/warranty

When you type the serial number and click on verify it will display warranty info as below:

![](https://blogger.googleusercontent.com/img/a/AVvXsEiDm4rpdjd75pZVagILrAVoykBYD3uFnUrH2_sy4Gw16-B_wB1jDRNjCbPhpGAUk_NZZGQLn1c4LbT7d3lBTAUfvUQl4s_Dk1w8p1ofHMFDMG0z1OPt7NUxu0Sel1PUVrAXU0kQmHysY0kIwHo4jod39FH3bYdnpHJpsGvvC3ocet2VkKWiiLO3pbsVI_Bd)  

Now with PowerShell we will do a request on the warranty URL we have mentioned before:

Then we need to get the content information to get all warranty info:

```powershell
$HTML_Content= $Web_Response.Content
```

![](https://blogger.googleusercontent.com/img/a/AVvXsEjca_ROsHeHIauhIGzrTYD1s2icFxHgJUm1oAFs90twDckeJFgdputYUf_OBlbFrqcIvqbyEh0JHYO_1rwRuTroKX7waoVibkLfdkLlc-ApMSe5yBpRkbV4FBwvayLE9qXmuiL9Ooj9DxfhWOzKjgjBt3jOkjZdSQGeAnglh-NN1TKR-6NxGqiR-bsU0_6T)  
  
Get the script

Click on the below GitHub picture to get the script

[![](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgo7zH8A1AkhUvhjgtCL6VGpnU7JWTLmITB5V75xF7NrKa3aEwX33Ny6A5Bu1qbSn8wzuxqgwoDVWHMjaievVccl2c35OXPAMrmoArYcJMJbv2_ZsuuvxmW1TniQnl2zCEziS4V719UsZh4ioPiBw2HY-nXXCGwyHEAY7aepJTOT4iLAImZ2yfU-k7FK7RF/w154-h128/Octocat.png)](https://github.com/damienvanrobaeys/Lenovo_Warranty_Info/blob/main/Get-LenovoWarranty.ps1)

  

**How works the script?**

The script is called **Get-LenovoWarranty.ps1**

To get the warranty status for a specific device you just need to add the serial number as parameter as below:

```powershell
Get-LenovoWarranty.ps1-SN"Serial number of the device"
```

If you want to get the warranty status of the current device, just add switch **\-ThisDevice** as below:

```powershell
Get-LenovoWarranty.ps1-ThisDevice
```

This will show info as below:

![](https://blogger.googleusercontent.com/img/a/AVvXsEjDg1bHXa0t9e2bn2tJRfcLq57jv-_b5BvSjaiS8zi8SDw3kLVKeSw7911g5RJC-aEQq2G3BfmDcK7sDl107xQ_76IF-5HVSvpNIxlyPyfoti3redBfL7-NlLn9MatI6JimqsblR-tEVRgP5XDbq9sLDOePhQQa_NM8uFydmhUmQH0i8aDzSjM52KbCcczj)  
  

**What's next?**

In the next posts I will show you:

\- An Azure Automation runbook to get the warranty status for all Lenovo devices

\- A Log Analytics dashboard to get warranty status for all your Lenovo devices

\- An Azure Automation runbook that will add Lenovo devices with expired warranty in a specific Entra ID group

See below an overview of the Lenovo warranty dashboard: