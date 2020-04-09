ENTRY_DIR = entries

SRC_DIR = src
SRC_ENTRY_DIR = $(SRC_DIR)/$(ENTRY_DIR)

OUT_DIR = out
PUB_DIR = $(OUT_DIR)/public
PUB_ENTRY_DIR = $(PUB_DIR)/$(ENTRY_DIR)

SRC_ENTRIES = $(shell find $(SRC_ENTRY_DIR) -type f -name '*.md')
SRC_ENTRY_FILES = $(shell find $(SRC_ENTRY_DIR) -type f -not -name '*.md')

PUB_ENTRIES = $(patsubst $(SRC_ENTRY_DIR)/%.md,$(PUB_ENTRY_DIR)/%.html,$(SRC_ENTRIES))
PUB_ENTRY_FILES = $(patsubst $(SRC_ENTRY_DIR)/%,$(PUB_ENTRY_DIR)/%,$(SRC_ENTRY_FILES))

PANDOC_TEMPLATE = $(SRC_DIR)/template.html
PANDOC_FLAGS = -f markdown -t html5 -s \
	-M lang="ja" \
	--template=$(PANDOC_TEMPLATE) \
	--highlight-style kate \
	-c https://unpkg.com/ress/dist/ress.min.css \
	-c /style.css \
	--mathjax

$(PUB_ENTRY_DIR)/%.html: $(SRC_ENTRY_DIR)/%.md $(PANDOC_TEMPLATE)
	@mkdir -p $(@D)
	pandoc $(PANDOC_FLAGS) -o $@ -V url=/$(ENTRY_DIR)/$*.html $<

$(PUB_ENTRY_DIR)/%: $(SRC_ENTRY_DIR)/%
	cp $< $@

all: $(PUB_ENTRIES) $(PUB_ENTRY_FILES) $(PUB_DIR)/index.html $(PUB_DIR)/style.css

$(OUT_DIR)/index.md: $(SRC_DIR)/make_index.sh $(SRC_ENTRIES)
	@mkdir -p $(@D)
	$(SRC_DIR)/make_index.sh > $@

$(PUB_DIR)/index.html: $(OUT_DIR)/index.md $(PANDOC_TEMPLATE)
	@mkdir -p $(@D)
	pandoc $(PANDOC_FLAGS) -o $@ -V url=/$(ENTRY_DIR)/index.html $<

$(PUB_DIR)/style.css: $(SRC_DIR)/style.sass
	@mkdir -p $(@D)
	sassc -a $< $@

clean:
	$(RM) -r $(OUT_DIR)

.PHONY: all clean
