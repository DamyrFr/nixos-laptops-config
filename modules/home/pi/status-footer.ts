/**
 * Custom bottom UI for pi, installed by modules/home/agent.nix as
 * ~/.pi/agent/extensions/status-footer.ts. /footer toggles it.
 *
 *   ~/nixos-config  ⎇ pi +12 −3 • session            claude-opus-5-5 · high
 *   ctx ▰▰▰▱▱▱▱▱▱▱ 31% 62k/200k │ 🔌 1 │ cache 94% · R1.2M W48k │ ↑8k ↓21k │ $0.412 +0.018 sub
 *
 * Segments are dropped by priority on narrow terminals (tokens first, then
 * cache, then cost) instead of being cut mid-word. Avoid nested theme.fg():
 * it ends with \x1b[39m and resets the outer color.
 */

import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { CustomEditor } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, ExtensionContext, KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const BAR_WIDTH = 10;
const SEP = " │ ";

type Usage = { input: number; output: number; cacheRead: number; cacheWrite: number; cost: { total: number } };

function fmtTokens(n: number): string {
	if (n < 1000) return `${n}`;
	if (n < 1_000_000) return `${(n / 1000).toFixed(n < 10_000 ? 1 : 0)}k`;
	return `${(n / 1_000_000).toFixed(1)}M`;
}

function shortPwd(cwd: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	if (home && (cwd === home || cwd.startsWith(home + "/"))) return "~" + cwd.slice(home.length);
	return cwd;
}

// Staged-change counters (+ added / - deleted) shown next to the branch.
// `git diff --cached --numstat` per render would be far too expensive, so
// results are cached for a short TTL; branch changes invalidate immediately
// (they trigger a re-render via onBranchChange and miss the cache).
const STAGED_TTL_MS = 2000;
let stagedCache: { at: number; branch: string; add: number; del: number } | undefined;

function stagedStats(ctx: ExtensionContext, branch: string): { add: number; del: number } | undefined {
	if (stagedCache && stagedCache.branch === branch && Date.now() - stagedCache.at < STAGED_TTL_MS) {
		return stagedCache;
	}
	try {
		const r = spawnSync("git", ["-C", ctx.sessionManager.getCwd(), "diff", "--cached", "--numstat", "--no-color"], {
			encoding: "utf8",
			timeout: 2000,
		});
		let add = 0;
		let del = 0;
		if (r.status === 0) {
			for (const line of r.stdout.split("\n")) {
				// Binary files report "-" for both counts; skip them.
				const m = line.match(/^(\d+|-)\s+(\d+|-)\s+/);
				if (m) {
					if (m[1] !== "-") add += Number(m[1]);
					if (m[2] !== "-") del += Number(m[2]);
				}
			}
		}
		stagedCache = { at: Date.now(), branch, add, del };
		return stagedCache;
	} catch {
		return undefined;
	}
}

