#!/bin/bash

##### Settings #####
TEXFILE="dissertation.tex"
OUTDIR="build"
COMPILER="pdflatex"

##### Code #####
cleanup()
{
  rm "$OUTDIR/"*.aux &> /dev/null
  rm "$OUTDIR/"*.bbl &> /dev/null
  rm "$OUTDIR/"*.blg &> /dev/null
  rm "$OUTDIR/"*.out &> /dev/null
  rm "$OUTDIR/"*.idx &> /dev/null
  rm "$OUTDIR/"*.ind &> /dev/null
  rm "$OUTDIR/"*.toc &> /dev/null
}

# Check if necessary commands available
if ! command -v "$COMPILER" &> /dev/null; then
  printf "\nThe $COMPILER utility must be installed.
Installation:
- Ubuntu: sudo apt update; sudo apt install texlive-full
- Fedora: sudo dnf install texlive-scheme-full
- Mac:    Download and install LaTeX from https://www.tug.org/mactex/.\n"
  exit 1
fi

if [ ! -f "$TEXFILE" ]; then
  echo "File $TEXFILE does not exist. Maybe wrong directory?"
  exit 1
fi

# Output path
OUTFILE=${TEXFILE%.*}.pdf
rm -r "$OUTDIR" &> /dev/null
mkdir "$OUTDIR"

# Create a copy of the chapters folder, because LaTeX permits only writing in subfolders of the main .tex file
# TODO Why does it work for the images folder without a copy/symlink? (These also need to be converted to pdf sometimes and thus written.) And the bibliography works, too?!
cp "$TEXFILE" "$OUTDIR/$TEXFILE"
cp references.bib "$OUTDIR"/references.bib
cp -r chapters "$OUTDIR"/chapters

echo "Generating PDF..."
# 1. find \cite arguments
"$COMPILER" -interaction nonstopmode -halt-on-error -output-directory "$OUTDIR" "$OUTDIR/$TEXFILE" &> /dev/null
# abort on error
if [[ $? -ne 0 ]] ; then
  echo "LaTeX error. See log file $OUTDIR/${TEXFILE%.*}.log"
  exit 1
fi
# 2. find relevant citations
(cd "$OUTDIR"; bibtex ${TEXFILE%.*}.aux) &> /dev/null
for auxfile in "$OUTDIR"/chapters/*.aux; do
  bibtex $auxfile &> /dev/null
  # abort on error
  # Commented out since files without any citations generate an error.  TODO Can we make bibtex ignore chapters without bibliography?
  #if [[ $? -ne 0 ]] ; then
  #  echo "BibTeX error. See log file ${auxfile%.*}.blg"
  #  exit 1
  #fi
done
# 3. generate citation labels and terms index (with correct page numbers)
"$COMPILER" -interaction nonstopmode -halt-on-error -output-directory "$OUTDIR" "$OUTDIR/$TEXFILE" &> /dev/null
makeindex "$OUTDIR/${TEXFILE%.*}" &> /dev/null
# 4. generate document
"$COMPILER" -interaction nonstopmode -halt-on-error -output-directory "$OUTDIR" "$OUTDIR/$TEXFILE" &> /dev/null
# Output: "$OUTDIR/$OUTFILE"
# DEBUG: To find LaTeX warnings, check "$OUTDIR/${TEXFILE%.*}.log".

cleanup

# Show PDF
#xdg-open "$OUTDIR/$OUTFILE"

exit 0

