# KillerPivot

**Per-Identity Validated Org-Toggle**

Switch between client Microsoft 365 tenants with one command, and verify the
tenant ID after every connect so a wrong-tenant session never survives to the
prompt.

Stores no credentials. The tenant list holds identifiers only and lives outside
the module, so KillerPivot contains no client data and can be installed by
anyone without carrying yours.

**Compatibility:** PowerShell 5.1 and PowerShell 7. Workstation only, since
Kaseya LiveConnect consoles do not load user modules.

**Requires:** ExchangeOnlineManagement v3 or later. Microsoft.Graph.Authentication
only if you use `-Graph`.

---

## Why

Every tech has had the moment where a command ran against the tenant they were
still connected to from an hour ago. `Connect-ExchangeOnline -UserPrincipalName`
does not prevent this: the Windows broker treats that parameter as a hint and
will hand back whatever account it saw last.

KillerPivot disables the broker to force a real prompt, then asks the session
what tenant it actually landed in. On a mismatch it disconnects and throws, so
you are left with no session rather than the wrong one.

---

## How it works

You save each client once as a short key plus its tenant GUID. From then on the
key is the whole interface. `pivot acme` runs five steps:

1. **Resolve.** The key is looked up in `tenants.json`. An unknown key throws
   before anything connects, and the error lists the keys you do have.
2. **Clear.** Any existing Exchange session is dropped first, so you are never
   half in two tenants. `-KeepExisting` skips this if you deliberately want to
   stack sessions.
3. **Connect.** `Connect-ExchangeOnline` runs with the saved admin UPN and
   `-DisableWAM`, which bypasses the Windows credential broker and forces a real
   sign-in prompt. This is the part that makes the check meaningful: without it
   the broker can satisfy the connect silently from cache and the UPN you asked
   for is ignored.
4. **Verify.** `Get-ConnectionInformation` reports the tenant the session
   actually landed in. That value is compared against the saved GUID. If the
   session returns no info at all, that is also a failure, since unknown is not
   the same as correct.
5. **Report.** A match prints `[VERIFIED]` at the end of the connect line. A
   mismatch prints the expected and received values in red, tears the session
   down, and throws.

With `-Graph`, the same connect-then-verify cycle runs again for Microsoft
Graph. Graph is pinned to the tenant GUID rather than the UPN, and a Graph
mismatch tears down both sessions, not just Graph.

The guarantee is only ever about the session you are in right now. It is not a
lock, so nothing stops you from running `Connect-ExchangeOnline` by hand
afterward. Use `pvc` when you want to confirm rather than assume.

---

## Install

```powershell
Install-Module KillerPivot -Scope CurrentUser
```

Confirm it landed:

```powershell
Get-Module -ListAvailable KillerPivot
```

No profile edits and no config file to create. PowerShell autoloads the module
the first time you run one of its commands. Later updates are
`Update-Module KillerPivot`, which does not touch your saved tenants.

---

## Saving tenants

This is a once-per-client step. After that you only ever type the key.

### Guided

Run it bare:

```powershell
Add-PivotTenant
```

Four values, three of which are filled in for you:

| Prompt         | Behavior                                                                                                                   |
| -------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `Admin UPN`    | The only value with no default. Type the admin account you use for that client, for example `admin@acme.onmicrosoft.com` |
| `Tenant ID`    | Looked up from the UPN domain against Microsoft's public OIDC discovery endpoint. No sign-in needed. If the lookup fails you are asked to paste the GUID |
| `Display name` | Suggested from the tenant's registered organization name. Enter to accept                                                   |
| `Short key`    | Suggested from the domain stem. This is what you will type to connect, so keep it short. Lowercase, digits and dashes, 32 chars max. Enter to accept |

A summary block is printed before anything is written, and nothing is saved
until you answer `Y`. If the key already exists you are asked whether to
overwrite it.

Guided mode triggers on a missing `-Upn`, so `Add-PivotTenant -Key acme` still
prompts for the rest.

### Scripted

Pass all four and it writes without prompting, which is what you want for
onboarding a batch:

```powershell
Add-PivotTenant -Key acme -Upn admin@acme.com -TenantId <guid> -Name 'Acme Inc'
```

`-Force` overwrites an existing key. Without it, a collision throws. Omitting
`-TenantId` or `-Name` in scripted mode still auto-resolves them, and a failed
tenant lookup throws rather than prompting. `-WhatIf` works if you want to see
the entry without writing it.

### Editing and removing

