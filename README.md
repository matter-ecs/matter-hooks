# Matter Hooks [![CI status][ci-badge]][ci] [![Docs status][docs-badge]][docs]

**Matter Hooks** is a _[Luau]_ hooks library for _[Matter]_.

It provides access to useful hooks not included in with Matter.

[ci-badge]: https://github.com/matter-ecs/matter-hooks/actions/workflows/ci.yaml/badge.svg
[docs-badge]: https://github.com/matter-ecs/matter-hooks/actions/workflows/docs.yaml/badge.svg
[ci]: https://github.com/matter-ecs/matter-hooks/actions/workflows/ci.yaml
[docs]: https://matter-ecs.github.io/matter-hooks/
[luau]: https://luau-lang.org/
[matter]: https://eryn.io/matter/

## Installation

Matter Hooks can be installed with [Wally] by including it as a dependency in
your `wally.toml` file.

```toml
MatterHooks = "matter-ecs/matter-hooks@0.2.0"
```

## Migration

If you're currently using the scope `lasttalon/matter-hooks`, this is the same
package. You can migrate by changing your `wally.toml` file to use the scope
`matter-ecs/matter-hooks`.

If you have migrated to `ecs-matter/matter`, you should also upgrade to
`matter-ecs/matter-hooks@0.2.0` or newer. This version of Matter Hooks is
compatible with the `matter-ecs/matter` package scope as a peer dependency.

## Building

Before building, you'll need to install all dependencies using [Wally].

You can then sync or build the project with [Rojo]. Matter Hooks contains
several project files with different builds of the project. The
`default.project.json` is the package build.

[rojo]: https://rojo.space/
[wally]: https://wally.run/

## Contributing

Contributions are welcome, please make a pull request! Check out our
[contribution] guide for further information.

Please read our [code of conduct] when getting involved.

[contribution]: CONTRIBUTING.md
[code of conduct]: CODE_OF_CONDUCT.md

## License

Matter Hooks is free software available under the MIT license. See the [license]
for details.

[license]: LICENSE.md
