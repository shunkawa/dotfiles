```
$ ./generate.sh
```

Edit `node-packages.nix`:

Find the lines like `"rsvp.fyi-client-./../../../rsvp.fyi/client" =
nodeEnv.buildNodePackage ...` and replace:

```
s/"rsvp.fyi-client-./../../../rsvp.fyi/client"/"rsvp.fyi-client"/
s/"rsvp.fyi-server-./../../../rsvp.fyi/server"/"rsvp.fyi-server"/
```

Correct the path in `src` for each of these if necessary.

