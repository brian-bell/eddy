#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scripts/install-codex-skills.sh [--force]

Create symlinks in ~/.agents/skills for each skill defined in .claude/skills/.

Options:
  --force    Replace conflicting symlinks in ~/.agents/skills.
EOF
}

force=0
if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

if [[ $# -eq 1 ]]; then
  case "$1" in
    --force)
      force=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
fi

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="${repo_root}/.claude/skills"
target_dir="${HOME}/.agents/skills"

if [[ ! -d "${source_dir}" ]]; then
  echo "Missing source skill directory: ${source_dir}" >&2
  exit 1
fi

mkdir -p "${target_dir}"

linked=0
skipped=0

for skill_dir in "${source_dir}"/*; do
  if [[ ! -d "${skill_dir}" || ! -f "${skill_dir}/SKILL.md" ]]; then
    continue
  fi

  skill_name="$(basename "${skill_dir}")"
  target_path="${target_dir}/${skill_name}"

  if [[ -L "${target_path}" ]]; then
    current_target="$(readlink "${target_path}")"
    if [[ "${current_target}" == "${skill_dir}" ]]; then
      echo "ok    ${skill_name} -> ${current_target}"
      continue
    fi

    if [[ "${force}" -eq 1 ]]; then
      rm "${target_path}"
    else
      echo "skip  ${skill_name}: ${target_path} already points to ${current_target} (use --force to replace)"
      skipped=$((skipped + 1))
      continue
    fi
  elif [[ -e "${target_path}" ]]; then
    echo "skip  ${skill_name}: ${target_path} exists and is not a symlink"
    skipped=$((skipped + 1))
    continue
  fi

  ln -s "${skill_dir}" "${target_path}"
  echo "link  ${skill_name} -> ${skill_dir}"
  linked=$((linked + 1))
done

echo
echo "Installed ${linked} skill link(s) into ${target_dir}."
if [[ "${skipped}" -gt 0 ]]; then
  echo "Skipped ${skipped} existing path(s)."
fi
echo "Start a new Codex session after installing or updating skill links."
