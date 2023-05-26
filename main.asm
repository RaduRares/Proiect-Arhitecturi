    DOSSEG
    .MODEL SMALL
    .STACK 32
    .DATA
tmp DB 0
tmp1 DB 0
tmp2 DB 0
tmp3 DB 0
biti2 DB 0
tmp4 DW 0
index db 0
index1 db 0 
final_encript DB 80 DUP(0)
encoded     DB  80 DUP(0)
temp        DB  '0x', 160 DUP(0)
binarycode DB 640 DUP(0)
fileHandler DW  ?
filename    DB  'in.txt',0         ; Trebuie sa existe acest fisier 'in/in.txt'!
outfile     DB  'out.txt', 0        ; Trebuie sa existe acest director 'out'!
message     DB  80 DUP(0)
message_back_up DB 80 DUP(0)
msglen      DW  ?
padding     DW  0
iterations  DW  0
x           DW  ?
x0          DW  ?
x01         DW  ?
a           DW  0
b           DW  0
aux DW 0
CODE64 DB 'Bqmgp86CPe9DfNz7R1wjHIMZKGcYXiFtSU2ovJOhW4ly5EkrqsnAxubTV04a=L/d', 0

    .CODE
START:
    MOV     AX, @DATA
    MOV     DS, AX

    CALL    FILE_INPUT                  ; NU MODIFICATI!
    
    CALL    SEED                        ; TODO - Trebuie implementata
    
    CALL    ENCRYPT                     ; TODO - Trebuie implementata
    
    CALL    ENCODE                      ; TODO - Trebuie implementata
    
                                        ; Mai jos se regaseste partea de
                                        ; afisare pe baza valorilor care se
                                        ; afla in variabilele x0, a, b, respectiv
                                        ; in sirurile message si encoded.
    MOV AX,x01
MOV x0,AX                                    ; NU MODIFICATI!
    MOV     AH, 3CH                     ; BIOS Int - Open file

    MOV     CX, 0
    MOV     AL, 1                       ; AL - Access mode ( Write - 1 )
    MOV     DX, OFFSET outfile          ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    CALL    WRITE                       ; NU MODIFICATI!

    MOV     AH, 4CH                     ; Bios Int - Terminate with return code
    MOV     AL, 0                       ; AL - Return code
    INT     21H
FILE_INPUT:
;deschide fisierul
    MOV     AH, 3DH                     ; BIOS Int - Open file
    MOV     AL, 0                       ; AL - Access mode ( Read - 0 )
    MOV     DX, OFFSET fileName         ; DX - Filename
    INT     21H
    MOV     [fileHandler], AX           ; Return: AX - file handler or error code

    MOV     AH, 3FH                     ; BIOD Int - Read from file or device
    MOV     BX, [fileHandler]           ; BX - File handler
    MOV     CX, 80                      ; CX - Number of bytes to read
    MOV     DX, OFFSET message          ; DX - Data buffer
    INT     21H
    MOV     [msglen], AX                ; Return: AX - number of read bytes
    ; cu tot cu enter care e 2 biti 
    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H

    RET
SEED:
    MOV     AH, 2CH                     ; BIOS Int - Get System Time
    INT     21H
  ; MOV tmp,0Eh
;MOV tmp1,17h
 ;  MOV tmp2,26h
  ; MOV tmp3,4Ch
  MOV tmp,CH
    MOV tmp1,CL
MOV tmp2,DH
    MOV tmp3,DL
    MOV AH,0

    MOV AL, tmp
    
    MOV CX,3CH
    MUL CX
    mov BH,0
    MOV BL,tmp1
    
    ADD AX,BX
    MUL CX
    MOV BH,0
    MOV BL,tmp2

    ADD AX,BX
    
    ;avem salvat in ax 
    ;acum ar trebui sa facem inmultirea 
       ;  muta numarul de 2 biti in ax
  
 
MOV BL,64h     ; move the value 64 into BL register
MUL BX          ; multiply AX by BL, result is in DX:AX ;multiplicam AX cu BL, 
                ; trebuie sa avem grija ca rezultatul este salvat sub forma DX:AX
                ;deoarece facand o inmultire asa mare nu avem registrii indeasuns de mari
                ;pentru a pute salva
MOV BH,0
MOV BL,tmp3

