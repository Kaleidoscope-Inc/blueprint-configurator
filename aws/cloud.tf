terraform {
  cloud {
    organization = "KaleidoscopeInc"
    workspaces {
      tags = ["crawl"]
    }
  }
}
