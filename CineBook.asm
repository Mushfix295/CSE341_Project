.MODEL SMALL
.STACK 100H

.DATA
;System Messages
MSG_WELCOME DB 13,10,'=====CINE BOOK- MOVIE TICKET BOOKING SYSTEM =====',13,10,'$'
MSG_MAIN_MENU DB 13,10,'1. Register',13,10,'2. Login',13,10,'3. Exit',13,10,'Choice: $'
MSG_USER_MENU DB 13,10,'1. View Movies',13,10,'2. Book Ticket',13,10,'3. View My Bookings',13,10,'4. Logout',13,10,'Choice: $'
MSG_ENTER_USER DB 13,10,'Enter Username (4 chars): $'
MSG_ENTER_PIN DB 13,10,'Enter PIN (4 digits): $'
MSG_REG_SUCCESS DB 13,10,'Registration Successful!',13,10,'$'
MSG_LOGIN_SUCCESS DB 13,10,'Login Successful!',13,10,'$'
MSG_LOGIN_FAIL DB 13,10,'Invalid Username or PIN!',13,10,'$'
MSG_USER_EXISTS DB 13,10,'Username already exists!',13,10,'$'
MSG_MAX_USERS DB 13,10,'Maximum users reached!',13,10,'$'

;Movie Messages
MSG_MOVIES DB 13,10,'===== AVAILABLE MOVIES =====',13,10,'$'
MSG_SELECT_MOVIE DB 13,10,'Select Movie (1-3): $'
MSG_SEAT_MAP DB 13,10,'===== SEAT MAP =====',13,10,'$'
MSG_SEAT_LEGEND DB '[O]=Available [X]=Taken',13,10,'$'
MSG_SELECT_ROW DB 13,10,'Enter Row (1-5): $'
MSG_SELECT_COL DB 13,10,'Enter Column (1-6): $'
MSG_SEAT_TAKEN DB 13,10,'Seat already taken!',13,10,'$'
MSG_BOOKING_SUCCESS DB 13,10,'Booking Successful!',13,10,'$'
MSG_PRICE DB 13,10,'Total Price: $'
MSG_MY_BOOKINGS DB 13,10,'===== MY BOOKINGS =====',13,10,'$'
MSG_NO_BOOKINGS DB 13,10,'No bookings found!',13,10,'$'
MSG_INVALID DB 13,10,'Invalid choice!',13,10,'$'
MSG_PRESS_KEY DB 13,10,'Press any key to continue...$'

;User Data Arrays 
USERNAMES DB 25 DUP(0)  
PINS DB 25 DUP(0)       
USER_COUNT DB 0
CURRENT_USER DB -1     

;Movie Data
MOVIE1 DB 'Avatar 2        $10',13,10,'$'
MOVIE2 DB 'Oppenheimer     $12',13,10,'$'  
MOVIE3 DB 'Barbie          $8 ',13,10,'$'
MOVIE_PRICES DB 10, 12, 8  ;Prices

;Seating Arrays (5 rowsx6cols =30 seats per movie)
SEATS_MOVIE1 DB 30 DUP(0)  ; 0=available, 1=taken
SEATS_MOVIE2 DB 30 DUP(0)
SEATS_MOVIE3 DB 30 DUP(0)

;Booking History (max 10 bookings per user)
;Format: MovieID(1) Row(1) Col(1) Price(1) =4 bytes per booking
BOOKINGS DB 200 DUP(0)  ;5 users*10 bookings*4 bytes
BOOKING_COUNT DB 5 DUP(0)  ; Number of bookings per user

;Input Buffers
INPUT_BUFFER DB 6 DUP(0)
TEMP_USER DB 5 DUP(0)
TEMP_PIN DB 5 DUP(0)

;Row/Column display helpers
ROW_NUM DB '1 $'
COL_NUMS DB '  1 2 3 4 5 6',13,10,'$'

.CODE
MAIN PROC
    ;Initialize DS
    MOV AX, @DATA
    MOV DS, AX
    
    ;Display Welcome
    LEA DX, MSG_WELCOME
    MOV AH, 09H
    INT 21H
    
MAIN_LOOP:
    ;Display Main Menu
    LEA DX, MSG_MAIN_MENU
    MOV AH, 09H
    INT 21H
    
    ;Get Choice
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JE REGISTER_USER
    CMP AL, '2'
    JE LOGIN_USER
    CMP AL, '3'
    JE EXIT_PROGRAM
    
    LEA DX, MSG_INVALID
    MOV AH, 09H
    INT 21H
    JMP MAIN_LOOP
    
