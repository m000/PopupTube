RM            = rm -f
J2            = j2 --undefined=strict --

CONFIG       ?= bfpstream
CONFIG_ALL    = $(wildcard conf/$(CONFIG)*.json)

HTML          = $(addprefix nginx/html/$(CONFIG)/,index.html dash.html hls.html)
HTML_DEFAULT  = hls.html

%.cmd: tpl/%.cmd.j2 $(CONFIG_ALL)
	$(J2) $(<) $(CONFIG_ALL) > $(@)
	chmod 755 $(@)

nginx/html/$(CONFIG)/%.html: tpl/%.html.j2 $(wildcard tpl/include/*.j2) $(CONFIG_ALL)
	mkdir -p $(@D)
	$(J2) $(<) $(CONFIG_ALL) > $(@)

nginx/conf/%.conf: tpl/%.conf.j2 $(CONFIG_ALL)
	$(J2) $(<) $(CONFIG_ALL) > $(@)

.PHONY: all run stream

all: nginx/conf/$(CONFIG).conf $(HTML) run.cmd stream.cmd

nginx/html/$(CONFIG)/index.html: nginx/html/$(CONFIG)/$(HTML_DEFAULT)
	cd $(@D) && ln -sf $(HTML_DEFAULT) $(@F)

run: run.cmd | all
	./$(@).cmd
	$(RM) $(@).cmd

stream: stream.cmd | all
	./$(@).cmd
	$(RM) $(@).cmd