```powershell
Get-PivotTenant              # list everything
Get-PivotTenant acme*        # filter, wildcards allowed
Add-PivotTenant -Key acme -Upn newadmin@acme.com -Force    # update in place
Remove-PivotTenant -Key acme
```

`Add-PivotTenant` is an upsert, so re-adding a key with `-Force` is the way to
change an admin UPN or fix a name. Keys tab-complete on `Get-PivotTenant`,
`Remove-PivotTenant` and `Connect-PivotTenant`.

---

## Switching between tenants

Connect:

```powershell
pivot acme
```

Type the first few letters and press Tab. Completion reads the saved list live
and shows the display name and admin UPN next to each key, so you do not have to
remember exact spellings.

Switching is the same command. There is no separate "disconnect first" step:
`pivot` drops the current Exchange session before it opens the next one, so
`pivot acme` followed by `pivot contoso` leaves you in Contoso only. Each switch
prompts for sign-in by design. That is the cost of the guarantee.

Exchange and Graph together:

```powershell
pivot acme -Graph
```

Default Graph scope is `User.Read.All`. Override per connect with `-Scopes`:

```powershell
pivot acme -Graph -Scopes 'User.Read.All','Group.Read.All'
```

Check where you are before anything consequential:

```powershell
pvc
```

That prints the organization, account and tenant GUID for both Exchange and
Graph, or `not connected` for either. Close everything when you are done:

```powershell
pvx
```

### Commands

| Command                  | Alias   | Purpose                                        |
| ------------------------ | ------- | ---------------------------------------------- |
| `Connect-PivotTenant`    | `pivot` | Connect and verify. Add `-Graph` for Graph too  |
| `Get-PivotContext`       | `pvc`   | Show which tenant you are currently in         |
| `Disconnect-PivotTenant` | `pvx`   | Close all sessions                             |
| `Add-PivotTenant`        |         | Save a tenant. Run bare for the guided version |
| `Remove-PivotTenant`     |         | Drop a tenant from the config                  |
| `Get-PivotTenant`        |         | List saved tenants                             |

`Connect-PivotTenant` parameters: `-Key` (positional), `-Graph`, `-Scopes`,
`-KeepExisting`.

---

## When it refuses

```
[!] Expected : <guid>  (Acme Inc)
[!] Received : <guid>  (Contoso Ltd)
[!] Session torn down. Nothing was run.
```

Working as intended. The sign-in landed somewhere other than where you asked,
usually because a cached browser account was picked up at the prompt. Sign out
of Microsoft accounts in the browser, run it again, and choose the right admin
account explicitly.

The other refusals:

| Message                  | Meaning                                                                    |
| ------------------------ | -------------------------------------------------------------------------- |
| `no tenant with key 'x'` | Not saved yet. The error lists the keys that are                           |
| `duplicate key 'x'`      | The JSON was hand-edited into two entries with the same key. Fix the file  |
| `no session info`        | Connect succeeded but returned no tenant. Unknown is treated as failure    |
| `no tenants configured`  | Empty list, or `PIVOT_CONFIG` points somewhere wrong. Check `Get-PivotTenant` |

---

## Config

Written to `%LOCALAPPDATA%\PIVOT\tenants.json` by default.

Four fields per tenant: a short lowercase key you type, a display name, the
admin UPN, and the tenant GUID. All four are identifiers. Nothing secret is
stored, and authentication stays interactive on every connect.

```json
{
  "schema": 1,
  "updated": "2026-07-29",
  "tenants": [
    {
      "key": "acme",
      "name": "Acme Inc",
      "upn": "admin@acme.com",
      "tenantId": "00000000-0000-0000-0000-000000000000"
    }
  ]
}
```

The file is rewritten and sorted by key on every change, so hand edits survive
but formatting does not. It is safe to edit directly if you prefer, as long as
the shape holds.

To keep the list somewhere backed up, point `PIVOT_CONFIG` at it:

```powershell
[Environment]::SetEnvironmentVariable('PIVOT_CONFIG', 'C:\path\to\tenants.json', 'User')
```

Copy your existing `tenants.json` there first, then open a new shell. Unset
falls back to `%LOCALAPPDATA%`, so a fresh install works with no setup.

Do not commit your own `tenants.json`. A map of every client tenant GUID to its
admin UPN is not a credential, but it is a target list.

---

## Notes

- Forcing a real sign-in prompt on every switch is what makes the guarantee
  real. That tradeoff is deliberate.
- Success prints two lines. The full status block only appears on `pvc`.
- A mismatch is loud and leaves you disconnected. That is the intended outcome.

---

Built and maintained by [Steve the Killer](https://thekiller.net).
