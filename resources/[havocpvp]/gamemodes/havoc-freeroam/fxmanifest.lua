-- Cette ressource a été modifiée et appartient désormais à HavocPvP

version '1.0.0'
author 'HavocPvP'
description 'Mode de jeu FreeRoam basique pour HavocPvP'

resource_type 'gametype' { 
    name = 'FreeRoam HavocPvP',
    description = 'Mode de jeu libre avec spawn automatique'
}

client_script 'freeroam_client.lua'
server_script 'freeroam_server.lua'

game 'common'
fx_version 'adamant'