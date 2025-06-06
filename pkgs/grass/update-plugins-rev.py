import sys
import json

from subprocess import run


if len(sys.argv) > 1:
    revision = sys.argv[1]
else:
    revision = "refs/heads/grass8"


def get_src_meta(revision):
    cmd = run(
        ["nix-prefetch-git", "https://github.com/OSGeo/grass-addons.git", "--rev", revision],
        capture_output=True,
        text=True,
    )
    return json.loads(cmd.stdout)


# generate grass-addons-rev.nix code
src_meta = get_src_meta(revision)

print("{")  # opening curly

print(f"  rev = \"{src_meta['rev']}\";")
print(f"  hash = \"{src_meta['hash']}\";")

print("}")  # closing curly
