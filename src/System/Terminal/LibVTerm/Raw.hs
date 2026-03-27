{-# LANGUAGE CApiFFI #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module System.Terminal.LibVTerm.Raw
    ( -- * Opaque types
      VTerm
    , VTermScreen
    , VTermState

      -- * Lifecycle
    , c_vterm_new
    , c_vterm_free
    , c_vterm_set_size
    , c_vterm_set_utf8

      -- * Input
    , c_vterm_input_write

      -- * Output
    , c_vterm_output_read

      -- * Screen
    , c_vterm_obtain_screen
    , c_vterm_screen_reset
    , c_vterm_screen_flush_damage
    , c_vterm_screen_enable_altscreen
    , c_vterm_screen_set_damage_merge

      -- * Screen cell (via C helper)
    , c_hs_vterm_screen_get_cell

      -- * Keyboard
    , c_vterm_keyboard_unichar
    , c_vterm_keyboard_key

      -- * State
    , c_vterm_obtain_state
    , c_vterm_state_reset

      -- * Cursor (via C helper)
    , c_hs_vterm_state_get_cursorpos
    ) where

-- \|
-- Module      : System.Terminal.LibVTerm.Raw
-- Description : Raw FFI bindings to libvterm
-- Copyright   : (c) paolino, 2026
-- License     : MIT
--
-- Low-level FFI imports from the libvterm C library. These are
-- not intended for direct use — see "System.Terminal.LibVTerm"
-- for the high-level API.

import Data.Word (Word32, Word8)
import Foreign.C.Types
    ( CChar
    , CInt (..)
    , CSize (..)
    )
import Foreign.Ptr (Ptr)

-- | Opaque handle to a libvterm terminal instance.
data VTerm

-- | Opaque handle to a libvterm screen layer.
data VTermScreen

-- | Opaque handle to a libvterm state layer.
data VTermState

-- * Lifecycle

foreign import capi "vterm.h vterm_new"
    c_vterm_new :: CInt -> CInt -> IO (Ptr VTerm)

foreign import capi "vterm.h vterm_free"
    c_vterm_free :: Ptr VTerm -> IO ()

foreign import capi "vterm.h vterm_set_size"
    c_vterm_set_size
        :: Ptr VTerm -> CInt -> CInt -> IO ()

foreign import capi "vterm.h vterm_set_utf8"
    c_vterm_set_utf8 :: Ptr VTerm -> CInt -> IO ()

-- * Input / Output

foreign import capi "vterm.h vterm_input_write"
    c_vterm_input_write
        :: Ptr VTerm -> Ptr CChar -> CSize -> IO CSize

foreign import capi "vterm.h vterm_output_read"
    c_vterm_output_read
        :: Ptr VTerm -> Ptr CChar -> CSize -> IO CSize

-- * Screen layer

foreign import capi "vterm.h vterm_obtain_screen"
    c_vterm_obtain_screen
        :: Ptr VTerm -> IO (Ptr VTermScreen)

foreign import capi "vterm.h vterm_screen_reset"
    c_vterm_screen_reset
        :: Ptr VTermScreen -> CInt -> IO ()

foreign import capi "vterm.h vterm_screen_flush_damage"
    c_vterm_screen_flush_damage
        :: Ptr VTermScreen -> IO ()

foreign import capi "vterm.h vterm_screen_enable_altscreen"
    c_vterm_screen_enable_altscreen
        :: Ptr VTermScreen -> CInt -> IO ()

foreign import capi "vterm.h vterm_screen_set_damage_merge"
    c_vterm_screen_set_damage_merge
        :: Ptr VTermScreen -> CInt -> IO ()

-- * Screen cell reading via C helper

-- Uses a C wrapper to handle VTermPos (passed by value)
-- and VTermScreenCell (complex struct) safely.

foreign import ccall "helpers.h hs_vterm_screen_get_cell"
    c_hs_vterm_screen_get_cell
        :: Ptr VTermScreen
        -> CInt
        -- ^ row
        -> CInt
        -- ^ col
        -> Ptr Word32
        -- ^ out_chars (6 elements)
        -> Ptr CInt
        -- ^ out_width
        -> Ptr CInt
        -- ^ out_bold
        -> Ptr CInt
        -- ^ out_underline
        -> Ptr CInt
        -- ^ out_italic
        -> Ptr CInt
        -- ^ out_blink
        -> Ptr CInt
        -- ^ out_reverse
        -> Ptr CInt
        -- ^ out_conceal
        -> Ptr CInt
        -- ^ out_strike
        -> Ptr CInt
        -- ^ out_fg_type (0=default, 1=rgb, 2=indexed)
        -> Ptr Word8
        -- ^ out_fg_red
        -> Ptr Word8
        -- ^ out_fg_green
        -> Ptr Word8
        -- ^ out_fg_blue
        -> Ptr Word8
        -- ^ out_fg_idx
        -> Ptr CInt
        -- ^ out_bg_type
        -> Ptr Word8
        -- ^ out_bg_red
        -> Ptr Word8
        -- ^ out_bg_green
        -> Ptr Word8
        -- ^ out_bg_blue
        -> Ptr Word8
        -- ^ out_bg_idx
        -> IO CInt

-- * Keyboard

foreign import capi "vterm.h vterm_keyboard_unichar"
    c_vterm_keyboard_unichar
        :: Ptr VTerm -> Word32 -> CInt -> IO ()

foreign import capi "vterm.h vterm_keyboard_key"
    c_vterm_keyboard_key
        :: Ptr VTerm -> CInt -> CInt -> IO ()

-- * State layer

foreign import capi "vterm.h vterm_obtain_state"
    c_vterm_obtain_state
        :: Ptr VTerm -> IO (Ptr VTermState)

foreign import capi "vterm.h vterm_state_reset"
    c_vterm_state_reset
        :: Ptr VTermState -> CInt -> IO ()

-- * Cursor position via C helper

foreign import ccall "helpers.h hs_vterm_state_get_cursorpos"
    c_hs_vterm_state_get_cursorpos
        :: Ptr VTermState
        -> Ptr CInt
        -- ^ out_row
        -> Ptr CInt
        -- ^ out_col
        -> IO ()
