# LocalMsg

Application de messagerie sur réseau local, façon [LocalSend](https://github.com/localsend/localsend) mais pour du texte au lieu de fichiers. Deux appareils ouvrant l'app sur le même réseau local se découvrent automatiquement et peuvent échanger des messages en 1:1.

## Fonctionnement

- **Découverte** : chaque appareil s'annonce toutes les ~3s sur le groupe multicast UDP `239.100.100.100:53320` (id, alias, plateforme, port du serveur de messages). Les appareils non vus depuis 10s disparaissent de la liste.
- **Messages** : chaque appareil fait tourner un petit serveur HTTP local ; envoyer un message est un simple `POST /message` vers l'IP/port du destinataire.
- **Historique** : gardé en mémoire tant que l'app est ouverte, pas de persistance disque (redémarrer l'app efface les conversations).

## Limitation connue

Pas de chiffrement ni d'authentification : les messages circulent en clair et un appareil du réseau pourrait usurper un `id`. Acceptable pour un usage LAN de confiance ; à traiter en v2 si besoin (ex. certificat auto-signé épinglé, comme LocalSend).

## Build par plateforme

### Linux / Windows (desktop)
```
flutter run -d linux    # ou -d windows
```
Aucune permission particulière à configurer.

### Android
```
flutter run -d <device>
```
Nécessite le SDK Android (non installé dans cet environnement de dev). Seule permission requise : `INTERNET` (déjà dans `android/app/src/main/AndroidManifest.xml`).

### macOS
```
flutter run -d macos
```
Nécessite un Mac avec Xcode. Les entitlements réseau (`network.client`/`network.server`) sont déjà configurés dans `macos/Runner/*.entitlements`.

### iOS — action manuelle requise avant de tester sur un iPhone physique

La découverte réseau (UDP multicast) nécessite sur iOS l'entitlement Apple **`com.apple.developer.networking.multicast`**, déjà présent dans `ios/Runner/Runner.entitlements` et référencé dans le projet Xcode. Mais cet entitlement doit être **approuvé manuellement par Apple** :

1. Avoir un compte Apple Developer Program.
2. Faire la demande via https://developer.apple.com/contact/request/networking-multicast (délai constaté : 3 à 14 jours, pas de suivi en ligne).
3. Une fois approuvé, associer l'entitlement à l'App ID dans le portail développeur.

Sans cet entitlement, l'app ne découvrira pas les autres appareils sur un **iPhone physique** (le simulateur iOS n'a pas cette restriction). Le code est prêt, il ne reste que cette démarche administrative côté Apple.

## Tests

```
flutter analyze
flutter test
```
