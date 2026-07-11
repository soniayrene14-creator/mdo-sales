# Flutter POS - Documentation

## Technologies

- Flutter 3.x
- Dart 3.x
- Riverpod (state management)
- GoRouter (navigation)
- SQLite (local storage via sqflite)
- HTTP (communication avec Django REST)

## Démarrage rapide

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd flutter_pos-main
```

### 2. Créer et activer l'environnement virtuel

```bash
flutter pub get
```

### 3. Configurer les variables d'environnement

Copier le fichier `config.example.json` vers `config.json` :

```bash
cp config.example.json config.json
```

Éditer `config.json` et renseigner l'URL du backend Django :

```json
{
  "BASE_URL": "http://localhost:8000"
}
```

Lancement depuis VS Code : la configuration `.vscode/launch.json` utilise déjà `--dart-define-from-file config.json`.

Lancement en ligne de commande :

```bash
flutter run --dart-define-from-file config.json
```

### 4. Lancer l'application

```bash
flutter run
```

## Architecture

Le projet suit le **Clean Architecture** avec 5 couches :

```
lib/
├── app/               # App root, DI, routing
├── core/              # Shared utilities, services, themes, constants, extensions
├── data/              # Datasources (local/remote), models, repository implementations
├── domain/            # Entities, abstract repositories, usecases
└── presentation/      # Providers (state), screens (UI), widgets (reusable)
```

### Authentification

L'application utilise **JWT** via le backend Django.

- `POST /api/v1/auth/login/` avec `username` + `password` → retourne `access`, `refresh`, `user`
- `GET /api/v1/auth/me/` pour récupérer le profil courant
- `POST /api/v1/auth/logout/` pour blacklister le refresh token

### Modules API consommés

- `/api/v1/auth/` - Authentification JWT
- `/api/v1/users/` - Gestion des utilisateurs
- `/api/v1/categories/` - Catégories de produits
- `/api/v1/products/` - Produits
- `/api/v1/stock/` - Stock et ajustements
- `/api/v1/sales/` - Ventes et factures PDF
- `/api/v1/proformas/` - Devis/proformas PDF
- `/api/v1/dashboard/` - Statistiques

### Stockage local

- SQLite via `sqflite` pour le cache hors-ligne
- Synchronisation automatique quand la connexion est disponible
- Queue d'actions hors-ligne pour les mutations critiques

## Scripts utiles

```bash
flutter run                                                 # lancer l'app
flutter analyze                                             # lint
dart fix --apply                                            # quick fixes
dart format lib/ test/ --line-length=120                    # format
flutter test                                                # tests
dart run build_runner build --delete-conflicting-outputs    # codegen
```

## Configuration

Fichier `config.json` (ignoré par git) :

```json
{
  "BASE_URL": "http://localhost:8000"
}
```

En production, remplacer par l'URL du serveur Django.

## Routes de l'application

- `/home` - Point de vente / panier
- `/products` - Liste des produits
- `/products/product-create` - Créer un produit
- `/products/product-edit/:id` - Modifier un produit
- `/products/product-detail/:id` - Détail d'un produit
- `/transactions` - Historique des ventes
- `/transactions/transaction-detail/:id` - Détail d'une vente
- `/sales` - Liste des ventes Django
- `/sales/sale-detail/:id` - Détail d'une vente + facture PDF
- `/proformas` - Liste des proformas
- `/proformas/proforma-detail/:id` - Détail d'un proforma + PDF
- `/stock` - Stock en temps réel et mouvements
- `/categories` - Catégories de produits
- `/dashboard` - Tableau de bord admin
- `/dashboard/employee` - Tableau de bord employé
- `/dashboard/reports/sales` - Rapport de ventes par période
- `/account` - Profil utilisateur
- `/account/profile` - Modifier le profil
- `/account/printer-settings` - Paramètres d'imprimante
- `/account/about` - À propos
- `/sign-in` - Connexion
- `/auth/change-password` - Changer le mot de passe
- `/error` - Écran d'erreur

## Notes

- Les images produits et employés sont servies par Django via `/media/`
- Le token JWT est stocké en mémoire pendant la session
- Le mode hors-ligne fonctionne grâce à la queue d'actions locales
- Les PDF (factures, proformas) sont ouverts via `url_launcher` depuis le backend Django
