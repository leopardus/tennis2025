# Project Conversation Summary

This document summarizes all user requests and feedback since the beginning of the project.

## Initial Setup & Project Overview
- User provided initial project context, folder structure, and confirmed setup.

## Core Functionality & UI Development

### Padel Time Page (`PadelTimePage`)
- **Initial Request:** Implement a time slot table for padel court reservations.
- **Feedback:**
    - Ensure the table is responsive.
    - Display reservations for "Teren 1" and "Teren 2".
    - Show the person's name for each reservation.
    - Indicate subscriptions with "[A]".
    - Add a header for the table.
    - Add a footer displaying "Total Ore Rezervate Azi: X".
    - Remove margins from the table rows.
    - Make the header text non-bold.
    - Refactor `AppBar` into a `_ResponsiveAppBar` for dynamic content/height.

### Reservation Form (`ReservationForm`)
- **Initial Request:** Create a form to add new reservations.
- **Feedback:**
    - Allow selecting hour, court, and entering person's name.
    - Handle single and subscription reservations.
    - Implement conflict checking for new reservations.
    - Use `AppStyles` for styling.
    - When editing a recurring reservation, ask whether to update only the single instance or the entire series.
    - When deleting a recurring reservation, ask whether to delete the single instance or the entire series.
    - Re-enable the "Abonament" checkbox in the `ReservationForm` while in edit mode to allow changing the subscription status of a reservation.

### Login Page (`LoginPage`)
- **Initial Request:** Implement a login page.
- **Feedback:**
    - Use `AppStyles` for styling.
    - Implement mock authentication with username/password (`admin`/`admin`) and Google Sign-In.

### Reports Page (`ReportsPage`)
- **Initial Request:** Create a reports page with statistics.
- **Feedback:**
    - Display statistics cards and charts.
    - Implement a 3-tier responsive layout for the reports page.

### Styling (`AppStyles`)
- **Initial Request:** Centralize application styles.
- **Feedback:**
    - Define colors, font sizes, and other visual constants.
    - Add specific styles for reports cards, chart lines, and chart areas.
    - Add UX blue theme colors (`uxPageBackground`, `uxCardBackground`, `uxHeaderBackground`, `uxPrimaryText`, `uxSecondaryText`, `uxDividerColor`, `uxReservationColor`, `uxSubscriptionColor`, `uxReservationCardBorder`, `uxAvailableTextColor`).
    - Add Drawer grayscale theme colors (`drawerHeaderBackground`, `drawerTextColor`, `drawerIconColor`).

## UX Experimentation (`PadelTimeUxPage` & `TimeSlotTableUx`)

### Safe UI Modification Strategy
- **Request:** "vreau sa incerc sa facem un design nou pt panelul de programari dar in caz ca nu iese bine vreau sa putem reveni la versiunea de acum. cum putem face modificari safe in momentul asta?" (want to try new design for reservations panel, how to make safe changes?).
- **Request:** "mai bine facem inca un meniu nou in care plecam de la ceea ce avem acum si modificam ui ul si daca nu o sa ne convina doar folosim pe cel de acum. daci fa un nou meniu numit Programari UX si apoi continuam" (better to make new menu "Programari UX" and modify UI there).

### `PadelTimeUxPage`
- **Request:** Create a new menu item "Programari UX" in the `Drawer` to navigate to `PadelTimeUxPage`.
- **Feedback:** Ensure correct navigation between original and UX pages.
- **Request:** "o sa lucram acum pe Programari Ux, pt inceput vreau sa sa nu mai avem decat nuante de albastru nu de gri" (work on Programari UX, only blue shades, no gray).
- **Feedback:** Apply grayscale styling to the `Drawer` in both `PadelTimePage` and `PadelTimeUxPage`.

### `TimeSlotTableUx` (Iterative Design)
- **Initial Request:** Create `TimeSlotTableUx` as a copy of `TimeSlotTable` to apply new UX designs.
- **Request:** "vreau acum ca progrmarile facute sa arate ca niste carduri precum cardurile folosite in rapoarte. Conturul sa fie de 1px cu rotunjimile de 2px iar backgroundul sa fie cu mult mai deschis la culoare decat marginile" (reservations to look like cards, 1px border, 2px rounded, background lighter than border).
- **Request:** "pe coloana cu ore din Ux cel nou vreau ca in loc de a arata intervalul de ex 8:00-9:00 sa aratam doar ora 08 insa cu un font un mai mic si in box ul in care punem aceasta ora si fie aliniata la stanga si pe vertical sa fie aliniata sus" (in new UX hour column, show "08" instead of "8:00-9:00", smaller font, top-left aligned).
- **Request:** "cuvantul Disponibil vreau sa fie scris cu o culoare f palida aproape invizivila" (make "Disponibil" text very pale).
- **Request:** "fa randul de 40px inaltime" (make row 40px high).
- **Request:** "cand ai 2 ore continue atunci nu mai pune margine pe partea de jos a primului card si nici border sus pe al doilea card care defapt formeaza o singura programare" (when 2 continuous hours, remove bottom margin of first card and top border of second card).
- **Request:** "coloana cu orele sa aiba latimea de 40px. sa nu mai afisam deloc liniile tabelei din spate. orele afisate sa aiba intre ele linii verticale ca intr un lant" (hour column 40px wide, no background grid lines, vertical lines between hours like a chain).
- **Feedback:** "UX cel nou nu mai functioneaza acum . as vrea sa dai revert ultimele modificari pana cand ti am zis sa faci latimea coloanei de ore de 40px" (new UX not working, revert changes until hour column width 40px).
- **Feedback:** "mai ai erori de compilare" (still have compilation errors).
- **Feedback:** "Undefined name 'isLastOccupiedTeren2'." (compilation error).
- **Request:** "vreau sa faci asta iara "cand ai 2 ore continue atunci nu mai pune margine pe partea de jos a primului card si nici border sus pe al doilea card care defapt formeaza o singura programare" (when 2 continuous hours, remove bottom margin of first card and top border of second card)." (re-implement card merging logic).

## Data Management
- **Initial Request:** Load mock reservation data from `assets/reservations.json`.

## Deployment
- **Initial Request:** Set up CI/CD for web deployment to Firebase Hosting via GitHub Actions.
- **Feedback:** Ensure `web/index.html` contains `<meta name="google-signin-client_id" ... />`.
