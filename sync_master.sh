git fetch --all
git switch master
git pull

rm -rf ../adrop_ads_flutter/*
rsync -av * ../adrop_ads_flutter