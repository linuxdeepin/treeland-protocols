---
name: treeland-wayland-protocol
description: Write or update Treeland Wayland protocol XML specifications. Use when the task is to design, draft, review, or version protocol files under xml/, following standard Wayland protocol conventions while correcting non-standard patterns in existing Treeland protocols.
---

Use this skill when working on Treeland Wayland protocol definitions in this repository.

## Scope

This skill is for:
- creating a new protocol XML under `xml/`
- extending an existing protocol in a backward-compatible way
- preparing a new major version for a backward-incompatible change
- reviewing protocol XML for naming, versioning, lifecycle, and wording issues

This skill is not for compositor/server implementation details. It only covers the protocol spec layer.

## Workflow

1. Read [references/treeland-wayland-protocol-rules.md](references/treeland-wayland-protocol-rules.md).
2. Open 2-3 nearby XML files under `xml/` that match the intended style or domain.
3. Use Treeland-unstable naming by default and only diverge when maintainers explicitly require a stable file line.
4. Draft or edit the XML using [assets/treeland-protocol-template.xml](assets/treeland-protocol-template.xml) as a starting point when useful.
5. If adding a new XML file, update `CMakeLists.txt` so it is installed with the rest of the protocol set.
6. Re-read the final XML once for protocol lifecycle correctness:
   - object creation and destruction are explicit
   - events vs requests are directionally correct
   - error enums are specific and actionable
   - additions in an existing major version use `since`
   - naming is consistent across file name, protocol name, interface names, and enum references

## Treeland-specific rules

- Protocol XML files live in `xml/`, not in `stable/`, `staging/`, or `experimental/` directories.
- Use unstable naming for new Treeland protocols by default: `xml/treeland-foo-unstable-v1.xml` with protocol name `treeland_foo_unstable_v1`.
- Important repo convention: even for unstable files, interface names usually stay in the form `treeland_foo_bar_v1` rather than `treeland_foo_bar_unstable_v1`. Match neighboring Treeland XMLs unless the repo convention changes.
- New protocol files must be added to the `XML` list in the top-level `CMakeLists.txt`.
- Use the repo's SPDX copyright block style from neighboring files.
- Existing Treeland XML may contain non-standard patterns. Prefer the rules in this skill over preserving those patterns.

## Authoring guidance

- Keep each protocol narrow in scope. If a request starts needing unrelated policy or multiple roles, split the protocol.
- Prefer clear object lifetimes over implicit state machines.
- Use `new_id` only when the compositor is creating a protocol object for the client.
- Within one interface, prefer the order: `description -> enum -> destroy request -> other requests -> events`.
- Interface descriptions should state the interface purpose and briefly describe the expected workflow when it is not obvious.
- Manager-style interfaces should provide an explicit `destroy` request.
- If an interface has a destroy-style request, place it as the first request in that interface.
- Use `type="destructor"` on explicit destroy requests.
- Keep all requests before all events inside one interface.
- Request descriptions should document any required call scenarios, preconditions, and ordering constraints.
- Put protocol errors in `enum name="error"` when clients can violate required rules.
- Avoid XML comments for protocol semantics. Put normative and behavioral information in `<description>` blocks. If a short comment is needed for maintenance, keep it non-semantic.
- Use `since` only for backward-compatible additions inside the same major version. Do not write `since="1"`.
- If an existing interface gains a new request or event, increment that interface's `version`, append the new member at the end of the existing request or event section, and mark the new member with the matching `since="N"`.
- For a breaking change, keep the old XML file, add a new `-vN+1` file, rename the protocol and interfaces to the new major suffix, reset interface `version` to `1`, and remove carried-over `since` attributes.
- Prefer precise `summary` text and concrete descriptions over placeholders.
- Event descriptions should explain event meaning and the compositor-side trigger timing for emission.
- When writing normative behavior, use RFC 2119 keywords in lowercase and include the RFC 2119 paragraph in the top-level protocol description if the document relies on those terms normatively.

## Validation

Before finishing:
- compare the XML against at least one standard Wayland reference spec for structure quality
- compare against at least one Treeland XML for local naming and packaging conventions, but do not preserve non-standard patterns just because they already exist
- ensure enum references are fully correct, especially `enum="interface.enum"` where needed
- ensure nullable object args explicitly use `allow-null="true"`
- ensure destroy ordering constraints are documented wherever misuse would be a protocol error
