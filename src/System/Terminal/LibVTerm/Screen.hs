module System.Terminal.LibVTerm.Screen
    ( -- * Reading the screen
      getCell
    , getGrid
    , getCursorPos
    ) where

-- \|
-- Module      : System.Terminal.LibVTerm.Screen
-- Description : Screen reading operations
-- Copyright   : (c) paolino, 2026
-- License     : MIT
--
-- Functions to read cell data from the terminal screen grid.

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Cont (ContT (..), evalContT)
import Data.Text qualified as T
import Data.Word (Word32, Word8)
import Foreign.C.Types (CInt (..))
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Array (allocaArray)
import Foreign.Ptr (Ptr)
import Foreign.Storable (Storable, peek)
import System.Terminal.LibVTerm.Raw qualified as Raw
import System.Terminal.LibVTerm.Types
    ( Cell (..)
    , CellAttrs (..)
    , Color (..)
    , Pos (..)
    , Term (..)
    )

-- | Lift 'alloca' into 'ContT'.
contAlloca :: forall a r. (Storable a) => ContT r IO (Ptr a)
contAlloca = ContT alloca

-- | Lift 'allocaArray' into 'ContT'.
contAllocaArray
    :: forall a r. (Storable a) => Int -> ContT r IO (Ptr a)
contAllocaArray n = ContT (allocaArray n)

-- | Read a single cell from the screen.
getCell :: Term -> Pos -> IO Cell
getCell Term{termPtr} Pos{posRow, posCol} = do
    screen <- Raw.c_vterm_obtain_screen termPtr
    evalContT $ do
        charsPtr <- contAllocaArray @Word32 6
        w <- contAlloca @CInt
        bo <- contAlloca @CInt
        ul <- contAlloca @CInt
        it <- contAlloca @CInt
        bl <- contAlloca @CInt
        rv <- contAlloca @CInt
        cn <- contAlloca @CInt
        st <- contAlloca @CInt
        fgT <- contAlloca @CInt
        fgR <- contAlloca @Word8
        fgG <- contAlloca @Word8
        fgB <- contAlloca @Word8
        fgI <- contAlloca @Word8
        bgT <- contAlloca @CInt
        bgR <- contAlloca @Word8
        bgG <- contAlloca @Word8
        bgB <- contAlloca @Word8
        bgI <- contAlloca @Word8
        liftIO $ do
            _ <-
                Raw.c_hs_vterm_screen_get_cell
                    screen
                    (fromIntegral posRow)
                    (fromIntegral posCol)
                    charsPtr
                    w
                    bo
                    ul
                    it
                    bl
                    rv
                    cn
                    st
                    fgT
                    fgR
                    fgG
                    fgB
                    fgI
                    bgT
                    bgR
                    bgG
                    bgB
                    bgI
            buildCell
                charsPtr
                w
                bo
                ul
                it
                bl
                rv
                cn
                st
                fgT
                fgR
                fgG
                fgB
                fgI
                bgT
                bgR
                bgG
                bgB
                bgI

-- | Read the entire screen grid as a 2D list of cells.
getGrid :: Term -> IO [[Cell]]
getGrid term@Term{termRows, termCols} =
    mapM getRow [0 .. termRows - 1]
  where
    getRow r =
        mapM
            (getCell term . Pos r)
            [0 .. termCols - 1]

-- | Get the current cursor position.
getCursorPos :: Term -> IO Pos
getCursorPos Term{termPtr} = do
    state <- Raw.c_vterm_obtain_state termPtr
    alloca $ \rowPtr ->
        alloca $ \colPtr -> do
            Raw.c_hs_vterm_state_get_cursorpos
                state
                rowPtr
                colPtr
            row <- peek rowPtr
            col <- peek colPtr
            pure
                Pos
                    { posRow = fromIntegral row
                    , posCol = fromIntegral col
                    }

-- * Internal

buildCell
    :: Ptr Word32
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr CInt
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr CInt
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> IO Cell
buildCell
    charsPtr
    widthPtr
    boldPtr
    ulPtr
    italicPtr
    blinkPtr
    revPtr
    concealPtr
    strikePtr
    fgTPtr
    fgRPtr
    fgGPtr
    fgBPtr
    fgIPtr
    bgTPtr
    bgRPtr
    bgGPtr
    bgBPtr
    bgIPtr = do
        c0 <- peek charsPtr
        width <- peek widthPtr
        bold <- peek boldPtr
        underline <- peek ulPtr
        italic <- peek italicPtr
        blink <- peek blinkPtr
        reverse' <- peek revPtr
        conceal <- peek concealPtr
        strike <- peek strikePtr
        fg <- readColor fgTPtr fgRPtr fgGPtr fgBPtr fgIPtr
        bg <- readColor bgTPtr bgRPtr bgGPtr bgBPtr bgIPtr
        let ch =
                if c0 == 0
                    then " "
                    else
                        T.singleton
                            (toEnum (fromIntegral c0))
        pure
            Cell
                { cellChars = ch
                , cellWidth = fromIntegral width
                , cellAttrs =
                    CellAttrs
                        { attrBold = bold /= 0
                        , attrUnderline =
                            fromIntegral underline
                        , attrItalic = italic /= 0
                        , attrBlink = blink /= 0
                        , attrReverse = reverse' /= 0
                        , attrConceal = conceal /= 0
                        , attrStrike = strike /= 0
                        }
                , cellFg = fg
                , cellBg = bg
                }

readColor
    :: Ptr CInt
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> Ptr Word8
    -> IO Color
readColor typePtr rPtr gPtr bPtr idxPtr = do
    t <- peek typePtr
    case t of
        1 -> do
            r <- peek rPtr
            g <- peek gPtr
            b <- peek bPtr
            pure (ColorRGB r g b)
        2 -> do
            idx <- peek idxPtr
            pure (ColorIndex idx)
        _ -> pure ColorDefault
