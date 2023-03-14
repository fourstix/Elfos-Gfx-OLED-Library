;-------------------------------------------------------------------------------
; gfx_oled - a library for basic graphics functions useful 
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
#include    include/ops.inc
#include    include/gfx_display.inc

            extrn   gfx_adj_cursor  
            extrn   gfx_clear_bg  
            extrn   gfx_write_char      

;-------------------------------------------------------
; Public routine - This routine validates the origin
;   and the next character position will wrap around
;   the display boundaries.
;-------------------------------------------------------


;---------------------------------------------------------------------
; Name: draw_char
;
; Set pixels in the display buffer to define a 6x8 
; ASCII character at position x,y.  
;
; Parameters: rf   - pointer to display buffer.
;             r7.1 - y (0 to 56) rows
;             r7.0 - x (0 to 122) columns
;             r9.1 - background (GFX_ BG_TRANSPARENT OR GFX_OPAQUE)
;             r9.0 - printable ASCII character (32 to 126)
;
; Note: Checks origin x,y values, error if out of bounds. 
;       Checks ASCII character value, draws DEL (127) if out of bounds
;                  
; Return: DF = 1 if error, 0 if no error
;         r7 will point to next cursor position (text wraps)
;---------------------------------------------------------------------
            proc    draw_char      
                  
            ;---- check for valid cursor location 
            ghi     r7              ; check y0 
            sdi     CURSOR_Y        ; y0 <= 56 
            lbnf    cursor_err      
            glo     r7              ; check x0
            sdi     CURSOR_X        ; x0 <= 122
            lbdf    cursor_ok         
cursor_err: ABEND                   ; return with error
            
            ;---- check for printable ASCII character
cursor_ok:  PUSH    r8              ; save scratch register
            PUSH    r9              ; save character register
            
            glo     r9              ; ASCII char in r9.0
            smi     C_OFFSET        ; space is 32 ($20)
            lbnf    char_err
            sdi     C_COUNT         ; 126 - 32 = 94 ($5E)
            lbdf    char_ok         ; c <= 126, c is printable            
char_err:   ldi     C_ERROR         ; load error character (DEL)
            plo     r9              ; show this instead
            
            ;---- clear background if GFX_OPAQUE
char_ok:    ghi     r9              ; do we need to clear background
            lbz     write_char      ; GFX_BG_TRANSPARENT = 0
            ldi     C_WIDTH         ; character is 6 pixels wide
            phi     r9              ; set size for clearing background
            CALL    gfx_clear_bg

write_char: CALL    gfx_write_char  ; write the character to display
            CALL    gfx_adj_cursor  ; adjust to next x,y position
            
            POP     r9              ; restore registers
            POP     r8
            CLC                     ; clear df flag to indicate okay
            RETURN               
            endp
