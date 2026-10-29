# Edge + OneDrive migration prep for ProfWiz (domain to Entra)

Two PowerShell scripts I wrote so users don't lose their browser passwords, their files, and a pile of random AppData crap when you move them from a domain account to Entra ID with ProfWiz. No credential dumping tools involved, and I'll get into why that matters further down.

MIT licensed, provided as-is. Pilot this on a handful of machines first. It changes machine policy and resets per-user browser state, so please don't YOLO it across a 400 seat client on a Friday afternoon.

## Why this exists

ProfWiz is great at keeping the Windows profile folder intact. The problem is that the stuff users actually notice is tied to the old identity, and it doesn't come along for the ride:

- Browser passwords and cookies are encrypted with keys bound to the old account and the machine (DPAPI, plus App-Bound Encryption in Chrome and Edge). You can copy the profile folder all day long and none of it will decrypt under the new Entra account.
- Desktop, Documents and Pictures stay local unless something moves them.
- Sticky Notes, Outlook signatures and Teams backgrounds live in per-user AppData folders that profile tools and Known Folder Move both skip. These are the ones that turn into angry tickets the Monday after cutover.

So instead of trying to drag all of that across the identity change by hand, each kind of data goes through whatever Microsoft already built to move it, and it lands keyed to the new identity on the other side:

| Data | How it moves | Which script |
|------|--------------|--------------|
| Favorites, passwords, history, settings | Edge enterprise sync (re-encrypts under the Entra account) | Prep |
| Desktop, Documents, Pictures | OneDrive Known Folder Move | Prep |
| Sticky Notes, Outlook signatures, Office templates and custom dictionary, Teams backgrounds | Copied into OneDrive | Cutover |
| Chrome saved passwords | It's complicated, see "Chrome passwords suck" below | Depends on your pilot |

## How it works

There are two scripts because there are two jobs. One sets things up days ahead of time, the other runs at cutover.

### Prepare-Migration.ps1 (run this well before cutover)

This one only changes policy and browser state, so everything is already syncing by the time you flip the switch. It doesn't move any user data.

- Forces Edge sign-in with the work account and turns on enterprise sync for every data type.
- Brings back the Edge first-run experience so Edge imports from Chrome or Firefox on next launch.
- Sets up OneDrive Known Folder Move for Desktop, Documents and Pictures (needs `-TenantId`).
- Rips out the on-prem-only Edge policies that block cloud sync.
- Tells you which users have Chrome saved passwords, since they might need the manual step below.
- Exports every policy key before it touches it, so `-Revert` can put things back the way they were.

```powershell
# dry run, changes nothing
.\Prepare-Migration.ps1 -TenantId <tenant-guid> -WhatIf

# apply it and close the browsers so the policy and the import kick in now
.\Prepare-Migration.ps1 -TenantId <tenant-guid> -CloseBrowsers -SignInPattern '.*@contoso\.com'

# undo all of it
.\Prepare-Migration.ps1 -Revert
```

### Invoke-MigrationCutover.ps1 (run this inside the ProfWiz sequence)

This grabs the last bits of data and decides whether it's safe to cut over.

- Copies the AppData leftovers into `<OneDrive>\_MigrationBackup`, keeping the same path relative to the profile so it's obvious where everything goes back. It only copies. The originals stay put.
- Checks that each user is ready, meaning Edge is signed in and OneDrive is set up.
- Shreds the password handoff folder so no exported CSV survives the cutover.
- Exits non-zero if anyone isn't ready, so ProfWiz holds instead of cutting someone over half done. `-Force` overrides that if you're gating cutover some other way.

```powershell
.\Invoke-MigrationCutover.ps1 -WhatIf   # dry run
.\Invoke-MigrationCutover.ps1           # stage and check; exit 0 means go
```

Exit codes: `0` everyone is ready, `2` at least one user isn't, `1` the script itself blew up.

## Chrome passwords suck

This is the one piece I couldn't fully automate, and it's a genuine pain in the ass, so read this before you count on it.

Only Chrome can decrypt Chrome's saved passwords. App-Bound Encryption ties the key to Chrome's own application identity and seals it with a SYSTEM service. Edge can't read it. Nothing you run as the user or as admin can read it. Roaming the profile folder doesn't help either, because the key doesn't move with it.

You'll find tools online that claim to "decrypt v20" passwords. Those are credential harvesters. Do not run them on client machines. That should be obvious, but I've read enough r/msp threads to know it isn't.

