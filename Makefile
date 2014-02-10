SHELL=		sh
UNAME=		uname
LS=		ls
MV=		mv
RM=		rm
LATEX=		latex
BIBTEX=		bibtex
DVIPS=		dvips
PS2PDF=		ps2pdf
GS=		gs
SED=		sed
GREP=		grep
EGREP=		egrep
CAT=		cat
PANDOC=		pandoc

.SUFFIXES:	.tex .dvi .eps .ps .pdf

MAIN = thesis

EMAIN = ethesis

FIGDIR = figures

FIGURES =	$(FIGDIR)/UNAM.eps		\
		$(FIGDIR)/Ingenieria.eps

CHAPTERS = cap1.tex cap2.tex cap3.tex cap4.tex cap5.tex

FILES = thesis.tex thesis.sty						\
	abstract.tex ack.tex contents.tex tables.tex figures.tex	\
	$(CHAPTERS)							\
	bib.tex ${REF_BIB} apdxa.tex

INTRO = intro.tex

REF_BIB = ref.bib

README = README.md

# PDF print settings
PAPERSIZE = letter
# default, printer, prepress, ebook, screen
PDFSETTINGS = printer
#GS_QUIET = -q -dQUIET
GS_QUIET =

# Set system specific programs and arguments
# Linux
ifeq ($(shell uname -s),Linux)
  BACKUP_SUFFIX=-i''
  VIEWER=$(shell which evince)
endif
# Darwin / Mac OS X
ifeq ($(shell uname -s),Darwin)
  BACKUP_SUFFIX=-i ''
  VIEWER=$(shell which open)
endif
# Cygwin
ifeq ($(shell uname -s),CYGWIN_NT-6.1-WOW64)
  BACKUP_SUFFIX=-i''
  RUN=/usr/bin/run
  VIEWER=/cygdrive/z/PortableApps/EvincePortable/EvincePortable.exe
endif

# Make pdf, clean all temporary files by default and open the document with
# the platform pdf viewer
# Added by Andrés Hernández
$(MAIN):	clean.doc accents $(MAIN).pdf view
# Build Markdown and html versions only in true UNIX platforms
ifneq ($(shell uname -s),CYGWIN_NT-6.1-WOW64)
	$(MAKE) $(MAIN).md $(MAIN).html
endif

# Preview automagically reload the document on change
view:	
	if [ -r $(MAIN).pdf -a -e ${VIEWER} ] ; \
	then \
	  if [ "`$(UNAME) -s`" = "CYGWIN_NT-6.1-WOW64" -a -e "$(RUN)" ] ; \
	  then \
	    $(RUN) ${VIEWER} $(MAIN).pdf ; \
	  else \
	    ${VIEWER} $(MAIN).pdf & \
	  fi \
	fi ;

# Optimize pdf for print size
optimize:	
	$(GS) $(GS_QUIET) -dBATCH -dNOPAUSE -sPAPERSIZE=$(PAPERSIZE) -sDEVICE=pdfwrite -dPDFSETTINGS=/$(PDFSETTINGS) -dUseCIEColor=true -sOutputFile=$(MAIN)..pdf $(MAIN).pdf
	$(LS) -l --sort=size $(MAIN).pdf $(MAIN)..pdf

$(MAIN).dvi:	$(MAIN).tex $(FIGURES) $(FILES)
	$(LATEX) $*.tex; 
	$(BIBTEX) $*;
	$(LATEX) $*.tex;
	while grep -s 'Rerun' $*.log 2> /dev/null; do	\
		$(LATEX) $*.tex;			\
	done

# GhostScript command line options based upon:
# http://pages.cs.wisc.edu/~ghost/doc/cvs/Ps2pdf.htm#PDFA
# http://dsanta.users.ch/resources/type1.html
# http://blog.rot13.org/2011/05/optimize-pdf-file-size-using-ghostscript.html
$(EMAIN).pdf:	$(MAIN).ps
	$(GS) -sPAPERSIZE=$(PAPERSIZE) -sProcessColorModel=DeviceCMYK -q \
	-dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor \
	-sDEVICE=pdfwrite -sOutputFile=$@ pdfa/PDFA_def.ps  $<

