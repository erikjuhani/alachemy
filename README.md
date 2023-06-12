# alachemy

A simple config manager for Alacritty written for a need of a simple utility to
manage alacritty configuration on the fly.

`alachemy` has a builtin schema to validate any configuration set to alacritty
config. The schema uses a set of regex to match certain values and value
compositions.

`alachemy` is recommended to be used with the configuration `live_config_reload`
set as `true`, since this will enable quick feedback loop when changing
alacritty configuration values.

Currently alacritty configuration is expected to be found directly under $HOME
folder. (`$HOME/.alacritty.yml`)

NOTE: Some configurations are not supported to be modified through `alachemy`.

## Use cases

Let's imagine a screen share situation, where the font size is too small and
you need to set the terminal opague (since for some reason you wanted to see
your cool new background previously!).

With `alachemy` it's as simple as:

```sh
alachemy window.opacity 1 && alachemy font.size 16
```

Other useful use case for `alachemy` is when you are testing new configurations
for font and colours.

## Installation

Easiest way to install `alachemy` is with [shm](https://github.com/erikjuhani/shm).

To install `shm` run either one of these oneliners:

curl:

```sh
curl -sSL https://raw.githubusercontent.com/erikjuhani/shm/main/shm.sh | sh
```

wget:

```sh
wget -qO- https://raw.githubusercontent.com/erikjuhani/shm/main/shm.sh | sh
```

then run the following command to get the latest version of `alachemy`:

```sh
shm get erikjuhani/alachemy
```

## Usage

```sh
alachemy <key> <value> [-h | --help]
```

### Options

```sh
-h --help	Show help
```

### Examples

An example of setting alacritty window opacity to a value of 0.85 

```sh
alachemy window.opacity 0.85
```
