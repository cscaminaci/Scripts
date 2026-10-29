# ProfWiz Tenant-to-Tenant Migration Kit

This is the kit I use for Entra ID tenant-to-tenant device moves with ForensiT's User Profile Wizard (ProfWiz) Corporate. ProfWiz does the real work on the profile itself. These scripts handle everything around it: figuring out what is on each machine, getting the data OneDrive won't pick up on its own into OneDrive, staging the device so ProfWiz and the new tenant's provisioning package have a clean runway, and putting it all back afterward.

It's three scripts. All of them run on the Windows PowerShell 5.1 that ships with Windows, need no extra modules, take a `-DryRun` switch, log everything, and return exit codes your RMM can alert on. Run the whole flow on a pilot machine before you touch anything that belongs to a real user. I mean it.

## What's in here

| Script | Runs as | When | What it does |
|---|---|---|---|
| `get-migration-inventory.ps1` | SYSTEM | Weeks before | One CSV row per user profile with device, join, tenant, MDM, BitLocker, profile size, browser data, PST/OST, and OneDrive details. Uploads to a blob container if you give it a SAS URL. |
| `invoke-user-data-transfer.ps1 -Mode Backup` | Logged-on user | A day or two before | Zips Chrome, Edge, Firefox, Sticky Notes, and Outlook signatures into the user's OneDrive, backs up Credential Manager entries (including their stored secrets), and sets the Edge ForceSync policy. |
| `invoke-profile-migration.ps1` | SYSTEM | Migration window | Downloads the ProfWiz package, blocks sign-in, logs everyone off, clears the old tenant's MDM enrollment and Windows Hello keys, runs ProfWiz, then lets people sign in again. |
| `invoke-user-data-transfer.ps1 -Mode Restore` | Logged-on user | After first sign-in | Finds the backup in the new OneDrive (or the old OneDrive folder still in the profile) and restores it without deleting anything. |
| `invoke-profile-migration.ps1 -Mode PostMigration` | SYSTEM | After the new join | Puts the original computer name back if the provisioning package changed it, and escrows the BitLocker recovery key to the new tenant. |

Every script has full help. `Get-Help .\invoke-profile-migration.ps1 -Full` lists every parameter.

## What you need first

| Requirement | Why |
|---|---|
| ProfWiz Corporate, with a single deployment exe built in the Deployment Kit using "Deploy using a Desktop Management tool" | That option bundles profwiz.config, the account mapping, and the target tenant's provisioning package (.ppkg) into one exe. It is the only file this kit downloads. Follow ForensiT's Corporate guide for the Azure AD to Azure AD specifics. |
| The `<Log>` value in profwiz.config set to `Migrate.log` (or pass `-ProfWizLogPath`) | The migration script prints the tail of the ProfWiz log into your RMM output. It looks in `C:\ProfileMigration` and `C:\Users\Public\Documents` by default. |
| An Azure storage account with a private container for the exe and one for inventory | Give the exe a read-only blob SAS (`sp=r`) and the inventory container a create/write SAS (`sp=cw`). Keep the expiry short. |
| OneDrive for Business signed in, with Known Folder Move on, in the source tenant | The user backup lands in OneDrive, and KFM covers Desktop, Documents, and Pictures. |
| A OneDrive content migration to the target tenant that includes the `ProfileMigrationBackup` folder | That is how the backup gets from the old OneDrive to the new one. The restore also checks the old `OneDrive - OldCo` folder left in the profile, but don't count on that copy being downloadable once the old account is gone. |
| An RMM that can run scripts as SYSTEM and as the logged-on user | The two user-data runs must be the user. The migration must be SYSTEM, because it logs off every session and would kill itself otherwise. |
| An RMM script timeout longer than your longest ProfWiz run | If the agent kills the script mid-run, the failsafe covers you, but users stay locked out until it fires. |

## Run order

### 1. Inventory

Run as SYSTEM on every device in scope. Pass the inventory container SAS as an RMM script variable named `SasUrl` (see the RMM notes below for why a variable beats a command-line argument):

```powershell
.\get-migration-inventory.ps1 -DryRun     # prints the rows, writes nothing
.\get-migration-inventory.ps1             # saves C:\ProfileMigration\Inventory\<PC>_<serial>_<time>.csv and uploads it
```

