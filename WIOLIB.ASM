; Copyright (C) 1995 by Holger Veit (Holger.Veit@gmd.de)
; Copyright (C) 1996 by  Alger Pike ( Alger@avenger.mri.psu.edu)
;
; Use at your own risk! No Warranty! The author is not responsible for
; any damage or loss of data caused by proper or improper use of this
; device driver or related software.
;
; This file contains the FASTIO API for the WASM assembler (10.0)

NAME IOLIB

.386

TEXT32 SEGMENT DWORD PUBLIC 'CODE'
TEXT32 ENDS

BSS32 SEGMENT DWORD PUBLIC 'BSS'
BSS32 ENDS

;gloabal data used

PUBLIC ioentry
PUBLIC gdt

BSS32 SEGMENT
ioentry DD 0
gdt DW 0
BSS32 ENDS


TEXT32 SEGMENT
 ALIGN 4

 ASSUME  CS:TEXT32
 ASSUME  DS:BSS32

; performs fast output of a byte to an I/O port
; this routine is intended to be called from WATCOM C code
;
; Calling convention:
; void c_outb(short port,char data)

 PUBLIC c_outb
c_outb PROC
 PUSH EBP
 MOV  EBP,  ESP               ;set standard stack frame
 PUSH EBX                     ;save register
 MOV   DX,  [EBP+8]           ;get  port
 MOV   AL,  [EBP+12]          ;get data
 MOV   BX,  4                 ;function code 4 = write byte
 CALL FWORD PTR [ioentry]     ;call intersegment indirect 16:32
 POP  EBX                     ;restore bx
 POP  EBP                     ;return
 RET
c_outb ENDP

; performs fast output of a word to an I/O port
; this routine is intended to be called from WATCOM C code
;
; Calling convention:
;	void c_outw(short port,short data)


 PUBLIC c_outw
c_outw PROC
 PUSH EBP
 MOV  EBP, ESP                ; set standard stack frame
 PUSH EBX                     ; save register
 MOV   DX, WORD PTR [EBP+8]   ; get port
 MOV   AX, WORD PTR [EBP+12]  ; get data
 MOV   BX, 5                  ; function code 5 = write word
 CALL FWORD PTR [ioentry]     ; call intersegment indirect 16:32
 POP EBX                      ; restore bx
 POP EBP                      ; return
 RET
 ALIGN 4
c_outw ENDP

; performs fast output of a longword to an I/O port
; this routine is intended to be called from WATCOM C code
;
; Calling convention:
;	void c_outl(short port,long data)


 PUBLIC c_outl
c_outl PROC

 PUSH EBP
 MOV  EBP, ESP                ; set standard stack frame
 PUSH EBX                     ; save register
 MOV   DX, WORD PTR [EBP+8]   ; get port
 MOV  EAX, DWORD PTR [EBP+12] ; get data
 MOV   BX, 6                  ; function code 6 = write longword
 CALL FWORD PTR [ioentry]     ; call intersegment indirect 16:32
 POP EBX                      ; restore bx
 POP EBP                      ; return
 RET
 ALIGN 4
c_outl ENDP

; performs fast input of a byte from an I/O port
; this routine is intended to be called from WATCOM C code
;
; Calling convention:
;	char c_inb(short port)

 PUBLIC c_inb
c_inb PROC
 PUSH EBP
 MOV  EBP, ESP                ;set standard stack frame
 PUSH EBX                     ;save register
 MOV   DX, [EBP+8]            ;get port
 MOV   BX, 1                  ;function code 1 = read byte
 CALL FWORD PTR [ioentry]     ;call intesegment indirerct 16:32
 AND  EAX, 0FFH               ;mask out rrequired byte
 POP  EBX                     ;restore register
 POP  EBP                     ;return
 RET
 ALIGN 4
c_inb ENDP

; performs fast input of a word from an I/O port
; this routine is intended to be called from gcc C code
;
; Calling convention:
;	short c_inw(short port)


 PUBLIC c_inw

c_inw PROC
 PUSH EBP
 MOV  EBP, ESP                ; set standard stack frame
 PUSH EBX                     ; save register
 MOV   DX, [EBP+8]            ; get port
 MOV   BX, 2                  ; function code 2 = read word
 CALL FWORD PTR [ioentry]     ; call intersegment indirect 16:32
 AND  EAX, 0FFFFH             ; mask out word
 POP  EBX                     ; restore register
 POP  EBP                     ; return
 RET
 ALIGN 4
 c_inw ENDP

; performs fast input of a longword from an I/O port
; this routine is intended to be called from WATCOM C code
;
; Calling convention:
;	lomg c_inl(short port)


PUBLIC c_inl
c_inl PROC
 PUSH EBP
 MOV  EBP, ESP                ; set standard stack frame
 PUSH EBX                     ; save register
 MOV   DX, WORD PTR [EBP+8]   ; get port
 MOV   BX, 3                  ; function code 3 = read longword
 CALL FWORD PTR [ioentry]     ; call intersegment indirect 16:32
 POP  EBX                     ; restore register
 POP  EBP                     ; return
 RET
 ALIGN 4
c_inl ENDP

 EXTRN DosOpen:PROC
 EXTRN DosDevIOCtl:PROC
 EXTRN DosClose:PROC

PUBLIC io_init

io_init PROC
 PUSH EBP
 MOV  EBP,  ESP
 MOV   AX,  WORD PTR [gdt]
 XOR  EAX, EAX
 MOV  DWORD PTR [ioentry], EAX
 POP  EBP
 RET

devname:
 DB "/dev/fastio$",0
 ALIGN 4

io_init ENDP

TEXT32 ENDS

END
