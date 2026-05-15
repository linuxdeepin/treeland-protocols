# Treeland Wayland Protocol Rules

This reference condenses standard Wayland protocol conventions together with the packaging and naming conventions used in this repository.

## 1. Source of truth

When drafting a protocol:
- use standard Wayland reference protocols as the style reference for XML structure and protocol evolution
- use `xml/` as the source of Treeland-specific naming and packaging conventions

Do not copy a reference protocol mechanically. Reuse its structure only when the lifecycle matches.

## 2. Naming and versioning

Treeland protocol defaults for this repo:
- file: `xml/treeland-foo-unstable-v1.xml`
- protocol: `treeland_foo_unstable_v1`
- interfaces usually still end with `_v1` and usually do not include `_unstable`
- if maintainers later stabilize a protocol line, follow the naming convention requested in that stabilization review

Backward-compatible extension:
- keep the same file
- keep the same interface major version suffix
- raise interface `version`
- add `since="N"` on each new request, event, enum entry, or arg introduced in version `N`
- never write `since="1"`
- append newly added requests or events after the existing ones instead of reordering old members
- if an upgraded interface is exposed by another interface via `new_id`, a request return object, or an event object, review that exposing interface and raise its `version` too when clients need the higher version to observe or use the new contract

Backward-incompatible extension:
- create a new file with the next major version
- keep the old file in the tree for compatibility
- rename the protocol and interfaces to the new major suffix
- reset interface versions to `1`
- remove old `since` attributes unless needed again within the new major line

## 3. XML structure

Recommended order:
1. XML declaration
2. `<protocol>`
3. `<copyright><![CDATA[ ... ]]></copyright>`
4. optional top-level `<description>`
5. one or more `<interface>`

Recommended interface order:
1. interface description
2. enums, if any
3. destroy request, if the interface has one
4. constructor-style requests
5. regular requests
6. events

Within one interface, keep enums before requests, and keep requests before events. Existing Treeland files vary, but new or updated protocol work should follow this ordering.

## 4. Description quality

Descriptions should answer:
- who owns the object
- who creates it
- when it becomes invalid
- which sequencing constraints are illegal
- whether the compositor or client defines a behavior

Good protocol text is concrete:
- say what triggers an event
- say whether state is latched, pending, or immediately applied
- say whether an object is singleton, per-output, per-surface, or per-session

Description minimums by member type:
- interface description should explain the interface purpose and, when useful, the high-level workflow
- request description should explain required call scenarios and ordering/precondition constraints
- event description should explain event meaning and compositor-side trigger timing

Avoid:
- vague summaries like "do something"
- implementation detail that does not affect the wire contract
- undocumented one-shot objects or hidden lifecycle rules
- semantic requirements hidden in XML comments

## 5. Requests, events, and errors

Use requests for client-to-compositor actions.

Use events for compositor-to-client notifications.

Manager-style interfaces should generally expose `destroy`.

Create a dedicated error enum when the client can violate protocol rules such as:
- using an object after required destruction ordering
- passing an invalid role target
- calling a one-shot request multiple times
- providing out-of-range values

Prefer specific error entries over a generic `failed`.

## 6. Object model heuristics

Prefer manager/object splits:
- manager global creates session/object instances
- per-object interfaces own ongoing state and events

Prefer separate objects when:
- lifetime differs from the manager
- events only make sense after setup
- the API would otherwise need ad-hoc request ordering rules

Avoid turning one interface into a grab-bag of unrelated features.

## 7. Arg conventions

Use:
- `new_id` for created protocol objects
- `object` for existing protocol objects such as `wl_output`, `wl_surface`, `wl_buffer`, `wl_callback`, `wl_compositor`, `wl_seat`, `wl_pointer`, `wl_touch`, and `wl_keyboard`
- `allow-null="true"` only when null is explicitly valid
- `enum="..."` on integer args that reference enums
- `bitfield="true"` on enum definitions used as flag sets

Add `summary` for args when it materially improves readability.

## 8. XML comments

Reference protocols do use XML comments in a few places, most commonly to mark versioned additions. However, comments are not a good place for protocol semantics.

Rule for Treeland skills:
- do not place normative behavior, sequencing rules, or lifecycle requirements in XML comments
- prefer `<description>` blocks for anything a protocol reader must understand
- use comments only sparingly for short maintenance markers

## 9. RFC 2119 usage

If the protocol text relies on words like `must`, `should`, or `may` normatively, add a top-level protocol description that includes the RFC 2119 interpretation paragraph used by standard Wayland protocol specifications.

Do not add that paragraph if the protocol text is otherwise non-normative.

## 10. Treeland repo integration

When adding a new protocol file:
- place it under `xml/`
- add it to the `XML` list in the repository `CMakeLists.txt`
- follow the local SPDX block:

```xml
<copyright><![CDATA[
SPDX-FileCopyrightText: 2026 UnionTech Software Technology Co., Ltd.
SPDX-License-Identifier: MIT
]]></copyright>
```

Match the year range used by neighboring files when editing an existing protocol family.

## 11. Review checklist

Before considering the XML finished, check:
- file name, protocol name, and interface suffixes all agree
- interface `version` matches the highest supported additive version
- interfaces that create or expose upgraded interfaces were reviewed for required version bumps
- new additions in an existing interface have `since`
- no member is annotated with `since="1"`
- newly added requests and events were appended without reordering older members
- destructor requests are marked `type="destructor"`
- enums, if present, appear before requests
- if an interface has a destroy request, it is the first request
- requests appear before events
- object lifetime constraints are documented
- event ordering constraints are documented where required
- all enum references resolve correctly
- nullable args are intentional
- the protocol is added to `CMakeLists.txt` if it is new
