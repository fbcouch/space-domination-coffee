# Space Domination (Coffee) #

**An AHS Gaming Production**

_(c) 2013 Jami Couch_

fbcouch 'at' gmail 'dot' com

Full source code available from and [https://github.com/fbcouch/space-domination-coffee]github.com/fbcouch

## BUILDING THE GAME ##

With nodejs:

    npm install
    grunt coffee

Without nodejs:

	coffee -o out/ -c src/*.coffee

## RUNNING THE GAME ##

With nodejs:

    grunt

Without nodejs:

	python -m SimpleHTTPServer

Then navigate to [http://localhost:8000]http://localhost:8000

## PLAYING THE GAME ##

Use WASD or arrow keys to control the ship:

* W/UP => accelerate
* S/DOWN => brake
* A/LEFT, D/RIGHT => rotate
* SPACE => fire weapon
* SHIFT => swap weapons
* ESC => pause/unpause

## LICENSE ##

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## LIBRARIES ##

CreateJS - licensed under the MIT license (see http://opensource.org/licenses/MIT for details).
	
	http://createjs.com

## ARTWORK ##

Unless otherwise noted, all artwork was created by Jami Couch and is licensed as CC-BY-SA.
