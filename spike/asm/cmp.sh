cd "$(dirname "$0")"
clang -target i386-pc-linux -c clang.s -o clang.o && llvm-objcopy -O binary --only-section=.text clang.o clang.bin && python3 - <<'PY'
b=open('clang.bin','rb').read(); i=0; bad=0; n=0
for line in open('ours.txt'):
    text,hx=line.rstrip('\n').split('\t'); ours=bytes.fromhex(hx); n+=1
    theirs=b[i:i+len(ours)]
    if ours!=theirs:
        bad+=1
        if bad<=15: print('DIFF',text,'| ours',ours.hex(' '),'| clang',theirs.hex(' '))
    i+=len(ours)
print(n,'compared,',bad,'differ; clang total',len(b),'ours total',i)
PY
