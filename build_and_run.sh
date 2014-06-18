#!/bin/bash
chmod 755 build_and_run.sh
sh find-node-or-install

# Make sure all packages are installed
echo ""
echo "Installing node packaged..."
npm install .
echo "Node packages installed!"
echo ""

# Make sure all files are build
echo "Compiling SASS"
sass stylesheets/main.scss stylesheets/main.css
echo "SASS compiled!"
echo ""

echo "Compiling CoffeeScripts"
node_modules/.bin/coffee -m -c javascripts/
echo "CoffeeScripts compiled!"
echo ""

echo "Compiling Jade"
node_modules/.bin/jade -P *
echo "Jade compiled!"
echo ""

echo "Compiling Handlebars"
node_modules/.bin/handlebars views/ -e hbs -m -f views/handlebars.js
echo "Handlebars compiled!"
echo

# use default port if called without args
PORT=2600 
if [[ $1 =~ ^[0-9]+$ ]]
  then PORT=$1
fi

echo "Starting local http server (ctrl-c to exit)"
echo ""
echo "Running at: http://127.0.0.1:$PORT/"
echo ""
open "http://127.0.0.1:$PORT/"
python -m SimpleHTTPServer $PORT