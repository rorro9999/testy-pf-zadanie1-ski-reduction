#!/usr/bin/bash

#program containing printPath function
lib="main.hs"

#temporary program that holds the reading of the trees
checker="check.hs"

cp $lib $checker

sed -i '/main/,$d' $checker


cat <<EOF >> $checker
--code by chatgpt, i won't pretend it was me
readNExprs :: Int -> IO [Expr]
readNExprs 0 = return []
readNExprs m = do
    line <- getLine               -- read one line
    let parsed = read line :: Expr
    rest <- readNExprs (m - 1)    -- read the remaining lines
    return (parsed : rest)

-- ----------------------------------------------------------------------
-- 2. Main routine
-- ----------------------------------------------------------------------
main :: IO ()
main = do
    -- 1  read how many trees we will get
    nLine <- getLine
    let n :: Int
        n = read nLine

    -- 2  read *n* trees
    exprs <- readNExprs n

    -- 3  process each one (here we just pretty‑print it)
    --       (this is a small hand‑rolled mapM_)
    let loop [] = return ()
        loop (e:es) = do
            printPath e
            loop es

    loop exprs

EOF

ghc $checker

if (($# != 0)); then
    echo "this is just compiling the checker for gen_test"
    exit 0
fi

toster ./${checker%.hs} --io small
toster ./${checker%.hs} --io medium
toster ./${checker%.hs} --io large --timeout 200