Here's what actually works, in order:

1. **Let Edge import from Chrome and test it in your pilot.** The prep script already sets the import policies. If the passwords make it over, Edge sync carries them and you're done, with no plaintext anywhere. Test it by logging into a real site in Edge. Seeing entries in the password list doesn't prove they work.
2. **If the pilot shows they didn't import, have the user export from Chrome themselves** (`chrome://password-manager/settings`, then Export). Chrome makes the user re-authenticate to do this, and that's deliberate: the person who owns the passwords has to sign off on moving them, and no script can do that for them. Save the CSV into the `PasswordHandoff` folder the prep script creates under `ProgramData` (it's outside OneDrive on purpose), import it into Edge, let it sync, and the cutover script shreds the folder. Do not save that CSV to Desktop, Documents or Pictures. KFM will happily upload a plaintext password file to the cloud for you.

And don't set Chrome's `ApplicationBoundEncryptionEnabled` to `0` to get around this. It weakens security on the machine, and it isn't retroactive, so the passwords that are already saved stay encrypted anyway. You'd be lowering your guard for literally nothing.

## Requirements

- Windows PowerShell 5.1 or newer. If something launches the scripts in 32-bit PowerShell, they relaunch themselves in 64-bit.
- Run elevated: an admin shell, or SYSTEM from Intune, ConfigMgr or a GPO startup script.
- Edge enterprise sync has to be licensed and turned on in the tenant. That means an Entra ID / Microsoft 365 plan that includes Rights Management. Microsoft's Edge enterprise sync prerequisites page has the details.
- Your Entra tenant ID for Known Folder Move (Entra admin center > Overview > Tenant ID).

## Parameters

### Prepare-Migration.ps1

| Parameter | Default | What it does |
|-----------|---------|--------------|
| `-TenantId` | *(none)* | Entra tenant GUID. Needed for OneDrive KFM. Leave it off and you only get the Edge stuff. |
| `-ImportFrom` | `Auto` | `Auto` / `Chrome` / `Firefox` / `DefaultBrowser` / `None`. Which browser Edge imports from at first run. |
| `-SignIn` | `Force` | `Force` makes users sign in before they can browse. `Allow` makes it optional. |
| `-SignInPattern` | *(none)* | Regex for which accounts can sign in, like `.*@contoso\.com`. |
| `-CloseBrowsers` | off | Closes Edge, Chrome and Firefox so the changes and the import happen now. |
| `-Revert` | off | Restores every policy key that was backed up on the first run, then exits. |
| `-StateDir` | `C:\ProgramData\EntraMigrationPrep` | Where the log, policy backups and password handoff folder live. |

### Invoke-MigrationCutover.ps1

| Parameter | Default | What it does |
|-----------|---------|--------------|
| `-StateDir` | `C:\ProgramData\EntraMigrationPrep` | Has to match whatever the prep run used. |
| `-SkipStaging` | off | Skip copying the leftovers. Only does the readiness check and the shred. |
| `-Force` | off | Exit 0 even if some users aren't ready. |

Both scripts support `-WhatIf` and write a timestamped log to `-StateDir`.

Want to grab more AppData stuff at cutover? Edit `Get-MigrationLeftover` in the cutover script and add a line per path. Everything in the table above is already in there.

## Gotchas

- **The Edge first-run reset isn't documented.** Deleting the `First Run` file so the import fires again is a well known trick, but Microsoft doesn't officially support it. Make sure it works on your Edge build during the pilot.
- **Edge only auto-imports from one browser per machine.** If a user has both Chrome and Firefox, the second one gets imported by hand. The prep log tells you who.
- **GPO will stomp on this.** If a domain GPO already manages these Edge or OneDrive settings, it'll overwrite these values at the next refresh. Set them in the GPO for the migration wave instead.
- **The readiness check can't prove the upload finished.** It confirms Edge is signed in and the OneDrive folder exists, both of which it can read locally. It can't tell you the cloud upload actually finished. The log points you at `edge://sync-internals` for that.
- **OneDrive has to be signed in before cutover can copy anything into it.** Run cutover after OneDrive setup, or just run it again.

## Disclaimer

MIT license, as-is, no warranty. These scripts change machine policy and per-user browser state. Test them in a pilot ring on your actual Edge and Chrome builds before you use them in a production migration. What you run on your fleet is on you.

Happy automating!

© 2026 MSP Automator Labs LLC (Ceej the MSP Automator)
