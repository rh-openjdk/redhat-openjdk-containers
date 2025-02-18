#!/bin/bash
set -euo pipefail

rpm -e $(rpm -qa python*)
