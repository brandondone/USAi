function Component() {
}

var targetDirectory;
Component.prototype.beginInstallation = function() {
    targetDirectory = installer.value("TargetDir");
};

Component.prototype.createOperations = function() {
    try {
        // call the base create operations function
        component.createOperations();
        if (systemInfo.productType === "windows") {
            try {
                var userProfile = installer.environmentVariable("USERPROFILE");
                installer.setValue("UserProfile", userProfile);
                component.addOperation("CreateShortcut",
                    targetDirectory + "/bin/chat.exe",
                    "@UserProfile@/Desktop/USAi.lnk",
                    "workingDirectory=" + targetDirectory + "/bin",
                    "iconPath=" + targetDirectory + "/USAi.ico",
                    "iconId=0", "description=Open USAi");
            } catch (e) {
                print("ERROR: creating desktop shortcut" + e);
            }
            component.addOperation("CreateShortcut",
                targetDirectory + "/bin/chat.exe",
                "@StartMenuDir@/USAi.lnk",
                "workingDirectory=" + targetDirectory + "/bin",
                "iconPath=" + targetDirectory + "/USAi.ico",
                "iconId=0", "description=Open USAi");
        } else if (systemInfo.productType === "macos") {
            var usaiAppPath = targetDirectory + "/bin/USAi.app";
            var symlinkPath = targetDirectory + "/../USAi.app";
            // Remove the symlink if it already exists
            component.addOperation("Execute", "rm", "-f", symlinkPath);
            // Create the symlink
            component.addOperation("Execute", "ln", "-s", usaiAppPath, symlinkPath);
        } else { // linux
            var homeDir = installer.environmentVariable("HOME");
            if (!installer.fileExists(homeDir + "/Desktop/USAi.desktop")) {
                component.addOperation("CreateDesktopEntry",
                    homeDir + "/Desktop/USAi.desktop",
                    "Type=Application\nTerminal=false\nExec=\"" + targetDirectory +
                    "/bin/chat\"\nName=USAi\nIcon=" + targetDirectory +
                    "/USAi-48.png\nName[en_US]=USAi");
            }
        }
    } catch (e) {
        print("ERROR: running post installscript.qs" + e);
    }
}

Component.prototype.createOperationsForArchive = function(archive)
{
    component.createOperationsForArchive(archive);

    if (systemInfo.productType === "macos") {
        var uninstallTargetDirectory = installer.value("TargetDir");
        var symlinkPath = uninstallTargetDirectory + "/../USAi.app";

        // Remove the symlink during uninstallation
        if (installer.isUninstaller()) {
            component.addOperation("Execute", "rm", "-f", symlinkPath, "UNDOEXECUTE");
        }
    }
}
