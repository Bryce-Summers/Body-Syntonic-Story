# Body-Syntonic-Story
A language, compiler, and game engine for Body Syntonic visual storytelling.


#Play the current demo!
[Demo](https://bryce-summers.github.io/Body-Syntonic-Story/)


# Dependancies

- 6/18/2016: Three.JS (revision 77) for client side rendering.

# Development Dependancies
- Coffeescript, better object oriented programming syntax.
- Grunt, handles html file inclusion and building.
- npm, manages dependancies.

# Installation

Download grunt to inject the all of the files automatically.

You can probably just use:
npm install

// Initialize npm repository.
npm init

<!-- include: "type": "css", "files": "**/*.css" -->
<!-- /include -->
<!-- include: "type": "js", "files": "**/*.js" -->
<!-- /include -->

npm install
npm install grunt --save-dev
npm install grunt-contrib-uglify --save-dev
npm install grunt-contrib-watch --save-dev
npm install grunt-contrib-concat --save-dev
npm install grunt-include-source --save-dev


npm update

# Building
1. Open up two terminals.
2. Navigate each of them to the folder containing this README.
   It should also contain the index.html file and the Gruntfile.js
   For easy navigation, try shift+click on this fold in windows then choose open command promt here.
   On Linux it is not too difficult. On a map, try dragging the file into the terminal or something of that nature.

3. Automatically compile the coffeescript code to javascript in one terminal:
 coffee -o lib/ -cw src/
4. In the other you can automatically inject all of the source code links into the html file:
 npm install
 grunt

 5.It may be useful to install python 3 and run python -m http.server in a command prompt to run a local server.
