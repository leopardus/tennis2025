# Idei de Statistici și Funcționalități Noi

Aceasta este o listă de posibile funcționalități și rapoarte noi care pot fi adăugate în aplicație pentru a oferi o valoare adăugată managerului clubului.

### Rapoarte și Statistici Avansate

1.  **Analiza Orelor de Vârf (Heatmap):**
    *   **Ce arată:** Un grafic vizual (heatmap) care arată care sunt cele mai aglomerate zile și ore ale săptămânii.
    *   **De ce e util:** Ajută la optimizarea prețurilor (prețuri mai mari la ore de vârf), la alocarea eficientă a personalului și la planificarea ofertelor pentru orele mai puțin populare.

2.  **Top Clienți (Leaderboard):**
    *   **Ce arată:** O listă cu cei mai fideli clienți, ordonată după numărul de rezervări sau totalul orelor jucate într-o anumită perioadă.
    *   **De ce e util:** Permite identificarea și recompensarea clienților loiali cu discounturi sau oferte speciale, încurajând astfel retenția.

3.  **Proiecția Veniturilor:**
    *   **Ce arată:** Dacă s-ar adăuga un preț pe oră pentru fiecare rezervare, acest raport ar putea calcula și afișa venitul total pe zi, săptămână sau lună.
    *   **De ce e util:** Oferă o imagine clară asupra performanței financiare și ajută la prognoza încasărilor.

4.  **Gradul de Ocupare al Terenurilor:**
    *   **Ce arată:** Un grafic (de tip pie chart) care compară popularitatea Terenului 1 versus Terenul 2.
    *   **De ce e util:** Se poate vedea dacă există o preferință clară pentru un anumit teren, ceea ce poate influența deciziile de întreținere sau preț.

5.  **Analiza Clienților Noi vs. Recurenți:**
    *   **Ce arată:** Un raport care urmărește lunar câți dintre clienți sunt noi (prima rezervare) și câți sunt recurenți.
    *   **De ce e util:** Ajută la înțelegerea eficienței campaniilor de marketing (dacă se atrag clienți noi) și a calității serviciilor (dacă clienții revin).

### Note de Implementare
*   Implementarea acestor funcționalități ar necesita, probabil, extinderea modelului de date pentru a include câmpuri noi precum `pret`, `status_rezervare` (confirmată, anulată), `id_client`, etc.
