---
sidebar_position: 1
---

# Getting Started

Matter Hooks is a Luau hooks library for [Matter], an Entity Component System
(ECS) library for Lua. Matter Hooks provides access to useful hooks that are not
included with Matter, allowing you to extend the functionality of your ECS
projects.

This guide will help you get started with Matter Hooks by walking you through
the process of installing it and using it in your projects.

[matter]: https://eryn.io/matter/

## Installation

To use Matter Hooks, you need to include it as a dependency in your `wally.toml`
file. Matter Hooks can then be installed with [Wally].

```toml
MatterHooks = "lasttalon/matter-hooks@0.2.1"
```

[wally]: https://wally.run

## Usage

To use Matter Hooks in your project, simply require the module and access the
hooks you want to use. For example, to use the `useMemo` hook:

```lua
local MatterHooks = require(ReplicatedStorage.Packages.MatterHooks)

MatterHooks.useMemo(function()
	-- Your code here
end, { dependency })
```

Refer to the [API documentation][api] for a list of available hooks and their
parameters.

[api]: ../api/
