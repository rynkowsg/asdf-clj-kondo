<div align="center">

# asdf-clj-kondo [![Build](https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/test.yml/badge.svg)](https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/test.yml) [![Lint](https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/lint.yml/badge.svg)](https://github.com/rynkowsg/asdf-clj-kondo/actions/workflows/lint.yml)

[clj-kondo](https://github.com/clj-kondo/clj-kondo) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
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

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to install & manage versions.

## Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/rynkowsg/asdf-clj-kondo/graphs/contributors)!

## License

Licensed under the [MIT license](LICENSE).
