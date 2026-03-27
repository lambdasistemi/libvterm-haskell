# libvterm-haskell Constitution

## Core Principles

### I. FFI Correctness
Safe, correct Haskell FFI bindings to libvterm-neovim. Memory safety is paramount: all C resources must be properly allocated and freed. Bracket patterns for resource management. No leaking pointers or handles.

### II. Pure Core / Impure Shell
Expose a high-level pure Haskell API where possible. Low-level FFI calls are internal; the public API should feel idiomatic to Haskell users. Types module defines pure data types, Raw module contains FFI internals.

### III. Test-First
Unit tests validate FFI bindings work correctly: terminal creation, input feeding, screen reading. Tests must run in CI without a real terminal. Property-based testing where applicable.

### IV. Hackage-Ready
Package must pass `cabal check` at all times. Haddock on all exports. Synopsis under 80 chars. `base` upper-bounded. `-Werror` behind a manual cabal flag, enabled only in nix builds.

### V. Nix-First Build
All build tools provided by `flake.nix`. CI and local dev use the same nix shell. No tool installation outside nix. `just` recipes assume `nix develop` environment.

## Domain Constraints

- Upstream dependency: libvterm-neovim (C library, provided by nixpkgs)
- FFI bindings use `Foreign.C` types and `Foreign.Ptr` for C interop
- The library targets GHC 9.8.x via haskell.nix
- No runtime dependencies beyond base, bytestring, text, transformers

## Development Workflow

- PRs required for all changes, linear history via rebase merge
- CI gates: build, test, formatting (fourmolu), hlint, cabal-check, haddock
- Build Gate pattern: single nix build gate job populates store before parallel jobs
- Conventional Commits for version bumps via release-please
- Small focused commits, one concern per commit

## Governance

Constitution supersedes ad-hoc practices. Amendments require documentation and rationale.

**Version**: 1.0.0 | **Ratified**: 2026-03-27
