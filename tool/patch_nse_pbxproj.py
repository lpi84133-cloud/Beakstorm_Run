#!/usr/bin/env python3
"""Wire GustNotification NSE + plist resources into Runner.xcodeproj."""

from pathlib import Path

ROOT = Path("/Users/vic/Desktop/ios/Beakstorm-Run/ios/Runner.xcodeproj/project.pbxproj")
txt = ROOT.read_bytes().decode("utf-8").replace("\r\n", "\n")
if txt.startswith("\ufeff"):
    raise SystemExit("BOM present")
if "GustNotification" in txt:
    print("already patched")
    raise SystemExit(0)

T = "\t"

def blk(*lines: str) -> str:
    return "\n".join(lines) + "\n"

# --- PBXBuildFile ---
txt = txt.replace(
    "/* End PBXBuildFile section */",
    blk(
        f"{T}{T}5C116A488E0480E8C1029C72 /* NotificationService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = 9A3A775EB4B6D9D8C050AFD5 /* NotificationService.swift */; }};",
        f"{T}{T}8DFD8FD05E360162A69E28F9 /* GoogleService-Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = DC5C5333A47021159038F33C /* GoogleService-Info.plist */; }};",
        f"{T}{T}6552FA91DEC45DDC252479EF /* PrivacyInfo.xcprivacy in Resources */ = {{isa = PBXBuildFile; fileRef = C008DE55C2BCC1E7C1331F05 /* PrivacyInfo.xcprivacy */; }};",
        f"{T}{T}3D788746DE3F239D2FD507A9 /* GustNotification.appex in Embed App Extensions */ = {{isa = PBXBuildFile; fileRef = A256C0ACEC9CB8C209E3B746 /* GustNotification.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};",
        f"{T}{T}60D9ACA354537AECB1D16EED /* Pods_GustNotification.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = 9424D645CC4A81D630BC7E7D /* Pods_GustNotification.framework */; }};",
        "/* End PBXBuildFile section */",
    ),
)

# --- PBXContainerItemProxy ---
txt = txt.replace(
    "/* End PBXContainerItemProxy section */",
    blk(
        f"{T}{T}FEE6ADD7697E33A89316278B /* PBXContainerItemProxy */ = {{",
        f"{T}{T}{T}isa = PBXContainerItemProxy;",
        f"{T}{T}{T}containerPortal = 97C146E61CF9000F007C117D /* Project object */;",
        f"{T}{T}{T}proxyType = 1;",
        f"{T}{T}{T}remoteGlobalIDString = 7E31DE9B9E54DA13E4ED1952;",
        f"{T}{T}{T}remoteInfo = GustNotification;",
        f"{T}{T}}};",
        "/* End PBXContainerItemProxy section */",
    ),
)

# --- Embed App Extensions phase ---
txt = txt.replace(
    "/* End PBXCopyFilesBuildPhase section */",
    blk(
        f"{T}{T}3BA8AD8530E29FB4C4E4A56A /* Embed App Extensions */ = {{",
        f"{T}{T}{T}isa = PBXCopyFilesBuildPhase;",
        f"{T}{T}{T}buildActionMask = 2147483647;",
        f'{T}{T}{T}dstPath = "";',
        f"{T}{T}{T}dstSubfolderSpec = 13;",
        f"{T}{T}{T}files = (",
        f"{T}{T}{T}{T}3D788746DE3F239D2FD507A9 /* GustNotification.appex in Embed App Extensions */,",
        f"{T}{T}{T});",
        f'{T}{T}{T}name = "Embed App Extensions";',
        f"{T}{T}{T}runOnlyForDeploymentPostprocessing = 0;",
        f"{T}{T}}};",
        "/* End PBXCopyFilesBuildPhase section */",
    ),
)

