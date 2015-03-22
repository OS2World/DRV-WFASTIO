
/*********************************************************************
; Coupyright(C) 1995 by Holger Veit
; Copyright (C) 1996 by Alger Pike (Alger@avenger.mri.psu.edu)
; Use at your own risk! No Warranty! The author is not responsible for
; any damage or loss of data caused by proper or improper use of this
; device driver.
; **********************************************************************

NAME xfree86

INCLUDE devhlp.inc

.286

; **********************************************************************
; SEGMENTS
; **********************************************************************

; These are the standard segments
_DATA   segment word public use16 'DATA'
_DATA   ends
CONST   segment word public use16 'CONST'
CONST   ends
_BSS	segment word public use16 'BSS'
_BSS	ends

DGROUP  GROUP   CONST, _BSS, _DATA

_TEXT   segment word public 'CODE'
_TEXT   ends

_DATA segment
public _Device_Help
public _io_gdt32

_Device_Help dd 0
_io_gdt32 dw 0                 ; 32 bit call gate for I/O
gdthelper dw 0
gdtsave   dq 0
_DATA ends

_TEXT segment
assume cs:_TEXT, ds:DGROUP, es:NOTHING, ss:DGROUP

public acquire_gdt_

; int acquire_gdt()
; This routine is the worst hack this driver contains, and you should study
; it, but avoid it under all circumstances.
;
; This routine must be explained in detail:
; We rely on the fact that there is a DevHlp function named DevHlp_DynamicAPI
; and will remain available in the future.
; Dynamic API will setup a callgate to a routine in the driver. This is the
; theory. What actually happens is that a very large thunking and parameter
; checking routine is entered first, and then indirectly calls the driver
; routine. What we do here is pretty much foul: we calculate the offset of
; this selector in the GDT, and change it to point to the driver routine
; directly. Therefore this routine must be run in ring 0 mode.
;
; I expect that this way is the fastest possible way in OS/2 to execute
; R0 code.

.386p

acquire_gdt_ proc near
       pusha                  ;remark we push only 16-bit regs but use 32-bit regs
       mov   ax, word ptr [_io_gdt32]
       or    ax, ax
       jnz   aexit            ;if we don't have on e make it
       xor   ax, ax
       mov word ptr [_io_gdt32], ax
       mov word ptr [gdthelper], ax
       push  ds
       pop   es
       mov   di, offset _io_gdt32
       mov   cx, 2
       mov   dl, DevHlp_AllocGDTSelector
       call  [_Device_Help]
       jc aexit

       sgdt fword ptr [gdtsave]  ;get GDT ptr
       mov   ebx, dword ptr [gdtsave+2]
       movzx eax, word ptr [_io_gdt32]
       and   eax, 0fffffff8h   ;mask required byte
       add   ebx, eax          ;biuld address

       mov   ax,  word ptr [gdthelper]
       mov   ecx, 08h
       mov   dl, DevHlp_LinToGDTSelector
       call  [_Device_Help]
       jc aexit0

       mov   ax, word ptr [gdthelper]
       mov   es, ax ;Build address to GDT
       xor   bx, bx

       mov word ptr es:[bx], offset io_call_ ;fix offset
       mov word ptr es:[bx+2], cs
       mov word ptr es:[bx+4], 0ec00h
       mov word ptr es:[bx+6], 0000h

       mov dl, DevHlp_FreeGDTSelector
       call [_Device_Help]
       jnc short aexit

   aexit0:
       xor ax, ax
       mov word ptr [_io_gdt32], ax
   aexit:
       popa
       mov ax, word ptr [_io_gdt32]
       ret
acquire_gdt_ endp

; This is the entry point to the io handler. In order to make it as
; fast as possible, this is written in assembler with passing data in
; registers
; Calling convention:
; In:
;    DX = port
;    AL,AX,EAX = data when port write
;    BX = function code
; Out:
;    DX = unchanged
;    Al,AX,EAX = return value or unchanged
;    Bx = destroyed
;

.386p

retfd macro
  db 066h, 0cbh;
endm

io_call_ proc far
       assume cs:_TEXT, ds:NOTHING, es:NOTHING
       and  bx, 7
       add  bx, bx
       add  bx, offset iotbl
       jmp  cs:[bx]
   iotbl:  dw iofret
       dw iof1
       dw iof2
       dw iof3
       dw iof4
       dw iof5
       dw iof6
       dw iofret

; Note: be aware that this code is called via a 386 call gate, so
; the return adresses stored follow the 32 bit convention
; even if the base segment, which this code is in, is a FAR 16:16 segment.
;

iof1:  in al,dx  ; read byte
iofret:  retfd   ; NOP exit
iof2:  in ax,dx  ; read word
  retfd
iof3:  in eax,dx ; read dword
  retfd
iof4:  out dx,al ; write byte
  retfd
iof5:  out dx,ax ; write word
  retfd
iof6:  out dx,eax ; write dword
  retfd
io_call_ endp

_TEXT ends

end
