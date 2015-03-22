/************************************************************************\
**                                                                      **
**               OS/2(r) Physical Device Driver Libraries               **
**                         for Watcom C/C++ 10                          **
**                                                                      **
**  COPYRIGHT:                                                          **
**                                                                      **
**    (C) Copyright Advanced Gravis Computer Technology Ltd 1994.       **
**        All Rights Reserved.                                          **
**                                                                      **
**  DISCLAIMER OF WARRANTIES:                                           **
**                                                                      **
**    The following [enclosed] code is provided to you "AS IS",         **
**    without warranty of any kind.  You have a royalty-free right to   **
**    use, modify, reproduce and distribute the following code (and/or  **
**    any modified version) provided that you agree that Advanced       **
**    Gravis has no warranty obligations and shall not be liable for    **
**    any damages arising out of your use of this code, even if they    **
**    have been advised of the possibility of such damages.  This       **
**    Copyright statement and Disclaimer of Warranties may not be       **
**    removed.                                                          **
**                                                                      **
\************************************************************************/


// Init.c
//
// Device driver initialization
//
// Note that the initialization code is discardable, so normally this
// module would start with the code_seg and data_seg pragmas.  However,
// Watcom C++ 10 currently handles these pragmas incorrectly, so for now
// this code and data will stay resident.
//
// History:
//
// Sep 30, 94  David Bollo    Initial version

#include <devdebug.h>
#include <devhelp.h>
#include <devtype.h>
#include <devrp.h>
#include <string.h>
#include <conio.h>

// Constant debugging strings (only defined when DEBUG is defined)

#if defined(DEBUG)

static const char* MSG_DEBUG =
  "OS/2(r) Physical Device Driver Libraries\r\n"
  "Sample Driver for Watcom C/C++ 10\r\n"
  "\r\n"
  "(C) Copyright Advanced Gravis Computer Technology Ltd 1994.\r\n"
  "All Rights Reserved.\r\n"
  "Your use of this code indicates your acceptance of the\r\n"
  "Disclaimer of Warranties included with this package.\r\n"
  "\r\n"
  "Terminal Debugger Interface Installed";

static const char* MSG_CS =               "Resident Code Size = ";
static const char* MSG_DS =               "Resident Data Size = ";

#else

#define            MSG_DEBUG              0
#define            MSG_CS                 0
#define            MSG_DS                 0

#endif // DEBUG



// Sign on and installation messages

static const char WELCOME[] =
  "\r\n"
  "WFASTIO- Fast Access to I/O Ports\r\n"
  "(C) Holger Veit 1995 All Rights Reserved\r\n"
  "(C) ACP Soft 1996. All Rights Reserved.\r\n";
const int WELCOME_LENGTH = sizeof(WELCOME) - 1;

extern "C"
{
extern WORD32 Device_Help;
}

// Initialize device driver

WORD16 StratInit(RP FAR* _rp)
  {

  RPInit FAR* rp = (RPInit FAR*)_rp;
  int result=0;

//  HFILE FAR* File;

  // MANDATORY: Initialize the Device Driver libraries.
  DevInit(rp->In.DevHlp);
  Device_Help=Dev_Entry;

  // Signal that we've installed successfully by setting the size of
  // our code and data segments.
  rp->Out.FinalCS = OffsetFinalCS;
  rp->Out.FinalDS = OffsetFinalDS;

  // Print a sign on message to the debugging terminal.
  cdbg << ALL << endl;
  cdbg << MSG_DEBUG << endl;
  cdbg << MSG_CS << hex << setw(4) << OffsetFinalCS
       << setw() << dec << 'h' << endl;
  cdbg << MSG_DS << hex << setw(4) << OffsetFinalDS
       << setw() << dec << 'h' << endl;
  cdbg << endl;

  // Print a sign on message to the console.
  DosPutMessage(1, WELCOME_LENGTH, WELCOME);

  //user code

  return RPDONE;

  }

