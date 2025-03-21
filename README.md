# nvim-checkhealth-gh-action
Run `:checkhealth` for `nvim` and then exit. If there's an error, the GitHub action fails.


## Usage
name: Run :checkhealth
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


## Plugin Authors
To make sure Neovim can see your health.lua file, make sure to add your plugin to the `:help runtimepath`.

An example,
[nvim-best-practices-plugin-template](https://github.com/ColinKennedy/nvim-best-practices-plugin-template/blob/main/.github/workflows/checkhealth.yml),
shows that you can modify the `nvim` executable to `nvim -u minimal_init.lua` and
provide any plugin-setup-logic there before this action gets called.


## Advanced Usage
You can customize the `:checkhealth` command:

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

It's common to override `checks` if you are writing a Neovim plugin that supports
`:checkhealth`.

If you're writing a plugin you probably will want to update `executable`. For an example,
see [nvim-best-practices-plugin-template](https://github.com/ColinKennedy/nvim-best-practices-plugin-template/blob/main/.github/workflows/checkhealth.yml).

And rarely does anyone want to check the default for `severity`.


## Settings
| Option           | Default | Description                                                                                           |
|------------------|---------|-------------------------------------------------------------------------------------------------------|
| checks           | "vim.*" | The checks to run. Use "" to run all checks. See `:help checkhealth` for more examples.               |
| executable       | "nvim"  | The relative or absolute path to the Neovim binary to run from.                                       |
| minimum_severity | "error" | All issues below "error" are ignored. "error" and above will cause this action to fail and end early. |
