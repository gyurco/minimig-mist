
/* Memory Definitions for a ZPU program running from boot / stack RAM
   but placing variables within external RAM.
   (Example assumes 4k of RAM is available at 0x7ff000) */

MEMORY
{
  BOOT (rx) : ORIGIN = 0x00000000, LENGTH = 0x00000100 /* Boot section contains just the initial jump */
  TRAP (rx) : ORIGIN = 0x00000100, LENGTH = 0x00000000 /* Dummy region to ensure we don't have any Initialized writable data */
  CODE (rx) : ORIGIN = 0x00000100, LENGTH = 0x0000fff8 /* Up to the end of the first 4K */
  EXRAM (rw)  : ORIGIN = 0x0007f000, LENGTH = 0x00001000 /* 4k at top end of 512k of SDRAM */
}


/* Section Definitions */

SECTIONS
{
  /* first section is .fixed_vectors which is used for startup code */
  . = 0x0000000;
  .fixed_vectors :
  {
    KEEP(*(.fixed_vectors*)) /* Seed section, allows -gc-sections */
  }>BOOT

  /* Remaining code sections */
  .text :
  {
	. = ALIGN(4);
    *(.text)                   /* remaining code */
    *(.text.*)                   /* remaining code */
  } >CODE

  .code :
  {
	. = ALIGN(4);
    *(.code)                   /* remaining code */
    *(.code.*)                   /* remaining code */
  } >CODE


  /* .rodata section which is used for read-only data (constants) */
  .rodata :
  {
    *(.rodata)
    *(.rodata.*)
  . = ALIGN(4);
  } >CODE
  _romend = . ;

  /* .data section which is used for initialized data.
     Since we don't want any writable data within the ROM
     itself, we put this stuff in a "trap" section. */
  .data :
  {
    _data = . ;
    *(.data)
    *(.data.*)
    SORT(CONSTRUCTORS)
    . = ALIGN(4);
  } >TRAP

  /* .bss section which is used for uninitialized data */
  .bss :
  {
    __bss_start = . ;
    __bss_start__ = . ;
    *(.bss)
    *(.bss.*)
    *(COMMON)
    . = ALIGN(4);
  } >EXRAM
  __bss_end__ = . ;
  stack_top = 0x7fffe;
  prg_start = 0x2000;
}

