;-----------------------------------
; Display constants
;-----------------------------------

#define DISP_WIDTH   128
#define DISP_HEIGHT   64
#define BUFFER_SIZE 1024

;-----------------------------------
; Pixel constants
;-----------------------------------

#define GFX_SET     $01
#define GFX_CLEAR   $00
#define GFX_INVERT  $80

;-----------------------------------
; Character constants
;-----------------------------------

#define C_OFFSET     32
#define C_COUNT      94
#define C_ERROR     127

#define C_WIDTH       6
#define C_HEIGHT      8

;-----------------------------------
; CURSOR_X = DISP_WIDTH - C_WIDTH
; CURSOR_Y = DISP_HEIGHT - C_HEIGHT
;-----------------------------------

#define CURSOR_X    122     
#define CURSOR_Y     56

;-----------------------------------
; Public Text background constants
;-----------------------------------

#define     GFX_BG_TRANSPARENT     0
#define     GFX_BG_OPAQUE          1
