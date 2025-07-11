# Guide d'Installation - HavocPvP Gamemode System

## Installation Rapide

### 1. Prérequis
- Serveur FiveM fonctionnel
- Accès aux fichiers du serveur
- Permissions administrateur

### 2. Installation
1. Copiez le dossier `[havocpvp]` dans votre dossier `resources/`
2. Ajoutez les lignes suivantes à votre `server.cfg`:

```cfg
# Système HavocPvP
start gamemode-manager
start lobby-system
start spawn-manager
start havoc-freeroam
start havoc-map-city
```

### 3. Ordre de Démarrage Important
```cfg
# 1. Gestionnaires principaux (dans cet ordre)
start gamemode-manager
start lobby-system  
start spawn-manager

# 2. Gamemodes
start havoc-freeroam

# 3. Cartes
start havoc-map-city
```

## Configuration Avancée

### Modification de la Position du Lobby
Éditez `gamemode-manager/shared.lua`:
```lua
Config = {
    LobbyPosition = {
        x = -1042.0,  -- Votre coordonnée X
        y = -2745.0,  -- Votre coordonnée Y  
        z = 21.36,    -- Votre coordonnée Z
        heading = 0.0 -- Direction (0-360)
    }
}
```

### Personnalisation de l'Interface
Modifiez les fichiers dans `lobby-system/html/`:
- `style.css` - Apparence et couleurs
- `index.html` - Structure HTML
- `script.js` - Comportement JavaScript

### Couleurs HavocPvP
Les couleurs par défaut utilisées:
- Orange principal: `#ff6b35`
- Orange foncé: `#e55a2b`
- Arrière-plan: `#1a1a1a` à `#2d2d2d`

## Création de Contenu

### Nouveau Gamemode
1. Créez un dossier dans `[havocpvp]/gamemodes/votre-gamemode/`
2. Ajoutez un `fxmanifest.lua`:
```lua
version '1.0.0'
author 'HavocPvP'
description 'Votre gamemode'

resource_type 'gametype' { 
    name = 'Nom du Gamemode',
    description = 'Description du gamemode'
}

client_script 'client.lua'
server_script 'server.lua'

fx_version 'adamant'
game 'gta5'
```

### Nouvelle Carte
1. Créez un dossier dans `[havocpvp]/maps/votre-carte/`
2. Ajoutez un `fxmanifest.lua`:
```lua
version '1.0.0'
author 'HavocPvP'
description 'Votre carte'

resource_type 'map' { 
    gameTypes = { 
        ['votre-gamemode'] = true 
    },
    name = 'Nom de la Carte'
}

map 'map.lua'

fx_version 'adamant'
game 'gta5'
```

3. Créez un `map.lua` avec des spawnpoints:
```lua
spawnpoint 'mp_m_freemode_01' { x = 0.0, y = 0.0, z = 75.0, heading = 0.0 }
```

## Dépannage

### Le lobby ne s'affiche pas
1. Vérifiez que `lobby-system` est démarré
2. Regardez la console F8 pour les erreurs NUI
3. Assurez-vous que des gamemodes sont détectés

### Les spawns ne fonctionnent pas
1. Vérifiez l'ordre de démarrage des ressources
2. Assurez-vous que `spawn-manager` démarre avant les autres
3. Vérifiez que les cartes ont des spawnpoints

### Erreurs de ressources
1. Vérifiez la syntaxe des fichiers `fxmanifest.lua`
2. Assurez-vous que tous les fichiers référencés existent
3. Regardez les logs du serveur pour plus de détails

### Gamemodes non détectés
1. Vérifiez que `resource_type 'gametype'` est correct
2. Assurez-vous que le gamemode démarre sans erreur
3. Redémarrez `gamemode-manager` après avoir ajouté un nouveau gamemode

## Commandes de Test

### Test du système
```
# Redémarrer les ressources
restart gamemode-manager
restart lobby-system

# Forcer l'ouverture du lobby
/havoc_lobby

# Tester les spawns
/kill

# Voir les stats
/stats
```

### Commandes admin
```
# Changer de carte (console)
havoc_map havoc-map-city

# Changer de gamemode (console)  
havoc_gamemode havoc-freeroam

# Donner de l'armure (console)
armor 1 100
```

## Support

Pour obtenir de l'aide:
1. Consultez la documentation complète dans `DOCUMENTATION.md`
2. Vérifiez les logs du serveur
3. Testez avec la configuration par défaut d'abord

## Compatibilité

### Compatible avec:
- Toutes les cartes existantes avec spawnpoints
- Le système mapmanager original (en mode de compatibilité)
- La plupart des ressources existantes

### Non compatible avec:
- Les systèmes de spawn personnalisés qui remplacent spawnmanager
- Les interfaces de sélection de gamemode existantes
- Les ressources qui modifient directement mapmanager

---
*Guide d'installation HavocPvP - Version 1.0*