REGISTER_USER:
    ;Check if max users reached
    CMP USER_COUNT, 5
    JL REG_CONTINUE
    LEA DX, MSG_MAX_USERS
    MOV AH, 09H
    INT 21H
    JMP MAIN_LOOP
    
REG_CONTINUE:
    ;Get Username
    LEA DX, MSG_ENTER_USER
    MOV AH, 09H
    INT 21H
    
    LEA SI, TEMP_USER
    CALL GET_STRING_INPUT
    
    ;Check if username exists
    CALL CHECK_USER_EXISTS
    CMP AL, 1
    JNE REG_ADD_USER
    
    LEA DX, MSG_USER_EXISTS
    MOV AH, 09H
    INT 21H
    JMP MAIN_LOOP
    
REG_ADD_USER:
    ;Get PIN
    LEA DX, MSG_ENTER_PIN
    MOV AH, 09H
    INT 21H
    
    LEA SI, TEMP_PIN
    CALL GET_STRING_INPUT
    
    ;Add user to arrays
    XOR BH, BH
    MOV BL, USER_COUNT
    MOV AL, 5
    MUL BL
    MOV DI, AX
    
    ;Copy username
    LEA SI, TEMP_USER
    LEA BX, USERNAMES
    ADD BX, DI
    MOV CX, 5
    CALL COPY_STRING
    
    ;Copy PIN
    LEA SI, TEMP_PIN
    LEA BX, PINS
    ADD BX, DI
    MOV CX, 5
    CALL COPY_STRING
    
    INC USER_COUNT
    
    LEA DX, MSG_REG_SUCCESS
    MOV AH, 09H
    INT 21H
    JMP MAIN_LOOP
    
LOGIN_USER:
    ;Get Username
    LEA DX, MSG_ENTER_USER
    MOV AH, 09H
    INT 21H
    
    LEA SI, TEMP_USER
    CALL GET_STRING_INPUT
    
    ;Get PIN
    LEA DX, MSG_ENTER_PIN
    MOV AH, 09H
    INT 21H
    
    LEA SI, TEMP_PIN
    CALL GET_STRING_INPUT
    
    ;Validate credentials
    CALL VALIDATE_LOGIN
    CMP AL, -1
    JNE LOGIN_SUCCESS
    
    LEA DX, MSG_LOGIN_FAIL
    MOV AH, 09H
    INT 21H
    JMP MAIN_LOOP
    
LOGIN_SUCCESS:
    MOV CURRENT_USER, AL
    LEA DX, MSG_LOGIN_SUCCESS
    MOV AH, 09H
    INT 21H
    
USER_MENU_LOOP:
    ;Display User Menu
    LEA DX, MSG_USER_MENU
    MOV AH, 09H
    INT 21H
    
    ;Get Choice
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JE VIEW_MOVIES
    CMP AL, '2'
    JE BOOK_TICKET
    CMP AL, '3'
    JE VIEW_BOOKINGS
    CMP AL, '4'
    JE LOGOUT
    
    LEA DX, MSG_INVALID
    MOV AH, 09H
    INT 21H
    JMP USER_MENU_LOOP
    
VIEW_MOVIES:
    LEA DX, MSG_MOVIES
    MOV AH, 09H
    INT 21H
    
    ; Display Movie 1
    MOV DL, '1'
    MOV AH, 02H
    INT 21H
    MOV DL, '.'
    INT 21H
    MOV DL, ' '
    INT 21H
    LEA DX, MOVIE1
    MOV AH, 09H
    INT 21H
    
    ; Display Movie 2
    MOV DL, '2'
    MOV AH, 02H
    INT 21H
    MOV DL, '.'
    INT 21H
    MOV DL, ' '
    INT 21H
    LEA DX, MOVIE2
    MOV AH, 09H
    INT 21H
    
    ; Display Movie 3
    MOV DL, '3'
    MOV AH, 02H
    INT 21H
    MOV DL, '.'
    INT 21H
    MOV DL, ' '
    INT 21H
    LEA DX, MOVIE3
    MOV AH, 09H
    INT 21H
    
    LEA DX, MSG_PRESS_KEY
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    JMP USER_MENU_LOOP
    
