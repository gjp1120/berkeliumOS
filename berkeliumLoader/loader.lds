/*
 * BerkeLiumOS
 *
 * BootLoader Linker Script
 *
 *
 */

SECTIONS
{
  . = 0x7c00;
  .text :
  {
    _ftext = .;     /* Program will be loaded to 0x7c00. */
  } = 0
}
