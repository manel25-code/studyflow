# StudyFlow – Student Revision Planner

## 1. Présentation du projet

**StudyFlow** est une application mobile développée avec Flutter et Dart, destinée aux étudiants pour organiser leurs révisions, gérer leurs tâches et suivre leur progression.

L'objectif est de faciliter la planification du travail universitaire grâce à une interface simple, intuitive et centralisée.

L'application permet de gérer les tâches de révision, de consulter les échéances, de visualiser les priorités et de suivre l'avancement du travail.

## 2. Objectifs

Les objectifs principaux de StudyFlow sont :

- Organiser les révisions et les tâches universitaires.
- Planifier les tâches selon leurs dates limites.
- Identifier les tâches urgentes ou en retard.
- Suivre les tâches terminées et celles restantes.
- Visualiser la progression sous forme de statistiques.
- Sauvegarder les données localement afin de les retrouver après la fermeture de l'application.

## 3. Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Flutter | Développement de l'interface mobile |
| Dart | Langage de programmation |
| Provider | Gestion et partage de l'état de l'application |
| SharedPreferences | Stockage local des tâches |
| fl_chart | Création des graphiques statistiques |
| Material Design | Conception de l'interface utilisateur |
| FlutLab | Environnement de développement et test en ligne |

## 4. Fonctionnalités

### 4.1 Accueil

L'écran d'accueil permet d'avoir une vue générale de l'activité de l'étudiant.

Il affiche notamment :
- Le nombre total de tâches.
- Le nombre de tâches terminées.
- Le nombre de tâches en cours.
- Les tâches en retard.
- Le taux global de progression.
- Les tâches à venir.

### 4.2 Gestion des tâches

L'utilisateur peut gérer ses tâches de révision.

Les fonctionnalités prévues et développées comprennent :

- Ajouter une tâche.
- Modifier une tâche existante.
- Supprimer une tâche.
- Marquer une tâche comme terminée.
- Consulter les informations d'une tâche.
- Rechercher une tâche par titre ou matière.
- Filtrer les tâches selon leur statut.

Chaque tâche contient les informations suivantes :

| Attribut | Description |
|---|---|
| ID | Identifiant unique de la tâche |
| Titre | Nom de la tâche |
| Matière | Matière universitaire concernée |
| Description | Détails supplémentaires |
| Date limite | Échéance de la tâche |
| Statut | Terminée ou non terminée |

### 4.3 Système de priorité

StudyFlow calcule automatiquement la priorité de chaque tâche en fonction de sa date limite et de son statut.

| Situation | Priorité | Couleur |
|---|---|---|
| Tâche terminée | Terminée | Vert |
| Date limite dépassée | En retard | Rouge |
| Date limite aujourd'hui ou demain | Urgente | Orange |
| Échéance dans 2 à 3 jours | Moyenne | Jaune |
| Échéance dans plus de 3 jours | Faible | Bleu |

Cette règle métier permet à l'utilisateur d'identifier rapidement les tâches qui nécessitent son attention.

### 4.4 Planning

L'écran Planning permet de visualiser les tâches non terminées selon leurs échéances.

Les tâches sont organisées en différentes catégories :

- En retard
- Aujourd'hui
- Demain
- Cette semaine
- Plus tard

Cette organisation facilite la planification quotidienne et hebdomadaire des révisions.

### 4.5 Statistiques

L'écran Statistiques permet de suivre la progression de l'utilisateur.

Il affiche :

- Le nombre total de tâches.
- Le nombre de tâches terminées.
- Le nombre de tâches en cours.
- Le nombre de tâches en retard.
- Le pourcentage de progression.
- Un graphique représentant la répartition des tâches terminées et non terminées.

## 5. Architecture du projet

Le projet est organisé en plusieurs dossiers afin de séparer les responsabilités et faciliter la maintenance.

```text
studyflow/
│
├── lib/
│   ├── main.dart
│   │
│   ├── models/
│   │   └── study_task.dart
│   │
│   ├── providers/
│   │   └── task_provider.dart
│   │
│   ├── database/
│   │   └── database_helper.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── tasks_screen.dart
│   │   ├── task_form_screen.dart
│   │   └── ...
│   │
│   └── utils/
│       └── priority_helper.dart
│
├── assets/
│
├── test/
│
├── pubspec.yaml
├── README.md
└── .gitignore
```

### Rôle des composants

**main.dart**

Point d'entrée de l'application. Il initialise StudyFlow, configure le thème et met en place le Provider.

**models/study_task.dart**

Définit la structure d'une tâche et les opérations de conversion des données.

**providers/task_provider.dart**

Gère les tâches et leur état. Il assure le lien entre les données et l'interface utilisateur.

**database/database_helper.dart**

