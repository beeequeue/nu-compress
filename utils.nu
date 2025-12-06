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

export const zstd_levels = {
  fast: 3,
  normal: 12,
  slow: 17,
  max: 19,
}
export def "nu-complete level zstd" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($zstd_levels | columns)
  }
}

export def "level zstd" [
  --fast: int = 3
  --normal: int = 12
  --slow: int = 17
  --max: int = 19
  input: string
] {
  match $input {
    "fast" => $fast
    "normal" => $normal
    "slow" => $slow
    "max" => $max
    _ => (
      error make {
        msg: $"Invalid zstd compression level: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: fast, normal, slow, max."
        }
      }
    )
  }
}

# Calculates the difference in size between two paths.
@example "Basic usage" { diff paths ./2048/ ./1024.tar.gz } --result {
  before: 2.0MB
  after: 1.0MB
  absolute: -1.0MB
  relative: -0.50
  percent: -50%
}
export def "diff paths" [
  before: path
  after: path
]: nothing -> record<before: filesize, after: filesize, absolute: filesize,relative: float,percent: string> {
  let before_size = ls -dt $before | math sum | get size
  let after_size = ls -dt $after | math sum | get size

 return {
  before: $before_size
  after: $after_size
  ...(diff filesize $before_size $after_size)
 }
}

# Calculates the difference in size between two `filesize`s.
@example "Basic usage" { diff filesize 2MB 1MB } --result { absolute: -1.0MB, relative: -0.50, percent: -50% }
export def "diff filesize" [
  before: filesize
  after: filesize
]: nothing -> record<absolute: filesize,relative: float,percent: string> {
  let diff = ($before - $after) * -1
  let relative = $diff / $before

  return {
    absolute: $diff,
    relative: $relative
    percent: $"($relative * 100 | math round --precision 2)%"
  }
}