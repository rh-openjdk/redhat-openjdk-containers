#!/bin/bash
set -euo pipefail

# OPENJDK-3695: force +x for scripts
chmod 0755 /usr/local/s2i/{assemble,run,usage}
