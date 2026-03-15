#!/usr/bin/bash

trap "echo 'Ctrl+C pressed, killing all background jobs'; kill 0; exit" SIGINT

rm -rf small medium large

ghc gen

mkdir -p small
for((i=0;i<1000;++i));do
    echo "10 $i 0.45 0.08" | ./gen  > small/$i.in &
done

mkdir -p medium
for((i=0+2137;i<1000+2137;++i));do
    echo "10 $i 0.8 0.05" | ./gen  > medium/$i.in &
done

mkdir -p large
for((i=10000;i<10010;++i));do
    echo "10 $i 0.6 0.01" | ./gen  > large/$i.in &
done

wait

cat small/*  | wc
cat medium/* | wc
cat large/*  | wc

for size in small medium large; do
    read total_lines total_words total_bytes <<< $(cat "$size"/* | wc)
    avg_bytes=$(( total_bytes / total_lines * 11 / 10))
    max_bytes=$(cat $size/* | wc -L)
    echo "in $size average bytes per tree: $avg_bytes, max was: $max_bytes"
done

echo "compiling program to generate answers"

./run_tests.sh "just compile" || exit 1
ans_prog=check.hs

echo "now running toster to generate the tests, good luck!"

echo "./${ans_prog%.hs}"

toster --io small  ./${ans_prog%.hs} --generate
toster --io medium ./${ans_prog%.hs} --generate
toster --io large  ./${ans_prog%.hs} --generate --timeout 10000
