#!/usr/bin/env bash
# SessionStart hook: list open question issues (labels soru-memo / soru-yusuf).
# Silent when gh is missing, offline, or there are no open questions.
# Uses --label (immediately consistent), not --search (index lags behind new labels).
command -v gh >/dev/null 2>&1 || exit 0
JQ='.[] | "#\(.number) \(if any(.labels[]; .name=="soru-memo") then "Memo" else "Yusuf" end)\(if any(.labels[]; .name=="engelliyor") then " [ENGELLIYOR]" else "" end) | \(((now - (.createdAt|fromdate))/86400)|floor) gun | \(.title)"'
out=$( { for l in soru-memo soru-yusuf; do
  gh issue list --state open --label "$l" --json number,title,labels,createdAt --jq "$JQ" 2>/dev/null
done; } | sort -t'#' -k2 -n -u)
[ -n "$out" ] || exit 0
echo "Acik sorular (soru-memo / soru-yusuf issue'lari). Cevap gelenleri belgeye isle, sonra kapat (CLAUDE.md 'Acik sorular'):"
echo "$out"
