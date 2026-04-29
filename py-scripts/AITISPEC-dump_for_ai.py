import os
from pathlib import Path

def dump_project(root: str = ".", limit_mb: float = 0.8):
	root_path = Path(root).resolve()
	skip_dirs = {'.git', '__pycache__', '.venv', 'venv', '.pytest_cache', '.mypy_cache', 'output', 'models', 'node_modules'}
	skip_ext = {'.parquet', '.feather', '.pkl', '.pickle', '.h5', '.hdf5', '.arrow', '.xlsx', '.xls', '.pyc', '.pyd', '.dll', '.exe', '.zip', '.tar.gz'}
	limit_bytes = int(limit_mb * 1024 * 1024)

	def _collect_dir(base_dir: Path) -> str:
		lines = [f"# Dump: {base_dir.name}\n\n", f"**Root:** `{base_dir}`\n\n---\n\n"]
		for dirpath, dirnames, filenames in os.walk(base_dir):
			dirnames[:] = [d for d in dirnames if d not in skip_dirs and not d.startswith('.')]
			for fname in sorted(filenames):
				fpath = Path(dirpath) / fname
				rel = fpath.relative_to(base_dir)

				if fpath.suffix.lower() in skip_ext:
					lines.append(f"- `[SKIP BIN] {rel}`\n")
					continue
				if fpath.stat().st_size > limit_bytes:
					lines.append(f"- `[SKIP LARGE] {rel}` ({fpath.stat().st_size/1024/1024:.1f} MB)\n")
					continue
				try:
					content = fpath.read_text(encoding='utf-8', errors='replace')
					lang = fpath.suffix.lower().lstrip('.') or 'text'
					lines.append(f"## 📄 {rel}\n\n```{lang}\n{content.rstrip()}\n```\n\n---\n\n")
				except Exception as e:
					lines.append(f"- `[ERROR READ] {rel}`: {e}\n")
		return "".join(lines)

	# 1. Дамп файлов корня
	root_lines = ["# Dump: ROOT FILES\n\n", f"**Root:** `{root_path}`\n\n---\n\n"]
	for fname in sorted([f for f in root_path.iterdir() if f.is_file() and f.name != "dump_for_ai.py"]):
		if fname.name.startswith('.'): continue
		if fname.suffix.lower() in skip_ext:
			root_lines.append(f"- `[SKIP BIN] {fname.name}`\n")
			continue
		if fname.stat().st_size > limit_bytes:
			root_lines.append(f"- `[SKIP LARGE] {fname.name}`\n")
			continue
		try:
			content = fname.read_text(encoding='utf-8', errors='replace')
			lang = fname.suffix.lower().lstrip('.') or 'text'
			root_lines.append(f"## 📄 {fname.name}\n\n```{lang}\n{content.rstrip()}\n```\n\n---\n\n")
		except Exception as e:
			root_lines.append(f"- `[ERROR READ] {fname.name}`: {e}\n")

	(root_path / "dump_root.md").write_text("".join(root_lines), encoding='utf-8')
	print("✅ Created: dump_root.md")

	# 2. Дампы папок первого уровня
	for item in sorted(root_path.iterdir()):
		if item.is_dir() and item.name not in skip_dirs and not item.name.startswith('.'):
			content = _collect_dir(item)
			(root_path / f"dump_{item.name}.md").write_text(content, encoding='utf-8')
			print(f"✅ Created: dump_{item.name}.md")

	print("Готово. Дампы сгенерированы.")

if __name__ == "__main__":
	dump_project()
