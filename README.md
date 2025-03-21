# nvim-checkhealth-gh-action
Run `:checkhealth` for `nvim` and then exit. If there's an error, the GitHub action fails.


## Usage
```yml
name: Run :checkhealth
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

But most of the time, you will want to keep the default values of `executable` and
`severity`.


## Settings
| Option           | Default | Description                                                                                           |
|------------------|---------|-------------------------------------------------------------------------------------------------------|
| checks           | "vim.*" | The checks to run. Use "" to run all checks. See `:help checkhealth` for more examples.               |
| executable       | "nvim"  | The relative or absolute path to the Neovim binary to run from.                                       |
| minimum_severity | "error" | All issues below "error" are ignored. "error" and above will cause this action to fail and end early. |
