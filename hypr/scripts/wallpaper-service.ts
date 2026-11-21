// =============================================================================
// wallpaper-service.ts — AGS wallpaper rotation + matugen daemon
//
// AGS (Astal, GTK4) daemon that sets wallpapers with awww:
//   - rotates every 30 min, at :00 and :30, skipping while a window is
//     fullscreen
//   - writes the chosen path to ~/.local/share/last-matugen-wallpaper for
//     the matugen color pipeline, and copies it to the greeter's
//     /var/lib/wallpapers/current.jpg
//   - logs to ~/.local/share/wallpaper-service.log
//
// On-demand rotation via AGS IPC:
//   ags request wallpaper-service rotate        — skip if fullscreen
//   ags request wallpaper-service force-rotate  — always rotate
//
// Run with:  ags run ~/.config/hypr/scripts/wallpaper-service.ts
// =============================================================================

import App from "astal/gtk4/app"
import Hyprland from "gi://AstalHyprland"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

// ─── Constants ────────────────────────────────────────────────────────────────

const HOME          = GLib.get_home_dir()!
const WALLPAPER_DIR = `${HOME}/Pictures/Wallpapers`
const LAST_FILE     = `${HOME}/.local/share/last-matugen-wallpaper`
const LOG_FILE      = `${HOME}/.local/share/wallpaper-service.log`
const GREETER_FILE  = "/var/lib/wallpapers/current.jpg"

// awww (0.12.1) transition types picked at random. All types: none, simple
// (default fade), fade, left, right, top, bottom, wipe, wave, grow, center,
// any, outer, random. grow/center/outer/any/random are left out: they draw
// full-screen circular animations with high GPU load.
const TRANSITIONS = ["fade", "wipe", "left", "right", "top", "bottom"] as const

// ─── Logging ──────────────────────────────────────────────────────────────────

function log(msg: string): void {
    const now = GLib.DateTime.new_now_local()?.format("%H:%M:%S") ?? "??:??:??"
    const line = `[${now}] ${msg}\n`
    try {
        const file   = Gio.File.new_for_path(LOG_FILE)
        const stream = file.append_to(Gio.FileCreateFlags.NONE, null)
        stream.write_all(new TextEncoder().encode(line), null)
        stream.close(null)
    } catch { /* ignore log failures */ }
    print(line.trimEnd())
}

// ─── Subprocess helper ────────────────────────────────────────────────────────

interface RunResult { ok: boolean; stdout: string; stderr: string }

function run(argv: string[]): RunResult {
    try {
        const [ok, outBytes, errBytes] = GLib.spawn_sync(
            null,                       // working dir
            argv,                       // command + args
            null,                       // inherit env
            GLib.SpawnFlags.SEARCH_PATH,
            null,                       // child_setup
        )
        const decode = (b: Uint8Array | null) =>
            b ? new TextDecoder().decode(b).trim() : ""
        return { ok: !!ok, stdout: decode(outBytes), stderr: decode(errBytes) }
    } catch (e) {
        return { ok: false, stdout: "", stderr: String(e) }
    }
}

// ─── Fullscreen detection — native Hyprland IPC ───────────────────────────────
// Reads clients through astal-hyprland; any client with a non-zero
// fullscreen mode counts (0 = none).

function hasFullscreenWindow(): boolean {
    try {
        return Hyprland.get_default()
            .get_clients()
            .some((c: { fullscreen: number }) => c.fullscreen > 0)
    } catch {
        return false  // if IPC isn't available, don't block rotation
    }
}

// ─── Wallpaper utilities ──────────────────────────────────────────────────────

function listWallpapers(): string[] {
    const result: string[] = []
    try {
        const dir = Gio.File.new_for_path(WALLPAPER_DIR)
        const en  = dir.enumerate_children(
            "standard::name", Gio.FileQueryInfoFlags.NONE, null
        )
        let info: Gio.FileInfo | null
        while ((info = en.next_file(null)) !== null) {
            const name = info.get_name()!
            if (/\.(jpe?g|png|webp)$/i.test(name))
                result.push(`${WALLPAPER_DIR}/${name}`)
        }
    } catch (e) { log(`WARN list: ${e}`) }
    return result
}

function pickRandom<T>(arr: T[]): T | null {
    return arr.length ? arr[Math.floor(Math.random() * arr.length)] : null
}

function readText(path: string): string {
    try {
        const [, bytes] = GLib.file_get_contents(path)
        return new TextDecoder().decode(bytes).trim()
    } catch { return "" }
}

function inode(path: string): string {
    return run(["stat", "-c", "%d:%i", path]).stdout
}

