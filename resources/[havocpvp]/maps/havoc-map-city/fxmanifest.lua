-- Cette ressource a été modifiée et appartient désormais à HavocPvP

version '1.0.0'
author 'HavocPvP'
description 'Carte urbaine avec points de spawn pour HavocPvP'

resource_type 'map' { 
    gameTypes = { 
        ['havoc-freeroam'] = true 
    },
    name = 'Ville HavocPvP',
    description = 'Carte avec spawns dans la ville de Los Santos'
}

map 'map.lua'

fx_version 'adamant'
game 'gta5'