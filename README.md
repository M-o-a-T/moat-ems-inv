# Victron Scripts

This repository attempts to establish a modern framework for talking to
Victron Energy products, mainly via Dbus.

## Rationale

The original Victron code uses synchronous Python and manages its
tasks et al. with GLib. Its documentation warns in multiple places
that GLib likes to swallow errors and might leaves the system in an
inconsistent state; it even includes a helper that, on error, directly
kills the program, circumventing the SystemExit exception Python
normally uses for this.

This is way beyond ugly, in this author's opinion. To be sure, there
were no good alternatives at the time it was written, but that's no
excuse for keeping it.

This library thus replaces the whole thing with an async library based on `anyio`
and `asyncdbus`. Usage is a bit different, of course, but there are several
advantages:

* no more swallowing of errors. Ever.

* you can write fallback code, or leave-the-system-in-a-safe-state-when-you-die
  code, that actually has a chance of running when conditions warrant.

* you can write multi-step control loops with timeouts and whatnot
  which don't depend on timer callbacks and related unsafe nonsense.

* etc.

## Modules

The modules `victron.dbus` and `victron.dbus.monitor` are suitably modified,
if not rewritten, copies of `/opt/victronenergy/dbus-systemcalc-py/ext/velib-python`.

## Random stuff

### Notes

#### Critical Settings

* com.victronenergy.settings /Settings/CGwacs/OvervoltageFeedIn

needs to be zero. This can happen when you play with your settings,
as some combination of changes appears to set this value but doesn't
bother to clear it.

The idea of this parameter is that an external program will increase
feed-out when the battery is at its charge limit, thus reducing solar
input is not necessary.

Unfortunately there is no safeguard if that feed-out should ever
not work (too much sun, AC inverter overheated, grid offline, …).

The result of this being set is that DVCC always sets solar power to
max and won't reduce it even if the battery becomes overloaded.
This is obviously a very bad idea.

