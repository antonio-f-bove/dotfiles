import { realpath, stat } from "node:fs/promises";
import { resolve } from "node:path";
import type { ExtensionAPI, SessionInfo } from "@mariozechner/pi-coding-agent";
import { SessionManager, SessionSelectorComponent } from "@mariozechner/pi-coding-agent";

type GitInfo = {
	topLevel?: string;
	commonDir?: string;
	head?: string;
	branch?: string;
};

type ForkCdState = {
	sourceSessionFile: string;
	sourceCwd: string;
	targetCwd: string;
	tmuxCwd?: string;
	sourceGit: GitInfo;
	targetGit: GitInfo;
};

async function isDirectory(path: string) {
	try {
		return (await stat(path)).isDirectory();
	} catch {
		return false;
	}
}

async function getGitInfo(pi: ExtensionAPI, cwd: string): Promise<GitInfo> {
	const run = async (args: string[]) => {
		const result = await pi.exec("git", args, { cwd, timeout: 5000 });
		if (result.code !== 0) return undefined;
		const text = result.stdout.trim();
		return text || undefined;
	};

	const [topLevel, rawCommonDir, head, branch] = await Promise.all([
		run(["rev-parse", "--show-toplevel"]),
		run(["rev-parse", "--git-common-dir"]),
		run(["rev-parse", "HEAD"]),
		run(["branch", "--show-current"]),
	]);

	let commonDir = rawCommonDir;
	if (rawCommonDir) {
		try {
			commonDir = await realpath(resolve(cwd, rawCommonDir));
		} catch {
			commonDir = resolve(cwd, rawCommonDir);
		}
	}

	return { topLevel, commonDir, head, branch };
}

async function getTmuxPaneCwd(pi: ExtensionAPI, fallbackCwd: string) {
	const target = process.env.TMUX_PANE?.trim();
	const args = target
		? ["display-message", "-p", "-t", target, "#{pane_current_path}"]
		: ["display-message", "-p", "#{pane_current_path}"];
	const result = await pi.exec("tmux", args, { cwd: fallbackCwd, timeout: 3000 });
	if (result.code !== 0) return undefined;
	const text = result.stdout.trim();
	return text || undefined;
}

function buildContextNote(sourceCwd: string, targetCwd: string, sourceGit: GitInfo, targetGit: GitInfo) {
	const sameCommonDir = sourceGit.commonDir && targetGit.commonDir && sourceGit.commonDir === targetGit.commonDir;
	const sameHead = sourceGit.head && targetGit.head && sourceGit.head === targetGit.head;

	const lines = [
		"Session forked into new cwd.",
		`Source cwd: ${sourceCwd}`,
		`Target cwd: ${targetCwd}`,
		"Re-scan repo state, files, branch, and uncommitted changes before edits.",
	];

	if (sourceGit.branch || targetGit.branch) {
		lines.push(`Source branch: ${sourceGit.branch || "unknown"}`);
		lines.push(`Target branch: ${targetGit.branch || "unknown"}`);
	}
	if (sourceGit.head || targetGit.head) {
		lines.push(`Source HEAD: ${sourceGit.head || "unknown"}`);
		lines.push(`Target HEAD: ${targetGit.head || "unknown"}`);
	}
	if (sameCommonDir !== undefined) {
		lines.push(`Same git common dir: ${sameCommonDir ? "yes" : "no"}`);
	}
	if (sameHead !== undefined) {
		lines.push(`Same HEAD commit: ${sameHead ? "yes" : "no"}`);
	}

	return lines.join("\n");
}

function remapForkPath(path: string, state: ForkCdState) {
	const mappings: Array<[string | undefined, string | undefined]> = [
		[state.sourceCwd, state.targetCwd],
		[state.sourceGit.topLevel, state.targetGit.topLevel],
	];
	for (const [from, to] of mappings) {
		if (!from || !to) continue;
		if (path === from) return to;
		if (path.startsWith(`${from}/`)) return `${to}${path.slice(from.length)}`;
	}
	return path;
}

function remapForkCommand(command: string, state: ForkCdState) {
	let next = command;
	const mappings: Array<[string | undefined, string | undefined]> = [
		[state.sourceGit.topLevel, state.targetGit.topLevel],
		[state.sourceCwd, state.targetCwd],
	];
	for (const [from, to] of mappings) {
		if (!from || !to || from === to) continue;
		next = next.split(from).join(to);
	}
	return next;
}

function loadForkState(entries: Array<any>): ForkCdState | undefined {
	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];
		if (entry.type === "custom" && entry.customType === "fork-cd-state" && entry.data) {
			return entry.data as ForkCdState;
		}
		if (entry.type === "custom_message" && entry.customType === "fork-cd" && entry.details) {
			return entry.details as ForkCdState;
		}
	}
	return undefined;
}

