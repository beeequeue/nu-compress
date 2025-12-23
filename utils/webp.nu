export const webp_quality = {
  smallest: 15,
  small: 35,
  average: 75,
  better: 85,
  best: 95,
}

export def "nu-complete quality webp" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($webp_quality | transpose value description)
  }
}

export def "quality webp" [
  --smallest: int = $webp_quality.smallest
  --small: int = $webp_quality.small
  --average: int = $webp_quality.average
  --better: int = $webp_quality.better
  --best: int = $webp_quality.best
  --lossless
  input: oneof<string, nothing>
]: nothing -> oneof<int, nothing> {
  match $input {
    "smallest" => $smallest
    "small" => $small
    "average" => $average
    "better" => $better
    "best" => $best
    null => (if not $lossless { return $better })
    _ => (
      error make {
        msg: $"Invalid webp compression quality: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($webp_quality | columns | str join ', ')."
        }
      }
    )
  }
}


export const webp_effort = {
  fast: 1,
  normal: 4,
  slow: 5,
  max: 6,
}

export def "nu-complete effort webp" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($webp_effort | columns)
  }
}

export def "effort webp" [
  --fast: int = $webp_effort.fast
  --normal: int = $webp_effort.normal
  --slow: int = $webp_effort.slow
  --max: int = $webp_effort.max
  input: string
]: nothing -> int {
  match $input {
    "fast" => $fast
    "normal" => $normal
    "slow" => $slow
    "max" => $max
    _ => (
      error make {
        msg: $"Invalid webp compression effort: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($webp_effort | columns | str join ', ')."
        }
      }
    )
  }
}
