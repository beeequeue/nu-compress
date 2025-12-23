use ../utils/error.nu *

# Removes the extension from a path.
export def filename [input: path]: nothing -> path {
  $input | path parse | get stem
}

export def get-and-check-paths [
  paths: list<path>
  suffix: string
  --rm-ext
  --metadata(-m): record<span: any>
  --force(-f)
  # Overwrite existing output file if it exists.
]: nothing -> list<record> {
  return ($paths | par-each -k {|path|
    let input_name = $path | path basename
    let output_name = if $rm_ext {
      $input_name | (filename $in) + $suffix
    } else {
      $input_name + $suffix
    }
    let active_dir = $path | path dirname
    let output_path = $active_dir | path join $output_name

    if not $force and ($output_path | path exists) {
      error input $"Output file already exists \(($output_name))" --hm "Use -f to overwrite" --metadata $metadata
    }

    return {
      input_name: $input_name,
      output_name: $output_name,
      active_dir: $active_dir,
      output_path: $output_path,
    }
  })
}

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
