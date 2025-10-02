# OS Definitions

## Introduction

Maru includes a custom grammar `osdefs.g` for generating constants for the current build environment. It's used to generate `osdefs.k` via `compile-osdefs.'.

An osdef file can be used to pull out constants that need to be passed through
to various APIs via the maru runtime. The system.osdefs file, for example, pulls
out build environment details.

## Where it sits in the lifecycle

OS Defs requires the interpreted version of Maru's `eval` to have successfully compiled. Additionally, it requires a valid C compiler to be present in the path.

## How to build
```shell
# Note: There are provisions for generating additional osdefs files
# system.osdefs is the default
$ make system.osdefs.k
```

## Defining a new osdefs file

Review the `osdefs.g` file for the grammar. The grammar is simple and should be easy to extend.



### example
```
header header1.h header2.h

integer __ELF__?

type size_t unsigned int

default FROTZ 1
```

