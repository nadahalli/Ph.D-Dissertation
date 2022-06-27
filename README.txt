Example doctoral thesis by Manuel Eichelberger. 6x9 inch page size and cover for publishing through Amazon KDP.

Most settings and metadata are in shared_settings.tex. dissertation.tex and book_cover.tex have some more specific settings at the top.


===== Compilation =====

Run ./build.sh to generate thesis PDF in "build" folder. For errors and warnings, check the LaTeX log at build/dissertation.log. (The script has been tested under Linux only.)

book_cover.tex needs to be compiled separately *after* the thesis has been generated. Its size (spine width) is calculated from the number of thesis pages.

