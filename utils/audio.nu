const audio_quality = {
  tiny: { samples: "24000", bits: 128k },
  average: { samples: "48000", bits: 256k },
  better: { samples: "48000", bits: 320k },
  best: { samples: "192000", bits: 512k },
}

export def "nu-complete quality audio" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: ($audio_quality | transpose value description)
  }
}

export def "quality audio" [
  --tiny: record<samples: string, bits: string> = $audio_quality.tiny
  --average: record<samples: string, bits: string> = $audio_quality.average
  --better: record<samples: string, bits: string> = $audio_quality.better
  --best: record<samples: string, bits: string> = $audio_quality.best
  input: string
]: nothing -> record<samples: string, bits: string> {
  match $input {
    "tiny" => $tiny
    "average" => $average
    "better" => $better
    "best" => $best
    _ => (
      error make {
        msg: $"Invalid audio compression quality: ($input)."
        label: {
          ...(metadata $input)
          text: $"Got ($input), expected one of: ($audio_quality | columns | str join ', ')."
        }
      }
    )
  }
}