Gère la sauvegarde, la lecture, la modification et la suppression des tâches dans le stockage local.

**screens/**

Contient les différents écrans de l'application et les interfaces destinées à l'utilisateur.

**utils/priority_helper.dart**

Contient la logique métier de calcul de priorité des tâches.

## 6. Gestion de l'état

StudyFlow utilise le package Provider pour centraliser la gestion des tâches.

Lorsqu'un utilisateur réalise une action, par exemple ajouter ou terminer une tâche :

1. L'utilisateur déclenche une action depuis l'interface.
2. Le Provider traite l'action.
3. Les données sont modifiées.
4. Les données sont sauvegardées localement.
5. Le Provider notifie les écrans concernés.
6. L'interface se met à jour automatiquement.

Cette organisation évite de dupliquer la logique dans les différents écrans.

## 7. Stockage des données

Les données sont sauvegardées localement à l'aide de SharedPreferences.

Les tâches sont converties en format JSON avant leur sauvegarde.

Les opérations prises en charge sont :

- Lecture des tâches.
- Ajout de tâches.
- Modification de tâches.
- Suppression de tâches.
- Suppression de toutes les tâches.

Le stockage local permet de conserver les données après la fermeture ou le rechargement de l'application, dans le même environnement de stockage.

Dans la version testée sur FlutLab Web, les données sont conservées dans le stockage local du navigateur.

## 8. Installation et exécution

### Environnement utilisé

Le projet a été développé et testé dans l'environnement FlutLab.

Lien : https://flutlab.io/

### Lancement dans FlutLab

1. Ouvrir FlutLab.
2. Charger le projet StudyFlow.
3. Vérifier les dépendances dans `pubspec.yaml`.
4. Cliquer sur Pub Get.
5. Lancer le projet avec Run.
6. Tester les fonctionnalités dans l'environnement de preview.

### Lancement en local

Si Flutter est installé sur la machine :

```bash
flutter pub get
```

Pour vérifier le projet :

```bash
flutter analyze
```

Pour lancer l'application sur un appareil ou un émulateur :

```bash
flutter run
```

## 9. Dépendances

Les principales dépendances du projet sont :

```yaml
dependencies:
  flutter:
    sdk: flutter

  provider: ^6.1.5
  shared_preferences: ^2.5.3
  fl_chart: ^1.1.1
```

Les versions exactes doivent être vérifiées dans le fichier `pubspec.yaml` du projet.

## 10. Tests fonctionnels

Les tests fonctionnels permettent de vérifier que les fonctionnalités répondent correctement aux actions de l'utilisateur.

| ID | Test | Résultat attendu |
|---|---|---|
| T01 | Ajouter une tâche valide | La tâche est ajoutée |
| T02 | Ajouter une tâche sans titre | Une erreur de validation est affichée |
| T03 | Ajouter une tâche sans matière | Une erreur de validation est affichée |
| T04 | Modifier une tâche | Les informations sont mises à jour |
| T05 | Supprimer une tâche | La tâche est supprimée |
| T06 | Terminer une tâche | Le statut change et les statistiques se mettent à jour |
| T07 | Naviguer entre les écrans | Les écrans sont accessibles |
| T08 | Recharger l'application | Les tâches sauvegardées sont conservées |
| T09 | Rechercher une tâche | Les résultats correspondent à la recherche |
| T10 | Filtrer les tâches | Les tâches correspondant au filtre sont affichées |

Les résultats des tests seront documentés dans le rapport final.

## 11. Captures d'écran

Les captures d'écran présentent les principales interfaces de l'application.

Captures à ajouter :

- Écran d'accueil.
- Écran de gestion des tâches.
- Formulaire d'ajout ou de modification.
- Écran Planning.
- Écran Statistiques.

Les captures doivent être réalisées directement depuis l'application exécutée.

## 12. Améliorations possibles

Plusieurs améliorations peuvent être envisagées dans les versions futures :

- Ajouter des notifications de rappel.
- Permettre la planification d'heures de révision.
- Ajouter un calendrier mensuel.
- Ajouter des catégories personnalisées.
- Améliorer les statistiques avec des graphiques supplémentaires.
- Ajouter une synchronisation cloud.
- Améliorer l'interface et les animations.

## 13. Conclusion

StudyFlow est une application de planification de révisions conçue pour aider les étudiants à mieux organiser leur travail.

Grâce à la gestion des tâches, au système de priorité, au planning et aux statistiques, l'application offre une solution simple pour améliorer l'organisation et le suivi des révisions.

Ce projet a permis de mettre en pratique les concepts de développement mobile avec Flutter, la gestion de l'état, la structuration d'une application, la persistance des données et la création d'une interface interactive.

---

**Projet académique – Développement mobile avec Flutter et Dart.**