# --- File refs ---
txt = txt.replace(
    "/* End PBXFileReference section */",
    blk(
        f'{T}{T}DC5C5333A47021159038F33C /* GoogleService-Info.plist */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; }};',
        f"{T}{T}C008DE55C2BCC1E7C1331F05 /* PrivacyInfo.xcprivacy */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; path = PrivacyInfo.xcprivacy; sourceTree = \"<group>\"; }};",
        f"{T}{T}E7FB4BDFE7A99FC0DAB97E65 /* Runner.entitlements */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.entitlements; path = Runner.entitlements; sourceTree = \"<group>\"; }};",
        f"{T}{T}9A3A775EB4B6D9D8C050AFD5 /* NotificationService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotificationService.swift; sourceTree = \"<group>\"; }};",
        f"{T}{T}0BB1268592A45F4EE5DA2B4B /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};",
        f'{T}{T}A256C0ACEC9CB8C209E3B746 /* GustNotification.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = GustNotification.appex; sourceTree = BUILT_PRODUCTS_DIR; }};',
        f"{T}{T}9424D645CC4A81D630BC7E7D /* Pods_GustNotification.framework */ = {{isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = Pods_GustNotification.framework; sourceTree = BUILT_PRODUCTS_DIR; }};",
        f'{T}{T}CAB79379A0E32FE5CF802FE6 /* Pods-GustNotification.debug.xcconfig */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-GustNotification.debug.xcconfig"; path = "Target Support Files/Pods-GustNotification/Pods-GustNotification.debug.xcconfig"; sourceTree = "<group>"; }};',
        f'{T}{T}34C46CE051421973BA064EC5 /* Pods-GustNotification.release.xcconfig */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-GustNotification.release.xcconfig"; path = "Target Support Files/Pods-GustNotification/Pods-GustNotification.release.xcconfig"; sourceTree = "<group>"; }};',
        f'{T}{T}E3B95C3DD47500B04D46B63D /* Pods-GustNotification.profile.xcconfig */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-GustNotification.profile.xcconfig"; path = "Target Support Files/Pods-GustNotification/Pods-GustNotification.profile.xcconfig"; sourceTree = "<group>"; }};',
        "/* End PBXFileReference section */",
    ),
)

# --- Frameworks phase for NSE ---
txt = txt.replace(
    "/* End PBXFrameworksBuildPhase section */",
    blk(
        f"{T}{T}62501C8F918864A61845BC2C /* Frameworks */ = {{",
        f"{T}{T}{T}isa = PBXFrameworksBuildPhase;",
        f"{T}{T}{T}buildActionMask = 2147483647;",
        f"{T}{T}{T}files = (",
        f"{T}{T}{T}{T}60D9ACA354537AECB1D16EED /* Pods_GustNotification.framework in Frameworks */,",
        f"{T}{T}{T});",
        f"{T}{T}{T}runOnlyForDeploymentPostprocessing = 0;",
        f"{T}{T}}};",
        "/* End PBXFrameworksBuildPhase section */",
    ),
)

# --- Groups ---
txt = txt.replace(
    "4BCE262BABB0693A9EF56EB3 /* Pods_RunnerTests.framework */,\n",
    "4BCE262BABB0693A9EF56EB3 /* Pods_RunnerTests.framework */,\n"
    f"{T}{T}{T}{T}9424D645CC4A81D630BC7E7D /* Pods_GustNotification.framework */,\n",
)

txt = txt.replace(
    "C97B4A9F1B9DE32891ED8C71 /* Pods-RunnerTests.profile.xcconfig */,\n",
    "C97B4A9F1B9DE32891ED8C71 /* Pods-RunnerTests.profile.xcconfig */,\n"
    f'{T}{T}{T}{T}CAB79379A0E32FE5CF802FE6 /* Pods-GustNotification.debug.xcconfig */,\n'
    f'{T}{T}{T}{T}34C46CE051421973BA064EC5 /* Pods-GustNotification.release.xcconfig */,\n'
    f'{T}{T}{T}{T}E3B95C3DD47500B04D46B63D /* Pods-GustNotification.profile.xcconfig */,\n',
)

txt = txt.replace(
    "97C146F01CF9000F007C117D /* Runner */,\n",
    "97C146F01CF9000F007C117D /* Runner */,\n"
    f"{T}{T}{T}{T}4545727FE48499AB1A4A22DD /* GustNotification */,\n",
)

txt = txt.replace(
    "331C8081294A63A400263BE5 /* RunnerTests.xctest */,\n",
    "331C8081294A63A400263BE5 /* RunnerTests.xctest */,\n"
    f"{T}{T}{T}{T}A256C0ACEC9CB8C209E3B746 /* GustNotification.appex */,\n",
)

