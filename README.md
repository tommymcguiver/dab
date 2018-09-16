# Dab

Developer lab.

## Usage

You need only have docker installed and any POSIX compliant shell to run the wrapper scripts and get going with dab. This will start the dab container and forward all arguments into it:

```bash
 $ ./dab --help
```

If you do not need to build the docker image yourself and just want to use dab, the [dab script](./dab) we just executed is all that is needed and can be used from (or moved to) any location.

It is recommended you add the directory containing the [dab script](./dab) to your shell's `PATH` environment variable.

### Updating

Dab has a self updating mechanism in that it will pull the latest version of the dab image when dab is next executed a day or more after the last time it checked. So generally you do not have to do anything at all to stay up to date with the latest features, bug fixes, and security improvements.

The [dab script](./dab) wrapper has been designed to reduce the requirement to update it when new features are added to dab, however it may be necessary to do so on occasion and can be accomplished simply by downloading the latest version of the file and replace the existing one on your machine.


Dab is quite young and as such everything is still subject to change with little to no warning. In the future dab will solidify on what works best.

### Implemented

- Only depends on docker and a small wrapper script
- Manage code repositories
- Easy tool access like [CyberChef](https://gchq.github.io/CyberChef/)
- Auto update of dab and its image
- Setup of private lab network
- Automatically collect logs to explore via TICK

### Proposed

The following features are being considered or have been planned to be implemented in a future version.

- Auto update of managed repositories that are master
- Automatically detect out of date wrapper script
- Automated observability improvements:
	- Autoconfigure network monitoring (eg ntopng)
	- Autoconfigure tracing via something like [linkerd](https://github.com/linkerd/linkerd-examples)+zipkin
	- Record common traffic like http via something like [mitmproxy](https://byteplumbing.net/2018/01/)

## Contributing

If you would like to help hone dab into a better tool check out our [contributing](./CONTRIBUTING) documentation.