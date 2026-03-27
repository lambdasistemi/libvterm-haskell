module System.Terminal.LibVTerm
    ( -- * Terminal lifecycle
      withTerm
    , newTerm
    , freeTerm
    , resizeTerm

      -- * Writing to the terminal
    , feedInput

      -- * Reading output (escape sequences for PTY)
    , readOutput

      -- * Screen
    , getCell
    , getGrid
    , getCursorPos

      -- * Keyboard
    , sendKey

      -- * Types (re-exported)
    , Term (..)
    , Cell (..)
    , CellAttrs (..)
    , Color (..)
    , Pos (..)
    , Key (..)
    , Modifier (..)
    , modNone
    , modShift
    , modAlt
    , modCtrl
    ) where

-- \|
-- Module      : System.Terminal.LibVTerm
-- Description : High-level Haskell interface to libvterm
-- Copyright   : (c) paolino, 2026
-- License     : MIT
--
-- Create virtual terminals, feed them byte streams, and read back
-- the resulting character grid with full color and attribute
-- information. Useful for embedding terminal emulation in Haskell
-- applications.
--
-- @
-- import System.Terminal.LibVTerm
--
-- main :: IO ()
-- main = withTerm 24 80 $ \\term -> do
--     feedInput term "Hello, world!\\r\\n"
--     grid <- getGrid term
--     mapM_ (putStrLn . show) grid
-- @

import Control.Exception (bracket)
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.ByteString.Unsafe (unsafeUseAsCStringLen)
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Ptr (castPtr)
import System.Terminal.LibVTerm.Keyboard (sendKey)
import System.Terminal.LibVTerm.Raw qualified as Raw
import System.Terminal.LibVTerm.Screen
    ( getCell
    , getCursorPos
    , getGrid
    )
import System.Terminal.LibVTerm.Types
    ( Cell (..)
    , CellAttrs (..)
    , Color (..)
    , Key (..)
    , Modifier (..)
    , Pos (..)
    , Term (..)
    , modAlt
    , modCtrl
    , modNone
    , modShift
    )

-- | Create a new terminal with the given dimensions.
newTerm
    :: Int
    -- ^ rows
    -> Int
    -- ^ columns
    -> IO Term
newTerm rows cols = do
    ptr <-
        Raw.c_vterm_new
            (fromIntegral rows)
            (fromIntegral cols)
    Raw.c_vterm_set_utf8 ptr 1
    screen <- Raw.c_vterm_obtain_screen ptr
    Raw.c_vterm_screen_reset screen 1
    Raw.c_vterm_screen_enable_altscreen screen 1
    Raw.c_vterm_screen_set_damage_merge screen 2
    pure
        Term
            { termPtr = ptr
            , termRows = rows
            , termCols = cols
            }

-- | Free a terminal. Do not use the 'Term' after this.
freeTerm :: Term -> IO ()
freeTerm Term{termPtr} = Raw.c_vterm_free termPtr

-- | Bracket-style terminal creation and cleanup.
withTerm
    :: Int
    -- ^ rows
    -> Int
    -- ^ columns
    -> (Term -> IO a)
    -> IO a
withTerm rows cols = bracket (newTerm rows cols) freeTerm

-- | Resize the terminal.
resizeTerm :: Term -> Int -> Int -> IO Term
resizeTerm term@Term{termPtr} rows cols = do
    Raw.c_vterm_set_size
        termPtr
        (fromIntegral rows)
        (fromIntegral cols)
    pure term{termRows = rows, termCols = cols}

{- | Feed raw bytes into the terminal (as if received from
a PTY). The terminal state machine will interpret escape
sequences and update the screen grid.
-}
feedInput :: Term -> ByteString -> IO ()
feedInput Term{termPtr} bs =
    unsafeUseAsCStringLen bs $ \(ptr, len) -> do
        _ <-
            Raw.c_vterm_input_write
                termPtr
                ptr
                (fromIntegral len)
        pure ()

{- | Read pending output bytes from the terminal. These are
the escape sequences generated in response to keyboard
input, which should be written to the PTY.
-}
readOutput :: Term -> IO ByteString
readOutput Term{termPtr} =
    allocaBytes 4096 $ \buf -> do
        n <-
            Raw.c_vterm_output_read
                termPtr
                (castPtr buf)
                4096
        BS.packCStringLen (castPtr buf, fromIntegral n)