txt = txt.replace(
    "74858FAD1ED2DC5600515810 /* Runner-Bridging-Header.h */,\n",
    "74858FAD1ED2DC5600515810 /* Runner-Bridging-Header.h */,\n"
    f"{T}{T}{T}{T}DC5C5333A47021159038F33C /* GoogleService-Info.plist */,\n"
    f"{T}{T}{T}{T}C008DE55C2BCC1E7C1331F05 /* PrivacyInfo.xcprivacy */,\n"
    f"{T}{T}{T}{T}E7FB4BDFE7A99FC0DAB97E65 /* Runner.entitlements */,\n",
)

txt = txt.replace(
    "/* End PBXGroup section */",
    blk(
        f"{T}{T}4545727FE48499AB1A4A22DD /* GustNotification */ = {{",
        f"{T}{T}{T}isa = PBXGroup;",
        f"{T}{T}{T}children = (",
        f"{T}{T}{T}{T}9A3A775EB4B6D9D8C050AFD5 /* NotificationService.swift */,",
        f"{T}{T}{T}{T}0BB1268592A45F4EE5DA2B4B /* Info.plist */,",
        f"{T}{T}{T});",
        f"{T}{T}{T}path = GustNotification;",
        f'{T}{T}{T}sourceTree = "<group>";',
        f"{T}{T}}};",
        "/* End PBXGroup section */",
    ),
)

# --- Native target NSE + Runner phases/deps ---
txt = txt.replace(
    "/* End PBXNativeTarget section */",
    blk(
        f"{T}{T}7E31DE9B9E54DA13E4ED1952 /* GustNotification */ = {{",
        f"{T}{T}{T}isa = PBXNativeTarget;",
        f'{T}{T}{T}buildConfigurationList = 91D42D50E6D2876165EAE653 /* Build configuration list for PBXNativeTarget "GustNotification" */;',
        f"{T}{T}{T}buildPhases = (",
        f"{T}{T}{T}{T}01196C16977EAF8774BBB20B /* [CP] Check Pods Manifest.lock */,",
        f"{T}{T}{T}{T}D6213369DCF168E7A61B67FE /* Sources */,",
        f"{T}{T}{T}{T}62501C8F918864A61845BC2C /* Frameworks */,",
        f"{T}{T}{T}{T}40C20313A838CFCF89C528B0 /* Resources */,",
        f"{T}{T}{T});",
        f"{T}{T}{T}buildRules = (",
        f"{T}{T}{T});",
        f"{T}{T}{T}dependencies = (",
        f"{T}{T}{T});",
        f"{T}{T}{T}name = GustNotification;",
        f"{T}{T}{T}productName = GustNotification;",
        f"{T}{T}{T}productReference = A256C0ACEC9CB8C209E3B746 /* GustNotification.appex */;",
        f'{T}{T}{T}productType = "com.apple.product-type.app-extension";',
        f"{T}{T}}};",
        "/* End PBXNativeTarget section */",
    ),
)

txt = txt.replace(
    "9705A1C41CF9048500538489 /* Embed Frameworks */,\n"
    f"{T}{T}{T}{T}3B06AD1E1E4923F5004D2608 /* Thin Binary */,",
    "9705A1C41CF9048500538489 /* Embed Frameworks */,\n"
    f"{T}{T}{T}{T}3BA8AD8530E29FB4C4E4A56A /* Embed App Extensions */,\n"
    f"{T}{T}{T}{T}3B06AD1E1E4923F5004D2608 /* Thin Binary */,",
)

txt = txt.replace(
    "			dependencies = (\n"
    "			);\n"
    "			name = Runner;",
    "			dependencies = (\n"
    f"{T}{T}{T}{T}ADC3A50EEAC18E23E7B91853 /* PBXTargetDependency */,\n"
    "			);\n"
    "			name = Runner;",
)

txt = txt.replace(
    "				TargetAttributes = {\n"
    "					331C8080294A63A400263BE5 = {",
    "				TargetAttributes = {\n"
    "					7E31DE9B9E54DA13E4ED1952 = {\n"
    "						CreatedOnToolsVersion = 16.4;\n"
    "					};\n"
    "					331C8080294A63A400263BE5 = {",
)

txt = txt.replace(
    "				331C8080294A63A400263BE5 /* RunnerTests */,\n"
    "			);",
    "				331C8080294A63A400263BE5 /* RunnerTests */,\n"
    "				7E31DE9B9E54DA13E4ED1952 /* GustNotification */,\n"
    "			);",
)

