cd "$(dirname "$0")"
clang -target arm64-apple-macos -c aclang.s -o aclang.o 2>&1 | grep error | head -10
llvm-objcopy --dump-section __TEXT,__text=aclang.bin aclang.o /dev/null && python3 - <<'PY'
import struct
b=open('aclang.bin','rb').read(); words=struct.unpack('<%dI'%(len(b)//4),b); bad=0; n=0
for i,line in enumerate(open('aours.txt')):
    text,hx=line.rstrip('\n').split('\t'); ours=int(hx,16); n+=1
    theirs=words[i] if i<len(words) else None
    if ours!=theirs:
        bad+=1
        if bad<=15: print('DIFF',text,'| ours %08x'%ours,'| clang', theirs is not None and '%08x'%theirs)
print(n,'compared,',bad,'differ; clang words',len(words))
PY
