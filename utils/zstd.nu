export const zstd_efforts = {
  fast: 3,
  normal: 12,
  slow: 17,
  max: 19,
}

export def "nu-complete effort zstd" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($zstd_efforts | columns)
  }
}

export def "effort zstd" [
  --fast: int = $zstd_efforts.fast
  --normal: int = $zstd_efforts.normal
  --slow: int = $zstd_efforts.slow
  --max: int = $zstd_efforts.max
  input: string
]: nothing -> int {
  match $input {
    "fast" => $fast
    "normal" => $normal
    "slow" => $slow
    "max" => $max
    _ => (
      error make {
        msg: $"Invalid zstd compression effort: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: fast, normal, slow, max."
        }
      }
    )
  }
}
