# Treeland Wayland Protocol Rules

This reference condenses standard Wayland protocol conventions together with the packaging and naming conventions used in this repository.

## 1. Source of truth

When drafting a protocol:
- use standard Wayland reference protocols as the style reference for XML structure and protocol evolution
- use AGENTS.md for file placement, naming, and repo integration conventions

Do not copy a reference protocol mechanically. Reuse its structure only when the lifecycle matches.

## 2. Versioning

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

See AGENTS.md for file naming and placement conventions.

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
### Enum reference format on `<arg>` elements

When an `<arg>` references an enum, use the format that matches where the enum is defined:

- **Same-interface enum**: short format — `enum="button_state"`
- **Cross-interface enum**: fully-qualified format with the interface prefix — `enum="wl_shm.format"` or `enum="wp_color_manager_v1.primaries"`

This matches how `wayland-scanner`'s `find_enumeration()` resolves references: short format searches only within the current interface, fully-qualified format searches across all interfaces in the protocol.

Upstream wayland-protocols consistently follows this rule (all 91 enum refs: 75 short for same-interface, 16 fully-qualified for cross-interface — zero exceptions).
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

## 10. Review checklist

Before considering the XML finished, check:
- file name, protocol name, and interface naming follow the conventions in AGENTS.md
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
- all enum references resolve correctly (short format for same-interface, fully-qualified `interface.enum` for cross-interface)
- nullable args are intentional
- the file is registered in the correct `CMakeLists.txt` variable — see AGENTS.md
- the protocol-level `<description>` contains the experimental disclaimer (see section 11)

## 11. Experimental status disclaimer

Every Treeland protocol XML must include the following experimental disclaimer in its **protocol-level** `<description>` (the `<description>` that is a direct child of `<protocol>`, not inside an `<interface>`):

```
Warning! This protocol is EXPERIMENTAL and under active development.
It may change at any time, including in backward-incompatible ways,
without incrementing the interface major version and without prior
notice. No compatibility guarantees of any kind are provided. Clients
and compositors must track the upstream definition in treeland-protocols
and must not rely on the current interface names, requests, events, or
semantics remaining stable across releases.
```

Rules:
- the disclaimer must appear exactly once, in the protocol-level `<description>` only
- do not duplicate the disclaimer inside `<interface>` descriptions
- do not use the old "testing phase" wording that promises version-bump discipline — the current disclaimer explicitly states that no compatibility guarantees are provided
- when creating a new protocol file from the template, the disclaimer is already present; keep it
