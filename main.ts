// Brainrot Blitz — the make.fun program/v1 entrypoint.
// Copies the built place, the play link, the sources and the screenshots
// into the output directory, then writes the dossier the scorer checks.
// Node standard library only. Deterministic: the same input always
// writes the same bytes, because nothing here reads the clock, a random
// number or the environment beyond the output directory.
import { buildDossier } from "./vendor/makefun-roblox.ts";
import { copyFileSync, cpSync, mkdirSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const sourceDir = process.cwd();
const outputDir = process.env.OUTPUT_DIR ?? "/output";

mkdirSync(outputDir, { recursive: true });

// The built place and the play link go in as single files.
copyFileSync(join(sourceDir, "game.rbxl"), join(outputDir, "game.rbxl"));
copyFileSync(join(sourceDir, "PLAY.json"), join(outputDir, "PLAY.json"));

// The sources go in whole, exactly as they are in the repository.
cpSync(join(sourceDir, "src"), join(outputDir, "src"), { recursive: true });

// The screenshots go in whole, skipping hidden files.
const shotDir = join(sourceDir, "screenshots");
const shotOut = join(outputDir, "screenshots");
mkdirSync(shotOut, { recursive: true });
for (const name of readdirSync(shotDir).sort()) {
	if (name.startsWith(".")) {
		continue;
	}
	copyFileSync(join(shotDir, name), join(shotOut, name));
}

// The dossier describes exactly what was copied above.
const dossier = buildDossier(outputDir, { text_max_bytes: 65536 });
writeFileSync(join(outputDir, "dossier.json"), dossier);