.dvi.ps:	$*.dvi
	$(DVIPS) -Ppdf -G0 -t $(PAPERSIZE) -o $@ $<
 
.ps.pdf:	$*.dvi
	$(PS2PDF) -sPAPERSIZE=$(PAPERSIZE) $< $@

clean.doc:	
	$(RM) -f *.aux \
		$(MAIN).dvi $(MAIN).ps $(MAIN).pdf $(EMAIN).pdf \
		$(MAIN).md  $(MAIN).html $(MAIN)..pdf \
	;

# Suggested by Neil B.
clean:	clean.doc
	$(RM) -f *.aux \
		$(MAIN).log $(MAIN).blg $(MAIN).bbl \
		$(MAIN).lot $(MAIN).lof $(MAIN).toc \
	;

# Translate spanish accents to LaTeX-friendly character sequences
# Added by Andrés Hernández
accents:	
	if [ -n "${BACKUP_SUFFIX}" ] ; \
	then \
	  for chapter in $(CHAPTERS) ; \
	  do \
	    $(SED) -e "s/á/\\\'{a}/g" \
	           -e "s/é/\\\'{e}/g" \
	           -e "s/í/\\\'{i}/g" \
	           -e "s/ó/\\\'{o}/g" \
	           -e "s/ú/\\\'{u}/g" \
	           -e "s/ñ/\\\~{n}/g" \
	           -e "s/Á/\\\'{A}/g" \
	           -e "s/É/\\\'{E}/g" \
	           -e "s/Í/\\\'{I}/g" \
	           -e "s/Ó/\\\'{O}/g" \
	           -e "s/Ú/\\\'{U}/g" \
	           -e "s/Ñ/\\\~{N}/g" \
	           ${BACKUP_SUFFIX} $$chapter ; \
	  done ; \
	fi ;

# Style up BibTeX entries before being rendered
ref-url:	
	${SED} -e 's/en-{US/en-US/g' -e 's/\(howpublished\ =\ \){\{1,\}\(.*\)}\{1,\},/\1{\\newline \\begin{footnotesize} \2 \\end{footnotesize}},/g' -e 's/}\(\ \\end\)/\1/g' ${BACKUP_SUFFIX} ${REF_BIB}
#	${SED} -e 's/\(howpublished\ =\ \){\{1,\}\(.*\)}\{1,\},/\1{\\newline \\begin{footnotesize} \\texttt{\2} \\end{footnotesize}},/g' -e 's/}\(}\ \\end\)/\1/g' ${BACKUP_SUFFIX} ${REF_BIB}

# Check for embedded references in the chapters and search them within the BibTeX references
extract-url:	
	for chapter in ${CHAPTERS} ; \
	do \
	  for url in `${EGREP} '^[[:space:]]*%[[:space:]]*http://' $$chapter` ; \
	  do \
	    ${GREP} "$$url" ${REF_BIB} ; \
	  done ; \
	done ;

# Convert latex to MarkDown using pandoc(1)
$(MAIN).md:	
	$(CAT) $(INTRO) $(CHAPTERS) | \
	$(GREP) -v '\\label{[[:alnum:]]\+:[[:alnum:]]\+}' | \
	$(PANDOC) --normalize --toc --standalone --self-contained --reference-links --preserve-tabs -B $(README) -A $(README) -r latex -w markdown > $(MAIN).md

# Convert latex to HTML5 using pandoc(1)
$(MAIN).html:	
	$(CAT) $(INTRO) $(CHAPTERS) | \
	$(GREP) -v '\\label{[[:alnum:]]\+:[[:alnum:]]\+}' | \
	$(PANDOC) --normalize --toc --standalone --self-contained --reference-links --preserve-tabs -B $(README) -A $(README) --bibliography $(REF_BIB) --biblatex -r latex -w html5 > $(MAIN).html

