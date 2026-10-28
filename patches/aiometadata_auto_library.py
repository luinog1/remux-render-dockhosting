from pathlib import Path

path = Path("crates/remux-server/src/addons/stremio.rs")
src = path.read_text()

needle = """        Ok(manifest
            .catalogs
            .into_iter()"""
replacement = """        // DockHosting: AIOMetadata is the catalog provider for the Jellyfin library.
        // New catalogs published by its manifest are enabled automatically.
        // Persisted per-catalog overrides still take precedence in resolve_catalogs().
        let auto_enable_catalogs = self
            .manifest_url
            .to_string()
            .contains("aiometadata.fortheweak.cloud");

        Ok(manifest
            .catalogs
            .into_iter()"""
if needle not in src:
    raise SystemExit("upstream Stremio catalog layout changed; refusing unsafe patch")
src = src.replace(needle, replacement, 1)

needle = """                CatalogInfo {
                    collection_media_kind:"""
replacement = """                CatalogInfo {
                    default_enabled: auto_enable_catalogs,
                    collection_media_kind:"""
if needle not in src:
    raise SystemExit("upstream CatalogInfo layout changed; refusing unsafe patch")
src = src.replace(needle, replacement, 1)

path.write_text(src)
