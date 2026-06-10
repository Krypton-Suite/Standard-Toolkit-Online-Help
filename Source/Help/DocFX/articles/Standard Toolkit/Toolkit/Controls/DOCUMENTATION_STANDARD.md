# Control documentation standard

Use this structure when authoring or upgrading topics under `Documents/Toolkit/Controls/`.

## Required sections

1. **Title** — control type name (`# KryptonDataGridView`)
2. **Overview** — purpose, `Namespace`, `Assembly`, inheritance chain
3. **Key features** — grouped bullets (palette, behavior, designer)
4. **Class hierarchy** — `text` tree
5. **Constructor** — signature and default behavior
6. **Properties** — Krypton-specific and notable overrides; each important member:
   - `### PropertyName`
   - `csharp` signature
   - Category, default, description, remarks, short example
7. **Methods** — public API not inherited from base
8. **Events** — Krypton-specific events
9. **Usage / feature guides** — designer walkthroughs, figures, scenarios (legacy tutorial content belongs here)
10. **Best practices**
11. **See also** — related controls, `TestForm` demos, Microsoft docs for base types

## Conventions

- Match existing repo voice: complete sentences, *italics* for designer property paths in prose, `` `csharp` `` for types and members in API blocks.
- Document **hidden** WinForms properties when users migrating from `DataGridView` need to know palette replaces them.
- Cross-link related topics with relative paths (`[KryptonGroup](KryptonGroup.md)`).
- Screenshots live in `Documents/Toolkit/Images/`; reference as `../Images/...`.
- Prefer accuracy from source (`Source/Krypton Components/Krypton.Toolkit`) over memory.
- V110+ assembly moves: note `Krypton.Toolkit.Utilities` when applicable.

## Coverage status

See [Controls.md](../Controls.md) for the index and per-topic coverage tier (comprehensive / legacy / needs work).
