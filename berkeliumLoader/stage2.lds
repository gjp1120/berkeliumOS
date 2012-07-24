/*
 * BerkeLiumOS Loader
 *
 * Stage2 
 * Linker Script
 *
 */


SECTIONS
{
  . = 0x0100;

  .text :
    {
      _ftext = .;  /*you can also run this program in dos*/
    } = 0
}
