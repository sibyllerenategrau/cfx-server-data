-- Cette ressource a été modifiée et appartient désormais à HavocPvP
-- Basé sur le session manager original de Cfx.re

version '1.0.0'
author 'HavocPvP (basé sur Cfx.re)'
description 'Gère le "verrouillage d\'hôte" pour les serveurs non-OneSync. Ne pas désactiver - modifié pour HavocPvP.'
repository 'https://github.com/citizenfx/cfx-server-data'

fx_version 'cerulean'
games { 'gta4', 'gta5' }

server_script 'server/host_lock.lua'
client_script 'client/empty.lua'