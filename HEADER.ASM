;/************************************************************************\
;**                                                                      **
;**               OS/2(r) Physical Device Driver Libraries               **
;**                         for Watcom C/C++ 10                          **
;**                                                                      **
;**  COPYRIGHT:                                                          **
;**                                                                      **
;**    (C) Copyright Advanced Gravis Computer Technology Ltd 1994.       **
;**        All Rights Reserved.                                          **
;**                                                                      **
;**  DISCLAIMER OF WARRANTIES:                                           **
;**                                                                      **
;**    The following [enclosed] code is provided to you "AS IS",         **
;**    without warranty of any kind.  You have a royalty-free right to   **
;**    use, modify, reproduce and distribute the following code (and/or  **
;**    any modified version) provided that you agree that Advanced       **
;**    Gravis has no warranty obligations and shall not be liable for    **
;**    any damages arising out of your use of this code, even if they    **
;**    have been advised of the possibility of such damages.  This       **
;**    Copyright statement and Disclaimer of Warranties may not be       **
;**    removed.                                                          **
;**                                                                      **
;\************************************************************************/
;
;
;// Header.c
;//
;// Device driver header
;//
;// Note that the Watcom compiler does not currently support the data_seg
;// pragma correctly, so until proper support is added, this file is
;// superseded by Header.asm.
;//
;// History:
;//
;// Sep 30, 94  David Bollo    Initial version
;
;
;
;#error Use Header.asm instead.
;
;#include <devtype.h>
;#include <devrp.h>
;
;
;
;// Ensure that the header is located at the beginning of the driver
;
;#pragma data_seg (_HEADER);
;
;
;
;
;// Declare the device driver header
;
;VOID Strategy(RP FAR* rp);
;
;DEVHEADER DDHeader =
;  {
;  FinalLink,                  // Link to next header in chain
;  DAW_CHARACTER | DAW_SHARE | DAW_OPEN | DAW_LEVEL3,
;  Strategy,                   // Entry point to strategy routine
;  0,                          // Entry point to IDC routine
;  { 'D','r','i','v','e','r','$',' ' },    // Device driver name
;  "",                         // Reserved
;  CAP_COMPLETE | CAP_SHUTDOWN // Capabilities bit strip (for level 3 DDs)
;  };








;; Header.asm
;;
;; Device driver header
;;
;; History:
;;
;; Sep 30, 94  David Bollo    Initial version



              .386p

_HEADER       segment word public use16 'DATA'

              extrn Strategy_ : far

              dd 0FFFFFFFFh               ;; Link to next header
              dw 9980h                    ;; Device attribute word
              dw Strategy_                ;; Strategy entry point
              dw 0                        ;; IDC entry point
              db "WFASTIO$"               ;; Device driver name
              dq 0                        ;; Reserved
              dd 00000011h                ;; Capabilities bit strip

_HEADER       ends


              end
