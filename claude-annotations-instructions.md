# Annotation fix routine

Fix each requested change in the code. Open a pull request (PR) that
describes each fix. Stay on the PR. Watch it for comments and reply to them.

## Input

This turn's text is the batch: a JSON array of annotation objects. Parse it.
If the array is empty, say so. Stop.

### Annotation fields

| Field | Use |
|---|---|
| `id` | Stable id. Link each fix to its annotation in the PR body. |
| `note` | The requested change. This is the task. |
| `toolkit` | `"uikit"` or `"swiftui"`. Tells you which locating strategy applies. An Android batch uses `"view"` / `"compose"` instead — if you see those, you are looking at the wrong platform. |
| `targetType` | View class name without its module prefix. For a SwiftUI target this is usually a private backing view (`CGDrawingView`, `_UIGraphicsView`) — see "A note on SwiftUI targets". |
| `targetPath` | Ancestor chain, broadest first, e.g. `UIStackView>UIButton>UILabel`. |
| `accessibilityIdentifier` | The strongest locator for a UIKit target. Greppable as `accessibilityIdentifier = "x"` in Swift and `<accessibility ... identifier="x"/>` in a storyboard/XIB. Normally `null` for a SwiftUI target — see below. |
| `accessibilityLabel` | The element's accessibility label. Often the only signal a SwiftUI leaf carries. |
| `swiftUIType` | The app's own SwiftUI view type hosting the element, e.g. `CheckoutScreen`. **Check this first for a SwiftUI target** — it is usually the only locator one has. `null` for UIKit. |
| `ordinal` / `ordinalCount` | Position "N of M" among same-type elements on the screen, top to bottom then left to right. Use this when there is no identifier. |
| `text` | Visible text, used to disambiguate identical siblings. Never the contents of a secure text field. |
| `screen` | Class name of the topmost presented view controller. The main grouping key. |
| `viewController` | Class name of the deepest view controller containing the target. The secondary grouping key. `null` when it is the same as `screen`. |

Sentinel keeps the capture coordinates and the sent flag to itself; they are
not in the payload.

### A note on SwiftUI targets

SwiftUI draws its own content and creates no backing view for `Text`, `Button`,
`Image` and the rest, so a tap on SwiftUI-drawn content resolves to the view
*hosting* the whole hierarchy. When `toolkit` is `"swiftui"`, expect
`targetType` to be `_UIHostingView` and `accessibilityIdentifier` to be `null`.
There is no in-process equivalent of a `file:line` for a SwiftUI view.

Locate the element like this:

1. Use `swiftUIType`. It names the app's own view type hosting the element
   (recovered from the enclosing `UIHostingController` / `_UIHostingView`
   generic parameter), e.g. `CheckoutScreen`. Open that type and pick the right
   view by reading the code, narrowed with `note`, `text`, `accessibilityLabel`
   and the `ordinal` position.
2. If `swiftUIType` is `null` — the app hosts an `AnyView` — fall back to
   `screen` and `viewController` to find the right file.
3. If `accessibilityIdentifier` *is* set on a SwiftUI target, the element was a
   control SwiftUI bridges to a real UIKit view. Search for it as usual.

A `targetType` of `UISwitch`, `UITextField` or similar with
`toolkit: "swiftui"` is exactly that bridged case: the annotation points at a
real UIKit control, but the code to change is the SwiftUI view named by
`swiftUIType` (a `Toggle`, for instance).

For `toolkit: "uikit"`, `targetType` is a real class name and
`accessibilityIdentifier` is greppable in both Swift and storyboard/XIB XML,
so location is usually exact. Note that a `UIControl` is annotated as a whole —
a note on a `UIButton` never points at its `titleLabel`.

## Workflow

1. Parse the input array.
2. If the array is empty, report "No annotations in this batch". Stop.
3. Group the annotations. See "Group the work".
4. Optional: track progress with the task board, one task per annotation id.
5. Dispatch one fix subagent per group. See "Fix subagent prompt".
6. Run independent groups in parallel.
7. Collect each subagent's report: the file:line changed, a one-line summary,
   and any annotation it could not locate.
