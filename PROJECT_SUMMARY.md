# Rezumat Proiect: Padel Time

Acest document descrie starea actuală a proiectului "Padel Time", funcționalitățile implementate și deciziile arhitecturale. Scopul său este de a oferi un context complet pentru a putea continua dezvoltarea într-o sesiune viitoare.

## 1. Obiectivul Proiectului

Crearea unei aplicații Flutter pentru managementul rezervărilor la un club de padel. Aplicația permite vizualizarea programărilor, adăugarea de rezervări noi (simple sau recurente), autentificarea utilizatorilor și vizualizarea de rapoarte statistice.

## 2. Tehnologii și Dependințe Cheie

- **Framework:** Flutter
- **Stocare Date:** O listă "in-memory" (`mockReservations`) localizată în `lib/time_slot_table.dart`. **Nu se folosește o bază de date persistentă.**
- **Dependințe Adăugate:**
  - `carousel_slider`: Pentru caruselul de zile din pagina principală.
  - `intl`: Pentru formatarea datelor (în special în limba română, `ro_RO`).
  - `google_sign_in`: Pentru autentificarea cu Google.
  - `provider`: Pentru managementul stării de autentificare (`AuthService`).
  - `firebase_core`: Pentru integrarea cu Firebase.
  - `fl_chart`: Pentru graficele din pagina de rapoarte.

## 3. Funcționalități Implementate

### A. Management Rezervări
- **Vizualizare:** Un carusel pe 30 de zile permite vizualizarea programului pe fiecare teren.
- **Creare/Editare:** Un formular (`ReservationForm`) permite adăugarea și modificarea rezervărilor.
- **Rezervări Recurente (Abonamente):** Se pot crea rezervări care se repetă săptămânal până la o dată de sfârșit specificată. Acestea sunt identificate printr-un `subscriptionId` comun.
- **Verificare Conflicte:** La crearea unei rezervări (simplă sau abonament), se verifică dacă intervalul orar este deja ocupat.

### B. Autentificare
- **Serviciu Mock:** `AuthService` gestionează starea de autentificare.
- **Metode de Login:**
  - Utilizator/Parolă: `admin`/`admin`.
  - Google Sign-In (necesită configurare în consola Firebase/Google Cloud).
- **UI:** Un meniu lateral (Drawer) permite acțiunile de Login/Logout.

### C. Pagina Principală (`PadelTimePage`)
- **Carusel de Zile:** Afișează 30 de zile, cu ziua curentă pre-selectată.
- **Buton "Azi":** Navighează rapid la ziua curentă în carusel.
- **Titlu Dinamic:** `AppBar`-ul afișează data selectată în carusel.

### D. Pagina de Rapoarte (`ReportsPage`)
- **Carduri Statistice:**
  - Total rezervări: azi, următoarele 7 zile, ultimele 30 de zile.
  - Comparație procentuală cu perioada anterioară pentru fiecare card.
  - Rata abonamentelor din totalul rezervărilor pe ultima lună.
- **Grafice:**
  - **Line Chart:** Afișează numărul de rezervări pe zi pentru ultimele 7 zile.
  - **Bar Chart:** Afișează distribuția rezervărilor pe intervale orare pentru ultimele 7 zile.

### E. Styling Centralizat
- Toate culorile, dimensiunile de font și stilurile de bază sunt definite în `lib/app_styles.dart` și aplicate consistent în întreaga aplicație.

## 4. Structura Fișierelor Cheie

- `lib/main.dart`: Punctul de intrare al aplicației, inițializare Firebase, temă globală (`ThemeData`), și provider de autentificare.
- `lib/padel_time_page.dart`: Pagina principală, conține caruselul și meniul lateral.
- `lib/time_slot_table.dart`: Conține logica de bază pentru afișarea tabelului orar și managementul datelor (`mockReservations`).
- `lib/reservation_form.dart`: Formularul pentru crearea/editarea rezervărilor.
- `lib/auth_service.dart`: Logica pentru autentificare.
- `lib/login_page.dart`: Interfața de login.
- `lib/reports_page.dart`: Pagina de statistici și grafice.
- `lib/app_styles.dart`: Fișierul central pentru stiluri.
- `task_todo.md`: Listă cu idei pentru funcționalități viitoare.
- `pubspec.yaml`: Fișierul de configurare al proiectului, unde sunt listate dependințele.

## 5. Configurare Necesară pentru Replicare

1.  **Setup Proiect Flutter:** Asigură-te că ai un mediu Flutter funcțional.
2.  **Dependințe:** Rulează `flutter pub get` pentru a instala toate dependințele listate în `pubspec.yaml`.
3.  **Configurare Firebase:**
    - Proiectul este configurat să folosească Firebase. Fișierele `firebase_options.dart` și `google-services.json` (în `android/app`) sunt necesare.
    - Pentru ca **Google Sign-In** să funcționeze pe web, este necesar un Client ID OAuth 2.0. Acesta trebuie adăugat în `web/index.html` în meta tag-ul `google-signin-client_id`.
4.  **Localizare:** S-a configurat suportul pentru limba română (`ro_RO`) pentru formatarea datelor.

Acest raport ar trebui să ofere toate informațiile necesare pentru a înțelege și a continua dezvoltarea proiectului.
