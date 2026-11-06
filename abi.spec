# What a stub needs to know of each C calling convention.  saved: what a called function must preserve; floats: the
# same, in pairs on arm64; scratch: registers a stub may use freely; args: integer arguments, in order; result: the return value;
# fargs, fresult and fscratch: the same for floating-point values (a 64-bit name, its 32-bit view taken by the lowering).
arm64	saved	X29 X30 X19 X20 X21 X22 X23 X24 X25 X26 X27 X28
arm64	floats	D8 D9 D10 D11 D12 D13 D14 D15
arm64	scratch	X9 X10 X11 X12 X16
arm64	args	X0 X1 X2 X3 X4 X5 X6 X7
arm64	result	X0
arm64	fargs	D0 D1 D2 D3 D4 D5 D6 D7
arm64	fresult	D0
arm64	fscratch	D16 D17
x64	saved	RBP RBX R12 R13 R14 R15
x64	floats
x64	scratch	R10 R9 R8 RCX R11
x64	args	RDI RSI RDX RCX R8 R9
x64	result	RAX
x64	fargs	XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
x64	fresult	XMM0
x64	fscratch	XMM8 XMM9
