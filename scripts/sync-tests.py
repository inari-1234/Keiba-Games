#!/usr/bin/env python3
"""Register native XCTest targets without project-generation dependencies."""
from pathlib import Path
import re
root=Path(__file__).resolve().parent.parent
project=root/'KawaiiRace.xcodeproj/project.pbxproj'
s=project.read_text()
s=re.sub(r'\n/\* AUTO TESTS START \*/.*?/\* AUTO TESTS END \*/\n','\n',s,flags=re.S)
objects=[]; targets=[]; products=[]; groups=[]; testables=[]
def ident(n): return f'{n:024X}'
for folder,base,name,ui in [('Tests',2000,'KawaiiRaceTests',False),('UITests',2100,'KawaiiRaceUITests',True)]:
 files=sorted((root/folder).glob('*.swift'))
 if not files: continue
 ids=[ident(base+i) for i in range(10)]
 group,target,configs,sources,frameworks,product,debug,release,proxy,dependency=ids
 groups.append(group);targets.append(target);products.append(product)
 refs=[];builds=[]
 for index,path in enumerate(files):
  ref=ident(base+10+index*2);build=ident(base+11+index*2)
  refs.append(ref);builds.append(build)
  objects += [f'{ref} = {{ isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path.relative_to(root)}"; sourceTree = "<group>"; }};',f'{build} = {{ isa = PBXBuildFile; fileRef = {ref}; }};']
 objects += [f'{group} = {{ isa = PBXGroup; children = ({",".join(refs)}); name = {folder}; sourceTree = "<group>"; }};',
 f'{target} = {{ isa = PBXNativeTarget; buildConfigurationList = {configs}; buildPhases = ({sources},{frameworks}); buildRules = (); dependencies = ({dependency}); name = {name}; productName = {name}; productReference = {product}; productType = "com.apple.product-type.bundle.{"ui-testing" if ui else "unit-test"}"; }};',
 f'{configs} = {{ isa = XCConfigurationList; buildConfigurations = ({debug},{release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};',
 f'{sources} = {{ isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ({",".join(builds)}); runOnlyForDeploymentPostprocessing = 0; }};',
 f'{frameworks} = {{ isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};',
 f'{product} = {{ isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {name}.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};',
 f'{proxy} = {{ isa = PBXContainerItemProxy; containerPortal = {ident(1)}; proxyType = 1; remoteGlobalIDString = {ident(4)}; remoteInfo = KawaiiRace; }};',
 f'{dependency} = {{ isa = PBXTargetDependency; target = {ident(4)}; targetProxy = {proxy}; }};']
 host='TEST_TARGET_NAME = KawaiiRace;' if ui else 'BUNDLE_LOADER = "$(TEST_HOST)"; TEST_HOST = "$(BUILT_PRODUCTS_DIR)/KawaiiRace.app/KawaiiRace";'
 for configID,configName in [(debug,'Debug'),(release,'Release')]:
  objects.append(f'{configID} = {{ isa = XCBuildConfiguration; buildSettings = {{ PRODUCT_BUNDLE_IDENTIFIER = com.inari.{name}; PRODUCT_NAME = "$(TARGET_NAME)"; GENERATE_INFOPLIST_FILE = YES; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = 1; CODE_SIGN_STYLE = Automatic; LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"; {host} }}; name = {configName}; }};')
 testables.append(f'<TestableReference skipped="NO"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target}" BuildableName="{name}.xctest" BlueprintName="{name}" ReferencedContainer="container:KawaiiRace.xcodeproj"/></TestableReference>')
s=re.sub(r'targets = \([^)]*\);',f'targets = ({",".join([ident(4)]+targets)});',s,count=1)
s=re.sub(r'('+ident(3)+r' = \{ isa = PBXGroup; children = )\([^)]*\)',lambda m:m[1]+'('+','.join([ident(6)]+products)+')',s)
s=re.sub(r'('+ident(2)+r' = \{ isa = PBXGroup; children = )\(([^)]*)\)',lambda m:m[1]+'('+','.join([x for x in m[2].split(',') if x not in [ident(2000),ident(2100)]]+groups)+')',s)
s=s.replace('\n}; rootObject','\n/* AUTO TESTS START */\n'+'\n'.join(objects)+'\n/* AUTO TESTS END */\n}; rootObject')
project.write_text(s)
scheme=root/'KawaiiRace.xcodeproj/xcshareddata/xcschemes/KawaiiRace.xcscheme'
s=scheme.read_text()
s=re.sub(r'<Testables\s*/>|<Testables>.*?</Testables>','<Testables>'+''.join(testables)+'</Testables>',s,flags=re.S)
scheme.write_text(s)
print('Registered XCTest targets:',len(targets))
