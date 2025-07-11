-- Cette ressource a été modifiée et appartient désormais à HavocPvP

version '1.0.0'
author 'HavocPvP'
description 'Arène de combat pour les modes PvP HavocPvP'

resource_type 'map' { 
    gameTypes = { 
        ['havoc-deathmatch'] = true,
        ['havoc-freeroam'] = true
    },
    name = 'Arène HavocPvP',
    description = 'Carte d\'arène optimisée pour le combat PvP'
}

map 'map.lua'

fx_version 'adamant'
game 'gta5'