ADD AX, BX      ; adauga 4Ch in AX
MOV BL, 100      ; move the value 100 into BL register
MOV CX, DX      ; Move the value in DX to CX
SHL DX, 8       ; SHiftam la stanga cu 8 biti
ADD DX, AX    ; combinam rezultatele din DX CU AX
MOV AX, DX      ; Move the combined value back to AX; Mutam valoarea in AX
XOR DX, DX      ; Clear DX pentru a ne pregati de impartire
MOV BX, 0FFh    ; Move the value 0FFh into BX ; adica 255
DIV BX          
                ;facem impartirea AX la BX iar restul ramane in DX
; DL Contine rezultatul  of (CA6Ah*64h+4Ch)*100%255

; Rezultatul este acum în AX și poate fi salvat în altă parte a memoriei
MOV x0, DX
;Punem in x0
      ; Move the remainder (i.e., the modulo) from AL to x0
  MOV AX,x0    
MOV x,AX    ;salvam si x0 si in x pentru a ne pregati de urmatoarea functie
    MOV x01,AX

    RET
          
     
ENCRYPT:
    MOV     CX, [msglen]
    MOV     SI, OFFSET message
  ;  CMP CX,0  



   ;     JE final_encript
 CALL functie_cal_a
    CALL functie_cal_b 
 DEC CX 
MOV AX,x0
  XOR   [SI],AX
     INC SI
 
FOR:
CALL RAND  
LOOP FOR                               ; TODO3: Completati subrutina ENCRYPT
                                     ; astfel incat in cadrul buclei sa fie
                                        ; XOR-at elementul curent din sirul de
                                            ; intrare cu termenul corespunzator din
                                            ; sirul generat, iar mai apoi sa fie generat
                                          ; si termenul urmator

    RET

RAND:  ;xn = (a ∗ xn−1 + b) mod 255
   
   MOV BX,a
    MOV AX,x0
    MUL BX
    mov x0,AX
    MOV BX,b
    ADD x0,BX
    MOV DX,0
    MOV AX,x0
    
    MOV BX,255
    DIV BX
    MOV x0,DX
    MOV AX,x0 
    
  
    
   
   
   
    XOR   [SI],AX ; xor destinatie sursa
    INC SI
    
    
    MOV AX,0
    MOV AX,x0
    MOV  x,AX



 
     RET
     ;aici o sa populam x folosindu ne de x0 iar a si b deja le stim                                           ; TODO2: Completati subrutina RAND, astfel incat
                                            ; in cadrul acesteia va fi calculat termenul
                                            ; de rang n pe baza coeficientilor a, b si a 
                                            ; termenului de rang inferior (n-1) si salvat
                                            ; in cadrul variabilei 'x'
MOV AX,x01
MOV x0,AX
  
ENCODE:
                                  ; TODO4: Completati subrutina ENCODE, astfel incat
      
       
       
MOV CX, msglen
    MOV SI,OFFSET message
    MOV DI,OFFSET message_back_up
    for_copiere:
        MOV AX,[SI]
        MOV [DI],AX
        INC si
        INC DI

    LOOP  for_copiere


        MOV AH,0
        MOV AX ,msglen
        mov bl,3
         DIV bl
         MOV Cl,AL                                 ; in cadrul acesteia va fi realizata codificarea

       MOV iterations,CX
        for_1:

    CALL cazul_fav
     MOV ah,0
    MOV AL,3
    ADD index,AL
    MOV ah,0
    MOV AL,4
    ADD index1,AL

        LOOP for_1                    ; sirului criptat pe baza alfabetului COD64 mentionat
   

       
        MOV AH,0
        MOV AX ,msglen
        mov bl,3
         DIV bl
                                        ; in enuntul problemei si rezultatul va fi stocat
         CMP AH,1
         JNZ treci_peste
