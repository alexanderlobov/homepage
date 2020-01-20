.RECIPEPREFIX := >
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.SHELLFLAGS := -eu -o pipefail -c

build_dir := build
post_dir := posts
site_dir := site
posts_md := $(wildcard $(post_dir)/*.md)
posts_html := $(patsubst $(post_dir)/%.md,$(site_dir)/%.html,$(posts_md))
posts_meta := $(patsubst $(post_dir)/%.md,$(build_dir)/%.meta,$(posts_md))
index := $(site_dir)/index.html
css_file := default.css
css := $(site_dir)/$(css_file)
markdown := markdown -f fencedcode


export env_markdown=$(markdown)

.DELETE_ON_ERROR:

all: $(posts_html) $(index) $(css)

$(site_dir)/%.html $(build_dir)/%.meta: $(post_dir)/%.md process-md
> @mkdir -p $(site_dir)
> @mkdir -p $(build_dir)
> ./process-md <$< $(build_dir)/$*.meta $*.html >$(site_dir)/$*.html

$(index): $(posts_meta) make-index
> ./make-index $(posts_meta) >$@

$(css): $(css_file)
> cp $< $@

run:
> nginx -c nginx.conf -p ${PWD}

clean:
> rm -rf $(build_dir)
> rm -rf $(site_dir)

.PHONY: all run clean
