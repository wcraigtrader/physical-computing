LIBRARY=ElvenLight.scad

BUILD=output
TEMP=temp

# Identify target output modules from ${LIBRARY}
TARGETS=$(shell sed '/^module [a-z0-9_-]*().*OUTPUT.*$$/!d;s/module /${BUILD}\//;s/().*/.stl/' ${LIBRARY})
SCADS=$(shell sed '/^module [a-z0-9_-]*().*OUTPUT.*$$/!d;s/module /${TEMP}\//;s/().*/.scad/' ${LIBRARY})

all:	${TARGETS}

# auto-generated .scad files with .deps make make re-build always. keeping the
# scad files solves this problem. (explanations are welcome.)
.SECONDARY: ${SCADS}

# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

${TEMP}/%.scad:
	@mkdir -p ${TEMP}
	echo -n 'use <${LIBRARY}>\n!$(*F)();' > $@

${BUILD}/%.stl:	${TEMP}/%.scad
	@mkdir -p ${BUILD}
	openscad -m make -o $@ -d $<.deps $<

clean:
	rm -f *~ ${TEMP}/*.deps ${TARGETS} ${SCADS}

