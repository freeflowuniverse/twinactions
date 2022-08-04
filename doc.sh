set -ex
v doc  -m  -f md  -no-timestamp -comments -o docs/src/v twinactions/
mv docs/src/v/_docs/*  docs/src/v/
rm -rf docs/src/v/_docs
rm -rf html2/
v fmt . -w

#v docs
v doc  -m  -f html  -no-timestamp -comments -o html2 twinactions/
rm -rf docsv
mv html2/_docs/ docsv/
rm -rf html2/


#Mdbook
pushd docs
bash run.sh
popd
if [ -x "$(command -v open)" ]; then
    open docs/book/index.html 2>&1 > /dev/null 
    open docsv/crypto.html 2>&1 > /dev/null 
fi