argparse
=========

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

Feature-rich command line parser for Lua inspired by argparse for Python. 

WIP. 

TODO L1
=======

* Document NYI declarative interface. Choices, converters. 
* Write tests related to NYI declarative interface. 
* Implement NYI declarative interface. 

TODO L2
=======

* Document parsing. 
* Write tests related to parsing. 
* Refactor/rewrite parsing stuff. 
* Current Parser class should be just a container for information used in parsingm such as options, commands, etc. The relation between Parser and ParserState should be reversed; ParserState should be the actual parser; it should process args and query Parser when needed. 
* `-` shouldn't be the only character for options/flags. Infer all of them from first characters of option aliases. 
* Suggestions for command typos. E.g. `$ luarocks isntall` -> `Did you mean 'install'?`