BOOK_TICKET:
    ; Select Movie
    LEA DX, MSG_SELECT_MOVIE
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    
    CMP AL, 1
    JL INVALID_MOVIE
    CMP AL, 3
    JG INVALID_MOVIE
    
    PUSH AX  ; Save movie choice
    
    ; Display Seat Map
    CALL DISPLAY_SEAT_MAP
    
    ; Get Row
    LEA DX, MSG_SELECT_ROW
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    
    CMP AL, 1
    JL INVALID_SEAT
    CMP AL, 5
    JG INVALID_SEAT
    
    MOV BH, AL  ; Save row (1-5)
    PUSH BX     ; Save row in BH on stack
    
    ; Get Column
    LEA DX, MSG_SELECT_COL
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    
    CMP AL, 1
    JL INVALID_SEAT_POP
    CMP AL, 6
    JG INVALID_SEAT_POP
    
    MOV BL, AL  ; Save column (1-6)
    POP CX      ; Get row back in CH
    MOV BH, CH  ; Restore row to BH
    POP AX      ; Restore movie choice
    
    ; Save row and column for later use
    PUSH BX     ; Save row(BH) and column(BL)
    
    ; Calculate seat index: (row-1)*6 + (col-1)
    PUSH AX     ; Save movie choice
    DEC BH
    MOV AL, 6
    MUL BH
    XOR BH, BH
    DEC BL
    ADD AL, BL
    XOR AH, AH
    MOV SI, AX  ; SI = seat index
    POP AX      ; Restore movie choice
    
    ; Get seat array base address
    CMP AL, 1
    JE CHECK_MOVIE1
    CMP AL, 2
    JE CHECK_MOVIE2
    JMP CHECK_MOVIE3
    
CHECK_MOVIE1:
    LEA BX, SEATS_MOVIE1
    JMP CHECK_SEAT_STATUS
    
CHECK_MOVIE2:
    LEA BX, SEATS_MOVIE2
    JMP CHECK_SEAT_STATUS
    
CHECK_MOVIE3:
    LEA BX, SEATS_MOVIE3
    
CHECK_SEAT_STATUS:
    ADD BX, SI
    CMP BYTE PTR [BX], 1
    JE SEAT_IS_TAKEN_POP
    
    ; Mark seat as taken
    MOV BYTE PTR [BX], 1
    
    ; Add to bookings
    PUSH AX  ; Save movie ID
    
    ; Calculate booking offset
    XOR AH, AH
    MOV AL, CURRENT_USER
    MOV CL, 40  ; 10 bookings * 4 bytes
    MUL CL      ; Result in AX
    MOV DI, AX
    
    XOR BH, BH
    MOV BL, CURRENT_USER
    LEA SI, BOOKING_COUNT
    ADD SI, BX
    XOR AH, AH
    MOV AL, [SI]
    MOV CL, 4
    MUL CL      ; Result in AX
    ADD DI, AX
    
    LEA BX, BOOKINGS
    ADD BX, DI
    
    POP AX  ; Restore movie ID
    MOV [BX], AL     ; Store movie ID
    
    POP CX  ; Get saved row(CH) and column(CL)
    MOV [BX+1], CH   ; Store row
    MOV [BX+2], CL   ; Store col
    
    ; Store price
    DEC AL
    XOR AH, AH
    MOV SI, AX
    PUSH BX         ; Save booking pointer
    LEA BX, MOVIE_PRICES
    ADD BX, SI
    MOV AL, [BX]
    POP BX          ; Restore booking pointer
    MOV [BX+3], AL
    
    ; Increment booking count
    XOR BH, BH
    MOV BL, CURRENT_USER
    LEA SI, BOOKING_COUNT
    ADD SI, BX
    INC BYTE PTR [SI]
    
    ; Display success message
    LEA DX, MSG_BOOKING_SUCCESS
    MOV AH, 09H
    INT 21H
    
    LEA DX, MSG_PRICE
    MOV AH, 09H
    INT 21H
    
    ; Display price
    MOV DL, '$'
    MOV AH, 02H
    INT 21H
    
    MOV AL, [BX+3]
    CALL PRINT_NUMBER
    
    LEA DX, MSG_PRESS_KEY
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    JMP USER_MENU_LOOP
    
SEAT_IS_TAKEN_POP:
    POP BX  ; Clean stack
SEAT_IS_TAKEN:
    LEA DX, MSG_SEAT_TAKEN
    MOV AH, 09H
    INT 21H
    JMP USER_MENU_LOOP
    
INVALID_SEAT_POP:
    POP BX  ; Clean stack
INVALID_SEAT:
    POP AX  ; Clean stack if movie was pushed
