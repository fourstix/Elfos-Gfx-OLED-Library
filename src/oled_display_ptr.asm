;-------------------------------------------------------------------------------
; oled_spi - a library for basic graphics functions useful 
; for an oled display connected to the 1802-Mini computer via 
; the SPI Expansion Board.  These routines operate on pixels
; in a buffer used by the display.
;
;
; Copyright 2023 by Gaston Williams
;
; Based on code from the Elf-Elfos-OLED library
; Written by Tony Hefner
; Copyright 2022 by Tony Hefner
;
; Based on code from Adafruit_SH110X library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
;
; SPI Expansion Board for the 1802/Mini Computer hardware
; Copyright 2022 by Tony Hefner 
;-------------------------------------------------------------------------------
#include    ../include/ops.inc
#include    ../include/gfx_display.inc
#include    ../include/oled_spi_def.inc
            
;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: oled_display_ptr
;
; Get a pointer to the byte in the oled display buffer  
; at position x,y.
;
; Parameters: 
;   r7.1 - y (line, 0 to 63)
;   r7.0 - x (pixel offset, 0 to 127)
; Registers Used:
;   rf   - pointer to display buffer.                   
; Returns: 
;   rd - pointer to byte (x,y) in display buffer
;-------------------------------------------------------
            proc    oled_display_ptr 
            push    rf                ; save buffer ptr

            load    rf, oled_display_buffer
            load    rd, 0             ; clear position
            ghi     r7                ; get line value (0 to $3f) 
            shr                       ; shift left (page = int y/8)
            shr                        
            shr                       
            phi     rd                ; put page into high byte (rd = page * 256)
            shr16   rd                ; shift right, rd = page * DISP_WIDTH (128))
            glo     r7                ; get x (byte offset)
            str     r2                ; save in M(X)
            glo     rd                ; add x to page * DISP_WIDTH (128)
            add                       ; D = rd + x  
            plo     rd                ; DF has carry
            ghi     rd                ; add carry into rd.1
            adci    0
            phi     rd                ; rd now has the cursor position

            glo     rd                ; add rf to rd
            str     r2                ; put in M(X)
            glo     rf          
            add                       ; add rd.0 to rf.0 
            plo     rd                ; put back into rf.0, DF = carry
            ghi     rd
            str     r2                ; put in M(X)
            ghi     rf
            adc                       ; add rd.1 to rf.1 with carry
            phi     rd                ; rd now points to byte in buffer
            
            pop     rf                ; restore buffer ptr
            return
            
            endp
