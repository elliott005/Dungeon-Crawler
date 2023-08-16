# Fichier GNU Makefile pour DungeonCrawler.lua
# Voir en ligne https://GitHub.com/Naereen/DungeonCrawler.lua pour plus d'informations
# © Elliot, août 2023
#

build_lovezip:
	zip -r DungeonCrawler.zip ./*.lua ./*.ttf ./README.md ./LICENSE ./images ./libraries ./maps ./sound
	mv -vf DungeonCrawler.zip DungeonCrawler.love

build_lovejs:	build_lovezip
# npx love.js [options] <input> <output>
	npx love.js --compatibility --title "dungeon crawler ~ By Elliott" --memory 70000000 ./DungeonCrawler.love www/
# git restore www/index.html

test_lovejs:
	firefox http://localhost:8910/ &
	cd www/ && python3 -m http.server 8910

send_server:
	rsync --exclude=.git --ipv4 --verbose --times --perms --compress --human-readable --progress --archive ./www/ TODO:path:to:server/TODO
	firefox https://perso.crans.org/besson/publis/DungeonCrawler.lua/

#install_dependencies:
#	# sudo apt install nodejs npm
#	# npm install npx love.js