async function pickSourceSession(ctx: {
	hasUI: boolean;
	cwd: string;
	sessionManager: { getSessionDir(): string | undefined };
	ui: {
		notify(message: string, type?: "info" | "warning" | "error"): void;
		custom<T>(
			renderer: (tui: any, theme: any, kb: any, done: (result: T) => void) => any,
		): Promise<T>;
	};
}, currentSessionFile: string | undefined) {
	const currentLoader = (onProgress?: (loaded: number, total: number) => void) =>
		SessionManager.list(ctx.cwd, ctx.sessionManager.getSessionDir(), onProgress);
	const allLoader = (onProgress?: (loaded: number, total: number) => void) => SessionManager.listAll(onProgress);

	const allSessions = await allLoader();
	if (allSessions.length === 0) {
		ctx.ui.notify("no sessions found", "error");
		return undefined;
	}

	if (!ctx.hasUI) {
		return [...allSessions].sort((a, b) => b.modified.getTime() - a.modified.getTime())[0];
	}

	const selectedPath = await ctx.ui.custom<string | undefined>((tui, _theme, _kb, done) => {
		const selector = new SessionSelectorComponent(
			currentLoader,
			allLoader,
			(sessionPath) => done(sessionPath),
			() => done(undefined),
			() => done(undefined),
			() => tui.requestRender(),
			{ showRenameHint: false },
			currentSessionFile,
		);
		selector.focused = true;
		return selector;
	});
	if (!selectedPath) return undefined;
	return allSessions.find((session) => session.path === selectedPath);
}

export default function forkCdExtension(pi: ExtensionAPI) {
	let forkState: ForkCdState | undefined;

	pi.on("session_start", async (_event, ctx) => {
		forkState = loadForkState(ctx.sessionManager.getEntries());
	});

	pi.on("before_agent_start", async (event, ctx) => {
		forkState = loadForkState(ctx.sessionManager.getEntries()) || forkState;
		if (!forkState) return;
		const note = buildContextNote(forkState.sourceCwd, forkState.targetCwd, forkState.sourceGit, forkState.targetGit);
		return {
			message: {
				customType: "fork-cd-active",
				content: `${note}\nCurrent session cwd: ${ctx.sessionManager.getCwd()}\nNever use source worktree paths. If an old absolute path appears, rewrite it to target worktree before tool use.`,
				display: false,
			},
		};
	});

	pi.on("tool_call", async (event, ctx) => {
		forkState = loadForkState(ctx.sessionManager.getEntries()) || forkState;
		if (!forkState) return;

		if (event.toolName === "read" || event.toolName === "write" || event.toolName === "edit") {
			const input = event.input as { path?: string };
			if (typeof input.path === "string") {
				const remapped = remapForkPath(input.path, forkState);
				if (remapped !== input.path) {
					ctx.ui.notify(`fork-cd remapped path to target worktree:\n${input.path}\n→ ${remapped}`, "warning");
					input.path = remapped;
				}
			}
		}

		if (event.toolName === "bash") {
			const input = event.input as { command?: string };
			if (typeof input.command === "string") {
				const remapped = remapForkCommand(input.command, forkState);
				if (remapped !== input.command) {
					ctx.ui.notify("fork-cd remapped bash command paths to target worktree", "warning");
					input.command = remapped;
				}
			}
		}
	});

	pi.registerCommand("fork-cd", {
		description: "Fork chosen session into tmux/current cwd, or explicit target cwd",
		handler: async (args, ctx) => {
			await ctx.waitForIdle();

			const trimmed = args.trim();
			const useCurrentSession = trimmed.startsWith("--current");
			const pathArg = useCurrentSession ? trimmed.slice("--current".length).trim() : trimmed;

			const currentSessionFile = ctx.sessionManager.getSessionFile();
			let sourceSessionFile = currentSessionFile;
			let sourceCwd = ctx.sessionManager.getCwd();

			if (!useCurrentSession) {
				const source = await pickSourceSession(ctx, currentSessionFile);
				if (!source) return;
				sourceSessionFile = source.path;
				sourceCwd = source.cwd || sourceCwd;
			}

			if (!sourceSessionFile) {
				ctx.ui.notify("fork-cd needs persisted source session", "error");
				return;
			}

			const tmuxCwd = await getTmuxPaneCwd(pi, ctx.cwd);
			const targetBase = tmuxCwd || ctx.cwd;
			const targetCwd = pathArg ? resolve(targetBase, pathArg) : targetBase;

			if (!(await isDirectory(targetCwd))) {
				ctx.ui.notify(`missing directory: ${targetCwd}`, "error");
				return;
			}

			const [sourceGit, targetGit] = await Promise.all([getGitInfo(pi, sourceCwd), getGitInfo(pi, targetCwd)]);
			const note = buildContextNote(sourceCwd, targetCwd, sourceGit, targetGit);
			const confirmText = [
				`Source session: ${sourceSessionFile}`,
				note,
				tmuxCwd ? `tmux pane cwd: ${tmuxCwd}` : "tmux pane cwd: unavailable",
			].join("\n\n");

			if (ctx.hasUI) {
				const ok = await ctx.ui.confirm("Fork into cwd", confirmText);
				if (!ok) return;
			}

			let forked: SessionManager;
			try {
				forked = SessionManager.forkFrom(sourceSessionFile, targetCwd);
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
				return;
			}

			const state: ForkCdState = {
				sourceSessionFile,
				sourceCwd,
				targetCwd,
				tmuxCwd,
				sourceGit,
				targetGit,
			};

			forked.appendCustomEntry("fork-cd-state", state);
			forked.appendCustomMessageEntry("fork-cd", note, true, state);

			const newSessionFile = forked.getSessionFile();
			if (!newSessionFile) {
				ctx.ui.notify("fork created no session file", "error");
				return;
			}

			const result = await ctx.switchSession(newSessionFile, {
				withSession: async (nextCtx) => {
					nextCtx.ui.notify(`Forked session into ${targetCwd}`, "info");
				},
			});
			if (result.cancelled) {
				ctx.ui.notify("switch cancelled", "warning");
				return;
			}
		},
	});
}
