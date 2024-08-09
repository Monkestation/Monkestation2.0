https://github.com/Monkestation/Monkestation2.0/pull/2199

## \<NTSL Coding> 

MODULE ID: NTSL

### Description:

Allows people to change how comms work via NTSL
for example, adding in their job after their name

### TG Proc/File Changes:

- code\datums\chatmessage.dm -- Added a if(!speaker); return; due to NTSL code not passing a speaker when you use broadcast()
- code\datums\id_trim\jobs.dm -- Added the ACCESS_TCOMMS_ADMIN to the CE's trim
- code\game\say.dm -- Adds a </a> to the end of endspanpart
- code\game\machinery\telecomms\telecomunications.dm -- Added some logging if there's a wrong filter path
- code\game\machinery\telecomms\machines\server.dm -- Added stuff to make the servers actually compile NTSL
- code\modules\research\techweb\all_nodes.dm -- Added the programming console thingy to the telecomms techweb

- interface\skin.dmf -- Added stuff to make NTSL code editing UI work... im sorry... i really need to turn it to TGUI

- icons\ui_icons\achievements.dmi -- Added the achievement icon for loud and silent birb
- icons\obj\card.dmi -- Added the icon for signal techs

### Included files that are not contained in this module:

- monkestation\code\modules\jobs\job_types\signal_technician.dm
- monkestation\code\modules\clothing\under\jobs\engineering.dm

- monkestation\icons\obj\clothing\uniforms.dmi
- monkestation\icons\mob\clothing\uniform.dmi

### Defines:

- code\__DEFINES\access.dm
- code\__DEFINES\jobs.dm
- code\__DEFINES\achievements.dm -- Added poly achievement defines, since apparently we dont modularize dat
- code\__DEFINES\logging.dm -- Added NTSL log stuff

- code\__DEFINES\~monkestation\access.dm
- code\__DEFINES\~monkestation\jobs.dm
- code\__DEFINES\~monkestation\NTSL.dm

### Credits:

- Altoids1 -- Original author in 2019
- JohnFulpWillard -- Doing a lot of stuff apparently
- Gboster-0 -- Porting to Monkestation, fixes
