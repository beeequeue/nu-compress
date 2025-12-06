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