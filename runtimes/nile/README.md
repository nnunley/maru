# Nile Runtime Library

This directory contains the C runtime library for the Nile programming language.

## Overview

The Nile runtime provides the execution environment for compiled Nile programs. It implements:

- **Stream Processing**: Efficient buffer-based stream operations
- **Process Management**: Creation, composition, and execution of stream processes
- **Memory Management**: Custom memory allocator for stream buffers
- **Multi-threading**: Support for parallel stream processing
- **Built-in Operations**: Mathematical and stream manipulation operations

## Architecture

### Core Components

1. **nile.h/nile.c**: Main runtime API and implementation
   - Process lifecycle management
   - Runtime initialization/shutdown
   - Error handling

2. **nile-process.c**: Process implementation
   - Process creation and composition
   - Data flow between processes
   - Process scheduling

3. **nile-buffer.h**: Buffer management
   - Efficient stream data storage
   - Buffer allocation and recycling

4. **nile-builtins.c**: Built-in operations
   - Mathematical functions (sqrt, floor, ceil, etc.)
   - Stream operations (reverse, sort, duplicate, etc.)

5. **nile-heap.h**: Memory management
   - Custom heap allocator
   - Memory pooling for buffers

6. **nile-thread.h**: Threading support
   - Thread pool management
   - Work distribution

### Support Files

- **nile-deque.h**: Double-ended queue implementation
- **nile-sleep.h**: Cross-platform sleep functions
- **nile-platform.h**: Platform-specific definitions
- **nile.k**: Maru FFI bindings for the runtime

## Building

### Using GCC (Unix/Linux/macOS)
```bash
cd runtimes/nile
make -f Makefile.gcc
```

### Using MSVC (Windows)
```bash
cd runtimes/nile
nmake -f Makefile.msvc
```

## Usage

### From C

```c
#include "nile.h"

// Initialize runtime with 1MB heap and 4 threads
char memory[1024 * 1024];
nile_Process_t *init = nile_startup(memory, sizeof(memory), 4);

// Create and run a pipeline
nile_Process_t *pipeline = nile_Process_pipe(
    MyModule_Process1(init, param1),
    MyModule_Process2(init, param2),
    NULL);

// Feed data to the pipeline
float input_data[] = {1.0, 2.0, 3.0, 4.0};
nile_Process_feed(pipeline, input_data, 4);

// Wait for completion
nile_sync(init);

// Cleanup
nile_shutdown(init);
```

### From Maru

The `nile.k` file provides FFI bindings for using the runtime from Maru:

```lisp
(require "nile.k")

; Create a process
(define process (nile_Process init quantum sizeof-vars
                              prologue body epilogue))

; Pipe processes together
(define pipeline (nile_Process_pipe process1 process2 NULL))
```

## Process Model

Nile processes follow a three-phase execution model:

1. **Prologue**: One-time initialization before processing stream data
2. **Body**: Main processing loop that consumes input and produces output
3. **Epilogue**: Cleanup after all input has been processed

Each process operates on fixed-size buffers (quanta) of stream data, enabling:
- Efficient memory usage
- Cache-friendly data access
- Natural parallelization boundaries

## Thread Safety

The runtime supports multi-threaded execution with:
- Thread-safe process scheduling
- Lock-free buffer management where possible
- Work-stealing for load balancing

## Testing

The `test/` directory contains unit tests for various runtime components:
- `dupcat-test.c`: Tests stream duplication and concatenation
- `recip-test.c`: Tests reciprocal calculation
- `reverse-test.c`: Tests stream reversal
- `sort-test.c`: Tests sorting operations
- `startup-test.c`: Tests runtime initialization

Build and run tests:
```bash
cd test
make -f Makefile.gcc
./dupcat-test
```

## Integration with Nile Compiler

The Nile compiler (in `compilers/nile/`) generates C code that uses this runtime. The generated code:
1. Includes `nile.h`
2. Defines process structs and functions following the runtime's conventions
3. Uses runtime APIs for buffer management and process composition

## Performance Considerations

- **Buffer Size**: Default quantum size balances throughput and latency
- **Thread Count**: Best performance typically with threads = CPU cores
- **Memory Pool**: Pre-allocated memory avoids allocation overhead
- **SIMD**: Buffer layout enables SIMD optimization in process bodies

## License

Part of the Nile project, available under the MIT license.