// Compare by inode so symlink vs. real-path differences don't matter.
// ~/Pictures/Wallpapers is a symlink into the assets repo (Wallpapers/<dir>).
function sameFile(a: string, b: string): boolean {
    if (!a || !b) return false
    const ia = inode(a), ib = inode(b)
    return !!ia && ia === ib
}

// Ask awww what wallpaper is currently displayed
function currentAwwwWallpaper(): string {
    const r = run(["awww", "query", "-j"])
    if (!r.ok || !r.stdout) return ""
    try {
        const d = JSON.parse(r.stdout) as Record<
            string,
            Array<{ displaying?: { image?: string } }>
        >
        return Object.values(d)[0]?.[0]?.displaying?.image ?? ""
    } catch { return "" }
}

// ─── Core: set wallpaper ─────────────────────────────────────────────────────
// Sets the wallpaper with awww img (--transition-type/-duration/-fps), then
// writes LAST_FILE. matugen is not run here: a separate systemd path unit
// watching that file runs it, so rapid changes do not start overlapping
// matugen runs (simultaneous CSS reloads can crash GTK4 apps).

function apply(wallpaper: string, skipTransition = false): void {
    const transition = skipTransition
        ? "none"
        : pickRandom([...TRANSITIONS])!

    const awww = run([
        "awww", "img", wallpaper,
        "--transition-type",     transition,
        "--transition-duration", "1",
        "--transition-fps",      "60",
    ])
    if (!awww.ok) log(`WARN awww: ${awww.stderr}`)

    // Write LAST_FILE for the matugen path unit
    try { GLib.file_set_contents(LAST_FILE, wallpaper) } catch { /* ignore */ }

    // Copy for the greeter, which cannot read ~/Pictures
    run(["cp", "-f", wallpaper, GREETER_FILE])

    log(`DONE ${wallpaper.split("/").at(-1)}`)
}

// ─── Rotation logic ───────────────────────────────────────────────────────────

function rotate(force = false): void {
    if (!force && hasFullscreenWindow()) { log("SKIP fullscreen"); return }

    const last = readText(LAST_FILE)
    let   candidates = listWallpapers()

    // Always pick something different from the current wallpaper
    const fresh = candidates.filter(w => !sameFile(w, last))
    if (fresh.length) candidates = fresh  // if only one wallpaper exists, allow repeat

    const wallpaper = pickRandom(candidates)
    if (!wallpaper) { log("SKIP no wallpapers"); return }

    log(`SET ${wallpaper.split("/").at(-1)}`)
    apply(wallpaper)
}

// ─── Startup sync ─────────────────────────────────────────────────────────────
// awww restores its last wallpaper when its daemon starts, but the colors
// may belong to another wallpaper. If awww's image differs from LAST_FILE
// (by inode), re-apply it with no transition to resync the colors.

function syncOnStart(): void {
    const current = currentAwwwWallpaper()

    if (!current) {
        // awww has no wallpaper (first boot or cleared state) — pick one
        log("STARTUP: awww empty, picking random")
        const w = pickRandom(listWallpapers())
        if (w) apply(w)
        return
    }

    const last = readText(LAST_FILE)
    if (!last || !sameFile(current, last)) {
        log(`STARTUP SYNC: ${current.split("/").at(-1)}`)
        apply(current, true)   // resync matugen — no visual transition at startup
    } else {
        log("STARTUP OK: in sync")
    }
}

// ─── Rotation timer ───────────────────────────────────────────────────────────

function secondsToNextSlot(): number {
    const now  = GLib.DateTime.new_now_local()!
    const m    = now.get_minute()
    const s    = now.get_second()
    let wait = m < 30 ? (30 - m) * 60 - s : (60 - m) * 60 - s
    // Under 60 s to the slot (e.g. the timer fired slightly early): use the
    // slot after it, so two rotations do not run back to back.
    if (wait < 60) wait += 30 * 60
    return wait
}

function scheduleNext(): void {
    const secs = secondsToNextSlot()
    log(`NEXT in ${Math.floor(secs / 60)}m ${secs % 60}s`)
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, secs, () => {
        rotate()
        scheduleNext()
        return GLib.SOURCE_REMOVE
    })
}

// ─── Entry point ─────────────────────────────────────────────────────────────

App.start({
    instanceName: "wallpaper-service",
    requestHandler(request: string, res: (response: string) => void) {
        switch (request) {
            case "rotate":        rotate(false); res("ok"); break
            case "force-rotate":  rotate(true);  res("ok"); break
            default:              res(`unknown: ${request}`)
        }
    },
    main() {
        // Prevent GTK from exiting when there are no windows
        App.hold()

        log("=== wallpaper-service started ===")
        syncOnStart()
        scheduleNext()
    },
})
