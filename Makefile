
COFFEE=node_modules/.bin/coffee
BOWER=node_modules/.bin/bower

all: lib/server.js client/js/site.js client/js/pikaday.js client/css/pikaday.css

run: all
	node lib/server.js

client/js/pikaday.js: bower_components/pikaday/pikaday.js
	cp $< $@
	
client/css/pikaday.css: bower_components/pikaday/css/pikaday.css
	cp $< $@

bower_components/pikaday/pikaday.js: ${BOWER}
	${BOWER} install pikaday

${BOWER}:
	npm install bower
	
client/js/site.js: lib/site.js
	cp $< $@

lib/%.js: src/%.coffee
	${COFFEE} -sc < $< > $@

${COFFEE}:
	npm install coffee-script
