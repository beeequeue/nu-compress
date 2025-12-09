export const av1_level = {
  smallest: 40,
  small: 30,
  average: 20,
  better: 15,
  best: 8,
}

export def "nu-complete level av1" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($av1_level | transpose value description)
  }
}

export def "level av1" [
  --smallest: int = $av1_level.smallest
  --small: int = $av1_level.small
  --average: int = $av1_level.average
  --better: int = $av1_level.better
  --best: int = $av1_level.best
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
        msg: $"Invalid av1 compression level: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($av1_level | columns | str join ', ')."
        }
      }
    )
  }
}


export const av1_speed = {
  veryfast: 10,
  fast: 8,
  normal: 4,
  slow: 2,
  max: 1,
}

export def "nu-complete preset av1" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($av1_speed | columns)
  }
}

export def "preset av1" [
  --veryfast: int = $av1_speed.veryfast
  --fast: int = $av1_speed.fast
  --normal: int = $av1_speed.normal
  --slow: int = $av1_speed.slow
  --max: int = $av1_speed.max
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
        msg: $"Invalid av1 compression speed: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($av1_speed | columns | str join ', ')."
        }
      }
    )
  }
}
