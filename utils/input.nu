export def "nu-complete thread-count" [--min: int, --max: int] {
  let cpu_count = sys cpu | length
  let actual_min = [1 (if $min != null { $min } else { 1 })] | math max
  let actual_max = [$cpu_count, if $max != null { $max } else { cpu_count }] | math min

  let thread_counts = $actual_min..$actual_max

  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($thread_counts | each { into string })
    # default: ($thread_counts | math avg | math floor | into string)
  }
}

export def get-threads [
  input: oneof<string, int, nothing>
]: nothing -> int {
  let cpu_count = sys cpu | length
  let input: int = (
    if $input != null {
      $input | into int
    } else {
      ($cpu_count * 0.75) | math ceil
    }
  )

  return ([1, $input] | math max | [$cpu_count, $in] | math min)
}