// MCP servers: configured (user/project mcp.json + extension registrations)
// vs connected. Pi registers a server's tools as mcp__<server>__<tool> when
// it connects and re-registers them with `hidden` exposure when the
// connection drops or the server is disabled, so a server is connected when
// it exposes at least one non-hidden tool. Server names in tool names are
// sanitized ([^a-zA-Z0-9_] -> _), so configured names are sanitized the
// same way before comparing. `exposure: "hidden"` servers are unreachable
// by design and do not count as configured.
function mcpStats(pi: ExtensionAPI, cwd: string) {
	const sanitize = (name: string) => name.replace(/[^a-zA-Z0-9_]/g, "_");
	const configured = new Map<string, boolean>();
	const readJson = (path: string) => {
		try {
			const raw = JSON.parse(readFileSync(path, "utf8")) as {
				mcpServers?: Record<string, { enabled?: boolean; exposure?: string }>;
			};
			// A project entry with the same name replaces the user-level one.
			for (const [name, cfg] of Object.entries(raw.mcpServers ?? {})) {
				configured.set(sanitize(name), (cfg?.enabled ?? true) && cfg?.exposure !== "hidden");
			}
		} catch {
			/* missing or invalid file: ignore */
		}
	};
	readJson(join(process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent"), "mcp.json"));
	readJson(join(cwd, ".pi", "mcp.json"));
	for (const server of pi.getMcpServers()) {
		const cfg = server.config as { enabled?: boolean; exposure?: string };
		configured.set(sanitize(server.name), (cfg.enabled ?? true) && cfg.exposure !== "hidden");
	}
	const total = [...configured.values()].filter(Boolean).length;
	const connected = new Set<string>();
	for (const tool of pi.getAllTools()) {
		if (tool.exposure === "hidden") continue;
		const m = /^mcp__(.+?)__/.exec(tool.name);
		if (m) connected.add(m[1]);
	}
	return { connected: connected.size, total };
}

// Same accounting as pi's built-in footer: every entry that carries usage,
// including cache-warming refreshes, tool results, compactions and branch
// summaries, across the whole session (not only the current branch).
function sessionStats(ctx: ExtensionContext) {
	const total = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
	let lastHit: number | undefined;
	let lastCost = 0;
	const add = (u?: Usage) => {
		if (!u) return;
		total.input += u.input;
		total.output += u.output;
		total.cacheRead += u.cacheRead;
		total.cacheWrite += u.cacheWrite;
		total.cost += u.cost?.total ?? 0;
	};
	for (const e of ctx.sessionManager.getEntries() as any[]) {
		if (e.type === "usage") add(e.usage);
		else if (e.type === "message" && e.message.role === "assistant") {
			const u = e.message.usage as Usage;
			add(u);
			const prompt = u.input + u.cacheRead + u.cacheWrite;
			lastHit = prompt > 0 ? (u.cacheRead / prompt) * 100 : undefined;
			lastCost = u.cost?.total ?? 0;
		} else if (e.type === "message" && e.message.role === "toolResult") add(e.message.usage);
		else if (e.type === "compaction" || e.type === "branch_summary") add(e.usage);
	}
	return { total, lastHit, lastCost };
}

export default function (pi: ExtensionAPI) {
	let requestRender: (() => void) | undefined;

	const installFooter = (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = () => tui.requestRender();
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubBranch,
				invalidate() {},
				render(width: number): string[] {
					const dim = (s: string) => theme.fg("dim", s);
					const muted = (s: string) => theme.fg("muted", s);
					const label = (s: string) => theme.fg("dim", s + " ");
					const level = (bad: boolean, warn: boolean) => (bad ? "error" : warn ? "warning" : "success");

					const { total, lastHit, lastCost } = sessionStats(ctx);

					// --- line 1: where + what -----------------------------------
					const branch = footerData.getGitBranch();
					const staged = branch ? stagedStats(ctx, branch) : undefined;
					let git = branch ? theme.fg("success", `⎇ ${branch}`) : theme.fg("warning", "∉ no-git");
					// Staged +/- next to the branch, only when there is something staged.
					if (branch && staged && staged.add + staged.del > 0) {
						git +=
							dim(" ") +
							theme.fg("success", `+${staged.add}`) +
							dim(" ") +
							theme.fg("error", `-${staged.del}`);
					}
					const name = ctx.sessionManager.getSessionName();
					const where = dim(shortPwd(ctx.sessionManager.getCwd())) + "  " + git + (name ? dim(` • ${name}`) : "");

					const effort = ctx.model?.reasoning ? (ctx.thinkingLevel ?? "off") : undefined;
					const what = muted(ctx.model?.id ?? "no-model") + (effort ? theme.fg("accent", ` · ${effort}`) : "");

					// --- line 2: segments, highest priority first -------------------
					const segs: { prio: number; text: string }[] = [];

					const usage = ctx.getContextUsage();
					const window = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					if (usage && usage.percent !== null && window > 0) {
						const pct = Math.min(100, Math.max(0, usage.percent));
						const filled = Math.min(BAR_WIDTH, Math.round((pct / 100) * BAR_WIDTH));
						const st = level(pct > 85, pct > 65);
						segs.push({
							prio: 0,
							text:
								label("ctx") +
								theme.fg(st, "▰".repeat(filled)) +
								dim("▱".repeat(BAR_WIDTH - filled)) +
								" " +
								theme.fg(st, `${pct.toFixed(0)}%`) +
								" " +
								muted(`${fmtTokens(usage.tokens ?? 0)}/${fmtTokens(window)}`),
						});
					} else if (window > 0) {
						segs.push({ prio: 0, text: label("ctx") + dim("▱".repeat(BAR_WIDTH)) + " " + muted(`?/${fmtTokens(window)}`) });
					}

					// MCP servers (🔌): show the count only when something is configured;
					// N/M (colored) while some server is not connected yet or failing.
					const mcp = mcpStats(pi, ctx.sessionManager.getCwd());
					if (mcp.total > 0) {
						const text =
							mcp.connected >= mcp.total
								? muted(`${mcp.connected}`)
								: theme.fg(level(mcp.connected === 0, true), `${mcp.connected}/${mcp.total}`);
						segs.push({ prio: 2, text: dim("🔌 ") + text });
					}

					if (total.cacheRead || total.cacheWrite) {
						const hit =
							lastHit !== undefined
								? theme.fg(level(lastHit < 50, lastHit < 80), `${lastHit.toFixed(0)}%`) + dim(" · ")
								: "";
						segs.push({
							prio: 2,
							text: label("cache") + hit + muted(`R${fmtTokens(total.cacheRead)} W${fmtTokens(total.cacheWrite)}`),
						});
					}

					if (total.input || total.output) {
						segs.push({ prio: 3, text: muted(`↑${fmtTokens(total.input)} ↓${fmtTokens(total.output)}`) });
					}

					// On a subscription (OAuth) the price is the API-equivalent
					// estimate, not what is billed: flag it with "sub".
					const sub = ctx.model ? ctx.modelRegistry.isUsingOAuth(ctx.model) : false;
					if (total.cost || sub) {
						segs.push({
							prio: 1,
							text:
								theme.fg("accent", `$${total.cost.toFixed(3)}`) +
								(lastCost ? dim(` +${lastCost.toFixed(3)}`) : "") +
								(sub ? dim(" sub") : ""),
						});
					}

					// Drop lowest-priority segments until line 2 fits.
					const order = segs.map((s, i) => ({ ...s, i }));
					let shown = order;
					const join = (xs: typeof order) => xs.sort((a, b) => a.i - b.i).map((s) => s.text).join(dim(SEP));
					while (shown.length > 1 && visibleWidth(join([...shown])) > width) {
						const worst = shown.reduce((a, b) => (b.prio > a.prio ? b : a));
						shown = shown.filter((s) => s !== worst);
					}
					const line2 = truncateToWidth(join([...shown]), width, dim("…"));

					// Line 1: left / right aligned, model wins over the path.
					const whatW = visibleWidth(what);
					const whereMax = Math.max(0, width - whatW - 2);
					const left = truncateToWidth(where, whereMax, dim("…"));
					const pad = Math.max(1, width - visibleWidth(left) - whatW);
					const line1 = truncateToWidth(left + " ".repeat(pad) + what, width, "");

					const lines = [line1, line2];

					const statuses = footerData.getExtensionStatuses();
					if (statuses.size > 0) {
						const text = Array.from(statuses.values())
							.sort()
							.map((s) => s.replace(/[\r\n]+/g, " "))
							.join(dim(SEP));
						lines.push(truncateToWidth(dim(text), width, dim("…")));
					}
					return lines;
				},
			};
		});
	};

	// Typed text follows the theme "text" role (pi has none for it); borders
	// keep their thinking-level color. Re-applied after every inner reset.
	const installEditor = (ctx: ExtensionContext) => {
		if (ctx.mode !== "tui") return;

		const factory = (tui: TUI, editorTheme: EditorTheme, keybindings: KeybindingsManager) =>
			new (class extends CustomEditor {
				constructor() {
					super(tui, editorTheme, keybindings, { embedWorkingStatus: true });
				}
				override render(width: number): string[] {
					const lines = super.render(width);
					if (lines.length <= 2) return lines;
					const fg = ctx.ui.theme.getFgAnsi("text");
					for (let i = 1; i < lines.length - 1; i++) {
						lines[i] = fg + lines[i].split("\x1b[0m").join(`\x1b[0m${fg}`) + "\x1b[39m";
					}
					return lines;
				}
			})();

		ctx.ui.setEditorComponent(factory);
	};

	// MCP servers connect in the background after startup; re-render for a
	// short window so the count settles without waiting for user activity.
	// Kept in installFooter's scope: requestRender only exists in tui mode.
	let mcpPoll: ReturnType<typeof setInterval> | undefined;

	pi.on("session_start", (_event, ctx) => {
		installFooter(ctx);
		installEditor(ctx);
		clearInterval(mcpPoll);
		const until = Date.now() + 15_000;
		mcpPoll = setInterval(() => {
			if (!requestRender || Date.now() >= until) {
				clearInterval(mcpPoll);
				return;
			}
			requestRender();
		}, 1000);
	});

	pi.on("model_select", () => requestRender?.());
	pi.on("thinking_level_select", () => requestRender?.());

	let custom = true;
	pi.registerCommand("footer", {
		description: "Toggle the custom status footer",
		handler: async (_args, ctx) => {
			custom = !custom;
			if (custom) {
				installFooter(ctx);
				ctx.ui.notify("Custom footer enabled", "info");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});
}
