module Main (main) where

-- \|
-- Module      : Main
-- Description : Unit tests for libvterm-haskell
-- Copyright   : (c) paolino, 2026
-- License     : MIT
--
-- Tests for the libvterm Haskell FFI bindings.

import Data.ByteString.Char8 qualified as BS
import System.Terminal.LibVTerm
    ( Cell (..)
    , Pos (..)
    , feedInput
    , getCell
    , getCursorPos
    , getGrid
    , withTerm
    )
import Test.Hspec
    ( describe
    , hspec
    , it
    , shouldBe
    )

main :: IO ()
main = hspec $ do
    describe "terminal lifecycle" $ do
        it "creates and frees a terminal" $ do
            withTerm 24 80 $ \_ -> pure ()

    describe "feedInput and getCell" $ do
        it "writes text and reads it back" $ do
            withTerm 24 80 $ \term -> do
                feedInput term (BS.pack "Hello")
                cell <- getCell term (Pos 0 0)
                cellChars cell `shouldBe` "H"

        it "reads multiple characters" $ do
            withTerm 24 80 $ \term -> do
                feedInput term (BS.pack "ABC")
                a <- getCell term (Pos 0 0)
                b <- getCell term (Pos 0 1)
                c <- getCell term (Pos 0 2)
                map cellChars [a, b, c]
                    `shouldBe` ["A", "B", "C"]

    describe "cursor" $ do
        it "tracks cursor position after input" $ do
            withTerm 24 80 $ \term -> do
                feedInput term (BS.pack "Hi")
                pos <- getCursorPos term
                posRow pos `shouldBe` 0
                posCol pos `shouldBe` 2

        it "moves to next line on newline" $ do
            withTerm 24 80 $ \term -> do
                feedInput term (BS.pack "Hi\r\n")
                pos <- getCursorPos term
                posRow pos `shouldBe` 1
                posCol pos `shouldBe` 0

    describe "getGrid" $ do
        it "returns correct number of rows and columns" $
            do
                withTerm 4 10 $ \term -> do
                    grid <- getGrid term
                    length grid `shouldBe` 4
                    all ((== 10) . length) grid
                        `shouldBe` True
