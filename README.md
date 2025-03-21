# nvim-checkhealth-gh-action
Run `:checkhealth` for `nvim` and then exit. If there's an error, the GitHub action fails.
This makes sure that your Neovim configuration or Neovim plugin works in
a user's environment (and across different OSes).


## Usage
### Usage - Neovim Plugin
Add this to your repository at `.github/workflows/checkhealth.yml`:

```yml
name: Run :checkhealth
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
    branches:
    - main
  push:
    branches:
      - main

jobs:
  checkhealth:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        neovim: [v0.9.0, v0.10.0, stable, nightly]

    runs-on: ${{ matrix.os }}
    name: "OS: ${{ matrix.os }} - Neovim: ${{ matrix.neovim }}"

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install Neovim
        uses: rhysd/action-setup-vim@v1
        with:
          neovim: true
          version: ${{ matrix.neovim }}

      - name: Run :checkhealth
        uses: ColinKennedy/nvim-checkhealth-gh-action@main
```

> [!Example]
> [nvim-best-practices-plugin-template](https://github.com/ColinKennedy/nvim-best-practices-plugin-template/blob/main/.github/workflows/checkhealth.yml)
> shows that you can modify the `nvim` executable to `nvim -u minimal_init.lua` and
> provide any plugin-setup-logic there before this action gets called.


### Usage - Neovim Configuration
Basically the same steps as above but with some small path-related tweaks.

```yml
name: Run :checkhealth
on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]
    branches:
    - main
  push:
    branches:
      - main

jobs:
  checkhealth:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        neovim: [v0.9.0, v0.10.0, stable, nightly]

    runs-on: ${{ matrix.os }}
    name: "OS: ${{ matrix.os }} - Neovim: ${{ matrix.neovim }}"

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          path: nvim

      - name: Install Neovim
        uses: rhysd/action-setup-vim@v1
        with:
          neovim: true
          version: ${{ matrix.neovim }}

      - name: Run :checkhealth
        env:
          XDG_CONFIG_HOME: ${{ github.workspace }}
        uses: ColinKennedy/nvim-checkhealth-gh-action@main
```

> [!NOTE]
> How it works: Neovim looks for a configuration file to load on-start-up at
> `$XDG_CONFIG_HOME/nvim/init.lua`. **Assuming** your repository contains a `init.lua`
> file at its root, adding `path: nvim` will create the `.../nvim/init.lua` part and
> `XDG_CONFIG_HOME: ${{ github.workspace }}` tells GitHub to treat your current working
> directory as a root for Neovim. Put that together and you've successfully spoofed
> Neovim's configuration-discovery mechanism.


## Advanced Usage
You can use this GitHub action directly to customize the `:checkhealth` command.

```yml
# Default
- name: Run :checkhealth
  uses: ColinKennedy/nvim-checkhealth-gh-action@main

# All settings
- name: Run :checkhealth
  uses: ColinKennedy/nvim-checkhealth-gh-action@main
  with:
    checks: "vim.* another.plugin etc"
    severity: warn
    executable: "./custom/neovim_executable_here"
```

> [!Example]
> [nvim-best-practices-plugin-template](https://github.com/ColinKennedy/nvim-best-practices-plugin-template/blob/main/.github/workflows/checkhealth.yml)
> shows that you can modify the `nvim` executable to `nvim -u minimal_init.lua` and
> provide any plugin-setup-logic there before this action gets called.

- `checks`: It's very common to override `checks` if you are writing a Neovim plugin
  that provides its own `health.lua` integration so that the plugin will run during
  `:checkhealth`.
- `executable`: Most plugins also require setup code to run in GitHub actions properly.
  Override `executable` to easily provide a setup `.lua` that's specific to your Plugin.
- `severity`: It's rare to ever want to change the default for `severity`.


## Settings
| Option           | Default | Description                                                                                           |
|------------------|---------|-------------------------------------------------------------------------------------------------------|
| checks           | "vim.*" | The checks to run. Use "" to run all checks. See `:help checkhealth` for more examples.               |
| executable       | "nvim"  | The relative or absolute path to the Neovim binary to run from.                                       |
| minimum_severity | "error" | All issues below "error" are ignored. "error" and above will cause this action to fail and end early. |