INVALID_MOVIE:
    LEA DX, MSG_INVALID
    MOV AH, 09H
    INT 21H
    JMP USER_MENU_LOOP
    
VIEW_BOOKINGS:
    LEA DX, MSG_MY_BOOKINGS
    MOV AH, 09H
    INT 21H
    
    ; Check if user has bookings
    XOR BH, BH
    MOV BL, CURRENT_USER
    LEA SI, BOOKING_COUNT
    ADD SI, BX
    CMP BYTE PTR [SI], 0
    JNE SHOW_BOOKINGS
    
    LEA DX, MSG_NO_BOOKINGS
    MOV AH, 09H
    INT 21H
    JMP BOOKINGS_END
    
SHOW_BOOKINGS:
    ; Calculate base offset for user's bookings
    XOR AH, AH
    MOV AL, CURRENT_USER
    MOV CL, 40
    MUL CL
    MOV DI, AX
    
    XOR BH, BH
    MOV BL, CURRENT_USER
    LEA SI, BOOKING_COUNT
    ADD SI, BX
    MOV CL, [SI]  ; Number of bookings
    XOR CH, CH
    
BOOKING_LOOP:
    PUSH CX
    
    ; Print booking number
    MOV DL, '['
    MOV AH, 02H
    INT 21H
    
    ; Get booking data
    LEA BX, BOOKINGS
    ADD BX, DI
    
    ; Print movie name
    MOV AL, [BX]
    CMP AL, 1
    JE PRINT_M1
    CMP AL, 2
    JE PRINT_M2
    
    MOV DL, 'B'
    MOV AH, 02H
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'r'
    INT 21H
    MOV DL, 'b'
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 'e'
    INT 21H
    JMP PRINT_SEAT_INFO
    
PRINT_M1:
    MOV DL, 'A'
    MOV AH, 02H
    INT 21H
    MOV DL, 'v'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'r'
    INT 21H
    JMP PRINT_SEAT_INFO
    
PRINT_M2:
    MOV DL, 'O'
    MOV AH, 02H
    INT 21H
    MOV DL, 'p'
    INT 21H
    MOV DL, 'p'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, 'n'
    INT 21H
    
PRINT_SEAT_INFO:
    MOV DL, ']'
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'R'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'w'
    INT 21H
    MOV DL, ':'
    INT 21H
    
    MOV AL, [BX+1]
    ADD AL, '0'
    MOV DL, AL
    INT 21H
    
    MOV DL, ' '
    INT 21H
    MOV DL, 'C'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'l'
    INT 21H
    MOV DL, ':'
    INT 21H
    
    MOV AL, [BX+2]
    ADD AL, '0'
    MOV DL, AL
    INT 21H
    
    MOV DL, ' '
    INT 21H
    MOV DL, '$'
    INT 21H
    
    MOV AL, [BX+3]
    CALL PRINT_NUMBER
    
    MOV DL, 13
    MOV AH, 02H
    INT 21H
    MOV DL, 10
    INT 21H
    
    ADD DI, 4
    POP CX
    LOOP BOOKING_LOOP
    
BOOKINGS_END:
    LEA DX, MSG_PRESS_KEY
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    JMP USER_MENU_LOOP
    
LOGOUT:
    MOV CURRENT_USER, -1
    JMP MAIN_LOOP
    
EXIT_PROGRAM:
    MOV AX, 4C00H
    INT 21H

; ===== PROCEDURES START HERE =====

; Display seat map for selected movie (movie ID in AL)
DISPLAY_SEAT_MAP:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; Get seat array base
    CMP AL, 1
    JE SEATS1
    CMP AL, 2
    JE SEATS2
    LEA SI, SEATS_MOVIE3
    JMP SHOW_MAP
SEATS1:
    LEA SI, SEATS_MOVIE1
    JMP SHOW_MAP
SEATS2:
    LEA SI, SEATS_MOVIE2
    
SHOW_MAP:
    LEA DX, MSG_SEAT_MAP
    MOV AH, 09H
    INT 21H
    
    LEA DX, MSG_SEAT_LEGEND
    MOV AH, 09H
    INT 21H
    
    ; Print column numbers
    LEA DX, COL_NUMS
    MOV AH, 09H
    INT 21H
    
    ; Print seats
    MOV CX, 5  ; 5 rows
    MOV BH, '1' ; Row number
    
ROW_LOOP:
    PUSH CX
    
    ; Print row number
    MOV DL, BH
    MOV AH, 02H
    INT 21H
    MOV DL, ' '
    INT 21H
    
    ; Print 6 seats in row
    MOV CX, 6
