#!/usr/bin/env python3
"""Register local Swift files in the native Xcode project without external tools."""
from pathlib import Path
import re
root=Path(__file__).resolve().parent.parent
p=root/'KawaiiRace.xcodeproj/project.pbxproj'
s=p.read_text()
s=re.sub(r'\n/\* AUTO SOURCES START \*/.*?/\* AUTO SOURCES END \*/\n','\n',s,flags=re.S)
files=sorted(str(f.relative_to(root)) for folder in ['Models','Data','Engine','ViewModels','Views','Components'] for f in (root/folder).rglob('*') if f.suffix in ['.swift', '.metal'])
refs=[]; builds=[]; objs=[]
for i,path in enumerate(files):
 ref=f'{100+i*2:024X}'; build=f'{101+i*2:024X}'
 refs.append(ref);builds.append(build)
 objs.extend([f'{ref} = {{ isa = PBXFileReference; lastKnownFileType = {('sourcecode.metal' if path.endswith('.metal') else 'sourcecode.swift')}; path = "{path}"; sourceTree = "<group>"; }};',f'{build} = {{ isa = PBXBuildFile; fileRef = {ref}; }};'])
s=re.sub(r'(000000000000000000000002 = \{ isa = PBXGroup; children = )\([^)]*\)',lambda m:m[1]+'('+','.join(['00000000000000000000001E','000000000000000000000005','000000000000000000000003']+refs)+')',s)
s=re.sub(r'(000000000000000000000008 = \{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = )\([^)]*\)',lambda m:m[1]+'('+','.join(['000000000000000000000007']+builds)+')',s)
s=s.replace('\n}; rootObject','\n/* AUTO SOURCES START */\n'+'\n'.join(objs)+'\n/* AUTO SOURCES END */\n}; rootObject')
p.write_text(s)
print(f'Registered {len(files)+1} Swift source files')
