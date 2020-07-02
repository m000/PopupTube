RM             = rm -vf
CP             = cp -vf
J2             = j2 --undefined=strict --

CONFIG        ?= conf/server.json conf/movie.json $(wildcard conf/*.local.json)
NGINX_TPL     ?= nginx.conf.j2
STREAM_CONFIG  = movie.json
MOVIES         = movies
HTML_DEFAULT   = dash.html
HTML_DEFAULT_POSTER = nginx/html/images/technical-problems-bw.jpg

# .SECONDEXPANSION needed for nginx/html/%.html
.SECONDEXPANSION:

.PHONY: all clean run stream-% html-%
.PRECIOUS: run.cmd stream-%.cmd
.SECONDARY: $$(wildcard nginx/html/%/*.html)

# recipes for files
%.cmd: tpl/cmd/%.cmd.j2 $(CONFIG)
	$(J2) $(^) > $(@)
	chmod 755 $(@)

stream-%.cmd: tpl/cmd/stream.cmd.j2 $(CONFIG) $(MOVIES)/%/$(STREAM_CONFIG)
	MOVIEDIR="$(MOVIES)/$(*)" $(J2) $(<) $(filter %.json,$(^)) > $(@)
	chmod 755 $(@)

nginx/html/%.html: tpl/html/$$(notdir %).html.j2 $(wildcard tpl/html/_*.html.j2) $(CONFIG) $(MOVIES)/$$(dir %)$(STREAM_CONFIG)
	mkdir -p $(@D)
	MOVIEDIR=$(MOVIES)/$(*D) $(J2) $(<) $(filter %.json,$(^)) > $(@)

nginx/html/%/index.html: nginx/html/%/$(HTML_DEFAULT)
	cd $(@D) && ln -sf $(HTML_DEFAULT) $(@F)

html-%: $(addprefix nginx/html/%/,dash.html hls.html index.html)
	$(CP) $(wildcard $(MOVIES)/$(*)/*.jpg) $(HTML_DEFAULT_POSTER) nginx/html/$(*)/

# actions
all: nginx/conf/nginx.conf run.cmd

nginx/conf/nginx.conf: tpl/conf/$(NGINX_TPL)
	$(J2) $(<) $(CONFIG) > $(@)

run: run.cmd | all
	./$(@).cmd

stream-%: stream-%.cmd | all html-%
	./$(@).cmd

clean:
	$(RM) $(wildcard *.cmd)
	sudo $(RM) -r $(wildcard nginx/tmp/*)

