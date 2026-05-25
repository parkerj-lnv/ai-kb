# Lenovo Warranty Check with PowerShell

**Summary**: How to query Lenovo device warranty status (active or expired) using PowerShell and the Lenovo Support REST API — no Vantage or third-party modules required.

**Sources**: `Get Lenovo device warranty info (expired or active) with PowerShell.md`

**Last updated**: 2026-04-13

---

## Overview

This technique by Damien Van Robaeys (systanddeploy.com, 2024-09-02) uses web scraping of the Lenovo support site via PowerShell to retrieve warranty status for any Lenovo device by serial number. It does not require Lenovo Vantage or any third-party module. (source: Get Lenovo device warranty info (expired or active) with PowerShell.md)

## How It Works

The script mimics what happens when you manually check warranty at `pcsupport.lenovo.com`:

**Step 1:** Query the Lenovo product API with the serial number to get the device ID:

```powershell
$Device_Info = Invoke-RestMethod "https://pcsupport.lenovo.com/us/en/api/v4/mse/getproducts?productId=$serialNumber"
$Device_ID = $Device_Info.id
```

**Step 2:** Build the warranty URL using the device ID:

```powershell
$Warranty_url = "https://pcsupport.lenovo.com/us/en/products/$Device_ID/warranty"
```

**Step 3:** Perform a web request to the warranty URL and parse the HTML content for warranty information.

(source: Get Lenovo device warranty info (expired or active) with PowerShell.md)

## The Script

Script name: `Get-LenovoWarranty.ps1`  
Available on GitHub: https://github.com/damienvanrobaeys/Lenovo_Warranty_Info/blob/main/Get-LenovoWarranty.ps1

**Usage — specific serial number:**
```powershell
Get-LenovoWarranty.ps1 -SN "Serial number of the device"
```

**Usage — current device (reads its own serial number):**
```powershell
Get-LenovoWarranty.ps1 -ThisDevice
```

(source: Get Lenovo device warranty info (expired or active) with PowerShell.md)

## Potential Extensions

The author noted planned follow-up posts for:
- Azure Automation runbook to check warranty status for all Lenovo devices in the fleet
- Log Analytics dashboard for fleet-wide warranty status
- Azure Automation runbook to automatically add expired-warranty Lenovo devices to a specific Entra ID group

These would make this useful for proactive hardware lifecycle management at scale.

## Notes

- Works for any Lenovo device model; does not require physical access to the device
- Only the serial number is needed — can be retrieved remotely via WMI/CIM: `(Get-CimInstance Win32_BIOS).SerialNumber`
- The REST API endpoint (`api/v4/mse/getproducts`) may change — verify if the script stops working

## Related pages

- [[windows-autopilot]]
