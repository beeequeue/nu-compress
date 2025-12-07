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
  --fast: int = $zstd_levels.fast
  --normal: int = $zstd_levels.normal
  --slow: int = $zstd_levels.slow
  --max: int = $zstd_levels.max
  input: string
]: nothing -> int {
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