# --- Resources ---
txt = txt.replace(
    "97C146FC1CF9000F007C117D /* Main.storyboard in Resources */,\n",
    "97C146FC1CF9000F007C117D /* Main.storyboard in Resources */,\n"
    f"{T}{T}{T}{T}8DFD8FD05E360162A69E28F9 /* GoogleService-Info.plist in Resources */,\n"
    f"{T}{T}{T}{T}6552FA91DEC45DDC252479EF /* PrivacyInfo.xcprivacy in Resources */,\n",
)

txt = txt.replace(
    "/* End PBXResourcesBuildPhase section */",
    blk(
        f"{T}{T}40C20313A838CFCF89C528B0 /* Resources */ = {{",
        f"{T}{T}{T}isa = PBXResourcesBuildPhase;",
        f"{T}{T}{T}buildActionMask = 2147483647;",
        f"{T}{T}{T}files = (",
        f"{T}{T}{T});",
        f"{T}{T}{T}runOnlyForDeploymentPostprocessing = 0;",
        f"{T}{T}}};",
        "/* End PBXResourcesBuildPhase section */",
    ),
)

# --- NSE Check Pods ---
txt = txt.replace(
    "/* End PBXShellScriptBuildPhase section */",
    blk(
        f"{T}{T}01196C16977EAF8774BBB20B /* [CP] Check Pods Manifest.lock */ = {{",
        f"{T}{T}{T}isa = PBXShellScriptBuildPhase;",
        f"{T}{T}{T}buildActionMask = 2147483647;",
        f"{T}{T}{T}files = (",
        f"{T}{T}{T});",
        f"{T}{T}{T}inputFileListPaths = (",
        f"{T}{T}{T});",
        f"{T}{T}{T}inputPaths = (",
        f'{T}{T}{T}{T}"${{PODS_PODFILE_DIR_PATH}}/Podfile.lock",',
        f'{T}{T}{T}{T}"${{PODS_ROOT}}/Manifest.lock",',
        f"{T}{T}{T});",
        f'{T}{T}{T}name = "[CP] Check Pods Manifest.lock";',
        f"{T}{T}{T}outputFileListPaths = (",
        f"{T}{T}{T});",
        f"{T}{T}{T}outputPaths = (",
        f'{T}{T}{T}{T}"$(DERIVED_FILE_DIR)/Pods-GustNotification-checkManifestLockResult.txt",',
        f"{T}{T}{T});",
        f"{T}{T}{T}runOnlyForDeploymentPostprocessing = 0;",
        f"{T}{T}{T}shellPath = /bin/sh;",
        f'{T}{T}{T}shellScript = "diff \\"${{PODS_PODFILE_DIR_PATH}}/Podfile.lock\\" \\"${{PODS_ROOT}}/Manifest.lock\\" > /dev/null\\nif [ $? != 0 ] ; then\\n    echo \\"error: The sandbox is not in sync with the Podfile.lock. Run \'pod install\' or update your CocoaPods installation.\\" >&2\\n    exit 1\\nfi\\necho \\"SUCCESS\\" > \\"${{SCRIPT_OUTPUT_FILE_0}}\\"\\n";',
        f"{T}{T}{T}showEnvVarsInLog = 0;",
        f"{T}{T}}};",
        "/* End PBXShellScriptBuildPhase section */",
    ),
)

# --- NSE Sources ---
txt = txt.replace(
    "/* End PBXSourcesBuildPhase section */",
    blk(
        f"{T}{T}D6213369DCF168E7A61B67FE /* Sources */ = {{",
        f"{T}{T}{T}isa = PBXSourcesBuildPhase;",
        f"{T}{T}{T}buildActionMask = 2147483647;",
        f"{T}{T}{T}files = (",
        f"{T}{T}{T}{T}5C116A488E0480E8C1029C72 /* NotificationService.swift in Sources */,",
        f"{T}{T}{T});",
        f"{T}{T}{T}runOnlyForDeploymentPostprocessing = 0;",
        f"{T}{T}}};",
        "/* End PBXSourcesBuildPhase section */",
    ),
)

