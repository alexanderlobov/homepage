.RECIPEPREFIX = >
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.SHELLFLAGS := -eu -o pipefail -c

build_dir = build
post_dir = posts
site_dir = site
posts_md = $(wildcard $(post_dir)/*.md)
posts_html = $(patsubst $(post_dir)/%.md,$(site_dir)/%.html,$(posts_md))
posts_meta = $(patsubst $(post_dir)/%.md,$(build_dir)/%.meta,$(posts_md))
index=$(site_dir)/index.html
markdown = markdown -f fencedcode

.DELETE_ON_ERROR:

all: $(posts_html) $(index)

$(site_dir)/%.html $(build_dir)/%.meta: $(post_dir)/%.md process-md
> @mkdir -p $(site_dir)
> @mkdir -p $(build_dir)
> ./process-md <$< $(build_dir)/$*.meta $*.html | $(markdown) >$(site_dir)/$*.html 

$(index): index.head.md $(posts_meta) make-index
> ./make-index $< $(posts_meta) | $(markdown) >$@

run:
> nginx -c nginx.conf -p ${PWD}

clean:
> rm -rf $(build_dir)
> rm -rf $(site_dir)

.PHONY: all run clean
