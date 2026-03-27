module System.Terminal.LibVTerm.Keyboard
    ( -- * Sending keys
      sendKey
    ) where

-- \|
-- Module      : System.Terminal.LibVTerm.Keyboard
-- Description : Keyboard input for libvterm
-- Copyright   : (c) paolino, 2026
-- License     : MIT
--
-- Convert high-level key events to libvterm keyboard input.

import Foreign.C.Types (CInt (..))
import System.Terminal.LibVTerm.Raw qualified as Raw
import System.Terminal.LibVTerm.Types
    ( Key (..)
    , Modifier (..)
    , Term (..)
    )

-- | Send a key press to the terminal.
sendKey :: Term -> Key -> Modifier -> IO ()
sendKey Term{termPtr} key (Modifier m) =
    let mods = fromIntegral m :: CInt
    in  case key of
            KeyChar c ->
                Raw.c_vterm_keyboard_unichar
                    termPtr
                    (fromIntegral (fromEnum c))
                    mods
            KeyEnter ->
                Raw.c_vterm_keyboard_key termPtr 1 mods
            KeyTab ->
                Raw.c_vterm_keyboard_key termPtr 2 mods
            KeyBackspace ->
                Raw.c_vterm_keyboard_key termPtr 3 mods
            KeyEscape ->
                Raw.c_vterm_keyboard_key termPtr 4 mods
            KeyUp ->
                Raw.c_vterm_keyboard_key termPtr 5 mods
            KeyDown ->
                Raw.c_vterm_keyboard_key termPtr 6 mods
            KeyLeft ->
                Raw.c_vterm_keyboard_key termPtr 7 mods
            KeyRight ->
                Raw.c_vterm_keyboard_key termPtr 8 mods
            KeyInsert ->
                Raw.c_vterm_keyboard_key termPtr 9 mods
            KeyDelete ->
                Raw.c_vterm_keyboard_key termPtr 10 mods
            KeyHome ->
                Raw.c_vterm_keyboard_key termPtr 11 mods
            KeyEnd ->
                Raw.c_vterm_keyboard_key termPtr 12 mods
            KeyPageUp ->
                Raw.c_vterm_keyboard_key termPtr 13 mods
            KeyPageDown ->
                Raw.c_vterm_keyboard_key termPtr 14 mods
            KeyFunction n ->
                Raw.c_vterm_keyboard_key
                    termPtr
                    (256 + fromIntegral n)
                    mods
