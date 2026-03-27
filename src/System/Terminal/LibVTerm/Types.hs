module System.Terminal.LibVTerm.Types
    ( -- * Terminal handle
      Term (..)

      -- * Cell data
    , Cell (..)
    , CellAttrs (..)
    , Color (..)
    , Pos (..)

      -- * Keys
    , Key (..)
    , Modifier (..)
    , modNone
    , modShift
    , modAlt
    , modCtrl
    ) where

-- \|
-- Module      : System.Terminal.LibVTerm.Types
-- Description : Types for the libvterm Haskell bindings
-- Copyright   : (c) paolino, 2026
-- License     : MIT
--
-- Data types representing terminal state, cells, colors,
-- keys, and modifiers.

import Data.Bits (Bits (..))
import Data.Text (Text)
import Data.Word (Word8)
import Foreign.Ptr (Ptr)
import System.Terminal.LibVTerm.Raw qualified as Raw

-- | Handle to a libvterm terminal instance.
data Term = Term
    { termPtr :: Ptr Raw.VTerm
    -- ^ raw pointer to the C terminal
    , termRows :: Int
    -- ^ number of rows
    , termCols :: Int
    -- ^ number of columns
    }

-- | Position on the terminal grid.
data Pos = Pos
    { posRow :: Int
    -- ^ row (0-indexed from top)
    , posCol :: Int
    -- ^ column (0-indexed from left)
    }
    deriving stock (Show, Eq, Ord)

-- | Color representation.
data Color
    = -- | 24-bit RGB color
      ColorRGB Word8 Word8 Word8
    | -- | indexed palette color (0-255)
      ColorIndex Word8
    | -- | default foreground or background
      ColorDefault
    deriving stock (Show, Eq)

-- | Text attributes for a cell.
data CellAttrs = CellAttrs
    { attrBold :: Bool
    , attrUnderline :: Int
    -- ^ 0=off, 1=single, 2=double, 3=curly
    , attrItalic :: Bool
    , attrBlink :: Bool
    , attrReverse :: Bool
    , attrConceal :: Bool
    , attrStrike :: Bool
    }
    deriving stock (Show, Eq)

-- | A single cell on the terminal screen.
data Cell = Cell
    { cellChars :: Text
    -- ^ characters in this cell (may include combining)
    , cellWidth :: Int
    -- ^ display width (1 for normal, 2 for wide)
    , cellAttrs :: CellAttrs
    -- ^ text attributes
    , cellFg :: Color
    -- ^ foreground color
    , cellBg :: Color
    -- ^ background color
    }
    deriving stock (Show, Eq)

-- | Keyboard keys.
data Key
    = KeyChar Char
    | KeyEnter
    | KeyTab
    | KeyBackspace
    | KeyEscape
    | KeyUp
    | KeyDown
    | KeyLeft
    | KeyRight
    | KeyInsert
    | KeyDelete
    | KeyHome
    | KeyEnd
    | KeyPageUp
    | KeyPageDown
    | KeyFunction Int
    deriving stock (Show, Eq, Ord)

-- | Keyboard modifier flags, combined with '(<>)'.
newtype Modifier = Modifier {unModifier :: Int}
    deriving stock (Show, Eq)
    deriving newtype (Bits)

instance Semigroup Modifier where
    Modifier a <> Modifier b = Modifier (a .|. b)

instance Monoid Modifier where
    mempty = Modifier 0

-- | No modifier.
modNone :: Modifier
modNone = Modifier 0

-- | Shift key.
modShift :: Modifier
modShift = Modifier 1

-- | Alt key.
modAlt :: Modifier
modAlt = Modifier 2

-- | Ctrl key.
modCtrl :: Modifier
modCtrl = Modifier 4
