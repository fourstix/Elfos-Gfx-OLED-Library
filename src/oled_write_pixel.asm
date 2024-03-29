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
; Name: oled_write_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: 
;  r7.1 - y (line, 0 to 63)
;  r7.0 - x (pixel offset, 0 to 127)
;  r9.1 - color (GFX_SET, GFX_CLEAR, GFX_INVERT)
; Registers Used: 
;  rd - pointer to byte in buffer
;  rc.1 - bit mask            
;  rc.0 - bit counter                  
; 
; Returns: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    oled_write_pixel
            push    rd                ; save position register 
            push    rc                ; save bit mask register

            call    oled_display_ptr  ; point rd to byte in buffer

            ldi     $01               ; bit mask for vertical pixie byte
            phi     rc                ; store bit mask in rc.1
            ghi     r7                ; vertical pixel bytes, so get y position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
            
shft_bit1:  lbz     set_bit
            ghi     rc
            shl                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_bit1         ; repeat until count down to zero

set_bit:    ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store mask at M(x)
            ghi     r9                ; get color from temp register
            lbz     clr_bit           ; check for GFX_CLEAR value
            shl                       ; check for GFX_INVERT value
            lbdf    flip_bit    
            ldn     rd                ; get byte from buffer
            or                        ; OR mask to set bit
            str     rd                ; put updated byte back in buffer
            lbr     wp_done           
clr_bit:    ldi     $FF               ; invert bit mask so selected bit is zero
            xor                       ; Filp all mask bits ~(Bit Mask) 
            str     r2                ; put inverse mask in M(X)
            ldn     rd                ; get byte from buffer
            and                       ; AND inverse mask to clear bit
            str     rd                ; put updated byte back in buffer
            lbr     wp_done           
flip_bit:   ldn     rd                ; get byte from buffer
            xor                       ; XOR mask to invert bit
            str     rd                ; put updated byte back in buffer

wp_done:    pop     rc                ; restore bit register 
            pop     rd                ; restore position register

            clc                       ; Set no error
            return

            endp 
