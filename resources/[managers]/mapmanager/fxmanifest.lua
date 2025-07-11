-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Basé sur le gestionnaire de cartes original de Cfx.re

version '1.0.0'
author 'HavocPvP (basé sur Cfx.re)'
description 'Gestionnaire flexible pour l\'association type de jeu/carte - modifié pour HavocPvP.'
repository 'https://github.com/citizenfx/cfx-server-data'

client_scripts {
    "mapmanager_shared.lua",
    "mapmanager_client.lua"
}

server_scripts {
    "mapmanager_shared.lua",
    "mapmanager_server.lua"
}

fx_version 'adamant'
games { 'gta5', 'rdr3' }

server_export "getCurrentGameType"
server_export "getCurrentMap"
server_export "changeGameType"
server_export "changeMap"
server_export "doesMapSupportGameType"
server_export "getMaps"
server_export "roundEnded"

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
