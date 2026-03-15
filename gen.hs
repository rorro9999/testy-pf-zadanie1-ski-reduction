import System.Random

data Expr = S | K | I | B 
          | Expr :$ Expr 
          | X | Z | V Int  
          deriving (Show, Read)

--rng, prob, falloff
randomExpr :: StdGen -> Double -> Double -> (Expr, StdGen)
--generator, probability of branching (MUST SET <0.5), returns the result and changed stdgen
randomExpr gen p f
  | toss <= p = ((l :$ r), gen3) --branch
  | otherwise = (leaf, gen4)     --leaf
  where
    (toss, gen1) = randomR (0.0 :: Double, 1.0 :: Double) gen
    (l,    gen2) = randomExpr gen1 (p-f) f
    (r,    gen3) = randomExpr gen2 (p-f) f
    (leaf, gen4) = randomLeaf gen1

randomLeaf :: StdGen -> (Expr, StdGen)
randomLeaf gen =
  let (i,   gen1) = randomR (0 :: Int, 6 :: Int) gen
      (val, gen2) = randomR (0 :: Int, 30 :: Int) gen1
  in (case i of
        0 -> S
        1 -> K
        2 -> I
        3 -> B
        4 -> X
        5 -> Z
        6 -> V val
     , gen2)

giveNTrees :: Int -> StdGen -> Double -> Double -> [Expr]
giveNTress 0 gen p f = error "not reachable"
giveNTrees n gen p f =
  case n of
    1         -> [randomTree]
    otherwise -> randomTree : giveNTrees (n-1) gen1 p f
    where
      (randomTree, gen1) = randomExpr gen p f


main :: IO()

main = do
  line <- getLine
  let [nStr, seedStr, pStr, fStr] = words line
      n    = read nStr :: Int
      seed = read seedStr :: Int
      p    = read pStr :: Double
      f    = read fStr :: Double
      gen  = mkStdGen seed

  let gen = mkStdGen seed
  putStrLn (show n)
  let trees = giveNTrees n gen p f
  mapM_ (putStrLn . show) trees