8. Create a branch.
9. Commit the changes.
10. If the remote name is not `origin`, run `git remote -v` first.
11. Push the branch.
12. Open a PR with `gh pr create`.
13. Build the PR body from the collected reports. See "PR body".
14. Enable notifications on the PR. See "After the PR opens".

## Group the work

Read all annotations before you split the work. Group by `screen` first,
then by `viewController`.

- Put related edits on one screen in one subagent. This avoids collisions.
- Give independent screens their own subagent. Dispatch these in parallel.
- A small batch across a few screens can stay one subagent.

Hard rule: two subagents must never edit the same file at the same time.

## Fix subagent prompt

Dispatch one `Agent` (`general-purpose`) per group with this prompt. Add the
annotation list for that group.

```
A user annotated one or more elements in an iOS app. Apply each requested
change to the code. The edit on disk is the deliverable.

Annotations in this group:
- id: <id>
  note (the requested change): "<note>"
  toolkit: <toolkit>
  targetType: <targetType>
  targetPath: <targetPath>
  accessibilityIdentifier: <accessibilityIdentifier, or "none">
  accessibilityLabel: <accessibilityLabel, or "none">
  swiftUIType: <swiftUIType, or "none">
  position: <ordinal> of <ordinalCount> same-type elements on the screen
  text: <text, or "none">
  screen: <screen>   viewController: <viewController>
- (repeat for each annotation in this group)

Steps:
1. Locate the exact element for each annotation. For a UIKit target, search
   for the accessibilityIdentifier first — `accessibilityIdentifier = "x"` in
   Swift and identifier="x" in .storyboard/.xib XML — then fall back to
   targetType plus screen and viewController. For a SwiftUI target,
   accessibilityIdentifier is normally absent and targetType is
   _UIHostingView: open the view type named by swiftUIType and pick the right
   view by reading the code, narrowed with note, text, accessibilityLabel or
   the ordinal position. Do not guess past what the fields support.
2. Apply the change the note asks for. Keep the edit small. Match the
   surrounding code style.
3. Build what you changed and make sure it still compiles, e.g.
   `xcodebuild -scheme <scheme> -destination 'generic/platform=iOS Simulator' build`.
   Fix any new issue you caused.
4. Report, for each annotation id: the file:line you changed, a one-line
   summary of the edit, and whether the build is clean. If you could not
   locate an element safely, say so. Do not guess. This report feeds the PR
   body.
```

## PR body

Map each annotation to its fix:

```
### <note>   (id: <id>)
- Annotated: <targetType> on <screen> (<viewController>) at <accessibilityIdentifier, swiftUIType, or ordinal>
- Fixed: <file:line> — <one-line description of the edit>
```

Group entries by screen when that matches the split of work. Add a short
summary line at the top (e.g. "N annotations across M screens. Build clean.").
List any annotation you could not locate under a **Not fixed** heading, with
the reason.

## After the PR opens

Stay engaged. Answer review feedback.

1. Get the repository name and PR number:
   `gh repo view --json nameWithOwner -q .nameWithOwner`
   `gh pr view --json number -q .number`
2. Enable notifications on the PR:
   `gh api -X PUT repos/<owner>/<repo>/issues/<pr_number>/subscription -f subscribed=true -f ignored=false`
3. Check for comments:
   - General comments: `gh pr view <pr_number> --comments`
   - Inline review comments: `gh api repos/<owner>/<repo>/pulls/<pr_number>/comments`
4. For each new comment:
   - If it asks for a code change, make the change. Commit it. Push it to
     the same branch. This updates the PR in place.
   - Reply to the comment. Use `gh pr comment <pr_number> --body "<reply>"`
     for a general reply. Reference the commit you pushed. For an inline
     comment, reply in its own thread with
     `gh api repos/<owner>/<repo>/pulls/<pr_number>/comments/<comment_id>/replies -f body="<reply>"`.
   - If a comment only asks a question, answer it in a reply. Do not push a
     commit for it.
5. Repeat step 3 and 4 while the routine runs.
