set -ex
v doc  -m  -f md  -no-timestamp -comments -o docs/src/v twinactions/
mv docs/src/v/_docs/*  docs/src/v/
rm -rf docs/src/v/_docs
rm -rf html2/
v fmt . -w
v doc  -m  -f html  -no-timestamp -comments -o html2 twinactions/
rm -rf html/
mv html2/_docs/ html/
open html/twinactions.html