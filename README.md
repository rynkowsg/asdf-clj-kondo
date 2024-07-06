<div align="center">

# asdf-clj-kondo
[![GitHub Actions Test Status][ci-actions-test-badge]][ci-actions-test]
[![GitHub Actions Lint Status][ci-actions-lint-badge]][ci-actions-lint]
[![CircleCI Lint Status][ci-circleci-lint-badge]][ci-circleci-lint]
[![License][license-badge]][license]

[asdf version manager][asdf-website] plugin for [clj-kondo][clj-kondo-repo], a Clojure linter.

</div>


## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [License](#license)

## Dependencies

- `bash`, `curl`, `unzip`: generic POSIX utilities.

## Install

Install plugin:

```shell
asdf plugin add clj-kondo https://github.com/rynkowsg/asdf-clj-kondo.git
```

Install clj-kondo:

```shell
# Show all installable versions
asdf list-all clj-kondo

# Install specific version
asdf install clj-kondo latest

# Set a version globally (on your ~/.tool-versions file)
asdf global clj-kondo latest

# Now clj-kondo commands are available
clj-kondo --help
```

Check [asdf][asdf-repo] readme for more instructions on how to install & manage versions.

## License

Licensed under the [MIT license][license].

[asdf-website]: https://asdf-vm.com
[asdf-repo]: https://github.com/asdf-vm/asdf
[ci-actions-test-badge]: https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/test.yml/badge.svg
[ci-actions-test]: https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/test.yml
[ci-actions-lint-badge]: https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/lint.yml/badge.svg
[ci-actions-lint]: https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/lint.yml
[ci-circleci-lint-badge]: https://circleci.com/gh/rynkowsg/asdf-clj-kondo.svg?style=shield
[ci-circleci-lint]: https://circleci.com/gh/rynkowsg/asdf-clj-kondo
[clj-kondo-repo]: https://github.com/clj-kondo/clj-kondo
[license-badge]: https://img.shields.io/badge/license-MIT-lightgrey.svg
[license]: LICENSE