COL_LOOP:
    MOV DL, '['
    MOV AH, 02H
    INT 21H
    
    CMP BYTE PTR [SI], 0
    JE PRINT_AVAIL
    MOV DL, 'X'
    JMP PRINT_STATUS
PRINT_AVAIL:
    MOV DL, 'O'
PRINT_STATUS:
    INT 21H
    
    MOV DL, ']'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    INC SI
    LOOP COL_LOOP
    
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H
    
    INC BH
    POP CX
    LOOP ROW_LOOP
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

; Get 4-character string input (SI = buffer)
GET_STRING_INPUT:
    PUSH AX
    PUSH CX
    PUSH SI
    
    MOV CX, 4
INPUT_LOOP:
    MOV AH, 01H
    INT 21H
    MOV [SI], AL
    INC SI
    LOOP INPUT_LOOP
    
    MOV BYTE PTR [SI], 0
    
    POP SI
    POP CX
    POP AX
    RET

; Check if username exists (TEMP_USER)
; Returns: AL = 1 if exists, 0 if not
CHECK_USER_EXISTS:
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    XOR CX, CX
    MOV CL, USER_COUNT
    CMP CL, 0
    JE USER_NOT_FOUND
    
    LEA SI, USERNAMES
    XOR BX, BX  ; User counter
CHECK_LOOP:
    PUSH CX
    PUSH SI
    LEA DI, TEMP_USER
    MOV CX, 4
    
COMPARE_LOOP:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE NEXT_USER
    INC SI
    INC DI
    LOOP COMPARE_LOOP
    
    ; User found
    POP SI
    POP CX
    MOV AL, 1
    JMP CHECK_DONE
    
NEXT_USER:
    POP SI
    ADD SI, 5  ; Move to next username (5 bytes each)
    POP CX
    LOOP CHECK_LOOP
    
USER_NOT_FOUND:
    MOV AL, 0
    
CHECK_DONE:
    POP DI
    POP SI
    POP CX
    POP BX
    RET

; Validate login credentials
; Returns: AL = user index if valid, -1 if invalid
VALIDATE_LOGIN:
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    XOR BX, BX
    MOV BL, USER_COUNT
    CMP BL, 0
    JE LOGIN_INVALID
    
    XOR DI, DI  ; User index
VALIDATE_LOOP:
    PUSH BX
    PUSH DI
    
    ; Calculate offset
    MOV AX, DI
    MOV CL, 5
    MUL CL
    MOV SI, AX
    
    ; Check username
    LEA BX, USERNAMES
    ADD BX, SI
    LEA DI, TEMP_USER
    MOV CX, 4
    
CHECK_USER:
    MOV AL, [BX]
    CMP AL, [DI]
    JNE NEXT_LOGIN
    INC BX
    INC DI
    LOOP CHECK_USER
    
    ; Username matches, check PIN
    POP DI
    PUSH DI
    MOV AX, DI
    MOV CL, 5
    MUL CL
    MOV SI, AX
    
    LEA BX, PINS
    ADD BX, SI
    LEA DI, TEMP_PIN
    MOV CX, 4
    
CHECK_PIN:
    MOV AL, [BX]
    CMP AL, [DI]
    JNE NEXT_LOGIN
    INC BX
    INC DI
    LOOP CHECK_PIN
    
    ; Login valid
    POP DI
    POP BX
    MOV AX, DI
    JMP LOGIN_DONE
    
NEXT_LOGIN:
    POP DI
    INC DI
    POP BX
    DEC BL
    JNZ VALIDATE_LOOP
    
LOGIN_INVALID:
    MOV AL, -1
    
LOGIN_DONE:
    POP DI
    POP SI
    POP CX
    POP BX
    RET

; Copy string (SI=source, BX=dest, CX=length)
COPY_STRING:
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH BX
    
COPY_LOOP:
    MOV AL, [SI]
    MOV [BX], AL
    INC SI
    INC BX
    LOOP COPY_LOOP
    
    POP BX
    POP SI
    POP CX
    POP AX
    RET

; Print number in AL
PRINT_NUMBER:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR AH, AH
    MOV BL, 10
    DIV BL
    
    ; Print tens digit if not zero
    CMP AL, 0
    JE PRINT_ONES
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
PRINT_ONES:
    ADD AH, '0'
    MOV DL, AH
    MOV AH, 02H
    INT 21H
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET

MAIN ENDP
END MAIN