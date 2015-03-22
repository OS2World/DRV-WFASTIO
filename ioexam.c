
/* Released to the public domain
 * Use this code freely for own developments
 */

/* This program uses the new wfastio$ device for 32 bit I/O access.
 * It is assumed to be faster than the traditional method of using
 * a 16 bit IOPL DLL, and BTW, it does not need such a DLL.
 *
 * This example demonstrates the in and out instructions by reading
 * out the CRT registers of a CGA/EGA/VGA/SVGA adapter. Some rare
 * display adapters are not VGA compatible. In this case this example
 * could fail. Note you should be able to run the program either in
 * a windowed PM session as well as in fullscreen. See the difference.
 */

#include <stdio.h>
#define INCL_DOSFILEMGR
#define INCL_DOS
#define INCL_DOSDEVICES
#define INCL_DOSDEVIOCTL
#define INCL_ERRORS
#include <os2.h>
#include <stdio.h>

#include <iolib.h>

HFILE 	 driver_handle=0;
USHORT      err;
UCHAR        far *myptr=0;
USHORT      ActionTaken;

int plen;
extern unsigned short gdt;


int main(int argc,char*argv[])
{
	int rc;
	int i;
	int base, port;
	unsigned int regs[19];

	/* initialize the I/O once */
        printf("i = %d: io_init()", gdt);
        if ((rc = DosOpen((PSZ) "wfastio$",
        &driver_handle,
        &ActionTaken,
        0,
        0,
        FILE_OPEN,
        OPEN_SHARE_DENYNONE | OPEN_ACCESS_READWRITE,
        NULL)) !=0)
		  {
                  printf("\nDosOpen failed, error = %d",rc);
                  getchar();
        	  DosExit(EXIT_PROCESS,0);
		  }
       plen = sizeof(gdt);
       rc=DosDevIOCtl(driver_handle, 0x76, 0x60,0,0,0,&gdt, plen, &plen);
       printf("Have gdt = %p\n", gdt);
       rc = io_init();
       printf("\n Have gdt after init pointer = %p\n", gdt);
       printf("\n Have gdt after init decimal = %d\n", gdt);


       DosClose(driver_handle);
        
	if (rc) {
		fprintf(stderr,"Error %d %d calling io_init\n",Gate.ioentry, Gate.gdt);
                getchar();
		exit(1);
	}

	/* warn the user */
	fprintf(stderr, "This example will read out the VGA CRT registers\n");
	fprintf(stderr, "If you don't have a VGA or SVGA compatible adapter\n");
	fprintf(stderr, "or are not sure, press CTRL-C now. Otherwise\n");
	fprintf(stderr, "proceed with RETURN\n");
	//getchar();

	/* This checks whether the VGA card is in mono or color mode */
	base = c_inb(0x3cc) & 1;
        printf("\n return from inb = %d", base);
	printf("\n\nThe VGA card is in %s mode\n", base ? "COLOR" : "MONO");
       //getchar();
	/* depending on the mode, the registers are a address 0x3d4 or 0x3b4 */
	port = base ? 0x3d4 : 0x3b4;
        getchar();
	/* read the CRT registers */
	for (i=0; i<0x19; i++) {
		c_outb(port, i);		/* address the index register */
		base  = c_inb(port+1) & 0xff;	/* read the data register */
                regs[i] = base;
	}
        
	/* print the result */
	for (i=0; i<0x19; i++)
        printf("CRT Register %2d = 0x%02X\n",i,regs[i]);
        getchar();
        exit(0);
}