;avem avem pentru doi de plus
  MOV SI,OFFSET message_back_up
    MOV DI,OFFSET code64
    MOV AH,0
    MOV BH,0
    MOV AL,index
    ADD SI,ax
    MOV AL,11111100b
    
    MOV BL,[SI]
    AND BL,AL
    SHR BL,2
    ;in bl avem ce trebuie
    mov bh,0
    ADD DI,BX
    MOV AX,[DI]; Avem in ax ce trebuie pus in encoded

    mov SI,OFFSET encoded
    MOV BX,0
    mov bl,index1
    add si,BX
    MOV AH,0
    MOV [SI],AX ;punem in encoded ce e elementul bun din code64
    ;MOV [SI],BL
    MOV SI,offset message_back_up
    MOV DI,offset code64
    MOV AX,0
    MOV AL,index
    ADD SI,AX

    MOV AX,[SI]
    
    MOV AH,0
    AND AL,00000011b
    SHL AL,4

    ;avem in al ce ne trebuie
    MOV SI,offset encoded
     MOV BX,0
    MOV BL,index1
    INC BL
    ADD SI,BX
    ADD DI,AX
        MOV AL,[DI]
    mov [si],al
    INC SI
    MOV [SI],2BH
    INC SI
    MOV [SI],2BH

    ADD padding,2
    RET


       ; JE cazul_favorit
        ; JMP cazul_fav
       
                                          ; in cadrul variabilei encoded
    

    treci_peste:
     CMP ah,2
     JZ un_plus
RET

    
    un_plus:
 MOV SI,OFFSET message_back_up
    MOV DI,OFFSET code64
    MOV AH,0
    MOV BH,0
    MOV AL,index
    ADD SI,ax
    MOV AL,11111100b
    
    MOV BL,[SI]
    AND BL,AL
    SHR BL,2
    ;in bl avem ce trebuie
    mov bh,0
    ADD DI,BX
    MOV AX,[DI]; Avem in ax ce trebuie pus in encoded

    mov SI,OFFSET encoded
    MOV BX,0
    mov bl,index1
    add si,BX
    MOV AH,0
    MOV [SI],AX ;punem in encoded ce e elementul bun din code64
    
    MOV SI, offset message_back_up
    MOV DI, offset code64
    mov bx,0
    mov bl,index
    ADD SI,BX
    MOV BX,[SI]
    AND BL,00000011b
    SHL BL,4
    mov AH,0
    MOV AL,BL
    INC SI
    MOV BX,[SI]
    AND BL,11110000b
    SHR BL,4
    OR AL,BL
    ADD DI,AX
    MOV AL,[DI]
    MOV SI,offset encoded
    MOV BH,0
    MOV BL,index1
    ADD SI,BX
    INC SI
    MOV [SI],AX
 MOV SI, offset message_back_up
 mov di,offset code64
 mov ah,0
 MOV AL,index
 add al,1
 ADD SI,AX
 mov aL,[si]
AND AL,00001111b
SHL AL,2
ADD DI,AX
MOV AL,[DI]
MOV SI,OFFSET encoded
MOV BH,0
MOV BL,index1
ADD BL,2
ADD SI,Bx
;AL este salvat prima parte
MOV AL,[DI]
MOV [SI],AX
INC SI
MOV [SI],2BH
INC SI
MOV AX,padding
INC AX
    MOV padding,AX
  
    
RET



 cazul_fav:
    MOV SI, offset message_back_up
    MOV DI, offset CODE64
    MOV Ax,0
    MOV AL , index
    ADD SI,Ax
    MOV AL, [SI]  ;trebuie sa facem si pe un octet ca sa ramana ultimii 6 biti
    AND AL,11111100b
    SHR AL, 2
    MOV AH,0 
    MOV tmp,AL 
  
    MOV BH,0
    ADD DI,AX
    MOV BL, [DI]
    MOV SI, offset encoded
    MOV AX,0
    MOV AL,index1  
    ADD SI,AX;
    MOV [SI],BL
    

;refacem code64


    MOV DI, OFFSET CODE64
   

; mai avem 2 biti de salvat

MOV SI,OFFSET message_back_up
 MOV ax,0
    MOV AL , index
    ADD SI,Ax
 MOV AL, [SI]
AND AL,00000011b
 MOV biti2 ,AL
 INC SI
MOV AL,[SI]
AND AL,11110000b
SHR AL,4
;avem 00000011b si trebuie sa punem pe bitul 5,6 cei doi biti ramasi
MOV SI,offset encoded
 MOV DX,0
    MOV DL , index1
    ADD SI,Dx

INC SI
MOV BL,biti2
SHL BL,4
OR AL,BL
MOV AH,0
ADD DI,AX
MOV AL,[DI]
MOV [SI],AL
    ; refacem code64
 MOV DI,OFFSET CODE64
  

 MOV SI,OFFSET message_back_up
  MOV DX,0
    MOV DL , index
    ADD SI,Dx
 INC SI
 MOV AL, [SI]
 AND AL,00001111b
 SHL AL,2
 ;00111100b
 INC SI
