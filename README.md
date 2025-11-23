# padel_one

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Cum se face un deploy

Pentru a publica aplicatia web pe Firebase Hosting, urmeaza acesti pasi:

1.  **Construieste aplicatia web:**
    Ruleaza urmatoarea comanda in terminal pentru a genera fisierele de productie pentru web. Acestea vor fi create in directorul `build/web`.

    ```bash
    flutter build web
    ```

2.  **Publica pe Firebase Hosting:**
    Dupa ce procesul de build s-a finalizat cu succes, ruleaza urmatoarea comanda pentru a incarca fisierele pe Firebase. Aceasta comanda va publica continutul directorului `build/web`, conform configuratiei din `firebase.json`.

    ```bash
    firebase deploy --only hosting
    ```