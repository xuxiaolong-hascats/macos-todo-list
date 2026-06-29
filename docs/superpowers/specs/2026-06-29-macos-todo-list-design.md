# macOS Todo List Design

Date: 2026-06-29

## Goal

Build a small native macOS todo app that stays available through the menu bar and can show a floating always-on-top todo panel.

The first version should be useful as a lightweight task reminder, not a full task management system.

## Success Criteria

- The app builds and runs from the workspace source.
- A menu bar item appears after launch.
- The menu bar item can show or hide the todo panel.
- The todo panel stays above normal windows and is visible across Spaces.
- Users can add, complete, and delete todos.
- Todos persist locally after quitting and reopening the app.
- The workspace is managed with git.

## Scope

Included:

- Native macOS app using SwiftUI plus AppKit where needed.
- Menu bar entry with commands for showing or hiding the panel, adding a todo, and quitting.
- Floating panel implemented with AppKit window behavior.
- Todo list UI with text entry, completion checkbox, and delete action.
- Local JSON persistence in the user's Application Support directory.

Excluded from the first version:

- iCloud or account sync.
- Due dates, reminders, tags, search, subtasks, or priorities.
- Launch at login.
- Global keyboard shortcuts.
- App Store packaging, signing, notarization, or installer generation.

## Architecture

The app will use a small SwiftUI model layer and AppKit integration for macOS-specific window behavior.

- `TodoItem`: immutable identity plus title, completion state, and creation time.
- `TodoStore`: observable state container that loads and saves todos as JSON.
- `TodoPanelController`: owns the floating panel and configures window level, size, and Space behavior.
- `MenuBarController`: owns the menu bar item and menu actions.
- `TodoListView`: SwiftUI view rendered inside the floating panel.

The app will avoid a full Xcode-generated project template. A focused Swift Package Manager executable is sufficient if it can build and launch a macOS app with AppKit. If SwiftPM app bundling is insufficient on the local toolchain, the project will use a minimal `.xcodeproj` instead.

## Data Flow

On launch:

1. `TodoStore` loads JSON from Application Support.
2. `MenuBarController` creates the menu bar item.
3. `TodoPanelController` creates the hidden floating panel.

During use:

1. The user adds, completes, or deletes a todo in `TodoListView`.
2. `TodoStore` updates in memory.
3. `TodoStore` writes the full todo array to JSON.

On quit:

- Current todos are already saved after each mutation, so no special shutdown flow is required.

## Error Handling

Persistence errors should not block UI use. If loading fails, the app starts with an empty list. If saving fails, the app logs the error to standard error.

The first version will not show a visible error banner because the app is intentionally small and local-only.

## Testing And Verification

Verification will include:

- Build the project from the command line.
- Run available tests if the chosen project structure supports them.
- Manually inspect the generated source layout.
- Confirm the persistence code has a deterministic file path and JSON encode/decode path.

Manual runtime verification may require launching the app on macOS from the local workspace.
