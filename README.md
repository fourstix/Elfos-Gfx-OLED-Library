# OBSOLETE
The code in this repository was merged into the [Elf/OS SPI OLED Drivers](https://github.com/fourstix/Elfos-SPI-OLED-Drivers) repository and is now maintained there. This repository was archived.  The latest version of this code is available at [Elf/OS SPI OLED Drivers](https://github.com/fourstix/Elfos-SPI-OLED-Drivers).
 
Elfos-Gfx-OLED-Library
----------------------
An implementation of the [GFX-1802-Library](https://github.com/fourstix/GFX-1802-Library) display interface in graphics device library for an OLED display using the [Elf/OS SPI OLED](https://github.com/fourstix/Elfos-SPI-OLED-Drivers) video driver connected to an Elf/OS system, such as the 1802/Mini with an SPI adapter board.

Introduction
------------
This repository contains 1802 Assembler code for an OLED graphics library that implements the GFX Display Interface from the [GFX-1802-Library](https://github.com/fourstix/GFX-1802-Library) based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried. 

Platform  
--------
The programs were written to run displays from an [1802-Mini](https://github.com/dmadole/1802-Mini) by David Madole running with the [1802/Mini SPI adapter board](https://github.com/arhefner/1802-Mini-SPI-DMA) by Tony Hefner. These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley. The updated versions required to assemble and link this code are available at [arhefner/Asm-02](https://github.com/arhefner/Asm-02) and [arhefner/Link-02](https://github.com/arhefner/Link-02).

Supported Displays
------------------
* [SH1106 OLED display](https://github.com/fourstix/Elfos-SPI-OLED-Drivers#sh1106-display-pinout)
* [SSD1306 OLED display](https://github.com/fourstix/Elfos-SPI-OLED-Drivers#ssd1306-display-pinout)
* [SSD1309 OLED display](https://github.com/fourstix/Elfos-SPI-OLED-Drivers#ssd1309-display-pinout)

OLED SPI Library API
--------------------

## Public API List

* oled_check_driver   - verify that an oled video driver is loaded.
* oled_clear_buffer   - clear all bits in the display buffer.
* oled_fill_buffer    - set all bits in the display buffer. 
* oled_init_display   - initialize the oled display
* oled_update_display - update the oled display with the contents of the memory buffer. 
* oled_print_char     - draw a character at cursor x0,y0
* oled_print_string   - draw a null-terminated string at x0,y0


## API Notes:
* rf = pointer to null-terminated string to draw
* r7.1 = origin y (row value, 0 to 63)
* r7.0 = origin x (column value, 0 to 127)
* r9.1 = color
* r9.0 = ASCII character to draw


<table>
<tr><th>API Name</th><th colspan="2">Inputs</th><th colspan="4">Notes</th></tr>
<tr><td>oled_check_driver</td><td colspan="2"> (None) </td><td colspan="4">Checks for an OLED driver in memory, returns error (DF = 1) if no driver found.</td></tr>
<tr><td>oled_init_display</td><td colspan="2"> (None) </td><td colspan="4">Initialize the SPI OLED display, returns error (DF = 1) if initialization failed.</td></tr>
<tr><td>oled_update_display</td><td colspan="2"> (None) </td><td colspan="4">Update the SPI OLED display with the contents of the display buffer, returns error (DF = 1) if update failed.</td></tr>
<tr><td>oled clear_buffer</td><td colspan="2"> (None) </td><td colspan="4">Clears all bits in the buffer memory</td></tr>
<tr><td>fill_buffer</td><td colspan="2"> (None) </td><td colspan="4">Sets all bits in the buffer memory</td></tr>
<tr><th rowspan="2">API Name</th><th>R7.1</th><th>R7.0</th><th>R9.1</th><th>R9.0</th><th colspan="2">RF</th></tr>
<tr><th colspan="6">Notes</th></tr>
<tr><td rowspan="2">oled_print_char</td><td>origin y</td><td>origin x</td><td>text style</td><td>character</td><th colspan="2">-</th></tr>
<tr><td colspan="6">Checks origin x,y values, returns error (DF = 1) if out of bounds. Checks ASCII character value, draws DEL (127) if non-printable.<br> On return r7 points to next character cursor position (text wraps).</td></tr>
<tr><td rowspan="2">oled_print_string</td><td>origin y</td><td> origin x</td><td>text style</td><td>-</td><td colspan="2">Pointer to null terminated ASCII string.</td></tr>
<tr><td colspan="6">Checks origin x,y values, returns error (DF = 1) if out of bounds. Checks ASCII character value, draws DEL (127) if non-printable.<br> On return r7 points to next character cursor position (text wraps).</td></tr>
</table>

## Color Constants
<table>
<tr><th>Name</th><th>Description</th><tr>
<tr><td>GFX_SET</td><td>Set Pixel (On)</td><tr>
<tr><td>GFX_CLEAR</td><td>Clear Pixel (Off)</td><tr>
<tr><td>GFX_INVERT</td><td>Flip Pixel State</td><tr>
</table>

## Text Constants
<table>
<tr><th>Name</th><th>Description</th><tr>
<tr><td>GFX_TXT_NORMAL</td><td>Background pixels are cleared and character pixels are set</td><tr>
<tr><td>GFX_TXT_INVERSE</td><td>Background pixels are set and character pixels are clear</td><tr>
<tr><td>GFX_TXT_OVERLAY</td><td>Background pixels unchanged and character pixels are inverted</td><tr>
</table>

## Private Methods
* oled_display_buffer - memory buffer for the SPI OLED display
* oled_display_ptr    - returns a pointer to a particular x,y pixel location in the display buffer
* oled_fill_bg        - fill in the background color for a character printed to the display 

GFX Display Interface
---------------------
The following methods are implemented in this library, oled_spi.lib, and are called by methods in the gfx library gfx.lib.  These methods encapsulate the SPI OLED specific details.  The source file gfx_display.asm contains the logic so that when a GFX display interface method is called it delegates to the appropriate SPI OLED private method.

## GFX Interface Methods

* gfx_disp_size   - return the height and width of the display.
* gfx_disp_clear  - set the memory buffer data to clear all pixels.
* gfx_disp_pixel  - set the data in the memory buffer corresponding to a particular x,y co-ordinates in the display.
* gfx_disp_h_line - set the data in the memory buffer for a horizontal line.
* gfx_disp_v_line - set the data in the memory buffer for a vertical line

## GFX Display Interface SPI OLED Methods

<table>
<tr><th>Interface Method</th><th>SPI OLED Method</th></tr>
<tr><td>gfx_disp_size</td><td>(code in gfx_display)</td></tr>
<tr><td>gfx_disp_clear</td><td>oled_clear_buffer</td></tr>
<tr><td>gfx_disp_pixel</td><td>oled_write_pixel</td></tr>
<tr><td>gfx_disp_h_line</td><td>oled_fast_h_line</td></tr>
<tr><td>gfx_disp_v_line</td><td>oled_fast_v_line</td></tr>
</table>

## Interface Registers:
* ra.1 = display height 
* ra.0 = display width
* r9.1 = color
* r9.0 = line length
* r7.1 = origin y (row value, 0 to display height-1)
* r7.0 = origin x (column value, 0 to display width-1)

<table>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R9.1</th><th>R9.0</th><th>Returns</th></tr>
<tr><td rowspan="2">gfx_disp_size</th><td rowspan="2" colspan="4">(No Inputs)</td><td>RA.1 = device height</td></tr>
<tr><td>RA.0 = display width</td></tr>
<tr><td>oled_clear_buffer</th><td colspan="4">(No Inputs)</td><td>DF = 1, if error</td></tr>
<tr><td>oled_write_pixel</td><td>y</td><td>x</td><td>color</td><td> - </td><td>DF = 1, if error</td></tr>
<tr><td>oled_fast_h_line</td><td>origin y</td><td>origin x</td><td>color</td><td>length</td><td>DF = 1, if error</td></tr>
<tr><td>oled_fast_v_line</td><td>origin y</td><td>origin x</td><td>color</td><td>length</td><td>DF = 1, if error</td></tr>
</table>

Repository Contents
-------------------
* **/src/**  -- Source files for the Elfo/OS Graphics OLED library.
  * *.asm - Assembly source files for library functions.
  * build.bat - Windows batch file to assemble and create the gfx_oled graphics library. Replace [Your_Path] with the correct path information for your system. 
  * clean.bat - Windows batch file to delete the gfx_oled library and its associated files.    
* **/include/**  -- Include files for the Elfo/OS Graphics OLED library.  
  * oled_spi_lib.inc - Definitions for SPI OLED library public methods.
  * oled_spi_def.inc - Definitions for SPI OLED private library methods.
  * gfx_display.inc - Definitions required for the GFX Display Interface.
  * gfx_lib.inc - GFX 1802 Library public method definitions
  * ops.inc - Opcode definitions for Asm/02.
* **/lib/**  -- Library files for the Elf/OS OLED graphics routines.
  * oled_spi.lib - SPI OLED GFX device library. The source files for library functions are in the */src/* directory.
  * gfx.lib - Common [GFX 1802 library.](https://github.com/fourstix/GFX-1802-Library)
  
License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Adafruit, the Adafruit logo, and other Adafruit products and services are
trademarks of the Adafruit Industries, in the United States, other countries or both. 

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on code written by Tony Hefner and assembled with the Asm/02 assembler and Link/02 linker written by Mike Riley.

Elf/OS  
Copyright (c) 2004-2023 by Mike Riley

Asm/02 1802 Assembler  
Copyright (c) 2004-2023 by Mike Riley

Link/02 1802 Linker  
Copyright (c) 2004-2023 by Mike Riley

The Adafruit_GFX Library  
Copyright (c) 2012-2023 by Adafruit Industries   
Written by Limor Fried/Ladyada for Adafruit Industries. 

The 1802/Mini SPI Adapter Board   
Copyright (c) 2022-2023 by Tony Hefner

The 1802-Mini Microcomputer Hardware   
Copyright (c) 2020-2023 by David Madole

Many thanks to the original authors for making their designs and code available as open source.
 
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2023 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
