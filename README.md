oven
====

Simple, extendable static site generator written in Haxe
--------------------------------------------------------
[![Haxe 3.1.3 Tested](https://img.shields.io/badge/haxe-3.1.3-F68712.svg?style=flat)](http://haxe.org)
![version alpha](https://img.shields.io/badge/version-alpha-red.svg?style=flat)

Oven is a simple, yet *potentially* powerful "static site generator" written in Haxe. It is usually compiled to Neko, though it might be possible to compile it to different platforms which has access to the `Sys` package (such as PHP, Python, Java etc.).

Oven's power lie in its *plugins*, an idea inspired by [Metalsmith](http://metalsmith.io). This means that by itself, Oven is no more than a tool to read files from a source directory, call plugins to manipulate these files, and save them to an export directory. Since all the good-stuff happens in the plugins, Oven can be used as a lot more than a static site generator. It can be an image atlas packer, an Ebook creator, a build tool, a code documentation generator and more.

#### Installation
First, make sure you have Haxe installed. It comes bundled with haxelib + Neko, all of which are needed.

from haxelib *(not yet supported)*
```
haxelib install oven
```
from git
```
haxelib git oven https://github.com/leshido:oven
```