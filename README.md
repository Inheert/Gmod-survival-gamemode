# Garry's Mod PvP Server

Ce dépôt contient le code source pour un serveur Garry's Mod axé sur le gameplay PvP. Le serveur inclut divers systèmes tels que la création de personnages, les commandes administratives, la journalisation, et plus encore.

**Note : Ce serveur est en cours de développement.**

## Objectifs du Projet

- Créer une expérience de jeu PvP immersive et équilibrée.
- Fournir des outils d'administration robustes pour gérer le serveur.
- Implémenter des systèmes de journalisation pour suivre les événements et les actions des joueurs.
- Offrir une personnalisation approfondie des personnages.

## Structure du Projet

### [`admin_system`](admin_system)

- **Objectif** : Contient le système d'administration pour gérer les commandes, la journalisation et les permissions des utilisateurs.
- **Fichiers Clés** :
  - [`sh_admin_system.lua`](admin_system/lua/autorun/sh_admin_system.lua) : Définitions et utilitaires partagés du système d'administration.

### [`character_manager`](character_manager)

- **Objectif** : Gère la création et la personnalisation des personnages.
- **Fichiers Clés** :
  - [`sh_character_manager.lua`](character_manager/lua/autorun/sh_character_manager.lua) : Définitions et utilitaires partagés pour la gestion des personnages.

### [`key_binding`](key_binding)

- **Objectif** : Gère les raccourcis clavier pour diverses actions.
- **Fichiers Clés** : Scripts Lua pour les configurations des raccourcis clavier.

### [`log`](log)

- **Objectif** : Gère la journalisation des divers événements et actions.
- **Fichiers Clés** : Définitions et utilitaires partagés pour la journalisation.

### [`network_var`](network_var)

- **Objectif** : Gère les variables réseau pour les données des joueurs.
- **Fichiers Clés** : Définitions partagées des variables réseau.

### [`conquest_system`](conquest_system)

- **Objectif** : Implémente un système de conquête pour le contrôle des territoires.
- **Fichiers Clés** :
  - [`sh_conquest_system.lua`](conquest_system/lua/autorun/sh_conquest_system.lua) : Définitions et utilitaires partagés pour le système de conquête.

### [`sql`](sql)

- **Objectif** : Gère les interactions avec la base de données SQL.
- **Fichiers Clés** : Logique SQL côté serveur.

### [`general_utils`](general_utils)

- **Objectif** : Fournit des utilitaires généraux utilisés dans tout le projet.
- **Fichiers Clés** : Scripts Lua utilitaires partagés.

## TODO

Consultez le fichier [TODO.txt](TODO.txt) pour une liste des tâches et des fonctionnalités à implémenter.