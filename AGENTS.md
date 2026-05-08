# AGENTS.md — Powershell-Scirpts

Script PowerShell per amministrazione Microsoft 365 / Entra ID.
Remote: `https://github.com/mattbrambilla/Powershell-Scirpts.git` (branch: `master`)

## Attenzione

- **README.md** è un template boilerplate non personalizzato → non fidarsi, usare AGENTS.md.
- Script contengono segnaposto da sostituire prima dell'esecuzione:
  - `TuoClientID`, `TuoClientSecret`, `TuoTenantID`
  - `[Your Mailbox adress here]`
  - `contoso.sharepoint.com`, `admin1contoso@example.com`
- Mix di commenti in italiano e inglese.

## Struttura directory

| Directory/file | Contenuto |
|---|---|
| `Exchange Online/` | Exchange Online: retention policy, address list, room mailbox, mailbox enumeration |
| `Microsoft Entra/` | Microsoft Entra ID: MFA metodi autenticazione |
| `SharePoint Online/` | SharePoint Online: aggiunta admin di sito in blocco |
| `remove duplicate users/` | Rimozione utenti duplicati |
| Root `*.ps1` | Script vari: app permissions, OneDrive, Teams export, blocco remoto PC, cambio lingua sistema, copia file tra server |

## Moduli PowerShell richiesti

Installare se mancanti, poi connettersi prima di eseguire script:

- `ExchangeOnlineManagement` → `Connect-ExchangeOnline`
- `Microsoft.Graph` (o `Microsoft.Graph.Authentication`) → `Connect-MgGraph`
- `Microsoft.Online.SharePoint.PowerShell` → `Connect-SPOService`

## Convenzioni stile

- Comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.LINK`, `.NOTES`, `.CHANGELOG`)
- Variabili in cima. Colori: `cyan` (sistema), `green` (processo), `red` (errore), `yellow` (avviso)
- Selezione interattiva con `Out-GridView -PassThru`
- Nessun test, linter, o CI configurato

## Commit

Messaggi in inglese. Conventional Commits preferiti:

| Prefisso | Uso |
|---|---|
| `feat:` | Nuovo script o funzionalità |
| `refactor:` | Miglioramenti/refactoring |
| `fix:` | Correzione bug |
| *(nessun prefisso)* | Frasi descrittive semplici (es. `Add script to ...`, `Remove ...`) |