MOV BL,[SI]
AND BL,11000000b
SHR BL,6
OR AL,BL
MOV AH,0
ADD DI,AX
MOV Al,[DI]
MOV SI, OFFSET encoded


  MOV DX,0
    MOV DL , index1
    ADD SI,DX
ADD SI,2
MOV [SI],AX
MOV DI,OFFSET code64
MOV SI,OFFSET message_back_up

 MOV DX,0
    MOV DL , index
    ADD SI,DX

add si,2
MOV AX,[SI]
MOV AH,0
AND AL,00111111b
add DI,AX
MOV AX,[DI]
MOV SI,OFFSET encoded

  MOV dx,0
    MOV DL , index1
    ADD sI,DX
ADD SI,3
MOV [SI],Al
MOV DI,OFFSET code64
 ;avem de salvat 


;acum trebuie sa stergem 3 caractere din sir ca sa le ia pe celelalte 3, din acesta cauza am facut si back message_back_up

   
RET


WRITE_HEX:
    MOV     DI, OFFSET temp + 2
    XOR     DX, DX
DUMP:
    MOV     DL, [SI]
    PUSH    CX
    MOV     CL, 4

    ROR     DX, CL
    
    CMP     DL, 0ah
    JB      print_digit1

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     next_digit

print_digit1:  
    OR      DL, 30h
    MOV     byte ptr [DI] ,DL
next_digit:
    INC     DI
    MOV     CL, 12
    SHR     DX, CL
    CMP     DL, 0ah
    JB      print_digit2

    ADD     DL, 37h
    MOV     byte ptr [DI], DL
    JMP     AGAIN

print_digit2:    
    OR      DL, 30h
    MOV     byte ptr [DI], DL
AGAIN:
    INC     DI
    INC     SI
    POP     CX
    LOOP    dump
    
    MOV     byte ptr [DI], 10
    RET
WRITE:
    MOV     SI, OFFSET x0
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21h

    MOV     SI, OFFSET a
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET b
    MOV     CX, 1
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET x
    MOV     CX, 1
    CALL    WRITE_HEX    
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, 5
    INT     21H

    MOV     SI, OFFSET message
    MOV     CX, [msglen]
    CALL    WRITE_HEX
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET temp
    MOV     CX, [msglen]
    ADD     CX, [msglen]
    ADD     CX, 3
    INT     21h
  ;  MOV AH,0




;MOV AX, [msglen]  ; Move the value from memory to AX register




    MOV     AX,[iterations] 
    

    MOV     BX, 4
    MUL     BX
    CMP padding,0
    JZ SKIP
    
    MOV BX,padding
    CMP padding ,1
    JZ inca_unu
    CMP padding ,2
JZ pad_2
inca_unu:
INC BX
pad_2:
    MUL BX 
     jmp skip
    SKIP:

    MOV     CX, AX
  
    MOV     AH, 40h
    MOV     BX, [fileHandler]
    MOV     DX, OFFSET encoded
    INT     21H

    MOV     AH, 3EH                     ; BIOS Int - Close file
    MOV     BX, [fileHandler]           ; BX - File handler
    INT     21H
    RET

functie_cal_a:
   
  MOV AX,0
; ADD AX,82 ; R
 ;   ADD AX,97 ; a
  ;  ADD AX,114 ; r 
   ; ADD AX,101 ; e 
    ;ADD AX,115 ; s 
    ADD AX,68 ; D
 ADD AX,114 ; r
  ADD AX,97 ; a 
    ADD AX,103 ; g 
   ADD AX,111 ; o 
    ADD AX,115 ; s
    MOV DX,0
    MOV BX,255
    DIV BX
    MOV a,DX

    RET

functie_cal_b:
MOV AX,0
    ADD AX,82 ;R
    ADD AX,97 ;a
    ADD AX,100 ;d
    ADD AX,117 ;u
   ;MOV b,0
    ;ADD AX,73 ; I
    ;ADD AX,111 ; o
    ;ADD AX,97 ; a 
    ;ADD AX,110 ; n 
   ;ADD AX,97 ; a 
 
    
    MOV DX,0
    MOV BX,255
    DIV BX
    
    MOV b,DX
    RET
    END START






final_encript:
  MOV AH,4CH
  MOV AL, 0
    INT 21H