#ifndef LIBVTERM_HASKELL_HELPERS_H
#define LIBVTERM_HASKELL_HELPERS_H

#include <vterm.h>

/* Get a cell at (row, col) and write its data into
   flat output arrays suitable for Haskell FFI. */
int hs_vterm_screen_get_cell(
    VTermScreen *screen,
    int row,
    int col,
    /* outputs */
    uint32_t *out_chars,    /* 6 uint32_t */
    int *out_width,
    /* attrs */
    int *out_bold,
    int *out_underline,
    int *out_italic,
    int *out_blink,
    int *out_reverse,
    int *out_conceal,
    int *out_strike,
    /* fg color */
    int *out_fg_type,
    uint8_t *out_fg_red,
    uint8_t *out_fg_green,
    uint8_t *out_fg_blue,
    uint8_t *out_fg_idx,
    /* bg color */
    int *out_bg_type,
    uint8_t *out_bg_red,
    uint8_t *out_bg_green,
    uint8_t *out_bg_blue,
    uint8_t *out_bg_idx
);

/* Get cursor position into row/col outputs */
void hs_vterm_state_get_cursorpos(
    VTermState *state,
    int *out_row,
    int *out_col
);

#endif
