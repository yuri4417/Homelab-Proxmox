#!/bin/bash
#
# Restart the Cloudflare quick tunnel and update Overleaf config.
# Run from the Overleaf Toolkit root directory (~/overleaf).

if [ ! -f config/variables.env ]; then
    echo "Error: Run this script from the Overleaf Toolkit root directory (~/overleaf)."
    exit 1
fi

# 1. Kill any stale tunnel still running
echo "Killing previous tunnels..."
pkill cloudflared || true
sleep 2

# 2. Start the new quick tunnel in background (truncate previous log)
echo "Starting new Quick Tunnel..."
: > tunnel.log
nohup cloudflared tunnel --url http://localhost:80 >> tunnel.log 2>&1 &

# 3. Wait for Cloudflare to generate and register the URL
echo "Waiting for Cloudflare response (6 seconds)..."
sleep 6
NEW_URL=$(grep -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' tunnel.log | head -n 1)

if [ -z "$NEW_URL" ]; then
    echo "Error: Could not capture the URL. Check tunnel.log."
    exit 1
fi
echo "New URL captured: $NEW_URL"

# 4. Update variables.env with the new URL (covers both variable spellings)
echo "Updating Overleaf configuration..."
sed -i "s|^OVERLEAF_SITE_URL=.*|OVERLEAF_SITE_URL=$NEW_URL|" config/variables.env
sed -i "s|^SHARELATEX_SITE_URL=.*|SHARELATEX_SITE_URL=$NEW_URL|" config/variables.env

# 5. Restart the stack to apply the new URL
echo "Restarting containers..."
bin/down && bin/up -d

echo "======================================================="
echo "Done! The lab is up and running at:"
echo "$NEW_URL"
echo "======================================================="
