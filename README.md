# remux-render-dockhosting

Dedicated DockHosting build for the Remux/Jellyfin deployment.

This repository intentionally keeps the DockHosting-specific Dockerfile separate
from `luinog1/remux-render`, so the existing Azure deployment is unaffected.

## DockHosting settings

- Runtime: Dockerfile
- Root directory: leave blank
- App port: `3000`
- Branch: `main`
- Persistent data directory used by the image: `/data`

The Dockerfile avoids `ghcr.io/lostb1t/remux` during the build because the
DockHosting builder was repeatedly resetting large GHCR downloads over IPv6.
