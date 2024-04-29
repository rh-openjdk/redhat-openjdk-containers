ret=0

# XXX this will only work for one commit PRs. Need to diff against the
# merge base
git diff-tree --no-commit-id --name-only HEAD -r |\
while read f; do
  case "${f##*.}" in
    yaml)
        # XXX we could use yamllint but it's too noisy for now
        yq < "$f" >/dev/null || {
            echo "$f is not valid YAML"
            ret=1
        }
        ;;
    json)
        jq < "$f" >/dev/null || {
            echo "$f is not valid JSON";
            ret=1
        }
        ;;
  esac
done
exit $ret
