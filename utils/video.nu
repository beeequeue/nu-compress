export const video_containers = [
  "mkv",
  "mp4",
  "webm",
]

export def "nu-complete video container" [] {
  {
    options: {
      sort: false,
      completion_algorithm: "fuzzy",
    },
    completions: $video_containers
  }
}
