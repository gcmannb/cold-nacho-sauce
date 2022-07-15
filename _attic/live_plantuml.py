#!/usr/bin/env python3
from sys import stderr
from livereload import Server, shell

server = Server()

server.watch('./diagram.puml', shell('/usr/bin/java -Djava.awt.headless=true  -jar /usr/local/Cellar/plantuml/1.2019.13/libexec/plantuml.jar -tsvg diagram.puml', cwd='.'))
server.serve(root='diagram.svg')


