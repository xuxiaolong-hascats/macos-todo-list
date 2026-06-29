# MacOSTodoList

A small native macOS todo app with a menu bar entry and a floating always-on-top todo panel.

## Requirements

- macOS
- Xcode command line tools with Swift 6 or newer

## Build

```sh
swift build
```

## Run

```sh
swift run MacOSTodoList
```

The app runs as a menu bar accessory. Use the menu bar checklist icon to show or hide the todo panel, add a todo, or quit.

## Test

```sh
swift test
```

## Data

Todos are stored as JSON in:

```text
~/Library/Application Support/MacOSTodoList/todos.json
```
