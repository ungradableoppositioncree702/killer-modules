<div align="center">

[![Killer Modules](header.png)](https://killertools.net/killer-modules)

</div>

PowerShell modules for Windows administration and MSP field work. Each folder is a standalone module published to the PowerShell Gallery. Install whichever ones you want.

## Modules

| Module | What it does | Install |
|--------|--------------|---------|
| [**KillerPivot**](KillerPivot) | Switch between Microsoft 365 tenants and verify which one you actually landed in before running anything. Save your tenants once, then pivot by name. | `Install-Module KillerPivot -Scope CurrentUser` |
| [**KillerScripts**](KillerScripts) | Every tool from [killer-scripts](https://github.com/SteveTheKiller/killer-scripts) as a command in any session, pulled fresh from the repo on each run. | `Install-Module KillerScripts -Scope CurrentUser` |

## KillerPivot

`Connect-ExchangeOnline` treats `-UserPrincipalName` as a suggestion. The credential broker hands back whichever account it cached last, so you can end up with a working session against the wrong client and no sign that anything is off.

KillerPivot kills the broker to force a real sign-in, then asks the session which tenant it landed in and compares it against the expected ID. On a mismatch it disconnects and throws, so you are left with no session rather than the wrong one.

```powershell
pivot contoso          # connect and verify
pivot contoso -Graph   # same, plus Microsoft Graph
pvc                    # where am I connected?
pvx                    # close everything
```

Stores identifiers only. No passwords, tokens, or certificates are ever written to disk.

## KillerScripts

Installs the whole killer-scripts toolbox as commands. Each tool is fetched from GitHub the moment you run it, so you are always on the current version, with a local cache as an offline fallback.

```powershell
Get-KillerScript       # list every tool with its description
urt                    # run the Universal Rename Tool
beret                  # BitLocker Encryption, Recovery & Escrow
Update-KillerScripts   # pre-download everything for offline use
```

All 18 tools get their own `Invoke-<NAME>` command and a short alias.

## Requirements

Windows PowerShell 5.1 or PowerShell 7. Individual modules list their own dependencies in their README.

## Issues

Bugs and requests go in [Issues](https://github.com/SteveTheKiller/killer-modules/issues). Include the module name and your PowerShell version.

## License

GPL-3.0

---

More free tools for techs at [killertools.net](https://killertools.net)
