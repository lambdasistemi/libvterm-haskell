#include "helpers.h"
#include <string.h>

int hs_vterm_screen_get_cell(
    VTermScreen *screen,
    int row,
    int col,
    uint32_t *out_chars,
    int *out_width,
    int *out_bold,
    int *out_underline,
    int *out_italic,
    int *out_blink,
    int *out_reverse,
    int *out_conceal,
    int *out_strike,
    int *out_fg_type,
    uint8_t *out_fg_red,
    uint8_t *out_fg_green,
    uint8_t *out_fg_blue,
    uint8_t *out_fg_idx,
    int *out_bg_type,
    uint8_t *out_bg_red,
    uint8_t *out_bg_green,
    uint8_t *out_bg_blue,
    uint8_t *out_bg_idx)
{
    VTermPos pos = { .row = row, .col = col };
    VTermScreenCell cell;
    memset(&cell, 0, sizeof(cell));

    int ret = vterm_screen_get_cell(screen, pos, &cell);

    for (int i = 0; i < VTERM_MAX_CHARS_PER_CELL; i++) {
        out_chars[i] = cell.chars[i];
    }
    *out_width     = cell.width;
    *out_bold      = cell.attrs.bold;
    *out_underline = cell.attrs.underline;
    *out_italic    = cell.attrs.italic;
    *out_blink     = cell.attrs.blink;
    *out_reverse   = cell.attrs.reverse;
    *out_conceal   = cell.attrs.conceal;
    *out_strike    = cell.attrs.strike;

    /* foreground */
    if (VTERM_COLOR_IS_DEFAULT_FG(&cell.fg)) {
        *out_fg_type = 0; /* default */
    } else if (VTERM_COLOR_IS_INDEXED(&cell.fg)) {
        *out_fg_type = 2; /* indexed */
        *out_fg_idx = cell.fg.indexed.idx;
    } else {
        *out_fg_type = 1; /* rgb */
        *out_fg_red   = cell.fg.rgb.red;
        *out_fg_green = cell.fg.rgb.green;
        *out_fg_blue  = cell.fg.rgb.blue;
    }

    /* background */
    if (VTERM_COLOR_IS_DEFAULT_BG(&cell.bg)) {
        *out_bg_type = 0;
    } else if (VTERM_COLOR_IS_INDEXED(&cell.bg)) {
        *out_bg_type = 2;
        *out_bg_idx = cell.bg.indexed.idx;
    } else {
        *out_bg_type = 1;
        *out_bg_red   = cell.bg.rgb.red;
        *out_bg_green = cell.bg.rgb.green;
        *out_bg_blue  = cell.bg.rgb.blue;
    }

    return ret;
}

void hs_vterm_state_get_cursorpos(
    VTermState *state,
    int *out_row,
    int *out_col)
{
    VTermPos pos;
    vterm_state_get_cursorpos(state, &pos);
    *out_row = pos.row;
    *out_col = pos.col;
}
