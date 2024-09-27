object "Solver" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
  code {
      mstore(0x00, 0x2a)
      return(0x00, 0x20)
    }
  }
}
