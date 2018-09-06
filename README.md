# **buildcannon**

## This is an automation build tool for iOS (for now).

It currently supports the commands bellow:
- [x] `buildcannon create`
    - Generates a project file at [project path]/buildcannon/default.cannon

- [x] `buildcannon create-target`
    - Generates a project file at [project path]/buildcannon/target name.cannon, "target name" is specified in the following questions process

- [x] `buildcannon distribute`
    - Uses the information in the default.cannon file to distribute your app to TestFlight

- [x] `buildcannon batch-distribute "target 1" "target 2" ...`
    - Uses the information in the `target 1.cannon`, `target 2.cannon` to batch-build all the informed targets

- [x] `buildcannon self-update`
    - Starts a self updating process that will update the buildcannon binary

- [ ] `buildcannon archive --output "/path/to/save/archive"`

- [x] `buildcannon export --output-path "/path/to/save/output.ipa" --export-method [app-store | ad-hoc | development | enterprise]`
    - Uses the information in the default.cannon file to export your app to a IPA file and saves it to `output-path`

- [ ] `buildcannon upload --input "/path/to/ipa"`

## **Install**

I'm assuming that you already have `swift toolchain 4.x` installed. You MUST have the swift.org or the Xcode built-in installed.
I'm assuming that you already have Homebrew installed.

Now that we are in the same page, let's begin.

Just copy and paste the following command in the terminal:

`sh -c "$(curl -s https://raw.githubusercontent.com/andersonlucasg3/buildcannon/master/installer/install.sh)"`

If the logs say that everything is ok, just start executing `buildcannon --help`, and be happy.

:D
