module program-distance where

open import flipbased-implem
open import Data.Bits
open import Data.Bool
open import Data.Vec.NP using (Vec; count)
open import Data.Nat.NP
open import Relation.Binary
open import Relation.Binary.PropositionalEquality
open import diff
import Data.Fin as Fin

record PrgDist : Set₁ where
  constructor mk
  field
    _]-[_ : ∀ {c} (f g : ↺ c Bit) → Set
    ]-[-cong : ∀ {c} {f f' g g' : ↺ c Bit} → f ≗↺ g → f' ≗↺ g' → f ]-[ f' → g ]-[ g'

  breaks : ∀ {c} (EXP : Bit → ↺ c Bit) → Set
  breaks ⅁ = ⅁ 0b ]-[ ⅁ 1b

  _≗⅁_ : ∀ {c} (⅁₀ ⅁₁ : Bit → ↺ c Bit) → Set
  ⅁₀ ≗⅁ ⅁₁ = ∀ b → ⅁₀ b ≗↺ ⅁₁ b

  ≗⅁-trans : ∀ {c} → Transitive (_≗⅁_ {c})
  ≗⅁-trans p q b R = trans (p b R) (q b R)

  -- An wining adversary for game ⅁₀ reduces to a wining adversary for game ⅁₁
  _⇓_ : ∀ {c₀ c₁} (⅁₀ : Bit → ↺ c₀ Bit) (⅁₁ : Bit → ↺ c₁ Bit) → Set
  ⅁₀ ⇓ ⅁₁ = breaks ⅁₀ → breaks ⅁₁

  extensional-reduction : ∀ {c} {⅁₀ ⅁₁ : Bit → ↺ c Bit}
                          → ⅁₀ ≗⅁ ⅁₁ → ⅁₀ ⇓ ⅁₁
  extensional-reduction same-games = ]-[-cong (same-games 0b) (same-games 1b)

ext-count : ∀ {n a} {A : Set a} {f g : A → Bool} → f ≗ g → (xs : Vec A n) → count f xs ≡ count g xs
ext-count f≗g [] = refl
ext-count f≗g (x ∷ xs) rewrite ext-count f≗g xs | f≗g x = refl

ext-# : ∀ {c} {f g : Bits c → Bit} → f ≗ g → #⟨ f ⟩ ≡ #⟨ g ⟩
ext-# f≗g = ext-count f≗g (allBits _)

count↺ : ∀ {c} → ↺ c Bit → ℕ
count↺ f = Fin.toℕ #⟨ run↺ f ⟩

module Implem k where
  --  | Pr[ f ≡ 1 ] - Pr[ g ≡ 1 ] | ≥ ε            [ on reals ]
  --  dist Pr[ f ≡ 1 ] Pr[ g ≡ 1 ] ≥ ε             [ on reals ]
  --  dist (#1 f / 2^ c) (#1 g / 2^ c) ≥ ε          [ on reals ]
  --  dist (#1 f) (#1 g) ≥ ε * 2^ c where ε = 2^ -k [ on rationals ]
  --  diff (#1 f) (#1 g) ≥ 2^(-k) * 2^ c            [ on rationals ]
  --  diff (#1 f) (#1 g) ≥ 2^(c - k)                [ on rationals ]
  --  diff (#1 f) (#1 g) ≥ 2^(c ∸ k)               [ on natural ]
  _]-[_ : ∀ {c} (f g : ↺ c Bit) → Set
  _]-[_ {c} f g = diff (count↺ f) (count↺ g) ≥ 2^(c ∸ k)

  ]-[-cong : ∀ {c} {f f' g g' : ↺ c Bit} → f ≗↺ g → f' ≗↺ g' → f ]-[ f' → g ]-[ g'
  ]-[-cong f≗g f'≗g' f]-[f' rewrite ext-# f≗g | ext-# f'≗g' = f]-[f'

  prgDist : PrgDist
  prgDist = mk _]-[_ ]-[-cong