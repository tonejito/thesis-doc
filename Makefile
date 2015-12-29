SHELL=		sh
UNAME=		uname
LS=		ls
MV=		mv
RM=		rm
LATEX=		latex
PDFLATEX=	pdflatex
BIBTEX=		bibtex
DVIPS=		dvips
PS2PDF=		ps2pdf
GS=		gs
SED=		sed
GREP=		grep
EGREP=		egrep
CAT=		cat
PANDOC=		pandoc
MAN=		man

SUDO=		sudo
APTITUDE=	aptitude
YUM=		yum
PORT=		/opt/local/bin/port

VIM=		vim

.SUFFIXES:	.tex .dvi .eps .ps .pdf

PRESENTATION = presentation

MAIN = thesis

EMAIN = ethesis

FIGDIR = figures

FIGURES =	$(FIGDIR)/UNAM.eps		\
		$(FIGDIR)/Ingenieria.eps

ABSTRACT = abstract.tex

ACK = ack.tex

APDX = apdxa.tex

INTRO = intro.tex

CHAPTERS = cap1.tex cap2.tex cap3.tex cap4.tex cap5.tex

FILES = thesis.tex thesis.sty \
	${ABSTRACT} ${ACK} \
	contents.tex tables.tex figures.tex \
	$(INTRO) \
	$(CHAPTERS) \
	bib.tex ${REF_BIB} \
	${APDX}

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
  # apt / aptitude
  ifeq ($(wildcard /etc/debian_version),/etc/debian_version)
    INSTALL=$(APTITUDE)
    PACKAGES=pandoc texlive \
             texlive-latex-extra  texlive-bibtex-extra \
             texlive-lang-english texlive-lang-spanish
  endif
  # yum / rpm
  ifeq ($(wildcard /etc/redhat-release),/etc/redhat-release)
    INSTALL=$(YUM)
    PACKAGES=pandoc texlive texlive-latex \
             texlive-texmf-latex texlive-texmf-errata-latex
  endif
endif
# Darwin / Mac OS X
ifeq ($(shell uname -s),Darwin)
  BACKUP_SUFFIX=-i ''
  VIEWER=$(shell which open)
  INSTALL=$(PORT)
  PACKAGES=pandoc texlive \
           texlive-latex-extra  texlive-bibtex-extra \
           texlive-lang-english texlive-lang-spanish \
           tex-beamerposter
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


# Install dependencies
deps:
	$(SUDO) $(INSTALL) install $(PACKAGES)

# Preview automagically reload the document on change
view:	
	if [ -r "$(MAIN).pdf" -a -e "${VIEWER}" ] ; \
	then \
	  if [ "`$(UNAME) -s`" = "CYGWIN_NT-6.1-WOW64" -a -e "$(RUN)" ] ; \
	  then \
	    $(RUN) ${VIEWER} $(MAIN).pdf ; \
	  else \
	    ${VIEWER} $(MAIN).pdf & \
	  fi \
	fi ;

edit:
	$(VIM) $(ABSTRACT) $(ACK) $(INTRO) $(CHAPTERS) $(APDX)

# Optimize pdf for print size
optimize:	
	$(GS) $(GS_QUIET) -dBATCH -dNOPAUSE -sPAPERSIZE=$(PAPERSIZE) -sDEVICE=pdfwrite -dPDFSETTINGS=/$(PDFSETTINGS) -dUseCIEColor=true -sOutputFile=$(MAIN)..pdf $(MAIN).pdf
	$(LS) -l --sort=size $(MAIN).pdf $(MAIN)..pdf

$(MAIN).dvi:	$(MAIN).tex $(FIGURES) $(FILES)
	$(LATEX) $*.tex; 
	$(BIBTEX) $*;
	$(LATEX) $*.tex;
	#while grep -s 'Rerun' $*.log 2> /dev/null; do	\
	#	$(LATEX) $*.tex;			\
	#done

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
	for ext in aux dvi ps md html pdf .pdf ; \
	do \
	  $(RM) -f *.aux \
		$(MAIN).$$ext $(EMAIN).$$ext $(PRESENTATION).$$ext $(MAN).$$ext ; \
	done \
	;

# Suggested by Neil B.
clean:	clean.doc
	for ext in aux out log lot lof blg bbl toc nav snm vrb brf glo ist ; \
	do \
	  $(RM) -f *.aux \
		$(MAIN).$$ext $(PRESENTATION).$$ext $(MAN).$$ext ; \
	done \
	;

# Translate spanish accents to LaTeX-friendly character sequences
# Added by Andrés Hernández
accents:	
	if [ -n "${BACKUP_SUFFIX}" ] ; \
	then \
	  for chapter in $(ABSTRACT) $(ACK) $(INTRO) $(CHAPTERS) $(APDX) ; \
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
# Add bibliography if bibtools is compiled in pandoc (might not work if compiled with -static flag)
$(MAIN).html:	
ifeq ($(shell which pandoc | xargs ldd | grep -i bibutils | wc -l),1)
	$(eval BIBLIOGRAPHY := --bibliography $(REF_BIB))
else
	$(eval BIBLIOGRAPHY := )
endif
	$(CAT) $(INTRO) $(CHAPTERS) | \
	$(GREP) -v '\\label{[[:alnum:]]\+:[[:alnum:]]\+}' | \
	$(PANDOC) --normalize --toc --standalone --self-contained --reference-links --preserve-tabs -B $(README) -A $(README) $(BIBLIOGRAPHY) --biblatex -r latex -w html5 > $(MAIN).html

# [texhax] Including tiff figures in LaTeX
# https://www.tug.org/pipermail/texhax/2004-June/002252.html

$(MAN):	$(MAN).tex
	for ext in out log dvi ps pdf ; \
	do \
	  if [ -e $(MAN).$$ext ] ; \
	  then \
	    rm $(MAN).$$ext ; \
	  fi ; \
	done ;
	$(LATEX) $(MAN).tex; 
	$(DVIPS) -Ppdf -G0 -t $(PAPERSIZE) -o $(MAN).ps $(MAN).dvi
	$(PS2PDF) -sPAPERSIZE=$(PAPERSIZE) $(MAN).ps $(MAN).pdf
	#$(GS) -sPAPERSIZE=$(PAPERSIZE) -sProcessColorModel=DeviceCMYK -q \
	#-dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor \
	#-sDEVICE=pdfwrite -sOutputFile=$(MAN).pdf $(MAN).ps
	#$(GS) $(GS_QUIET) -dBATCH -dNOPAUSE -sPAPERSIZE=$(PAPERSIZE) \
	#-sDEVICE=pdfwrite -dPDFSETTINGS=/$(PDFSETTINGS) -dUseCIEColor=true \
	#-sOutputFile=$(MAN).pdf $(MAN).pdf

$(PRESENTATION): $(PRESENTATION).tex
	for i in {1..2} ; \
	do \
	  $(LATEX) $(PRESENTATION).tex ; \
	done ;
	$(DVIPS) -Ppdf -G0 -o $(PRESENTATION).ps $(PRESENTATION).dvi
	$(PS2PDF) $(PRESENTATION).ps $(PRESENTATION).pdf

