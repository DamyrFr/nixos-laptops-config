/**
 * Custom bottom UI for pi, installed by modules/home/agent.nix as
 * ~/.pi/agent/extensions/status-footer.ts. /footer toggles it.
 *
 *   ~/nixos-config  ⎇ pi • session                    claude-opus-5-5 · high
 *   ctx ▰▰▰▱▱▱▱▱▱▱ 31% 62k/200k │ cache 94% · R1.2M W48k │ ↑8k ↓21k │ $0.412 +0.018 sub
 *
 * Segments are dropped by priority on narrow terminals (tokens first, then
 * cache, then cost) instead of being cut mid-word. Avoid nested theme.fg():
 * it ends with \x1b[39m and resets the outer color.
 */

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
					const git = branch ? theme.fg("success", `⎇ ${branch}`) : theme.fg("warning", "∉ no-git");
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

	pi.on("session_start", (_event, ctx) => {
		installFooter(ctx);
		installEditor(ctx);
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
