# Random Spin

Application web pour **tirer au sort avec une roue** et **former des groupes
aléatoires** en classe, projetée au beamer. Même esprit que *Plan de Classe* :
un seul fichier (`public/index.html`), aucune dépendance, aucun réseau requis,
aucune donnée sur le serveur.

## Fonctionnalités

- **🎡 Roue** : grande roue colorée, son de cliquet, confettis, nom du gagnant en
  très grand. Le nom tiré peut être retiré de la roue (chacun passe une fois),
  avec la liste « Déjà tirés » dans l'ordre et un bouton pour remettre un nom
  ou tout le monde. Durée réglable (3 s, 6 s, 10 s de suspense).
  `Espace` fait tourner la roue, `F` passe en plein écran.
- **👥 Groupes** : par nombre de groupes ou par nombre d'élèves par groupe
  (les restes sont répartis, jamais d'élève seul). Options :
  - élèves **à séparer** (jamais dans le même groupe) ;
  - **éviter les mêmes binômes** que la fois précédente ;
  - **rôles** distribués au hasard (porte-parole, secrétaire…, modifiables) ;
  - noms de groupes à thème : planètes, éléments chimiques, animaux des Alpes, couleurs.
  Ajustement à la main par glisser-déposer, historique des 8 derniers tirages,
  copie en texte et impression.
- **🧰 Outils** : ordre de passage, minuteur avec sonnerie, pile ou face, dés
  (4 à 20 faces), nombre au hasard.
- **📋 Listes** : plusieurs listes (classes, sujets d'exposé…), collage direct
  depuis un tableur, absents du jour en un clic, export / import JSON.
  L'import accepte aussi un **export de Plan de Classe**.
- **Projection** : bouton « Projeter » (plein écran, interface épurée).

Le hasard vient de `crypto.getRandomValues` avec tirage par rejet : chaque nom
a exactement la même chance. Le gagnant est choisi *avant* l'animation, la roue
est ensuite amenée sur lui.

## Arborescence sur le serveur

```
/opt/stacks/random-spin/
├── docker-compose.yml
├── deploy.sh
├── public/
│   └── index.html      ← l'application entière
└── README.md
```

Seul `public/` est monté (en lecture seule) dans nginx, servi sur le port **3004**
(3000 à 3003 restent libres pour les autres applications).

## Installation / mise à jour

Sur le serveur, une seule commande (installe la première fois, met à jour ensuite) :

```bash
curl -fsSL https://raw.githubusercontent.com/Renaar/Random-Spin/main/deploy.sh | bash
```

ou, une fois installé :

```bash
bash /opt/stacks/random-spin/deploy.sh
```

Le script clone (ou met à jour) le dépôt dans `/opt/stacks/random-spin`, ouvre
le port 3004 dans `ufw` s'il est actif, puis lance `docker compose up -d`.
L'application est ensuite disponible sur `http://<adresse-du-serveur>:3004`.

La stack apparaît aussi dans Dockge (dossier `/opt/stacks`).

Après une mise à jour, il suffit de recharger la page (`Ctrl+F5` au besoin) :
le dossier est monté, pas copié, donc aucun redémarrage n'est nécessaire.

## Où vivent les données ?

Tout est enregistré dans le `localStorage` du **navigateur qui ouvre la page**,
sous la clé `random-spin/v1` : rien n'est stocké sur le serveur, rien n'est
partagé entre deux machines. Utilisez l'export JSON (onglet « Listes ») pour
sauvegarder ou transférer vos listes.
