SHELL=		sh
RM=		rm
LATEX=		latex
BIBTEX=		bibtex
DVIPS=		dvips
PS2PDF=		ps2pdf
GS=		gs

.SUFFIXES:      .tex .dvi .eps .ps .pdf

MAIN = thesis

EMAIN = ethesis

FIGDIR = figures

FIGURES =	$(FIGDIR)/MUN_Logo_Pantone.eps		\
		$(FIGDIR)/enrollment.eps 		\
		$(FIGDIR)/enrollment-landscape.eps 	\
		$(FIGDIR)/enrollment-rotate.eps 	\
		$(FIGDIR)/db-deadlock.eps

FILES = thesis.tex thesis.sty						\
	abstract.tex ack.tex contents.tex tables.tex figures.tex	\
	chap1.tex chap2.tex chap3.tex chap4.tex chap5.tex chap6.tex	\
	bib.tex ref.bib apdxa.tex

PREVIEW=/Applications/Preview.app/Contents/MacOS/Preview

# Make pdf, clean all temporary files by default and open the document with
# the platform pdf viewer
# Added by Andrés Hernández
$(MAIN):	clean.pdf $(MAIN).pdf neat
	# Preview automagically reload the document on change
	#if [ -r $(MAIN).pdf -a -e ${PREVIEW} ] ; \
	#then \
	#  VIEWER="$(shell which open)" ; \
	#  $$VIEWER $(MAIN).pdf ; \
	#fi ;
	if [ -r $(MAIN).pdf -a -n "$(shell which evince)" ] ; \
	then \
	  VIEWER="$(shell which evince)" ; \
	  $$VIEWER $(MAIN).pdf ; \
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

clean.pdf:
	$(RM) -f *.aux $(MAIN).pdf $(EMAIN).pdf

clean:	clean.pdf
	$(RM) -f *.aux \
		$(MAIN).log $(MAIN).dvi $(MAIN).ps $(MAIN).blg $(MAIN).bbl \
		$(MAIN).lot $(MAIN).lof $(MAIN).toc

# Suggested by Neil B.
neat:
	$(RM) -f *.aux \
		$(MAIN).log $(MAIN).blg $(MAIN).bbl \
		$(MAIN).lot $(MAIN).lof $(MAIN).toc

