---
type: Playbook
title: Flutter project and widget basics
description: Explains the Flutter project layout and the widget building blocks used by the Home Debit registration screen.
resource: workspace:home-debit-ui/week-1/project-and-widgets
tags: [flutter, week-1, widgets, project-structure]
timestamp: 2026-09-28T12:00:00+08:00
okf_version: "0.1"
source: ../../lib/main.dart
---
# Flutter project and widget basics

## Project structure

| Path | Responsibility |
|---|---|
| `lib/main.dart` | Calls `runApp` and configures the root `MaterialApp`. |
| `lib/screens/` | Screen-level UI: registration and customer profile. |
| `lib/widgets/` | Reusable form fields, buttons, and cards. |
| `lib/models/` | Dart data objects such as `Customer`. |
| `lib/services/` | Operations used by screens; registration calls the customer API. |
| `lib/theme/` | Shared colors, spacing, text styles, and theme. |
| `test/` | Flutter widget tests for validation and navigation. |
| `pubspec.yaml` | Package metadata, SDK constraint, dependencies, and Flutter assets/settings. |
| `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` | Platform-specific launchers and configuration. |

## App entry point

Flutter starts at `main()`. In this project, `runApp(const MyApp())` attaches
the root widget. `MyApp` is a `StatelessWidget` that returns `MaterialApp`,
sets the theme and title, and chooses `RegistrationScreen` as the initial
screen.

## `MaterialApp` and `Scaffold`

`MaterialApp` provides app-wide Material Design configuration and navigation
infrastructure. A screen uses `Scaffold` for its standard page layout. The
registration screen's scaffold contains an `AppBar` and a body with the form.

## Common widgets in this app

| Widget | Role |
|---|---|
| `Text` | Displays a title, label, or instruction that is not directly editable. |
| `TextFormField` | Accepts input and can display a validator's error message. `AppTextField` wraps it. |
| `Column` | Places its children vertically. |
| `Padding` | Adds space around its child; the form uses it for screen-edge spacing. |
| `ElevatedButton` | Presents an important action. `AppPrimaryButton` wraps it and provides a loading appearance. |
| `SizedBox` | Adds fixed spacing between form elements. |
| `Form` | Groups fields so they can be validated together. |

## Widget tree

Widgets describe the UI as a hierarchy. A simplified tree for the startup
screen is:

```text
MyApp
└── MaterialApp
    └── RegistrationScreen
        └── Scaffold
            ├── AppBar
            └── Padding
                └── Form
                    └── Column
                        ├── Text
                        ├── AppTextField (Full Name)
                        ├── AppTextField (Email)
                        ├── AppTextField (Mobile Number)
                        └── AppPrimaryButton (Register)
```

Parent widgets configure or lay out their children. Flutter reconciles
updated widget descriptions with the existing element/render trees to update
what is displayed.

## `StatelessWidget` and `StatefulWidget`

`MyApp` and `ProfileScreen` are stateless: they describe UI from fixed
configuration or constructor data. `RegistrationScreen` is stateful because
submitting the form changes `_isSubmitting`, which changes the button's
appearance and enabled state. Text controllers hold the editable field values.

## Sources

* [Flutter application entry point](../../lib/main.dart)
* [Registration screen](../../lib/screens/registration_screen.dart)
* [Reusable text field](../../lib/widgets/app_text_field.dart)
* [Reusable primary button](../../lib/widgets/app_primary_button.dart)

# Citations

[1][Week 1 training brief](../../../../../Downloads/Flutter_4_Week_Training_Developer_Week_1.docx)
[2][Flutter source](../../lib/main.dart)
