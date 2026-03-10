#!/usr/bin/env bash
# ABOUTME: Build script for Cloudflare Pages deployment.
# ABOUTME: Replaces placeholder tokens with environment variables.

set -euo pipefail

cp index.html index.html.bak

sed -i.tmp "s|%%SUPABASE_URL%%|${SUPABASE_URL:-}|g" index.html
sed -i.tmp "s|%%SUPABASE_ANON_KEY%%|${SUPABASE_ANON_KEY:-}|g" index.html
rm -f index.html.tmp

echo "Build complete. Supabase credentials injected."
