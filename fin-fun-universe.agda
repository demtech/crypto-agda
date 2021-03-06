module fin-fun-universe where

open import Type
open import Data.Nat using (ℕ)
open import Data.Fin using (Fin)

open import data-universe
open import fun-universe

_→ᶠ_ : ℕ → ℕ → ★
_→ᶠ_ i o = Fin i → Fin o

finFunU : FunUniverse ℕ
finFunU = Fin-U , _→ᶠ_

module FinFunUniverse = FunUniverse finFunU
