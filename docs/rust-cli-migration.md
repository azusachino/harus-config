# mise configuration for consumers

The shared base installs mise and configures shell integration, but it does not
ship a global `mise/config.toml`, choose global tools, or trust project
configuration roots. Those choices are consumer-specific and belong in the
consumer's Home Manager configuration.

Consumers that configure global tools can install them explicitly after
activation with `mise install` and `mise reshim`. The base does not install
mise tools during Home Manager activation. Project-level `.mise.toml` files and
lockfile policy remain under each project's ownership.