# --- Target dependency ---
txt = txt.replace(
    "/* End PBXTargetDependency section */",
    blk(
        f"{T}{T}ADC3A50EEAC18E23E7B91853 /* PBXTargetDependency */ = {{",
        f"{T}{T}{T}isa = PBXTargetDependency;",
        f"{T}{T}{T}target = 7E31DE9B9E54DA13E4ED1952 /* GustNotification */;",
        f"{T}{T}{T}targetProxy = FEE6ADD7697E33A89316278B /* PBXContainerItemProxy */;",
        f"{T}{T}}};",
        "/* End PBXTargetDependency section */",
    ),
)

# --- Entitlements on Runner configs ---
for marker in (
    "		249021D4217E4FDB00AE95B9 /* Profile */ = {",
    "		97C147061CF9000F007C117D /* Debug */ = {",
    "		97C147071CF9000F007C117D /* Release */ = {",
):
    needle = marker + "\n			isa = XCBuildConfiguration;\n"
    # Find the PRODUCT_BUNDLE_IDENTIFIER line in each Runner config and insert CODE_SIGN_ENTITLEMENTS before it
    pass

# Safer: insert CODE_SIGN_ENTITLEMENTS next to DEVELOPMENT_TEAM in the three Runner target configs
# Profile 249021D4, Debug 97C14706, Release 97C14707 — they all have DEVELOPMENT_TEAM then ENABLE_BITCODE
txt = txt.replace(
    "				DEVELOPMENT_TEAM = Q946GDB53X;\n				ENABLE_BITCODE = NO;\n				INFOPLIST_FILE = Runner/Info.plist;",
    "				CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;\n				DEVELOPMENT_TEAM = Q946GDB53X;\n				ENABLE_BITCODE = NO;\n				INFOPLIST_FILE = Runner/Info.plist;",
)

# --- NSE build configs ---
txt = txt.replace(
    "/* End XCBuildConfiguration section */",
    blk(
        f"{T}{T}C3892770FB2D3456C5086D05 /* Debug */ = {{",
        f"{T}{T}{T}isa = XCBuildConfiguration;",
        f"{T}{T}{T}baseConfigurationReference = CAB79379A0E32FE5CF802FE6 /* Pods-GustNotification.debug.xcconfig */;",
        f"{T}{T}{T}buildSettings = {{",
        f"{T}{T}{T}{T}CODE_SIGN_STYLE = Automatic;",
        f"{T}{T}{T}{T}CURRENT_PROJECT_VERSION = 1;",
        f"{T}{T}{T}{T}DEVELOPMENT_TEAM = Q946GDB53X;",
        f"{T}{T}{T}{T}ENABLE_BITCODE = NO;",
        f"{T}{T}{T}{T}INFOPLIST_FILE = GustNotification/Info.plist;",
        f"{T}{T}{T}{T}IPHONEOS_DEPLOYMENT_TARGET = 15.0;",
        f"{T}{T}{T}{T}MARKETING_VERSION = 1.0;",
        f"{T}{T}{T}{T}PRODUCT_BUNDLE_IDENTIFIER = com.beakstormrun.beakstormrungame.NotificationService;",
        f'{T}{T}{T}{T}PRODUCT_NAME = "$(TARGET_NAME)";',
        f"{T}{T}{T}{T}SDKROOT = iphoneos;",
        f"{T}{T}{T}{T}SKIP_INSTALL = YES;",
        f'{T}{T}{T}{T}SWIFT_OPTIMIZATION_LEVEL = "-Onone";',
        f"{T}{T}{T}{T}SWIFT_VERSION = 5.0;",
        f'{T}{T}{T}{T}TARGETED_DEVICE_FAMILY = "1,2";',
        f"{T}{T}{T}}};",
        f"{T}{T}{T}name = Debug;",
        f"{T}{T}}};",
        f"{T}{T}FB527462AE804054B9CB02A9 /* Release */ = {{",
        f"{T}{T}{T}isa = XCBuildConfiguration;",
        f"{T}{T}{T}baseConfigurationReference = 34C46CE051421973BA064EC5 /* Pods-GustNotification.release.xcconfig */;",
        f"{T}{T}{T}buildSettings = {{",
        f"{T}{T}{T}{T}CODE_SIGN_STYLE = Automatic;",
        f"{T}{T}{T}{T}CURRENT_PROJECT_VERSION = 1;",
        f"{T}{T}{T}{T}DEVELOPMENT_TEAM = Q946GDB53X;",
        f"{T}{T}{T}{T}ENABLE_BITCODE = NO;",
        f"{T}{T}{T}{T}INFOPLIST_FILE = GustNotification/Info.plist;",
        f"{T}{T}{T}{T}IPHONEOS_DEPLOYMENT_TARGET = 15.0;",
        f"{T}{T}{T}{T}MARKETING_VERSION = 1.0;",
        f"{T}{T}{T}{T}PRODUCT_BUNDLE_IDENTIFIER = com.beakstormrun.beakstormrungame.NotificationService;",
        f'{T}{T}{T}{T}PRODUCT_NAME = "$(TARGET_NAME)";',
        f"{T}{T}{T}{T}SDKROOT = iphoneos;",
        f"{T}{T}{T}{T}SKIP_INSTALL = YES;",
        f"{T}{T}{T}{T}SWIFT_VERSION = 5.0;",
        f'{T}{T}{T}{T}TARGETED_DEVICE_FAMILY = "1,2";',
        f"{T}{T}{T}}};",
        f"{T}{T}{T}name = Release;",
        f"{T}{T}}};",
        f"{T}{T}735AA103FCD3C4AF45E4A396 /* Profile */ = {{",
        f"{T}{T}{T}isa = XCBuildConfiguration;",
        f"{T}{T}{T}baseConfigurationReference = E3B95C3DD47500B04D46B63D /* Pods-GustNotification.profile.xcconfig */;",
        f"{T}{T}{T}buildSettings = {{",
        f"{T}{T}{T}{T}CODE_SIGN_STYLE = Automatic;",
        f"{T}{T}{T}{T}CURRENT_PROJECT_VERSION = 1;",
        f"{T}{T}{T}{T}DEVELOPMENT_TEAM = Q946GDB53X;",
        f"{T}{T}{T}{T}ENABLE_BITCODE = NO;",
        f"{T}{T}{T}{T}INFOPLIST_FILE = GustNotification/Info.plist;",
        f"{T}{T}{T}{T}IPHONEOS_DEPLOYMENT_TARGET = 15.0;",
        f"{T}{T}{T}{T}MARKETING_VERSION = 1.0;",
        f"{T}{T}{T}{T}PRODUCT_BUNDLE_IDENTIFIER = com.beakstormrun.beakstormrungame.NotificationService;",
        f'{T}{T}{T}{T}PRODUCT_NAME = "$(TARGET_NAME)";',
        f"{T}{T}{T}{T}SDKROOT = iphoneos;",
        f"{T}{T}{T}{T}SKIP_INSTALL = YES;",
        f"{T}{T}{T}{T}SWIFT_VERSION = 5.0;",
        f'{T}{T}{T}{T}TARGETED_DEVICE_FAMILY = "1,2";',
        f"{T}{T}{T}}};",
        f"{T}{T}{T}name = Profile;",
        f"{T}{T}}};",
        "/* End XCBuildConfiguration section */",
    ),
)

