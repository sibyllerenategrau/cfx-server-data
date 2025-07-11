-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Basé sur le Map Manager original de Cfx.re

version '1.0.0'
author 'HavocPvP'
description 'Gestionnaire de cartes et modes de jeu flexible pour HavocPvP'

client_scripts {
    "shared.lua",
    "client.lua"
}

server_scripts {
    "shared.lua",
    "server.lua"
}

fx_version 'adamant'
games { 'gta5', 'rdr3' }

-- Exports pour la gestion des cartes
server_export "getCurrentGameType"
server_export "getCurrentMap"
server_export "changeGameType"
server_export "changeMap"
server_export "doesMapSupportGameType"
server_export "getMaps"
server_export "getGameTypes"
server_export "roundEnded"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'