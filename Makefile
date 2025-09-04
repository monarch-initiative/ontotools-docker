URIBASE = http://purl.obolibrary.org/obo

ROBOT=robot
# the below onts were collected from ols-config.yaml
# (note that .owl is appended to each of these later on, so there's no need to add it here)
ONTS = upheno-reordered upheno-patterns vbo-edit chr mondo-edit mondo-rare mondo-patterns mondo-matrix omim mondo-clingen

#monarch
ONTFILES = $(foreach n, $(ONTS), ontologies/$(n).owl)
IM=monarchinitiative/monarch-ols
OLSCONFIG=/opt/ols/ols-config.yaml

# Download and pre-process the ontologies
clean:
	rm -rf ontologies/*

ontologies: $(ONTFILES)

ontologies/mondo-branch-%.owl:
	mkdir -p github && mkdir -p github/mondo-branch-$* && rm -rf github/mondo-branch-$*/*
	cd github/mondo-branch-$* && git clone --depth 1 https://github.com/monarch-initiative/mondo.git -b $* 
	cd github/mondo-branch-$*/mondo/src/ontology/ && make IMP=false PAT=false MIR=false mondo.owl
	cp github/mondo-branch-$*/mondo/src/ontology/mondo.owl $@

# Stub entry for Mondo branch to use specifically to review content for ClinGen. Replace `issue-9178` with new feature branch to deploy.
# ontologies/mondo-clingen-review.owl:
#	mkdir -p github/mondo-clingen-review && rm -rf github/mondo-clingen-review/*
#	cd github/mondo-clingen-review && \
#	  git clone --depth 1 https://github.com/monarch-initiative/mondo.git -b issue-9178 && \
#	  cd mondo/src/ontology && \
#	  make subsets/mondo-clingen.owl IMP=false MIR=false && \
#	  mv subsets/mondo-clingen.owl ../../../../../ontologies/mondo-clingen-review.owl

# ontologies/mondo-edit.owl:
# 	mkdir -p github && mkdir -p github/main && rm -rf github/main/*
# 	cd github/main && git clone --depth 1 https://github.com/monarch-initiative/mondo.git
# 	cd github/main/mondo/src/ontology/ && make IMP=false PAT=false MIR=false mondo.owl
# 	cp github/main/mondo/src/ontology/mondo.owl $@

# TEST for issue-34
MONDO_REF ?= master

github/mondo/.cloned:
	rm -rf github/mondo
	git clone --depth 1 --single-branch --branch $(MONDO_REF) \
	  https://github.com/monarch-initiative/mondo.git github/mondo
	touch $@

ontologies/mondo-edit.owl: github/mondo/.cloned
	./odk.sh make -C github/mondo/src/ontology IMP=false PAT=false MIR=false mondo-edit.owl
	cp github/mondo/src/ontology/mondo-edit.owl $@


ontologies/hp-branch-%.owl:
	mkdir -p github && mkdir -p github/hp-branch-$* && rm -rf github/hp-branch-$*/*
	cd github/hp-branch-$* && git clone --depth 1 https://github.com/obophenotype/human-phenotype-ontology.git -b $* 
	cd github/hp-branch-$*/human-phenotype-ontology/src/ontology/ && make IMP=false PAT=false MIR=false hp.owl
	cp github/hp-branch-$*/human-phenotype-ontology/src/ontology/hp.owl $@

ontologies/hp-edit.owl:
	mkdir -p github && mkdir -p github/main && rm -rf github/main/*
	cd github/main && git clone --depth 1 https://github.com/obophenotype/human-phenotype-ontology.git
	cd github/main/human-phenotype-ontology/src/ontology/ && make IMP=false PAT=false MIR=false hp.owl
	cp github/main/human-phenotype-ontology/src/ontology/hp.owl $@

ontologies/vbo-edit.owl:
	mkdir -p github && mkdir -p github/main && rm -rf github/main/*
	cd github/main && git clone --depth 1 https://github.com/monarch-initiative/vertebrate-breed-ontology.git
	cd github/main/vertebrate-breed-ontology/src/ontology/ && make IMP=false PAT=false MIR=false vbo.owl -B
	cp github/main/vertebrate-breed-ontology/src/ontology/vbo.owl $@

ontologies/chr.owl: 
	$(ROBOT) convert -I https://raw.githubusercontent.com/monarch-initiative/monochrom/master/chr.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/omim.owl: 
	$(ROBOT) convert -I https://github.com/monarch-initiative/omim/releases/latest/download/omim.owl -o $@.tmp.owl && mv $@.tmp.owl $@

UPHENO_URL=https://github.com/obophenotype/upheno-dev/releases/download/v2023-10-27/upheno_all.owl

ontologies/upheno-reordered.owl: 
	$(ROBOT) convert -I https://github.com/obophenotype/upheno-dev/releases/latest/download/upheno-curated.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/upheno-patterns.owl:
	$(ROBOT) convert -I https://raw.githubusercontent.com/obophenotype/upheno/master/src/patterns/pattern.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/mondo-patterns.owl:
	$(ROBOT) convert -I https://raw.githubusercontent.com/monarch-initiative/mondo/master/src/patterns/pattern.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/mondo-rare.owl:
	$(ROBOT) convert -I http://purl.obolibrary.org/obo/mondo/subsets/mondo-rare.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/mondo-clingen.owl:
	$(ROBOT) convert -I https://github.com/monarch-initiative/mondo/releases/latest/download/mondo-clingen.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/mondo-matrix.owl:
	$(ROBOT) convert -I https://github.com/everycure-org/matrix-disease-list/releases/latest/download/mondo-with-filter-designations.owl -o $@.tmp.owl && mv $@.tmp.owl $@

ontologies/uberon-human-view.owl:
	$(ROBOT) convert -I http://purl.obolibrary.org/obo/uberon/subsets/human-view.owl -o $@.tmp.owl && mv $@.tmp.owl $@


update-ui:
	wget https://raw.githubusercontent.com/EBISPOT/ols4/refs/heads/dev/frontend/src/components/Footer.tsx -O frontend/Footer.tsx
	wget https://raw.githubusercontent.com/EBISPOT/ols4/refs/heads/dev/frontend/src/components/Header.tsx -O frontend/Header.tsx
	wget https://raw.githubusercontent.com/EBISPOT/ols4/refs/heads/dev/frontend/src/pages/home/Home.tsx -O frontend/Home.tsx 





