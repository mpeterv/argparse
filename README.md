# argparse

[![Build Status](https://travis-ci.org/mpeterv/argparse.png?branch=master)](https://travis-ci.org/mpeterv/argparse)

argparse is a feature-rich command line parser for Lua inspired by argparse for Python. 

## Contents

* [Status](#status)
* [Installation](#installation)
* [Tutorial](#tutorial)
* [Testing](#testing)
* [License](#license)

## Status

Almost everything is implemented, and a WIP version will be available soon. 

TODO till first release: 

* Add `Content` section to this README. 
* Add a small example to the beginning of this README. 
* Check the grammar in this README. 
* Generate .html file from the tutorial part of this README and put it into `doc` directory. 
* Write a rockspec for `v0.1` and push it to moonrocks. 

TODO till first 'stable' release: 

* Write a formal reference. 
* Write more tests. Some cases are still poorly covered. 
* Add mutually exclusive groups(`:mutex{option1, option2, ...}`). 
* Optionally(?): Add comments to the source. 
* Optionally: get rid of `30log` dependency. It's great but can cause problems with old luarocks versions. 

## Installation

### Using luarocks

Installing argparse using luarocks ~~is~~ will be easy. 

```bash
$ luarocks install argparse
```

#### Problems with old luarocks versions

You may get an error like `Parse error processing dependency '30log >= 0.8'` if you use luarocks 2.1 or older. In this case, either upgrade to at least luarocks 2.1.1 or install [30log](http://yonaba.github.io/30log/) manually, then download the rockspec for argparse, remove the line `"30log >= 0.8"` and run

```bash
$ luarocks install /path/to/argparse/rockspec
```

### Without luarocks

Download `/src/argparse.lua` file and put it into the directory for libraries or your working directory. Install 30log using luarocks or manually download `30log.lua` file from [30log repo](https://github.com/Yonaba/30log). 


## Tutorial

The tutorial is available [online](http://mpeterv.github.io/argparse/) and in the `doc` directory. If argparse was installed using luarocks 2.1.2 or later, it can be viewed using `luarocks doc argparse` command. 

## Testing

argparse comes with a testing suite located in `spec` directory. [busted](http://olivinelabs.com/busted/) is required for testing, it can be installed using luarocks. Run the tests using `busted spec` command from the argparse folder. 

## License

argparse is licensed under the same terms as Lua itself(MIT license). 
