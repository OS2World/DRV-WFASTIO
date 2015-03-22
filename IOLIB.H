/* Copyright (C) 1995 by Holger Veit (Holger.Veit@gmd.de) */
/* Copyright (C) 1996 by  Alger Pike ( Alger@avenger.mri.psu.edu) */
/* Use at your own risk! No Warranty! The author(s) is not responsible for
 * any damage or loss of data caused by proper or improper use of this
 * device driver or related software
 */

#ifndef _IOLIB_H
#define _IOLIB_H

#if     defined(__BORLANDC__)
#define _LINKAGE _cdecl
#endif

#if defined (__WATCOMC__)

  #define _LINKAGE _System
  #pragma aux io_init parm [] caller reverse;
  #pragma aux c_inb parm [] caller reverse;
  #pragma aux c_inw parm [] caller reverse;
  #pragma aux c_inl parm [] caller reverse;
  #pragma aux c_outb parm [] caller reverse;
  #pragma aux c_outw parm [] caller reverse;
  #pragma aux c_outl parm [] caller reverse;
#endif

#ifdef __IBMC__
  #define _LINKAGE _System
#endif

//Globals from Assembler routine
extern unsigned short gdt;

//Function prototypes from assmebler routine
int _LINKAGE io_init(void);
char _LINKAGE c_inb(short port);
short _LINKAGE c_inw(short port);
long _LINKAGE c_inl(short port);
void _LINKAGE c_outb(short port, unsigned char value);
void _LINKAGE c_outb(short port, short data);
void _LINKAGE c_outl(short port, long data);

#endif  /* _IOLIB_H */
