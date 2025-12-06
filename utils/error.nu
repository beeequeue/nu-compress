export def "error input" [
  message: string
  --metadata: record<span: any>
]: nothing -> error {
  error make {
    msg: "Invalid input",
    label: { ...$metadata, text: $message }
  }
}