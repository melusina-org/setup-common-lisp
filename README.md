# Setup Common Lisp on GitHub Runners

This GitHub Action installs Common Lisp implementations on GitHub
Runners.

[![Continuous Integration](https://github.com/melusina-org/setup-common-lisp/actions/workflows/continuous-integration.yaml/badge.svg)](https://github.com/melusina-org/setup-common-lisp/actions/workflows/continuous-integration.yaml)

This action is complemented by other actions related to the Common
Lisp eco system:

- [setup-quicklisp](https://github.com/melusina-org/setup-quicklisp)
- [asdf-operate](https://github.com/melusina-org/asdf-operate)
- [run-common-lisp-program](https://github.com/melusina-org/run-common-lisp-program)
- [make-lisp-system-documentation-texinfo](https://github.com/melusina-org/make-lisp-system-documentation-texinfo)


## Usage

Create a workflow file in the`.github/workflows` directory of your
working copy.  This workflow file should use a MacOS runner or a
Ubuntu Runner and use the branch `v1` of this action.

An [example workflow](#example-workflow) is available below. See the GitHub Help Documentation for
[Creating a workflow file](https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file)
to get started with GitHub workflows.

## Outcomes

Once the action has been executed succesfully, the required Common
Lisp implementation is installed on the runner and can be used.


## Inputs

* `implementation` — The Common Lisp implementation to setup. This can
  be one of the values `abcl ecl sbcl` and
  in the future we would like to support all of `abcl clasp clisp ecl gcl sbcl`
  and maybe other implementations. Please open an issue to express
  interest for other implementations.

  On Windows Runners, only `sbcl` is supported.

## Outputs

* `lisp-implementation-type`: The implementation type for Common Lisp.
* `lisp-implementation-version`: The implementation version for Common Lisp.
* `lisp-implementation-init-filename`: The user initialisation file
      associated to the GitHub runner user for the selected implementation.


## Example worflow

```yaml
jobs:
  install-common-lisp:
    strategy:
      matrix:
        implementation: ['abcl', 'clisp', 'ecl', 'sbcl']
        os: ['ubuntu-latest', 'macos-11', 'macos-12', 'macos-13']
    runs-on: '${{ matrix.os }}'
    name: 'Install Common Lisp'
    steps:
      - uses: actions/checkout@v3
      - name: 'Install MacPorts'
        if: runner.os == 'macOS'
        uses: melusina-org/setup-macports@v1
      - uses: ./
        id: common-lisp
        with:
          implementation: '${{ matrix.implementation }}'
      - name: 'Validate installed implementation'
        run: >-
          test "${{ steps.common-lisp.outputs.implementation }}" = '${{ matrix.implementation }}'
```

## License
The scripts and documentation in this project are released under the [MIT License](LICENSE)
