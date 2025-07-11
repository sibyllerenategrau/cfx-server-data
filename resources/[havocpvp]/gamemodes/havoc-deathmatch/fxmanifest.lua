-- Cette ressource a été modifiée et appartient désormais à HavocPvP

version '1.0.0'
author 'HavocPvP'
description 'Mode Deathmatch compétitif pour HavocPvP'

resource_type 'gametype' { 
    name = 'Deathmatch HavocPvP',
    description = 'Combat PvP avec équipement complet et respawn rapide'
}

client_script 'deathmatch_client.lua'
server_script 'deathmatch_server.lua'

game 'gta5'
fx_version 'adamant'