Pull the CSVs down and merge them on your workstation:

```powershell
azcopy copy "<inventory container SAS URL>" .\inventory --recursive
Get-ChildItem .\inventory -Filter *.csv -Recurse | Import-Csv | Export-Csv .\all-devices.csv -NoTypeInformation
```

Storage Explorer works just as well for the download. If you want the old filterable HTML view, `Import-Csv .\all-devices.csv | Out-HtmlView` does it once PSWriteHTML is installed.

Things worth a look before the window: profiles with `PstCount` above zero (they are big, Outlook holds them open, and nothing in this kit copies them), `(unresolved)` accounts (orphaned profiles you probably don't want to migrate), low `FreeSpaceGB`, and devices whose `BitLocker` shows `On` (the recovery keys live in the old tenant until PostMigration escrows them to the new one).

Sizes only count what is actually on disk. Cloud-only OneDrive files and profile junctions are skipped, so the numbers don't double count. `-SkipSizeScan` skips the size walk entirely if you just need the device list fast.

### 2. User data backup

Run as the logged-on user a day or two before the window:

```powershell
.\invoke-user-data-transfer.ps1 -Mode Backup -DryRun
.\invoke-user-data-transfer.ps1 -Mode Backup -CloseApps
```

`-CloseApps` closes Chrome, Edge, Firefox, and Sticky Notes first (politely, then forcefully after 15 seconds). Without it the backup still runs, but files a running browser has locked get skipped, copies of databases it has open can be inconsistent, and the run ends with exit code 50 to tell you so. Warn users before you close their browsers.

The backup goes to `<OneDrive>\ProfileMigrationBackup\<COMPUTER>_<USER>\` with one zip per item, `manifest.json`, `SavedLogins.csv`, and `backup-log.txt`. Zips are built in `%TEMP%` and moved in when finished, so OneDrive never syncs a half-written file. Before migrating, check in OneDrive on the web that the folder is there and the zips have real sizes. `-Storage Local` writes the same folder inside the user's profile instead, if OneDrive is not an option. It stays in the profile on purpose: other users can't read it there, and ProfWiz hands it to the new account with everything else.

The backup also sets the Edge ForceSync policy so Edge signs in and syncs the user's favorites, passwords, and settings from their account after the move.

⚠ CRITICAL: `SavedLogins.csv` contains the Credential Manager secrets in clear text, so the backup folder and the OneDrive it syncs to are sensitive. Restore writes those credentials back into the new account's Credential Manager. Browser passwords are separate: Chrome and Edge encrypt saved passwords and cookies with the account's DPAPI keys, and those keys do not transfer, so the restore brings back bookmarks, history, extensions, and settings but not browser passwords, and neither can ProfWiz. Turn on Edge or browser sync, or export browser passwords, before the move. Firefox is the exception, since it keeps its own key store instead of using DPAPI.

### 3. Migration

Run as SYSTEM in the window. Put the payload SAS URL in an RMM script variable named `PayloadUrl`, then:

```powershell
.\invoke-profile-migration.ps1 -DryRun
.\invoke-profile-migration.ps1 -PayloadSha256 '<hash of your ProfWiz exe>'
```

Get the hash with `Get-FileHash .\Migrate-Contoso.exe` before you upload it. The hash is optional, but it guarantees the device runs the exact package you built. If the exe is already on the device (pushed by the RMM, say), use `-PayloadPath` instead of a URL. It gets copied into the locked working folder before it runs.

What it does, in order:

1. Locks `C:\ProfileMigration` down to SYSTEM and Administrators (by default every signed-in user can write to a new folder on `C:\`, and the failsafe runs a script from this one as SYSTEM), then saves the computer name and current join state to `state.json`. A rerun never overwrites the original name. If you change `-WorkingDirectory`, point it at a dedicated folder: the script refuses one that already holds unrelated files rather than rewriting its permissions.
2. Downloads the payload (TLS 1.2, three attempts) and checks the hash. The download happens before anyone is locked out.
3. Registers a failsafe scheduled task that lifts the logon block at the next startup, or after `-FailsafeMinutes` (default 120), whichever comes first.
4. Denies local and RDP sign-in to Everyone, logs off every session, and waits up to `-LogoffTimeoutSeconds` for profiles to unload so ProfWiz can work on them.
5. Removes the old tenant's Intune enrollment: the registry keys under Enrollments, EnterpriseResourceManager, PolicyManager, and OMADM, the EnterpriseMgmt scheduled tasks, and the Intune MDM device certificate. Without this the new tenant's bulk enrollment trips over the old one. Only enrollments whose ProviderID is `MS DM Server` are touched; pass `-MdmProviderId` if the source tenant used something else.
6. Clears the Windows Hello containers (NGC) and the biometric database. Those keys belong to the old tenant and block PIN setup for the new account.
7. Runs ProfWiz, lifts the logon block, removes the failsafe task, and prints the last 100 lines of the ProfWiz log.

`-SkipLogonBlock` skips the failsafe and the sign-in block (users are still logged off), and `-SkipMdmCleanup` and `-SkipHelloReset` skip steps 5 and 6. MDM and Hello failures are logged and the run continues (exit code 50), because stopping halfway with everyone logged off helps nobody.

⚠ CRITICAL: ProfWiz or the provisioning package will usually reboot the device, sometimes before the script reaches its cleanup. That is what the failsafe task is for. Its startup trigger removes the block as the device boots. Leave `-FailsafeMinutes` well above your longest ProfWiz run, because if it fires mid-run, users can sign back in while ProfWiz is still working.

### 4. First sign-in on the new tenant

After the reboot the device finishes joining the new tenant (give it a few minutes before the new credentials work). The user signs in with the new account, OneDrive signs in to the new tenant, and the `ProfileMigrationBackup` folder shows up once the content migration has moved it. Files On-Demand is fine; the restore downloads what it needs.

If the Start menu or search looks broken on first sign-in, check `%LOCALAPPDATA%\ForensiT\Migrate-AppxPackage.log`. That is ProfWiz re-registering the built-in apps for the new account, and security tools interfering with it is the usual cause.

### 5. User data restore

Run as the logged-on user after first sign-in:

```powershell
.\invoke-user-data-transfer.ps1 -Mode Restore -DryRun
.\invoke-user-data-transfer.ps1 -Mode Restore -CloseApps
```

The restore looks in the new OneDrive, then in any older `OneDrive*` folder still in the profile, and picks the backup named `<COMPUTER>_<USER>`. If the name changed (new UPN, device renamed by the provisioning package), it uses the newest backup in that OneDrive and logs a warning. With `-Storage Local` and several backups in the local folder, it stops and asks for `-BackupPath` instead of guessing.

Each existing folder is renamed to `<folder>.pre-restore-<timestamp>` before the zip is extracted, and put back if extraction fails. Nothing gets deleted. Any app still running is skipped (it would overwrite the restore when it closes), so use `-CloseApps` or have the user close everything. Sticky Notes is only restored if its app folder already exists for the account (ProfWiz keeps it), because creating that folder by hand can stop the app from launching. If it gets skipped, open Sticky Notes once and run the restore again. `SavedLogins` writes the backed-up credentials back into the new account's Credential Manager, so mapped drives, RDP hosts, and app logins keep working.

Use `-Item` to restore only some things, for example `-Item Chrome, OutlookSignatures`.

### 6. Post-migration cleanup

Run as SYSTEM once the device is joined to the new tenant:

```powershell
.\invoke-profile-migration.ps1 -Mode PostMigration -DryRun
.\invoke-profile-migration.ps1 -Mode PostMigration -Restart
```

This renames the device back to the name saved in `state.json` (pass `-OriginalComputerName` if that file is gone) and backs up the system drive's BitLocker recovery key to the new tenant. `-Restart` reboots 60 seconds later so the name takes effect. If your provisioning package does not rename devices, add `-SkipRename`. Don't skip the BitLocker part, since the old tenant's copy of the key is the only one otherwise.

## If a device is stuck at "The sign-in method you're trying to use isn't allowed"

That is the logon block still in place. Any of these clears it:

1. Run `.\invoke-profile-migration.ps1 -Mode UnblockLogon` as SYSTEM from the RMM.
2. Restart the device. The failsafe task runs at startup. A real restart, not shut down and power on, because Fast Startup skips startup tasks.
3. Wait for `-FailsafeMinutes` to pass.

`UnblockLogon` only removes rights this kit added, based on `state.json`, so a "Deny log on through Remote Desktop Services" rule Everyone already had before the first run stays in place. Add `-Force` to remove both deny rights from Everyone no matter what `state.json` says.

## RMM notes

Pass SAS URLs as script variables, not command-line arguments. They are full of `&`, which some RMMs mangle on the way to PowerShell. The scripts read `$env:PayloadUrl` and `$env:SasUrl` by default, which is how NinjaOne, Datto RMM, and most others hand script variables over. SAS signatures are masked (`sig=***`) in every log line.

If the agent is 32-bit, `invoke-profile-migration.ps1` relaunches itself in 64-bit PowerShell. A 32-bit process sees a redirected `HKLM\SOFTWARE` and would miss the MDM enrollment keys completely.

`-Verbosity` controls console output only (`Low`, `Medium`, or `High`, default `High`). The log files always get everything.

The scripts are not signed. RMM agents normally run scripts with the execution policy bypassed. If your environment enforces AllSigned, sign them with your own code signing certificate after you make any changes.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Finished cleanly |
| 1 | Unexpected error (the log has the stack trace), or PowerShell rejected a parameter value before the script started |
| 2 | Bad parameters, bad SAS URL, payload hash mismatch, or an ambiguous local backup |
| 10 | Payload download or inventory upload failed |
| 20 | Wrong account (migration not running as SYSTEM, user-data script running as SYSTEM) or not elevated |
| 30 | Payload, OneDrive, or backup not found |
| 40 | ProfWiz returned a non-zero exit code |
| 50 | Finished with warnings: a step or item was skipped or partly failed. The last log line lists them. |
| 60 | The logon block could not be removed and nobody can sign in. Alert on this one. The failsafe task stays registered and tries again at the next startup. |

## Where the logs are

| Log | Location |
|---|---|
| Inventory, migration, post-migration, unblock | `C:\ProfileMigration\Logs\<mode>-<timestamp>.log` |
| Saved state (original name, join state, rights added) | `C:\ProfileMigration\state.json` |
| ProfWiz | Wherever `<Log>` in profwiz.config points. The migration log includes its last 100 lines. |
| ProfWiz AppX re-registration at first sign-in | `%LOCALAPPDATA%\ForensiT\Migrate-AppxPackage.log` |
| User backup and restore | `%LOCALAPPDATA%\ProfileMigration\Logs\user-data-<mode>-<timestamp>.log`, with a copy of the backup log saved as `backup-log.txt` next to the backup |
| Inventory CSV | `C:\ProfileMigration\Inventory\` and the inventory container |

## What does not carry over

| Item | Why | What to do |
|---|---|---|
| Browser saved passwords and cookies (Chrome, Edge) | Encrypted with the old account's DPAPI keys | Export passwords or turn on browser sync before the move |
| Credential Manager passwords | Carried over by the backup and restore (stored in `SavedLogins.csv` in clear text) | Keep the backup folder and its OneDrive restricted |
| Windows Hello PIN and fingerprints | Cleared on purpose, since they are tied to the old tenant | The user sets up a new PIN at first sign-in |
| Office, Teams, and OneDrive sign-in | They belong to the old tenant | They sign in fresh with the new account |
| PST files | Not copied by this kit | Plan for them using the inventory numbers |
| BitLocker recovery keys | Escrowed to the old tenant | `-Mode PostMigration` escrows them to the new one |

## Changelog

2.0.0 (2026-09-22). Consolidated the nine original scripts into three. The three inventory versions and the collate script became `get-migration-inventory.ps1`, which writes CSV and uploads with a single PUT instead of azcopy. Backup, restore, and computer-name restore merged into `invoke-user-data-transfer.ps1` and the PostMigration mode. The staging script replaced ntrights.exe with native Windows calls and picked up the failsafe task, a locked-down working folder, RDP blocking, session detection that works in any OS language, the full MDM cleanup list, BitLocker escrow, 64-bit relaunch, dry runs, logging, and exit codes. Credential Manager backup and restore of the stored secrets, and the Edge ForceSync policy, both carry over from the original, and Edge's data is now backed up as well.

1.x (2023). Original release.

Provided as-is with no warranty.
