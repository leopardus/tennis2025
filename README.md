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

## Project Description

This is a Flutter application designed for managing padel court reservations. It provides a user-friendly interface for viewing court availability, making new reservations, and managing existing ones.

**Key Features:**

*   **Authentication:** Users can sign in using Google Sign-In, leveraging Firebase for backend authentication.
*   **Dynamic Schedule View:** The application displays daily schedules for padel courts, allowing users to see available time slots at a glance.
*   **Reservation Management:** Users can easily create, edit, and delete reservations. The system supports both single-session bookings and subscription-based reservations with defined end dates.
*   **Configurable Courts:** The number of available padel courts can be configured by the user from 2 to 5 via the settings page, with 2 courts as the default. The application's UI dynamically adapts to display the selected number of courts.
*   **Reporting:** Includes a reporting section for insights and statistics related to reservations.
*   **Responsive UI:** Designed to provide a consistent and optimal user experience across various screen sizes.

**Technical Details:**

*   **Framework:** Flutter (Dart)
*   **State Management:** Provider pattern is utilized for efficient state management across the application.
*   **Backend Services:** Firebase is integrated for core backend functionalities, including authentication.
*   **UI Components:** Leverages `carousel_slider` for date navigation and `fl_chart` for data visualization in reports.

**Code Structure and Refactoring:**

The codebase has undergone significant refactoring to enhance maintainability and organization. Key UI elements and logic have been extracted into smaller, reusable widgets located in the `lib/widgets` directory, with specific dialogs separated into `lib/widgets/dialogs`. This modular approach promotes cleaner code and easier future development.