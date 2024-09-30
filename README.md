# og-2024-kc-nara

aperitiiif batch of nara a files for migrants and the state neh grant project 🥂

## description

this is a modified aperitiiif batch repo. because of the size, images are not stored cannonically in the repo and processed by the github `publish-batch` action. 

instead, cannonical pdfs and images are stored in an NYU Research Workspace (RW) volume. the scripts in `lib` process the files from the volume mounted locally and sync the generated image and json resources for the IIIF APIs directly to AWS S3 using credentials stored (and gitignored) in `.env`.

the github action is used to deploy the results to github pages only.

## owner(s)
- [@mnyrop](https://github.com/mnyrop)

## usage
- Run csv initialization & pdf splitting script with `bundle exec ruby lib/split-pdfs-populate-csv.rb`
