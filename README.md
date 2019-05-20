# **buildcannon**

## This is an automation build tool for iOS (for now).

It currently supports the commands bellow:
- [x] `buildcannon self-update`
    - Starts a self updating process that will update the buildcannon binary.

- [x] `buildcannon create`
    - Generates a project file at [project path]/buildcannon/default.cannon.

- [x] `buildcannon list`
    - List available targets to distribute or export.

- [x] `buildcannon create-target`
    - Generates a project file at [project path]/buildcannon/target name.cannon, "target name" is specified in the following questions process.

- [x] `buildcannon distribute [--all] [--targets=["target name,other target name"]] [--legacy-build] [--username=a@b.c --password=******]`
    - Uses the information in the default.cannon file to distribute your app to TestFlight.
    - When provided a **target name** the information in the `target name.cannon` file to distribute your app to TestFlight with the configurations from `default.cannon` overrided by the configurations in the target file.
    - When a list of targets is provided, it will distribute each target.
    - When `--all` is provided the process will distribute each target in the buildcannon folder.
    - When `--legacy-build` is provided the process of archive will use the legacy build system, compatible with Xcode 9 and previous.

- [ ] `buildcannon archive [--targets=["target name,other target name"]] --output="/path/to/save/archive"`
    - Starts the archive process and moves the output to the specified path.

- [x] `buildcannon export [--all] [--targets=["target name,other target name"]] --output-path="/path/to/save/output.ipa" --export-method=[app-store | ad-hoc | development | enterprise] [--legacy-build]`
    - Uses the information in the default.cannon file to export your app to a IPA file and saves it to `output-path`.

- [x] `buildcannon upload --ipa-path="/path/to/ipa" [--username=a@b.c --password=******]`
    - Uploads the given IPA file to AppStore Connect.

- [x] `buildcannon run-tests --scheme="MyScheme" --platform="iOS|tvOS|macOS" --device="iPhone Xs|Apple TV 4K" --os-version="12.2|11.3|10.14.5"`
    - Run the test suits in the specified scheme, in the specified platform, in the specified device and version.
    - If any test fails, it stops and fails immediatelly.

## **Install**

I'm assuming that you already have `swift toolchain 5.x` installed. You MUST have the swift.org or the Xcode built-in installed.
I'm assuming that you already have Homebrew installed.

Now that we are in the same page, let's begin.

Just copy and paste the following command in the terminal:

`sh -c "$(curl -s https://raw.githubusercontent.com/andersonlucasg3/buildcannon/1.2.4-swift4.2/installer/install.sh)"`

If the logs say that everything is ok, just start executing `buildcannon --help`, and be happy.

:D
