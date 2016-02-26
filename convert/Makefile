SHELL=/bin/bash

# http://www.imagemagick.org/script/convert.php
# https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
# https://github.com/gutschke/pdf2odt
# https://helpx.adobe.com/acrobat/using/scan-documents-pdf.html#Searchable%20Image

FILE=thesis
PREFIX=scratch

DPI=300

RM=rm
MKDIR=mkdir
CONVERT=convert
BASENAME=basename
PDF2ODT=pdf2odt
PDFTK=pdftk

.PHONY: magic clean

magic:	$(FILE).pdf mkdir pdf2pngs pngs2odt pngs2pdfs pdftk

# Create `$(PREFIX)` directory
mkdir:
	if [ ! -d $(PREFIX) ] ; then mkdir -v $(PREFIX) ; fi ;

# `convert` pdf to independent images
pdf2pngs:	$(FILE).pdf
	$(CONVERT) -verbose -density $(DPI) -quality 100 $(FILE).pdf $(PREFIX)/$(FILE)-%03d.png

# Convert each image into an ODT document
pngs2odt:	$(PREFIX)/$(FILE)-???.png
	$(PDF2ODT)  --format=odt --paper=letter --portrait --resolution=$(DPI) --no-trim $(PREFIX)/$(FILE)-???.png $(FILE).odt

# `convert` each image into a independent pdf
pngs2pdfs:	$(PREFIX)/$(FILE)-???.png
	for img in $(PREFIX)/$(FILE)-???.png ; \
	do \
	  $(CONVERT) -verbose $$img $(PREFIX)/`$(BASENAME) $$img .png`.pdf ; \
	done

# Concatenate all independent pdf into a single output
pdftk:	$(PREFIX)/$(FILE)-???.pdf
	$(PDFTK) $(PREFIX)/$(FILE)-???.pdf cat output $(FILE)-pdftk.pdf verbose

clean:
	$(RM) $(PREFIX)/$(FILE)-???.{png,pdf}

