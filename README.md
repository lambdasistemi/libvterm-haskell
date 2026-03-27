# libvterm-haskell

Haskell FFI bindings to [libvterm](https://www.leonerd.org.uk/code/libvterm/) (neovim fork) — a VT220/xterm/ECMA-48 terminal emulator library.

## Usage

```haskell
import System.Terminal.LibVTerm

main :: IO ()
main = withTerm 24 80 $ \term -> do
    feedInput term "Hello, world!\r\n"
    cell <- getCell term (Pos 0 0)
    print (cellChars cell) -- "H"
```

## Development

```bash
nix develop
just build
just unit
just CI
```

## License

MIT
