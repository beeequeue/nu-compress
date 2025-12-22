export const av1_quality = {
  smallest: 40,
  small: 30,
  average: 20,
  better: 15,
  best: 8,
}

export def "nu-complete quality av1" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($av1_quality | transpose value description)
  }
}

export def "quality av1" [
  --smallest: int = $av1_quality.smallest
  --small: int = $av1_quality.small
  --average: int = $av1_quality.average
  --better: int = $av1_quality.better
  --best: int = $av1_quality.best
  input: string
]: nothing -> int {
  match $input {
    "smallest" => $smallest
    "small" => $small
    "average" => $average
    "better" => $better
    "best" => $best
    _ => (
      error make {
        msg: $"Invalid av1 compression quality: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($av1_quality | columns | str join ', ')."
        }
      }
    )
  }
}


export const av1_effort = {
  veryfast: 10,
  fast: 8,
  normal: 4,
  slow: 2,
  max: 1,
}

export def "nu-complete effort av1" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($av1_effort | columns)
  }
}

export def "effort av1" [
  --veryfast: int = $av1_effort.veryfast
  --fast: int = $av1_effort.fast
  --normal: int = $av1_effort.normal
  --slow: int = $av1_effort.slow
  --max: int = $av1_effort.max
  input: string
]: nothing -> int {
  match $input {
    "veryfast" => $veryfast
    "fast" => $fast
    "normal" => $normal
    "slow" => $slow
    "max" => $max
    _ => (
      error make {
        msg: $"Invalid av1 compression effort: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($av1_effort | columns | str join ', ')."
        }
      }
    )
  }
}
