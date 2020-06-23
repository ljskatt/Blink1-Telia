# Blink1-Telia 

### Krav til scriptet
- Blink(1) USB lys
- [blink1-tool](https://github.com/todbot/blink1) programvare
- Linux med Powershell
- Internett-tilkobling
- Bruker på [Telia sentralbord](https://sb.telia.no) (Bedrift)

### Konfigurasjon

| Konfigurasjon | Beskrivelse | Standardverdi |
| --- | --- | --- |
| blink1_delay | Antall millisekunder lyset bruker på å skifte farge | 800 |
| busy_delay | Antall sekunder det lyser rødt etter samtalen er slutt | 10 |
| error_delay | Antall sekunder fra en feil oppstår til den fortsetter | 10 |
| exit_on_error | Stopp scriptet om det oppstår en feil | false |
| reboot_color | Farge som lyset vil gi når det oppstår feil i scriptet | 40,40,40 |
| blink1_tool | Path til hvor blink1-tool er installert | /usr/local/bin/blink1-tool |

### Farge status

| Farge | Status |
| --- | --- |
| Grønn | Du sitter ikke i en samtale |
| Rød | Du sitter i en samtale, eller cooldown etter samtale (busy_delay) |
| Gul | Innlogging pågår |
| Magenta | Vellykket innlogging til sb.telia.no |
| Svak hvit | Feil har oppstått |
| Ingen farge | Out of office hours, eller feil mellom blink1-tool og USB |


### License

'blink(1)' er et varemerke av ThingM Corporation