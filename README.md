# **buildcannon**

## This is an automation build tool for iOS (for now).

It currently supports the commands bellow:
- [x] `buildcannon create`
    - Generates a project file at [project path]/buildcannon/default.cannon

- [x] `buildcannon distribute`
    - Uses the information in the default.cannon file to distribute your app to TestFlight

- [ ] `buildcannon archive --output "/path/to/save/archive"`

- [ ] `buildcannon export --input "/path/to/archive" --output "/path/to/save/ipa"`

- [ ] `buildcannon upload --input "/path/to/ipa"`

## **Install**

Just copy and paste the following command in the terminal:

`sh -c "$(curl -s https://raw.githubusercontent.com/andersonlucasg3/buildcannon/master/installer/install.sh)"`

If the logs say that everything is ok, just start executing `buildcannon --help`, and be happy.

:D
