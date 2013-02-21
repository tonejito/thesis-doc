SHELL=		sh
RM=		rm
LATEX=		latex
BIBTEX=		bibtex
DVIPS=		dvips
PS2PDF=		ps2pdf
GS=		gs
SED=		sed

.SUFFIXES:      .tex .dvi .eps .ps .pdf

MAIN = thesis

EMAIN = ethesis

FIGDIR = figures

FIGURES =	$(FIGDIR)/MUN_Logo_Pantone.eps		\
		$(FIGDIR)/enrollment.eps 		\
		$(FIGDIR)/enrollment-landscape.eps 	\
		$(FIGDIR)/enrollment-rotate.eps 	\
		$(FIGDIR)/db-deadlock.eps

CHAPTERS = chap1.tex chap2.tex chap3.tex chap4.tex chap5.tex chap6.tex	\
	   cap1.tex cap2.tex cap3.tex cap4.tex cap5.tex

FILES = thesis.tex thesis.sty						\
	abstract.tex ack.tex contents.tex tables.tex figures.tex	\
	$(CHAPTERS)							\
	bib.tex ${REF_BIB} apdxa.tex

REF_BIB = ref.bib

# URL size in reference section
URL_SIZE = footnotesize

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

# Make pdf, clean all temporary files by default and open the document with
# the platform pdf viewer
# Added by Andrés Hernández
$(MAIN):	clean.doc accents $(MAIN).pdf
	# Preview automagically reload the document on change
	if [ -r $(MAIN).pdf -a -e ${VIEWER} ] ; \
	then \
	  ${VIEWER} $(MAIN).pdf & \
	fi ;

$(MAIN).dvi:    $(MAIN).tex $(FIGURES) $(FILES)
	$(LATEX) $*.tex; 
	$(BIBTEX) $*;
	$(LATEX) $*.tex;
	while grep -s 'Rerun' $*.log 2> /dev/null; do	\
		$(LATEX) $*.tex;			\
	done

# GhostScript command line options based upon:
# http://pages.cs.wisc.edu/~ghost/doc/cvs/Ps2pdf.htm#PDFA
$(EMAIN).pdf:	$(MAIN).ps
	$(GS) -sPAPERSIZE=letter -sProcessColorModel=DeviceCMYK -q \
	-dPDFA -dBATCH -dNOPAUSE -dNOOUTERSAVE -dUseCIEColor \
	-sDEVICE=pdfwrite -sOutputFile=$@ pdfa/PDFA_def.ps  $<

.dvi.ps:        $*.dvi
	$(DVIPS) -Ppdf -G0 -t letter -o $@ $<
 
.ps.pdf:       $*.dvi
	$(PS2PDF) -sPAPERSIZE=letter $< $@

clean.doc:
	$(RM) -f *.aux $(MAIN).dvi $(MAIN).ps $(MAIN).pdf $(EMAIN).pdf

# Suggested by Neil B.
clean:	clean.doc
	$(RM) -f *.aux \
		$(MAIN).log $(MAIN).blg $(MAIN).bbl \
		$(MAIN).lot $(MAIN).lof $(MAIN).toc

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
	${SED} -e 's/\(howpublished\ =\ \){\{1,\}\(.*\)}\{1,\},/\1{\\newline \\begin{footnotesize} \2 \\end{footnotesize}},/g' -e 's/}\(\ \\end\)/\1/g' ${BACKUP_SUFFIX} ${REF_BIB}
#	${SED} -e 's/\(howpublished\ =\ \){\{1,\}\(.*\)}\{1,\},/\1{\\newline \\begin{footnotesize} \\texttt{\2} \\end{footnotesize}},/g' -e 's/}\(}\ \\end\)/\1/g' ${BACKUP_SUFFIX} ${REF_BIB}