txt = txt.replace(
    "/* End XCConfigurationList section */",
    blk(
        f'{T}{T}91D42D50E6D2876165EAE653 /* Build configuration list for PBXNativeTarget "GustNotification" */ = {{',
        f"{T}{T}{T}isa = XCConfigurationList;",
        f"{T}{T}{T}buildConfigurations = (",
        f"{T}{T}{T}{T}C3892770FB2D3456C5086D05 /* Debug */,",
        f"{T}{T}{T}{T}FB527462AE804054B9CB02A9 /* Release */,",
        f"{T}{T}{T}{T}735AA103FCD3C4AF45E4A396 /* Profile */,",
        f"{T}{T}{T});",
        f"{T}{T}{T}defaultConfigurationIsVisible = 0;",
        f"{T}{T}{T}defaultConfigurationName = Release;",
        f"{T}{T}}};",
        "/* End XCConfigurationList section */",
    ),
)

if "\\t" in txt:
    raise SystemExit("literal \\t leaked")
if txt.count("CODE_SIGN_ENTITLEMENTS") != 3:
    raise SystemExit(f"entitlements count {txt.count('CODE_SIGN_ENTITLEMENTS')}")

g0 = txt.find("/* Begin PBXGroup section */")
g1 = txt.find("/* End PBXGroup section */")
if "4545727FE48499AB1A4A22DD" not in txt[g0:g1]:
    raise SystemExit("NSE group outside PBXGroup section")

ROOT.write_bytes(txt.encode("utf-8"))
print("pbxproj patched OK")
