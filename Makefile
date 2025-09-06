URIBASE = http://purl.obolibrary.org/obo

ROBOT=robot
# the below onts were collected from ols-config.yaml
# (note that .owl is appended to each of these later on, so there's no need to add it here)
# ONTS = upheno-reordered upheno-patterns vbo-edit chr mondo-edit mondo-rare mondo-patterns mondo-matrix omim mondo-clingen

ONTS = mondo-edit mondo-clingen.noid chr

#monarch
ONTFILES = $(foreach n, $(ONTS), ontologies/$(n).owl)
IM=monarchinitiative/monarch-ols

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

MONDO_REF ?= master

.PHONY: ontologies/mondo-edit.owl
ontologies/mondo-edit.owl:
	@echo "\nBuilding MONDO (edit) from GitHub..."
	mkdir -p github && rm -rf github/mondo
	git clone --depth 1 --single-branch --branch $(MONDO_REF) \
	  https://github.com/monarch-initiative/mondo.git github/mondo
	cd github/mondo/src/ontology/ && make IMP=false PAT=false MIR=false mondo.owl
	cp github/mondo/src/ontology/mondo.owl $@

ontologies/hp-branch-%.owl:
	mkdir -p github && mkdir -p github/hp-branch-$* && rm -rf github/hp-branch-$*/*
	cd github/hp-branch-$* && git clone --depth 1 https://github.com/obophenotype/human-phenotype-ontology.git -b $* 
	cd github/hp-branch-$*/human-phenotype-ontology/src/ontology/ && make IMP=false PAT=false MIR=false hp.owl
	cp github/hp-branch-$*/human-phenotype-ontology/src/ontology/hp.owl $@

.PHONY: ontologies/hp-edit.owl
ontologies/hp-edit.owl:
	@echo "\nBuilding HPO (edit) from GitHub..."
	mkdir -p github && rm -rf github/hp/
	git clone --depth 1 --single-branch https://github.com/obophenotype/human-phenotype-ontology.git github/hp
	cd github/hp/src/ontology/ && make IMP=false PAT=false MIR=false hp.owl
	cp github/hp/src/ontology/hp.owl $@

.PHONY: ontologies/vbo-edit.owl
ontologies/vbo-edit.owl:
	@echo "\nBuilding VBO (edit) from GitHub..."
	mkdir -p github && rm -rf github/vbo/
	git clone --depth 1 --single-branch https://github.com/monarch-initiative/vertebrate-breed-ontology.git github/vbo
	cd github/vbo/src/ontology/ && make IMP=false PAT=false MIR=false vbo.owl
	cp github/vbo/src/ontology/vbo.owl $@

.PHONY: ontologies/chr.owl
ontologies/chr.owl:
	@echo "\nDownloading CHR (latest) → $@"
	$(ROBOT) convert -I https://raw.githubusercontent.com/monarch-initiative/monochrom/master/chr.owl -o $@.tmp.owl && mv $@.tmp.owl $@

.PHONY: ontologies/omim.owl
ontologies/omim.owl:
	@echo "\nDownloading OMIM (latest) → $@"
	$(ROBOT) convert -I https://github.com/monarch-initiative/omim/releases/latest/download/omim.owl -o $@.tmp.owl && mv $@.tmp.owl $@

UPHENO_URL=https://github.com/obophenotype/upheno-dev/releases/download/v2023-10-27/upheno_all.owl

.PHONY: ontologies/upheno-reordered.owl
ontologies/upheno-reordered.owl:
	@echo "\nDownloading upheno-reordered (latest) → $@"
	$(ROBOT) convert -I https://github.com/obophenotype/upheno-dev/releases/latest/download/upheno-curated.owl -o $@.tmp.owl && mv $@.tmp.owl $@

.PHONY: ontologies/upheno-patterns.owl
ontologies/upheno-patterns.owl:
	@echo "\nDownloading upheno-patterns (latest) → $@"
	$(ROBOT) convert -I https://raw.githubusercontent.com/obophenotype/upheno/master/src/patterns/pattern.owl -o $@.tmp.owl && mv $@.tmp.owl $@

.PHONY: ontologies/mondo-patterns.owl
ontologies/mondo-patterns.owl:
	@echo "\nDownloading mondo-patterns (latest) → $@"
	$(ROBOT) convert -I https://raw.githubusercontent.com/monarch-initiative/mondo/master/src/patterns/pattern.owl -o $@.tmp.owl && mv $@.tmp.owl $@

.PHONY: ontologies/mondo-rare.owl
ontologies/mondo-rare.owl:
	@echo "\nDownloading mondo-rare (latest) → $@"
	$(ROBOT) convert -I http://purl.obolibrary.org/obo/mondo/subsets/mondo-rare.owl -o $@.tmp.owl && mv $@.tmp.owl $@

.PHONY: ontologies/mondo-clingen.owl
ontologies/mondo-clingen.owl:
	@echo "\nDownloading mondo-clingen (latest) → $@"
	$(ROBOT) convert -I https://github.com/monarch-initiative/mondo/releases/latest/download/mondo-clingen.owl -o $@.tmp.owl && mv $@.tmp.owl $@

# Example: ClinGen subset post-processing
.PHONY: ontologies/mondo-clingen.noid.owl
ontologies/mondo-clingen.noid.owl: ontologies/mondo-clingen.owl
	@echo "\nStripping oboInOwl:id from mondo-clingen → $@"
	robot remove \
	  --input $< \
	  --term '<http://www.geneontology.org/formats/oboInOwl#id>' \
	  --axioms annotation \
	  --trim false \
	  --output $@


.PHONY: ontologies/mondo-matrix.owl
ontologies/mondo-matrix.owl:
	@echo "\nDownloading mondo-matrix (latest) → $@"
	$(ROBOT) convert -I https://github.com/everycure-org/matrix-disease-list/releases/latest/download/mondo-with-filter-designations.owl -o $@.tmp.owl && mv $@.tmp.owl $@

.PHONY: ontologies/uberon-human-view.owl
ontologies/uberon-human-view.owl:
	@echo "\nDownloading uberon-human-view (latest) → $@"
	$(ROBOT) convert -I http://purl.obolibrary.org/obo/uberon/subsets/human-view.owl -o $@.tmp.owl && mv $@.tmp.owl $@


update-ui:
	wget https://raw.githubusercontent.com/EBISPOT/ols4/refs/heads/dev/frontend/src/components/Footer.tsx -O frontend/Footer.tsx
	wget https://raw.githubusercontent.com/EBISPOT/ols4/refs/heads/dev/frontend/src/components/Header.tsx -O frontend/Header.tsx
	wget https://raw.githubusercontent.com/EBISPOT/ols4/refs/heads/dev/frontend/src/pages/home/Home.tsx -O frontend/Home.tsx 





