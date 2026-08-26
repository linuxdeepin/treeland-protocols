---
name: treeland-wayland-protocol
description: Write or update Treeland Wayland protocol XML specifications. Use when the task is to design, draft, review, or version protocol XML files, following standard Wayland protocol conventions while correcting non-standard patterns in existing Treeland protocols.
---

Use this skill when working on Treeland Wayland protocol definitions.

## Scope

This skill is for:
- creating a new protocol XML
- extending an existing protocol in a backward-compatible way
- preparing a new major version for a backward-incompatible change
- reviewing protocol XML for naming, versioning, lifecycle, and wording issues

This skill is not for compositor/server implementation details. It only covers the protocol spec layer.

## Prerequisites

Before drafting or reviewing, read:

1. **[AGENTS.md](../../../AGENTS.md)** — repository structure, file placement, naming conventions, protocol classification, and CMakeLists.txt integration.
2. **[references/treeland-wayland-protocol-rules.md](references/treeland-wayland-protocol-rules.md)** — XML structure, description quality, arg conventions, enum references, versioning rules, and the review checklist.

## Workflow

1. Read AGENTS.md for where to place the file and how to name it.
2. Read the rules reference for XML authoring and validation.
3. Open 2-3 nearby XML files that match the intended style or domain.
4. Use [assets/treeland-protocol-template.xml](assets/treeland-protocol-template.xml) as a starting point when useful.
5. Draft or edit the XML.
6. Re-read the final XML against the rules reference checklist.

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
- Prefer precise `summary` text and concrete descriptions over placeholders.
- Event descriptions should explain event meaning and the compositor-side trigger timing for emission.
- When writing normative behavior, use RFC 2119 keywords in lowercase and include the RFC 2119 paragraph in the top-level protocol description if the document relies on those terms normatively.

## Validation

Before finishing:
- compare the XML against at least one standard Wayland reference spec for structure quality
- compare against at least one Treeland XML for local naming and packaging conventions — see AGENTS.md, but do not preserve non-standard patterns just because they already exist
- ensure enum references follow the short-format (same-interface) vs fully-qualified (cross-interface) convention — see rules reference section 7
- ensure nullable object args explicitly use `allow-null="true"`
- ensure destroy ordering constraints are documented wherever misuse would be a protocol error
