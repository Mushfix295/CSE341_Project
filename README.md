# CSE341_Project
Microprocessor
# 🎬 Cine Book - Movie Ticket Booking System (emu8086 Assembly)

This project is a **movie ticket booking system** implemented entirely in **x86 Assembly (emu8086)**.  
It provides a simulation of user registration, login, movie listings, seat selection, booking, and viewing purchase history.

---

## ✨ Features

1. **User Account System**
   - Register new users with a 4-character username and 4-digit PIN.
   - Login validation using parallel arrays for usernames and PINs.

2. **Movie Listings**
   - Displays a list of available movies with their respective ticket prices.
   - Movies are stored in the `.DATA` segment.

3. **Interactive Seating Map**
   - Seats displayed in a **5x6 grid** per movie (30 seats).
   - `[O]` = Available, `[X]` = Taken.
   - Built with nested loops that iterate through seating arrays.

4. **Seat Selection & Validation**
   - Users select a row and column.
   - Input is validated to ensure the seat is available.
   - Seat status updated dynamically.

5. **Booking & Payment Confirmation**
   - Once a seat is booked, it updates as **taken**.
   - Displays total price of the booking.
   - Booking data stored in a user’s personal booking history.

6. **View My Bookings**
   - Logged-in users can view their personal booking history.
   - Each booking includes:
     - Movie name
     - Seat row & column
     - Ticket price

---

## ⚙️ How to Run

1. Download and install **emu8086** (or use DOSBox + TASM/MASM).
2. Open the file:
CineBook.asm


3. Compile and run the program in **emu8086**.
4. Follow the on-screen instructions:
- Register or login
- View movies
- Select seats
- Confirm booking
- View purchase history

---

## 🖥️ Controls

- Input is taken one character at a time.
- Press any key when prompted to continue.
- Username: 4 characters  
- PIN: 4 digits

---

## 📸 Sample Screenshots

### 1. Welcome & Main Menu
<img width="1280" height="656" alt="welcome" src="https://github.com/user-attachments/assets/43ffb786-a7df-4c72-8196-5850f2045ade" />

### 2. Movies List
<img width="1280" height="656" alt="movies" src="https://github.com/user-attachments/assets/43eae5de-b99f-452a-aa7c-70b886dda2e2" />

### 3. Seat Map Example
<img width="1280" height="656" alt="seatmap" src="https://github.com/user-attachments/assets/ab4790de-0a45-4dca-863b-97e3e2a70421" />

### 4. Booking Confirmation
<img width="1280" height="656" alt="booking" src="https://github.com/user-attachments/assets/6460e3d6-7b05-4ea3-acb1-af002a7692f6" />

### 5. View My Bookings
<img width="1280" height="656" alt="bookings" src="https://github.com/user-attachments/assets/dc943c0b-4335-4767-979d-3956b3b2f2a4" />

---

## 📂 File Structure

- `CineBook.asm` → Main assembly source file.

---

## 🚀 Example Flow

1. Register as a new user.
2. Login using your username & PIN.
3. View available movies.
4. Select a movie, view the seat map, and choose your seat.
5. Confirm your booking and view the total price.
6. Check your booking history anytime.

---


Project developed as part of **emu8086 Assembly Programming coursework**.

